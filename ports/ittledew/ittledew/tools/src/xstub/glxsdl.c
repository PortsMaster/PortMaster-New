/*
 * glxsdl: the GLX host for Westonpack's pass-through gl4es (gl4es_glxpass), without crusty, Weston or Xwayland.
 *
 * That gl4es build exports the glX* entry points the game calls and forwards each to a crusty_glX* symbol that it
 * expects the process to provide. This library provides them on the firmware's SDL2 (dlopen'd, so it builds without
 * SDL headers): one fullscreen window, one GLES 2 context, gl4es initialised on it through set_getprocaddress() +
 * initialize_gl4es(), gl4es_pre_swap()/gl4es_post_swap() around every SDL_GL_SwapWindow. SDL2 picks the platform:
 * Knulli's "mali" fbdev driver, ROCKNIX's wayland (Sway), KMSDRM elsewhere. Preload order: gl4es first, this library
 * second (its undefined crusty_glX* bind to us). Also: a "Loading..." screen while the game starts, the ASTC relabel /
 * CPU decode of the textures setup re-encoded, a game window smaller than the screen shown centred (letterbox), and a
 * joystick filter. Settings come from the file named by GLXSDL_CONFIG ("key = value" lines, "#" comments; see
 * load_config).
 * The fatal-signal handlers in place before SDL starts (box64's: SIGSEGV drives its dynarec write protection) are
 * restored after the window exists: dArkOS's SDL2 installs its own console-restore handlers over them.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <elf.h>
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <linux/joystick.h>
#include <signal.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <GL/glx.h>

/* ---- the bits of SDL2 we use, by hand ---- */
typedef struct SDL_Window SDL_Window;
typedef struct { unsigned format; int w, h, refresh_rate; void *driverdata; } SDL_DisplayMode;
enum { SDL_INIT_VIDEO = 0x20, SDL_INIT_EVENTS = 0x4000 };
enum { SDL_WINDOW_FULLSCREEN = 1, SDL_WINDOW_OPENGL = 2, SDL_WINDOW_SHOWN = 4, SDL_WINDOW_FULLSCREEN_DESKTOP = 0x1001 };
enum { SDL_GL_RED_SIZE, SDL_GL_GREEN_SIZE, SDL_GL_BLUE_SIZE, SDL_GL_ALPHA_SIZE, SDL_GL_DOUBLEBUFFER = 5, SDL_GL_DEPTH_SIZE, SDL_GL_STENCIL_SIZE,
       SDL_GL_CONTEXT_MAJOR_VERSION = 17, SDL_GL_CONTEXT_MINOR_VERSION, SDL_GL_CONTEXT_PROFILE_MASK = 21 };
#define SDL_GL_CONTEXT_PROFILE_ES 4
#define SDL_WINDOWPOS_UNDEFINED 0x1FFF0000
#define SDL_FUNCS(F) F(int, SDL_Init, (unsigned)) F(const char *, SDL_GetError, (void)) F(const char *, SDL_GetCurrentVideoDriver, (void)) \
    F(int, SDL_GetCurrentDisplayMode, (int, SDL_DisplayMode *)) F(int, SDL_GL_SetAttribute, (int, int)) \
    F(SDL_Window *, SDL_CreateWindow, (const char *, int, int, int, int, unsigned)) F(void *, SDL_GL_CreateContext, (SDL_Window *)) \
    F(int, SDL_GL_MakeCurrent, (SDL_Window *, void *)) F(void, SDL_GL_SwapWindow, (SDL_Window *)) F(int, SDL_GL_SetSwapInterval, (int)) \
    F(void *, SDL_GL_GetProcAddress, (const char *)) F(void, SDL_GL_GetDrawableSize, (SDL_Window *, int *, int *)) \
    F(void, SDL_PumpEvents, (void)) F(void, SDL_FlushEvents, (unsigned, unsigned)) F(int, SDL_ShowCursor, (int)) \
    F(int, SDL_SetHint, (const char *, const char *))
#define DECLARE(ret, name, args) static ret (*p_##name) args;
SDL_FUNCS(DECLARE)

/* ---- gl4es control, resolved in the process at load (gl4es is preloaded first) ---- */
static void (*p_set_getprocaddress)(void *(*)(const char *));
static void (*p_initialize_gl4es)(void);
static void *(*p_gl4es_GetProcAddress)(const char *);
static void (*p_gl4es_pre_swap)(void);
static void (*p_gl4es_post_swap)(void);
static int astc_mode;                  /* dxt5_astc: 1 = ASTC under the DXT5 label, 2 = the same, halved on the CPU path */
static char pad_name[128];             /* pad: the only joystick the game may open ("" = joysticks untouched) */

/* GLXSDL_CONFIG: "dxt5_astc = 0|1|2", "pad = <joystick name>" */
static void load_config(void)
{
    const char *path = getenv("GLXSDL_CONFIG");
    FILE *f = path && *path ? fopen(path, "r") : NULL;
    char line[256], key[32];
    if (!f) { if (path && *path) fprintf(stderr, "[glxsdl] %s: cannot read, defaults used\n", path); return; }
    while (fgets(line, sizeof line, f)) {
        char *l = line + strspn(line, " \t"), *v = strchr(l, '=');
        if (*l == '#' || *l == '\n' || *l == '\r' || !*l) continue;
        if (!v || sscanf(l, "%31[a-z0-9_]", key) != 1) { fprintf(stderr, "[glxsdl] %s: ignored line: %s", path, l); continue; }
        v++; v += strspn(v, " \t"); v[strcspn(v, "\r\n")] = 0;
        if (!strcmp(key, "dxt5_astc")) astc_mode = atoi(v);
        else if (!strcmp(key, "pad")) snprintf(pad_name, sizeof pad_name, "%s", v);
        else fprintf(stderr, "[glxsdl] %s: unknown setting %s\n", path, key);
    }
    fclose(f);
}

__attribute__((constructor)) static void load(void)
{
    p_set_getprocaddress = dlsym(RTLD_DEFAULT, "set_getprocaddress");
    p_initialize_gl4es = dlsym(RTLD_DEFAULT, "initialize_gl4es");
    p_gl4es_GetProcAddress = dlsym(RTLD_DEFAULT, "gl4es_GetProcAddress");
    p_gl4es_pre_swap = dlsym(RTLD_DEFAULT, "gl4es_pre_swap");
    p_gl4es_post_swap = dlsym(RTLD_DEFAULT, "gl4es_post_swap");
    load_config();
}

static SDL_Window *win;
static void *ctx, *egl_lib, *gles_lib;
static int win_w, win_h, ready, failed, astc_gpu, loading;   /* loading: the loading screen is up */
static Display *cur_dpy;
static GLXDrawable cur_draw;
static GLXContext cur_ctx;
static int fbconfig_slot = 1;                       /* the one config; its address is the GLXFBConfig handle */

static void *getproc(const char *name)
{
    void *p = p_SDL_GL_GetProcAddress(name);
    if (!p && gles_lib) p = dlsym(gles_lib, name);
    if (!p && egl_lib) p = dlsym(egl_lib, name);
    return p;
}
static void swap(void)
{
    if (p_gl4es_pre_swap) p_gl4es_pre_swap();
    p_SDL_GL_SwapWindow(win);
    if (p_gl4es_post_swap) p_gl4es_post_swap();
}

/* ---- letterbox: a game window smaller than the screen (xstub keeps a fullscreen window at the size the game asked
 * for) is drawn through gl4es's main FBO, which gl4es puts in place of framebuffer 0 once it exists, and shown centred
 * at its own aspect ratio with black around it (Unity 4 would stretch it over the screen). gl4es's createMainFBO /
 * blitMainFBO / bindMainFBO / unbindMainFBO are not exported: found by name in the symbol table of the gl4es file this
 * port ships. Off when they are missing or the window fills the screen. */
static void (*p_createMainFBO)(int, int), (*p_blitMainFBO)(int, int, int, int), (*p_bindMainFBO)(void), (*p_unbindMainFBO)(void);
static int lb_w, lb_h;                                  /* main FBO size, 0 = letterbox off */
static void lb_symbols(void)
{
    Dl_info info;
    if (!p_gl4es_pre_swap || !dladdr((void *)p_gl4es_pre_swap, &info) || !info.dli_fname) return;
    FILE *f = fopen(info.dli_fname, "rb");
    if (!f) return;
    Elf64_Ehdr eh; Elf64_Shdr *sh = NULL; char *str = NULL; Elf64_Sym *sym = NULL; size_t n = 0;
    if (fread(&eh, sizeof eh, 1, f) == 1 && (sh = calloc(eh.e_shnum, sizeof *sh)) && !fseek(f, eh.e_shoff, SEEK_SET)
        && fread(sh, sizeof *sh, eh.e_shnum, f) == eh.e_shnum)
        for (int i = 0; i < eh.e_shnum; i++) {
            if (sh[i].sh_type != SHT_SYMTAB || sh[i].sh_link >= eh.e_shnum) continue;
            Elf64_Shdr *ss = &sh[sh[i].sh_link];
            n = sh[i].sh_size / sizeof *sym;
            if ((sym = malloc(sh[i].sh_size)) && (str = malloc(ss->sh_size)) && !fseek(f, sh[i].sh_offset, SEEK_SET)
                && fread(sym, sh[i].sh_size, 1, f) == 1 && !fseek(f, ss->sh_offset, SEEK_SET) && fread(str, ss->sh_size, 1, f) == 1)
                for (size_t k = 0; k < n; k++) {
                    if (ELF64_ST_TYPE(sym[k].st_info) != STT_FUNC || !sym[k].st_value || sym[k].st_name >= ss->sh_size) continue;
                    void *p = (char *)info.dli_fbase + sym[k].st_value; const char *s = str + sym[k].st_name;
                    if (!strcmp(s, "createMainFBO")) p_createMainFBO = p;
                    else if (!strcmp(s, "blitMainFBO")) p_blitMainFBO = p;
                    else if (!strcmp(s, "bindMainFBO")) p_bindMainFBO = p;
                    else if (!strcmp(s, "unbindMainFBO")) p_unbindMainFBO = p;
                }
            break;
        }
    free(sh); free(sym); free(str); fclose(f);
    if (!p_createMainFBO || !p_blitMainFBO || !p_bindMainFBO || !p_unbindMainFBO) {
        p_createMainFBO = NULL; fprintf(stderr, "[glxsdl] gl4es main FBO functions not found: no letterbox\n");
    }
}
static void lb_update(void)                             /* after a swap: the game window's size -> main FBO */
{
    XWindowAttributes a;
    if (!p_createMainFBO || !cur_dpy || !cur_draw || !XGetWindowAttributes(cur_dpy, (Window)cur_draw, &a)) return;
    int w = a.width < win_w ? a.width : win_w, h = a.height < win_h ? a.height : win_h;
    if (w <= 0 || h <= 0 || (w == lb_w && h == lb_h) || (!lb_w && w == win_w && h == win_h)) return;
    p_createMainFBO(w, h);                              /* a resize keeps it; once on, it stays on */
    lb_w = w; lb_h = h;
    fprintf(stderr, "[glxsdl] letterbox: game window %dx%d shown centred on %dx%d\n", w, h, win_w, win_h);
}
/* clear colour (black), depth and stencil of the bound framebuffer, keeping the game's GL state. Every frame of the
 * main FBO starts like this, as a window's back buffer does after a swap (Mali hands out a cleared one): the game's
 * pause menu draws its buttons with a camera that clears nothing, and old depth in the FBO hid them. */
static void lb_clear(void)
{
    unsigned char (*isenabled)(GLenum) = p_gl4es_GetProcAddress("glIsEnabled");
    void (*getb)(GLenum, unsigned char *) = p_gl4es_GetProcAddress("glGetBooleanv");
    void (*getf)(GLenum, float *) = p_gl4es_GetProcAddress("glGetFloatv");
    void (*geti)(GLenum, GLint *) = p_gl4es_GetProcAddress("glGetIntegerv");
    void (*enable)(GLenum) = p_gl4es_GetProcAddress("glEnable"), (*disable)(GLenum) = p_gl4es_GetProcAddress("glDisable");
    void (*colormask)(unsigned char, unsigned char, unsigned char, unsigned char) = p_gl4es_GetProcAddress("glColorMask");
    void (*depthmask)(unsigned char) = p_gl4es_GetProcAddress("glDepthMask");
    void (*stencilmask)(GLuint) = p_gl4es_GetProcAddress("glStencilMask");
    void (*clearcolor)(float, float, float, float) = p_gl4es_GetProcAddress("glClearColor");
    void (*cleardepth)(float) = p_gl4es_GetProcAddress("glClearDepthf");
    void (*clearstencil)(GLint) = p_gl4es_GetProcAddress("glClearStencil");
    void (*clear)(unsigned) = p_gl4es_GetProcAddress("glClear");
    unsigned char sc = isenabled(0x0C11), cm[4], dm; float cc[4], cd; GLint sm, cs;   /* GL_SCISSOR_TEST */
    getb(0x0C23, cm); getb(0x0B72, &dm); geti(0x0B98, &sm);           /* colour, depth, stencil write masks */
    getf(0x0C22, cc); getf(0x0B73, &cd); geti(0x0B91, &cs);           /* clear colour, depth, stencil values */
    if (sc) disable(0x0C11);
    colormask(1, 1, 1, 1); depthmask(1); stencilmask(~0u); clearcolor(0, 0, 0, 1); cleardepth(1); clearstencil(0);
    clear(0x4000 | 0x100 | 0x400);                                    /* colour, depth, stencil */
    colormask(cm[0], cm[1], cm[2], cm[3]); depthmask(dm); stencilmask(sm); clearcolor(cc[0], cc[1], cc[2], cc[3]);
    cleardepth(cd); clearstencil(cs);
    if (sc) enable(0x0C11);
}
static void lb_present(void)                            /* before the swap: the main FBO centred on a black screen */
{
    p_unbindMainFBO();
    lb_clear();
    float s = (float)win_w / lb_w < (float)win_h / lb_h ? (float)win_w / lb_w : (float)win_h / lb_h;
    int dw = (int)(lb_w * s + 0.5f), dh = (int)(lb_h * s + 0.5f);
    p_blitMainFBO((win_w - dw) / 2, (win_h - dh) / 2, dw, dh);
}

/* "Loading..." on black, drawn into both buffers with nothing but scissored clears (no shader, no texture, no font
 * file) through gl4es's own entry points, so its state tracking sees every change; the state it touches is put back to
 * the defaults afterwards. 5x8 glyphs, '#' = lit. */
static void draw_loading(void)
{
    static const char *const glyph[][8] = {
        { "#....", "#....", "#....", "#....", "#....", "#....", "#####", "....." },   /* L */
        { ".....", ".....", ".###.", "#...#", "#...#", "#...#", ".###.", "....." },   /* o */
        { ".....", ".....", ".###.", "....#", ".####", "#...#", ".####", "....." },   /* a */
        { "....#", "....#", ".##.#", "#..##", "#...#", "#...#", ".####", "....." },   /* d */
        { "..#..", ".....", ".##..", "..#..", "..#..", "..#..", ".###.", "....." },   /* i */
        { ".....", ".....", "#.##.", "##..#", "#...#", "#...#", "#...#", "....." },   /* n */
        { ".....", ".....", ".####", "#...#", "#...#", ".####", "....#", ".###." },   /* g */
        { ".....", ".....", ".....", ".....", ".....", ".##..", ".##..", "....." },   /* . */
    };
    static const int text[] = { 0, 1, 2, 3, 4, 5, 6, 7, 7, 7 };                      /* Loading... */
    void (*clearcolor)(float, float, float, float) = p_gl4es_GetProcAddress("glClearColor");
    void (*clear)(unsigned) = p_gl4es_GetProcAddress("glClear");
    void (*enable)(unsigned) = p_gl4es_GetProcAddress("glEnable"), (*disable)(unsigned) = p_gl4es_GetProcAddress("glDisable");
    void (*scissor)(int, int, int, int) = p_gl4es_GetProcAddress("glScissor");
    void (*viewport)(int, int, int, int) = p_gl4es_GetProcAddress("glViewport");
    int n = (int)(sizeof text / sizeof text[0]);
    int px = win_h / 120 > 1 ? win_h / 120 : 1;          /* screen pixels per font pixel: 6 at 720 lines, 2 at 320 */
    int x0 = (win_w - (n * 6 * px - px)) / 2, y0 = (win_h + 8 * px) / 2;   /* y0: top of the text, GL y up */
    if (lb_w) p_unbindMainFBO();                         /* on the screen itself, not the letterboxed game picture */
    viewport(0, 0, win_w, win_h);
    for (int pass = 0; pass < 2; pass++) {               /* both buffers of the double-buffered window */
        disable(0x0C11);                                   /* GL_SCISSOR_TEST */
        clearcolor(0, 0, 0, 1); clear(0x4000);             /* GL_COLOR_BUFFER_BIT */
        enable(0x0C11); clearcolor(0.85f, 0.85f, 0.85f, 1);
        for (int c = 0; c < n; c++)
            for (int r = 0; r < 8; r++)
                for (int k = 0; k < 5; k++)
                    if (glyph[text[c]][r][k] == '#') { scissor(x0 + (c * 6 + k) * px, y0 - (r + 1) * px, px, px); clear(0x4000); }
        swap();
    }
    disable(0x0C11); scissor(0, 0, win_w, win_h); clearcolor(0, 0, 0, 0);
    if (lb_w) p_bindMainFBO();
}

/* the frame the game just finished (back buffer, before its swap): black along five full-width rows (1/6 to 5/6 of
 * the height, so a splash logo in the middle counts as content)? The loading screen is drawn once the window and
 * gl4es are up and put back after every such frame (Unity clears and swaps a few times while loading); the first
 * frame with content ends it. */
static int frame_is_dark(void)
{
    void (*readpix)(GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, void *) = p_gl4es_GetProcAddress("glReadPixels");
    int w = lb_w ? lb_w : win_w, h = lb_w ? lb_h : win_h;   /* the game's picture: the main FBO when letterboxed */
    unsigned char *row = malloc((size_t)w * 4);
    int dark = row != NULL;
    for (int r = 1; r <= 5 && dark; r++) {
        readpix(0, h * r / 6, w, 1, 0x1908, 0x1401, row);           /* GL_RGBA, GL_UNSIGNED_BYTE */
        for (int x = 0; x < w; x++)
            if (row[x * 4] > 8 || row[x * 4 + 1] > 8 || row[x * 4 + 2] > 8) { dark = 0; break; }
    }
    free(row);
    return dark;
}

static int init(void)
{
    if (ready || failed) return ready;
    failed = 1;
    if (!p_initialize_gl4es || !p_gl4es_GetProcAddress) { fprintf(stderr, "[glxsdl] gl4es is not preloaded\n"); return 0; }
    static const int fatal[] = { SIGSEGV, SIGBUS, SIGILL, SIGFPE, SIGTRAP, SIGABRT };
    struct sigaction saved[6];
    for (int i = 0; i < 6; i++) sigaction(fatal[i], NULL, &saved[i]);
    void *sdl = dlopen("libSDL2-2.0.so.0", RTLD_NOW | RTLD_GLOBAL);
    if (!sdl) { fprintf(stderr, "[glxsdl] no SDL2: %s\n", dlerror()); return 0; }
#define LOAD(ret, name, args) if (!(p_##name = dlsym(sdl, #name))) { fprintf(stderr, "[glxsdl] SDL2 lacks " #name "\n"); return 0; }
    SDL_FUNCS(LOAD)
    p_SDL_SetHint("SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS", "0");
    if (p_SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) != 0) { fprintf(stderr, "[glxsdl] SDL_Init: %s\n", p_SDL_GetError()); return 0; }
    static const int attr[][2] = { { SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES }, { SDL_GL_CONTEXT_MAJOR_VERSION, 2 },
        { SDL_GL_CONTEXT_MINOR_VERSION, 0 }, { SDL_GL_RED_SIZE, 8 }, { SDL_GL_GREEN_SIZE, 8 }, { SDL_GL_BLUE_SIZE, 8 }, { SDL_GL_ALPHA_SIZE, 8 },
        { SDL_GL_DEPTH_SIZE, 24 }, { SDL_GL_STENCIL_SIZE, 8 }, { SDL_GL_DOUBLEBUFFER, 1 } };
    for (int i = 0; i < 10; i++) p_SDL_GL_SetAttribute(attr[i][0], attr[i][1]);
    const char *dw = getenv("DISPLAY_WIDTH"), *dh = getenv("DISPLAY_HEIGHT");   /* PortMaster's control.txt */
    int w = dw ? atoi(dw) : 0, h = dh ? atoi(dh) : 0;
    SDL_DisplayMode m = { 0 };
    p_SDL_GetCurrentDisplayMode(0, &m);
    if (w <= 0 || h <= 0) { w = m.w; h = m.h; }                  /* not passed through: the display's own mode */
    win = p_SDL_CreateWindow("glxsdl", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, w, h,
                             SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | (m.w == w && m.h == h ? SDL_WINDOW_FULLSCREEN_DESKTOP : SDL_WINDOW_FULLSCREEN));
    if (!win || !(ctx = p_SDL_GL_CreateContext(win))) { fprintf(stderr, "[glxsdl] SDL window/context: %s\n", p_SDL_GetError()); return 0; }
    p_SDL_GL_MakeCurrent(win, ctx);
    p_SDL_GL_SetSwapInterval(1);
    p_SDL_ShowCursor(0);
    p_SDL_GL_GetDrawableSize(win, &win_w, &win_h);
    for (int i = 0; i < 6; i++) sigaction(fatal[i], &saved[i], NULL);   /* SDL2 builds with crash handlers: box64's back */
    egl_lib = dlopen("libEGL.so.1", RTLD_NOW | RTLD_GLOBAL);
    gles_lib = dlopen("libGLESv2.so.2", RTLD_NOW | RTLD_GLOBAL);
    if (p_set_getprocaddress) p_set_getprocaddress(getproc);
    p_initialize_gl4es();
    lb_symbols();
    draw_loading();
    loading = 1;
    if (astc_mode) {                                    /* can the GPU take the relabelled textures? */
        const char *(*gs)(GLenum) = (const char *(*)(GLenum))getproc("glGetString");
        const char *x = gs ? gs(0x1F03) : NULL;         /* GL_EXTENSIONS of the GLES context */
        astc_gpu = x && strstr(x, "GL_KHR_texture_compression_astc_ldr");
        fprintf(stderr, "[glxsdl] ASTC textures: %s\n", astc_gpu ? "uploaded as ASTC 4x4 (GPU support)" : "decoded on the CPU (no GL_KHR_texture_compression_astc_ldr)");
    }
    ready = 1; failed = 0;
    fprintf(stderr, "[glxsdl] SDL2 %s driver, window %dx%d (display %dx%d @ %d Hz), GLES 2 context, gl4es initialised\n",
            p_SDL_GetCurrentVideoDriver(), win_w, win_h, m.w, m.h, m.refresh_rate);
    return 1;
}

/* ---- the crusty_glX* surface the pass-through gl4es binds to ---- */
GLXFBConfig *crusty_glXChooseFBConfig(Display *d, int screen, const int *attribs, int *n)
{
    if (!init()) { *n = 0; return NULL; }
    GLXFBConfig *r = malloc(sizeof *r); r[0] = (GLXFBConfig)&fbconfig_slot; *n = 1;
    return r;
}
GLXFBConfig *crusty_glXGetFBConfigs(Display *d, int screen, int *n) { return crusty_glXChooseFBConfig(d, screen, NULL, n); }
int crusty_glXGetFBConfigAttrib(Display *d, GLXFBConfig c, int attr, int *v)
{
    switch (attr) {
    case GLX_FBCONFIG_ID: case GLX_DOUBLEBUFFER: case GLX_X_RENDERABLE: *v = 1; break;
    case GLX_BUFFER_SIZE: *v = 32; break;
    case GLX_RED_SIZE: case GLX_GREEN_SIZE: case GLX_BLUE_SIZE: case GLX_ALPHA_SIZE: case GLX_STENCIL_SIZE: *v = 8; break;
    case GLX_DEPTH_SIZE: *v = 24; break;
    case GLX_CONFIG_CAVEAT: case GLX_TRANSPARENT_TYPE: *v = GLX_NONE; break;
    case GLX_RENDER_TYPE: *v = GLX_RGBA_BIT; break;
    case GLX_DRAWABLE_TYPE: *v = GLX_WINDOW_BIT; break;
    case GLX_X_VISUAL_TYPE: *v = GLX_TRUE_COLOR; break;
    case GLX_VISUAL_ID: *v = 0x21; break;
    case GLX_SAMPLES: case GLX_SAMPLE_BUFFERS: case GLX_LEVEL: case GLX_STEREO: case GLX_AUX_BUFFERS:
    case GLX_ACCUM_RED_SIZE: case GLX_ACCUM_GREEN_SIZE: case GLX_ACCUM_BLUE_SIZE: case GLX_ACCUM_ALPHA_SIZE: *v = 0; break;
    case GLX_MAX_PBUFFER_WIDTH: case GLX_MAX_PBUFFER_HEIGHT: *v = 4096; break;
    case GLX_MAX_PBUFFER_PIXELS: *v = 4096 * 4096; break;
    default: *v = 0; return GLX_BAD_ATTRIBUTE;
    }
    return 0;
}
XVisualInfo *crusty_glXGetVisualFromFBConfig(Display *d, GLXFBConfig c)
{
    XVisualInfo tpl = { .screen = 0, .depth = 24 }; int n = 0;
    XVisualInfo *v = XGetVisualInfo(d, VisualScreenMask | VisualDepthMask, &tpl, &n);
    return n ? v : NULL;
}
XVisualInfo *crusty_glXChooseVisual(Display *d, int screen, int *attribs) { return crusty_glXGetVisualFromFBConfig(d, NULL); }
int crusty_glXGetConfig(Display *d, XVisualInfo *v, int attr, int *value)
{
    *value = attr == GLX_USE_GL || attr == GLX_RGBA || attr == GLX_DOUBLEBUFFER ? 1 : attr == GLX_BUFFER_SIZE ? 32 : attr == GLX_DEPTH_SIZE ? 24 :
             attr == GLX_RED_SIZE || attr == GLX_GREEN_SIZE || attr == GLX_BLUE_SIZE || attr == GLX_ALPHA_SIZE || attr == GLX_STENCIL_SIZE ? 8 : 0;
    return 0;
}
GLXContext crusty_glXCreateNewContext(Display *d, GLXFBConfig c, int type, GLXContext share, Bool direct) { return init() ? (GLXContext)ctx : NULL; }
GLXContext crusty_glXCreateContext(Display *d, XVisualInfo *v, GLXContext share, Bool direct) { return init() ? (GLXContext)ctx : NULL; }
GLXContext crusty_glXCreateContextAttribsARB(Display *d, GLXFBConfig c, GLXContext share, Bool direct, const int *attribs) { return init() ? (GLXContext)ctx : NULL; }
void crusty_glXDestroyContext(Display *d, GLXContext c) { }
void crusty_glXCopyContext(Display *d, GLXContext a, GLXContext b, unsigned long mask) { }
Bool crusty_glXMakeCurrent(Display *d, GLXDrawable dr, GLXContext c)
{
    if (!init()) return False;
    cur_dpy = d; cur_draw = dr; cur_ctx = c;          /* one SDL context, always current on this thread */
    if (c) p_SDL_GL_MakeCurrent(win, ctx);
    return True;
}
Bool crusty_glXMakeContextCurrent(Display *d, GLXDrawable draw, GLXDrawable read, GLXContext c) { return crusty_glXMakeCurrent(d, draw, c); }
GLXContext crusty_glXGetCurrentContext(void) { return cur_ctx; }
GLXDrawable crusty_glXGetCurrentDrawable(void) { return cur_draw; }
GLXDrawable crusty_glXGetCurrentReadDrawable(void) { return cur_draw; }
Display *crusty_glXGetCurrentDisplay(void) { return cur_dpy; }
void crusty_glXSwapBuffers(Display *d, GLXDrawable dr)
{
    if (!ready) return;
    if (loading) loading = frame_is_dark();
    if (lb_w) lb_present();
    swap();
    if (lb_w) { p_bindMainFBO(); lb_clear(); }         /* the game's next frame starts on a cleared main FBO */
    if (loading) draw_loading();                        /* a loading frame: text back */
    lb_update();
    p_SDL_PumpEvents(); p_SDL_FlushEvents(0, 0xFFFF);   /* keep the window server happy; the game reads input elsewhere */
}
Bool crusty_glXQueryVersion(Display *d, int *maj, int *min) { *maj = 1; *min = 4; return True; }
Bool crusty_glXQueryExtension(Display *d, int *err, int *ev) { if (err) *err = 0; if (ev) *ev = 0; return True; }
const char *crusty_glXQueryExtensionsString(Display *d, int screen) { return "GLX_ARB_get_proc_address GLX_ARB_create_context GLX_ARB_create_context_profile GLX_EXT_swap_control GLX_SGI_swap_control GLX_MESA_swap_control GLX_ARB_multisample"; }
const char *crusty_glXQueryServerString(Display *d, int screen, int name) { return name == GLX_VENDOR ? "glxsdl" : name == GLX_VERSION ? "1.4" : crusty_glXQueryExtensionsString(d, screen); }
const char *crusty_glXGetClientString(Display *d, int name) { return crusty_glXQueryServerString(d, 0, name); }
Bool crusty_glXIsDirect(Display *d, GLXContext c) { return True; }
int crusty_glXQueryContext(Display *d, GLXContext c, int attr, int *v) { *v = attr == GLX_FBCONFIG_ID ? 1 : attr == GLX_RENDER_TYPE ? GLX_RGBA_TYPE : 0; return 0; }
void crusty_glXQueryDrawable(Display *d, GLXDrawable dr, int attr, unsigned *v)
{
    if (ready) p_SDL_GL_GetDrawableSize(win, &win_w, &win_h);
    *v = !ready ? 0 : attr == GLX_WIDTH ? win_w : attr == GLX_HEIGHT ? win_h : attr == GLX_FBCONFIG_ID ? 1 : 0;
}
void crusty_glXWaitGL(void) { ((void (*)(void))p_gl4es_GetProcAddress("glFinish"))(); }
void crusty_glXWaitX(void) { }
/* the game's swap-interval requests (a Wayland compositor never tears, and waiting for its frame callback would
   quantise a 31 ms frame to 33 or 50 ms) */
static void set_interval(int i) { if (ready) p_SDL_GL_SetSwapInterval(i); }
void crusty_glXSwapIntervalEXT(Display *d, GLXDrawable dr, int i) { set_interval(i); }
int crusty_glXSwapIntervalSGI(int i) { set_interval(i); return 0; }
int crusty_glXSwapIntervalMESA(unsigned i) { set_interval((int)i); return 0; }
int crusty_glXGetSwapIntervalMESA(void) { return 1; }
GLXWindow crusty_glXCreateWindow(Display *d, GLXFBConfig c, Window w, const int *a) { return (GLXWindow)w; }
void crusty_glXDestroyWindow(Display *d, GLXWindow w) { }
GLXPixmap crusty_glXCreatePixmap(Display *d, GLXFBConfig c, Pixmap p, const int *a) { return (GLXPixmap)p; }
void crusty_glXDestroyPixmap(Display *d, GLXPixmap p) { }
GLXPixmap crusty_glXCreateGLXPixmap(Display *d, XVisualInfo *v, Pixmap p) { return (GLXPixmap)p; }
void crusty_glXDestroyGLXPixmap(Display *d, GLXPixmap p) { }
GLXPbuffer crusty_glXCreatePbuffer(Display *d, GLXFBConfig c, const int *a) { return 0; }
void crusty_glXDestroyPbuffer(Display *d, GLXPbuffer p) { }
void crusty_glXSelectEvent(Display *d, GLXDrawable dr, unsigned long m) { }
void crusty_glXGetSelectedEvent(Display *d, GLXDrawable dr, unsigned long *m) { *m = 0; }
void crusty_glXUseXFont(Font f, int first, int count, int base) { }

/* GLXSDL_DXT5_ASTC: texture files whose DXT5 images setup re-encoded as ASTC 4x4 keep their DXT5 label (the Unity 4
 * player decodes real ASTC on the CPU), so DXT5 uploads are relabelled here and gl4es forwards them as they are. A GPU
 * without ASTC gets them decoded on the CPU as RGBA4444 (what gl4es's own decode of DXT5 would cost); with =2 (half-size
 * files on a 1 GB device) halved again, i.e. what a quarter-size DXT5 texture costs. Colour averaged by alpha. */
#define FMT_DXT5 0x83F3
#define FMT_ASTC_4x4 0x93B0
typedef void (*cti_fn)(GLenum, GLint, GLenum, GLsizei, GLsizei, GLint, GLsizei, const void *);
typedef void (*ctsi_fn)(GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLsizei, const void *);
static cti_fn real_cti;
static ctsi_fn real_ctsi;
int astc_decode(const uint8_t *blocks, int w, int h, uint8_t *rgba);   /* astc_dec.cpp */

static void astc_fallback(GLenum t, GLint l, GLint x, GLint y, GLsizei w, GLsizei h, const void *d, int sub)
{
    static void (*teximage)(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, const void *);
    static void (*texsubimage)(GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, const void *);
    static void (*pixelstorei)(GLenum, GLint), (*getintegerv)(GLenum, GLint *);
    if (!teximage) {
        teximage = p_gl4es_GetProcAddress("glTexImage2D"); texsubimage = p_gl4es_GetProcAddress("glTexSubImage2D");
        pixelstorei = p_gl4es_GetProcAddress("glPixelStorei"); getintegerv = p_gl4es_GetProcAddress("glGetIntegerv");
    }
    int s = astc_mode == 2 ? 2 : 1, w4 = (w + 3) & ~3, h4 = (h + 3) & ~3, w2 = w >= s ? w / s : 1, h2 = h >= s ? h / s : 1;
    uint8_t *rgba = malloc((size_t)w4 * h4 * 4);
    uint16_t *o = malloc((size_t)w2 * h2 * 2);
    if (astc_decode(d, w4, h4, rgba)) { fprintf(stderr, "[glxsdl] ASTC fallback decode failed (%dx%d)\n", w, h); free(rgba); free(o); return; }
    for (int y = 0; y < h2; y++)
        for (int x = 0; x < w2; x++) {
            unsigned a = 0, c[3] = { 0, 0, 0 }, cs[3] = { 0, 0, 0 }, n = 0, v[4];
            for (int dy = 0; dy < s; dy++)
                for (int dx = 0; dx < s; dx++) {
                    int sx = s * x + dx, sy = s * y + dy;
                    if (sx >= w || sy >= h) continue;
                    const uint8_t *p = rgba + ((size_t)sy * w4 + sx) * 4;
                    a += p[3]; n++;
                    for (int k = 0; k < 3; k++) { c[k] += p[k] * p[3]; cs[k] += p[k]; }
                }
            for (int k = 0; k < 3; k++) v[k] = a ? (c[k] + a / 2) / a : (cs[k] + n / 2) / n;
            v[3] = (a + n / 2) / n;
            o[(size_t)y * w2 + x] = (uint16_t)((v[0] >> 4) << 12 | (v[1] >> 4) << 8 | (v[2] >> 4) << 4 | v[3] >> 4);
        }
    GLint align = 4; getintegerv(0x0CF5, &align); pixelstorei(0x0CF5, 1);          /* GL_UNPACK_ALIGNMENT */
    if (sub) texsubimage(t, l, x / s, y / s, w2, h2, 0x1908, 0x8033, o);          /* GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4 */
    else teximage(t, l, 0x1908, w2, h2, 0, 0x1908, 0x8033, o);
    pixelstorei(0x0CF5, align);
    free(rgba); free(o);
}
static void astc_cti(GLenum t, GLint l, GLenum f, GLsizei w, GLsizei h, GLint b, GLsizei n, const void *d)
{
    if (f == FMT_DXT5 && !astc_gpu && d) astc_fallback(t, l, 0, 0, w, h, d, 0);
    else real_cti(t, l, f == FMT_DXT5 ? FMT_ASTC_4x4 : f, w, h, b, n, d);
}
static void astc_ctsi(GLenum t, GLint l, GLint x, GLint y, GLsizei w, GLsizei h, GLenum f, GLsizei n, const void *d)
{
    if (f == FMT_DXT5 && !astc_gpu && d) astc_fallback(t, l, x, y, w, h, d, 1);
    else real_ctsi(t, l, x, y, w, h, f == FMT_DXT5 ? FMT_ASTC_4x4 : f, n, d);
}

void *crusty_glXGetProcAddressARB(const GLubyte *name)
{
    const char *n = (const char *)name;
    if (!strncmp(n, "glX", 3)) {
        char buf[128]; snprintf(buf, sizeof buf, "crusty_%s", n);
        void *p = dlsym(RTLD_DEFAULT, buf);                  /* our own glX implementation, else gl4es's export */
        return p ? p : dlsym(RTLD_DEFAULT, n);
    }
    if (astc_mode && !strncmp(n, "glCompressedTexImage2D", 22) && (real_cti = (cti_fn)p_gl4es_GetProcAddress(n))) return (void *)astc_cti;
    if (astc_mode && !strncmp(n, "glCompressedTexSubImage2D", 25) && (real_ctsi = (ctsi_fn)p_gl4es_GetProcAddress(n))) return (void *)astc_ctsi;
    return p_gl4es_GetProcAddress(n);
}

/* pad: the Unity 4 player opens /dev/input/js* itself. Only the joystick the config names (gptokeyb2 -x makes a
 * virtual "Microsoft X-Box 360 pad", the same layout on every device) is let through; every other joystick node fails
 * to open, so the game sees exactly one pad. box64 runs the game's open() calls through these (this library is
 * preloaded); nothing else is touched. */
static int pad_filter(const char *path, int fd)
{
    if (fd < 0 || !path || (strncmp(path, "/dev/input/js", 13) && strncmp(path, "/dev/js", 7))) return fd;
    if (!pad_name[0]) return fd;
    char name[128] = "";
    ioctl(fd, JSIOCGNAME(sizeof name), name);
    int ok = !strcmp(name, pad_name);
    fprintf(stderr, "[glxsdl] %s (%s): %s\n", path, name, ok ? "the game's pad" : "hidden");
    if (ok) return fd;
    close(fd); errno = ENOENT;
    return -1;
}
#define MODE_ARG(f) mode_t m = 0; if ((f) & O_CREAT || ((f) & O_TMPFILE) == O_TMPFILE) { va_list a; va_start(a, f); m = va_arg(a, int); va_end(a); }
typedef int (*open_fn)(const char *, int, ...);
typedef int (*openat_fn)(int, const char *, int, ...);
typedef int (*open2_fn)(const char *, int);
#define NEXT(name, type) static type real; if (!real) real = (type)dlsym(RTLD_NEXT, name)
int open(const char *p, int f, ...) { MODE_ARG(f) NEXT("open", open_fn); return pad_filter(p, real(p, f, m)); }
int open64(const char *p, int f, ...) { MODE_ARG(f) NEXT("open64", open_fn); return pad_filter(p, real(p, f, m)); }
int openat(int d, const char *p, int f, ...) { MODE_ARG(f) NEXT("openat", openat_fn); return pad_filter(p, real(d, p, f, m)); }
int openat64(int d, const char *p, int f, ...) { MODE_ARG(f) NEXT("openat64", openat_fn); return pad_filter(p, real(d, p, f, m)); }
int __open_2(const char *p, int f) { NEXT("__open_2", open2_fn); return pad_filter(p, real(p, f)); }
int __open64_2(const char *p, int f) { NEXT("__open64_2", open2_fn); return pad_filter(p, real(p, f)); }
