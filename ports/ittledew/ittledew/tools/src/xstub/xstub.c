/*
 * xstub: libX11.so.6 stand-in for the Unity 4 player under box64, so that no X server has to run. It has exactly the
 * Xlib calls the player imports, plus XGetVisualInfo (glxsdl) and the two mutex hooks box64's libX11 wrapper reads;
 * Display, Screen and Visual keep the real Xlib layout because the player uses the Xlib macros on them.
 *   - one screen of DISPLAY_WIDTH x DISPLAY_HEIGHT, depth 24 TrueColor, with the properties of an EWMH window manager;
 *   - windows are records in a table; map/configure/focus events are queued for windows that selected them;
 *   - the keyboard is read from evdev (/dev/input/event*, rescanned every 2 s so gptokeyb's uinput keyboard is found
 *     whenever it appears); keycodes are evdev + 8, XLookupString maps them with a US layout; autorepeat is never
 *     delivered (the player asks for detectable autorepeat);
 *   - nothing is drawn: glxsdl presents through the firmware's SDL2.
 * Build: build.sh.
 */
#define _GNU_SOURCE
#include <X11/Xlib.h>
#include <X11/Xlibint.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/XKBlib.h>
#include <X11/keysym.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <linux/input.h>
#include <poll.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>
#include <time.h>
#include <unistd.h>

static pthread_mutex_t lock = PTHREAD_RECURSIVE_MUTEX_INITIALIZER_NP;
#define L() pthread_mutex_lock(&lock)
#define U() pthread_mutex_unlock(&lock)

static Display *the_dpy;
static Screen the_screen;
static Visual the_visual;
static Depth the_depth;
static ScreenFormat the_format;
static int scr_w, scr_h, evpipe[2] = { -1, -1 }, focus_win;   /* focus_win: index into wins */
static XID next_id = 0x400001;
static Time t0ms;

#define ROOT_WIN 0x1cb
#define CMAP 0x20
#define MAXWIN 64
typedef struct { XID id, parent; int x, y, w, h, bw, mapped, override; long mask; } win_t;
static win_t wins[MAXWIN];
static int nwins;

typedef struct qev { XEvent ev; struct qev *next; } qev_t;
static qev_t *qhead, *qtail;
static int qlen;

#define MAXATOM 256                    /* predefined atoms 1..68 are Xatom.h's; ours start at 100 */
static char *atoms[MAXATOM];
static int natoms = 100;
static Window sel_owner[MAXATOM];

typedef struct prop { XID win; Atom atom, type; int format; unsigned char *data; unsigned long n; struct prop *next; } prop_t;
static prop_t *props;

#define MAXKBD 16
#define MAXSEEN 64
static int kbd_fd[MAXKBD], nkbd, nseen;
static char kbd_name[MAXKBD][32], seen_name[MAXSEEN][32];   /* seen: nodes looked at and rejected */
static time_t last_scan, seen_at[MAXSEEN];
static unsigned modstate;

static Time now_ms(void)
{
    struct timespec ts; clock_gettime(CLOCK_MONOTONIC, &ts);
    return (Time)(ts.tv_sec * 1000 + ts.tv_nsec / 1000000) - t0ms;
}

static win_t *find_win(XID id)
{
    for (int i = 0; i < nwins; i++) if (wins[i].id == id) return &wins[i];
    return NULL;
}

/* the event queue; a byte in the pipe behind ConnectionNumber() while it is not empty wakes a select() on it */
static void push(XEvent *ev)
{
    qev_t *q = calloc(1, sizeof *q); q->ev = *ev;
    if (qtail) qtail->next = q; else qhead = q;
    qtail = q; the_dpy->qlen = ++qlen;
    if (qlen == 1) { char c = 1; if (write(evpipe[1], &c, 1) < 0) {} }
}
/* take the first queued event that match() accepts (all with match NULL) */
static int take(XEvent *ev, int (*match)(XEvent *, void *), void *arg)
{
    for (qev_t *q = qhead, *prev = NULL; q; prev = q, q = q->next)
        if (!match || match(&q->ev, arg)) {
            if (prev) prev->next = q->next; else qhead = q->next;
            if (qtail == q) qtail = prev;
            *ev = q->ev; free(q); the_dpy->qlen = --qlen;
            if (!qlen) { char c; while (read(evpipe[0], &c, 1) > 0) {} }
            return 1;
        }
    return 0;
}
static void send_to(win_t *w, long mask, XEvent *ev)
{
    if (!w || !(w->mask & mask)) return;
    ev->xany.display = the_dpy; ev->xany.window = w->id; ev->xany.serial = ++the_dpy->request;
    push(ev);
}

/* ---------------------------------------------------------------- evdev keyboards */
/* raw syscalls: the preloaded gl4es hooks libc file functions in this process */
static int ev_open(const char *path) { return (int)syscall(SYS_openat, AT_FDCWD, path, O_RDONLY | O_NONBLOCK | O_CLOEXEC); }
static int ev_ioctl(int fd, unsigned long req, void *arg) { return (int)syscall(SYS_ioctl, fd, req, arg); }
static void ev_close(int fd) { syscall(SYS_close, fd); }
static int is_keyboard(int fd)
{
    unsigned long evbits[EV_MAX / (8 * sizeof(long)) + 1] = { 0 }, keybits[KEY_MAX / (8 * sizeof(long)) + 1] = { 0 };
#define HAS(b, k) (b[(k) / (8 * sizeof(long))] & (1UL << ((k) % (8 * sizeof(long)))))
    if (ev_ioctl(fd, EVIOCGBIT(0, sizeof evbits), evbits) < 0 || !HAS(evbits, EV_KEY) ||
        ev_ioctl(fd, EVIOCGBIT(EV_KEY, sizeof keybits), keybits) < 0) return 0;
    /* gamepads (gptokeyb reads those) may also declare KEY_UP..KEY_RIGHT for the D-pad */
    if (HAS(keybits, BTN_SOUTH) || HAS(keybits, BTN_EAST) || HAS(keybits, BTN_START) || HAS(keybits, BTN_SELECT) || HAS(keybits, BTN_JOYSTICK)) return 0;
    return HAS(keybits, KEY_ENTER) || HAS(keybits, KEY_Z) || HAS(keybits, KEY_UP) || HAS(keybits, KEY_ESC);
#undef HAS
}
/* new keyboards every 2 s; rejected nodes are looked at again only after 20 s (opening evdev nodes is slow on some
   kernels and showed as a stall) */
static void scan_keyboards(void)
{
    time_t t = time(NULL);
    if (t - last_scan < 2) return;
    last_scan = t;
    DIR *d = opendir("/dev/input"); if (!d) return;
    for (struct dirent *e; (e = readdir(d)) && nkbd < MAXKBD;) {
        int skip = strncmp(e->d_name, "event", 5) != 0, k = -1;
        for (int i = 0; i < nkbd; i++) if (!strcmp(kbd_name[i], e->d_name)) skip = 1;
        for (int i = 0; i < nseen; i++) if (!strcmp(seen_name[i], e->d_name)) k = i;
        if (skip || (k >= 0 && t - seen_at[k] < 20)) continue;
        char path[300]; snprintf(path, sizeof path, "/dev/input/%s", e->d_name);
        int fd = ev_open(path);
        if (fd < 0) continue;
        if (is_keyboard(fd)) { kbd_fd[nkbd] = fd; snprintf(kbd_name[nkbd++], 32, "%s", e->d_name); continue; }
        ev_close(fd);
        if (k < 0 && nseen < MAXSEEN) snprintf(seen_name[k = nseen++], 32, "%s", e->d_name);
        if (k >= 0) seen_at[k] = t;
    }
    closedir(d);
}
static void key_event(int code, int value)
{
    if (value == 2 || code > 247) return;           /* autorepeat: detectable autorepeat means no repeats at all */
    XEvent ev; memset(&ev, 0, sizeof ev);
    ev.xkey.type = value ? KeyPress : KeyRelease;
    ev.xkey.root = ROOT_WIN; ev.xkey.time = now_ms(); ev.xkey.same_screen = True;
    ev.xkey.state = modstate; ev.xkey.keycode = code + 8;
    unsigned bit = code == KEY_LEFTSHIFT || code == KEY_RIGHTSHIFT ? ShiftMask : code == KEY_LEFTCTRL || code == KEY_RIGHTCTRL ? ControlMask :
                   code == KEY_LEFTALT || code == KEY_RIGHTALT ? Mod1Mask : 0;
    if (value) modstate |= bit; else modstate &= ~bit;
    send_to(&wins[focus_win], value ? KeyPressMask : KeyReleaseMask, &ev);
}
static void read_keyboards(void)
{
    scan_keyboards();
    struct input_event ie[32];
    for (int i = 0; i < nkbd; i++)
        for (;;) {
            long n = syscall(SYS_read, kbd_fd[i], ie, sizeof ie);
            if (n <= 0) {                               /* gone (a virtual keyboard can be recreated): drop it */
                if (n == 0 || errno != EAGAIN) { ev_close(kbd_fd[i]); kbd_fd[i] = kbd_fd[--nkbd]; strcpy(kbd_name[i], kbd_name[nkbd]); i--; }
                break;
            }
            for (int k = 0; k < (int)(n / sizeof ie[0]); k++) if (ie[k].type == EV_KEY) key_event(ie[k].code, ie[k].value);
        }
}
/* block until an event is queued */
static void wait_event(void)
{
    struct pollfd p[MAXKBD];
    while (!qlen) {
        for (int i = 0; i < nkbd; i++) { p[i].fd = kbd_fd[i]; p[i].events = POLLIN; }
        struct timespec ts = { 0, 500000000L };
        syscall(SYS_ppoll, p, nkbd, &ts, NULL, 0);
        read_keyboards();
    }
}

static const KeySym keymap[248] = {
    [KEY_ESC] = XK_Escape, [KEY_1] = XK_1, [KEY_2] = XK_2, [KEY_3] = XK_3, [KEY_4] = XK_4, [KEY_5] = XK_5,
    [KEY_6] = XK_6, [KEY_7] = XK_7, [KEY_8] = XK_8, [KEY_9] = XK_9, [KEY_0] = XK_0, [KEY_MINUS] = XK_minus,
    [KEY_EQUAL] = XK_equal, [KEY_BACKSPACE] = XK_BackSpace, [KEY_TAB] = XK_Tab, [KEY_Q] = XK_q, [KEY_W] = XK_w,
    [KEY_E] = XK_e, [KEY_R] = XK_r, [KEY_T] = XK_t, [KEY_Y] = XK_y, [KEY_U] = XK_u, [KEY_I] = XK_i, [KEY_O] = XK_o,
    [KEY_P] = XK_p, [KEY_LEFTBRACE] = XK_bracketleft, [KEY_RIGHTBRACE] = XK_bracketright, [KEY_ENTER] = XK_Return,
    [KEY_LEFTCTRL] = XK_Control_L, [KEY_A] = XK_a, [KEY_S] = XK_s, [KEY_D] = XK_d, [KEY_F] = XK_f, [KEY_G] = XK_g,
    [KEY_H] = XK_h, [KEY_J] = XK_j, [KEY_K] = XK_k, [KEY_L] = XK_l, [KEY_SEMICOLON] = XK_semicolon,
    [KEY_APOSTROPHE] = XK_apostrophe, [KEY_GRAVE] = XK_grave, [KEY_LEFTSHIFT] = XK_Shift_L, [KEY_BACKSLASH] = XK_backslash,
    [KEY_Z] = XK_z, [KEY_X] = XK_x, [KEY_C] = XK_c, [KEY_V] = XK_v, [KEY_B] = XK_b, [KEY_N] = XK_n, [KEY_M] = XK_m,
    [KEY_COMMA] = XK_comma, [KEY_DOT] = XK_period, [KEY_SLASH] = XK_slash, [KEY_RIGHTSHIFT] = XK_Shift_R,
    [KEY_KPASTERISK] = XK_KP_Multiply, [KEY_LEFTALT] = XK_Alt_L, [KEY_SPACE] = XK_space, [KEY_CAPSLOCK] = XK_Caps_Lock,
    [KEY_F1] = XK_F1, [KEY_F2] = XK_F2, [KEY_F3] = XK_F3, [KEY_F4] = XK_F4, [KEY_F5] = XK_F5, [KEY_F6] = XK_F6,
    [KEY_F7] = XK_F7, [KEY_F8] = XK_F8, [KEY_F9] = XK_F9, [KEY_F10] = XK_F10, [KEY_NUMLOCK] = XK_Num_Lock,
    [KEY_SCROLLLOCK] = XK_Scroll_Lock, [KEY_KP7] = XK_KP_7, [KEY_KP8] = XK_KP_8, [KEY_KP9] = XK_KP_9,
    [KEY_KPMINUS] = XK_KP_Subtract, [KEY_KP4] = XK_KP_4, [KEY_KP5] = XK_KP_5, [KEY_KP6] = XK_KP_6, [KEY_KPPLUS] = XK_KP_Add,
    [KEY_KP1] = XK_KP_1, [KEY_KP2] = XK_KP_2, [KEY_KP3] = XK_KP_3, [KEY_KP0] = XK_KP_0, [KEY_KPDOT] = XK_KP_Decimal,
    [KEY_F11] = XK_F11, [KEY_F12] = XK_F12, [KEY_KPENTER] = XK_KP_Enter, [KEY_RIGHTCTRL] = XK_Control_R,
    [KEY_KPSLASH] = XK_KP_Divide, [KEY_SYSRQ] = XK_Sys_Req, [KEY_RIGHTALT] = XK_Alt_R, [KEY_HOME] = XK_Home,
    [KEY_UP] = XK_Up, [KEY_PAGEUP] = XK_Page_Up, [KEY_LEFT] = XK_Left, [KEY_RIGHT] = XK_Right, [KEY_END] = XK_End,
    [KEY_DOWN] = XK_Down, [KEY_PAGEDOWN] = XK_Page_Down, [KEY_INSERT] = XK_Insert, [KEY_DELETE] = XK_Delete,
    [KEY_PAUSE] = XK_Pause, [KEY_LEFTMETA] = XK_Super_L, [KEY_RIGHTMETA] = XK_Super_R, [KEY_MENU] = XK_Menu,
};

int XLookupString(XKeyEvent *ev, char *buf, int len, KeySym *sym, XComposeStatus *st)
{
    KeySym s = ev->keycode >= 8 && ev->keycode < 256 ? keymap[ev->keycode - 8] : NoSymbol;
    if (ev->state & ShiftMask) {
        if (s >= XK_a && s <= XK_z) s -= 0x20;
        else if (s >= XK_0 && s <= XK_9) s = (unsigned char)")!@#$%^&*("[s - XK_0];
    }
    if (sym) *sym = s;
    char c = s == XK_Return || s == XK_KP_Enter ? '\r' : s == XK_BackSpace ? 8 : s == XK_Tab ? 9 : s == XK_Escape ? 27 : s >= 0x20 && s <= 0x7e ? (char)s : 0;
    if (!c || len < 1) return 0;
    buf[0] = c;
    return 1;
}
Bool XkbSetDetectableAutoRepeat(Display *d, Bool det, Bool *sup) { if (sup) *sup = True; return True; }

/* ---------------------------------------------------------------- windows */
static win_t *new_win(XID parent, int x, int y, int w, int h, int bw)
{
    if (nwins >= MAXWIN) return NULL;
    win_t *r = &wins[nwins++]; memset(r, 0, sizeof *r);
    r->id = next_id++; r->parent = parent; r->x = x; r->y = y; r->w = w; r->h = h; r->bw = bw;
    return r;
}
static void configured(win_t *r)
{
    XEvent ev; memset(&ev, 0, sizeof ev); ev.xconfigure.type = ConfigureNotify; ev.xconfigure.event = ev.xconfigure.window = r->id;
    ev.xconfigure.x = r->x; ev.xconfigure.y = r->y; ev.xconfigure.width = r->w; ev.xconfigure.height = r->h; ev.xconfigure.border_width = r->bw;
    if (r->mapped) send_to(r, StructureNotifyMask, &ev);
}
static void focus_event(win_t *r, int type)
{
    XEvent ev; memset(&ev, 0, sizeof ev); ev.xfocus.type = type; ev.xfocus.mode = NotifyNormal; ev.xfocus.detail = NotifyNonlinear;
    send_to(r, FocusChangeMask, &ev);
}
/* StructureNotify events whose fields after the header are (event, window) */
static void notify(win_t *r, int type)
{
    XEvent ev; memset(&ev, 0, sizeof ev); ev.type = type; ev.xmap.event = ev.xmap.window = r->id;
    send_to(r, StructureNotifyMask, &ev);
}
static int geometry(Window w, int x, int y, int wd, int ht, int pos, int size)
{
    L(); win_t *r = find_win(w);
    if (r) { if (pos) { r->x = x; r->y = y; } if (size) { r->w = wd; r->h = ht; } configured(r); }
    U(); return 0;
}

Window XCreateWindow(Display *d, Window parent, int x, int y, unsigned w, unsigned h, unsigned bw, int depth,
                     unsigned class, Visual *vis, unsigned long vmask, XSetWindowAttributes *a)
{
    L(); win_t *r = new_win(parent, x, y, w, h, bw);
    if (r && a) { if (vmask & CWEventMask) r->mask = a->event_mask; if (vmask & CWOverrideRedirect) r->override = a->override_redirect; }
    U(); return r ? r->id : 0;
}
Window XCreateSimpleWindow(Display *d, Window parent, int x, int y, unsigned w, unsigned h, unsigned bw, unsigned long border, unsigned long bg)
{
    return XCreateWindow(d, parent, x, y, w, h, bw, 24, InputOutput, NULL, 0, NULL);
}
int XDestroyWindow(Display *d, Window w) { L(); win_t *r = find_win(w); if (r) { notify(r, DestroyNotify); r->id = 0; } U(); return 0; }
int XMapWindow(Display *d, Window w)
{
    L(); win_t *r = find_win(w);
    if (r && !r->mapped) {
        r->mapped = 1;
        configured(r);
        XEvent ev; memset(&ev, 0, sizeof ev); ev.xmap.type = MapNotify; ev.xmap.event = w; ev.xmap.override_redirect = r->override; send_to(r, StructureNotifyMask, &ev);
        memset(&ev, 0, sizeof ev); ev.xvisibility.type = VisibilityNotify; ev.xvisibility.state = VisibilityUnobscured; send_to(r, VisibilityChangeMask, &ev);
        configured(r);
        memset(&ev, 0, sizeof ev); ev.xexpose.type = Expose; ev.xexpose.width = r->w; ev.xexpose.height = r->h; send_to(r, ExposureMask, &ev);
        focus_win = (int)(r - wins);
        focus_event(r, FocusIn);
    }
    U(); return 0;
}
int XUnmapWindow(Display *d, Window w) { L(); win_t *r = find_win(w); if (r && r->mapped) { r->mapped = 0; notify(r, UnmapNotify); } U(); return 0; }
int XMoveResizeWindow(Display *d, Window w, int x, int y, unsigned wd, unsigned ht) { return geometry(w, x, y, wd, ht, 1, 1); }
int XMoveWindow(Display *d, Window w, int x, int y) { return geometry(w, x, y, 0, 0, 1, 0); }
int XResizeWindow(Display *d, Window w, unsigned wd, unsigned ht) { return geometry(w, 0, 0, wd, ht, 0, 1); }
int XRaiseWindow(Display *d, Window w) { return geometry(w, 0, 0, 0, 0, 0, 0); }
int XLowerWindow(Display *d, Window w) { return geometry(w, 0, 0, 0, 0, 0, 0); }
int XReparentWindow(Display *d, Window w, Window p, int x, int y)
{
    L(); win_t *r = find_win(w);
    if (r) {
        r->parent = p; r->x = x; r->y = y;
        XEvent ev; memset(&ev, 0, sizeof ev); ev.xreparent.type = ReparentNotify; ev.xreparent.event = ev.xreparent.window = w;
        ev.xreparent.parent = p; ev.xreparent.x = x; ev.xreparent.y = y; send_to(r, StructureNotifyMask, &ev);
    }
    U(); return 0;
}
int XSelectInput(Display *d, Window w, long mask) { L(); win_t *r = find_win(w); if (r) r->mask = mask; U(); return 0; }
Status XGetWindowAttributes(Display *d, Window w, XWindowAttributes *a)
{
    L(); win_t *r = find_win(w); memset(a, 0, sizeof *a);
    if (r) {
        a->x = r->x; a->y = r->y; a->width = r->w; a->height = r->h; a->border_width = r->bw; a->depth = 24;
        a->visual = &the_visual; a->root = ROOT_WIN; a->class = InputOutput; a->bit_gravity = ForgetGravity; a->win_gravity = NorthWestGravity;
        a->backing_store = NotUseful; a->colormap = CMAP; a->map_installed = True; a->map_state = r->mapped ? IsViewable : IsUnmapped;
        a->all_event_masks = a->your_event_mask = r->mask; a->override_redirect = r->override; a->screen = &the_screen;
    }
    U(); return r != NULL;
}
Status XGetGeometry(Display *d, Drawable w, Window *root, int *x, int *y, unsigned *wd, unsigned *ht, unsigned *bw, unsigned *depth)
{
    L(); win_t *r = find_win(w);
    *root = ROOT_WIN; *depth = 24;
    if (r) { *x = r->x; *y = r->y; *wd = r->w; *ht = r->h; *bw = r->bw; }
    else { *x = *y = 0; *wd = scr_w; *ht = scr_h; *bw = 0; }
    U(); return 1;
}
Status XQueryTree(Display *d, Window w, Window *root, Window *parent, Window **children, unsigned *n)
{
    L(); win_t *r = find_win(w);
    *root = ROOT_WIN; *parent = r && w != ROOT_WIN ? r->parent : None; *children = NULL; *n = 0;
    for (int i = 0; i < nwins; i++)
        if (wins[i].id && wins[i].parent == w) { *children = realloc(*children, (*n + 1) * sizeof(Window)); (*children)[(*n)++] = wins[i].id; }
    U(); return 1;
}
Bool XTranslateCoordinates(Display *d, Window src, Window dst, int x, int y, int *dx, int *dy, Window *child)
{
    L(); win_t *s = find_win(src), *t = find_win(dst);
    *dx = x + (s && src != ROOT_WIN ? s->x : 0) - (t && dst != ROOT_WIN ? t->x : 0);
    *dy = y + (s && src != ROOT_WIN ? s->y : 0) - (t && dst != ROOT_WIN ? t->y : 0);
    *child = None; U(); return True;
}
int XSetInputFocus(Display *d, Window w, int revert, Time t)
{
    L(); win_t *r = find_win(w);
    if (r && r - wins != focus_win) { focus_event(&wins[focus_win], FocusOut); focus_win = (int)(r - wins); focus_event(r, FocusIn); }
    U(); return 0;
}
int XGetInputFocus(Display *d, Window *w, int *revert) { L(); *w = focus_win > 0 && wins[focus_win].mapped ? wins[focus_win].id : PointerRoot; *revert = RevertToPointerRoot; U(); return 0; }
Colormap XCreateColormap(Display *d, Window w, Visual *v, int alloc) { return CMAP; }

/* ---------------------------------------------------------------- atoms, properties, selections */
Atom XInternAtom(Display *d, const char *name, Bool only)
{
    L();
    for (int i = 1; i < natoms; i++) if (atoms[i] && !strcmp(atoms[i], name)) { U(); return i; }
    Atom a = only || natoms >= MAXATOM ? None : natoms;
    if (a) atoms[natoms++] = strdup(name);
    U(); return a;
}
static int is_atom(Atom a, const char *name) { return a < (Atom)natoms && atoms[a] && !strcmp(atoms[a], name); }
static int item_size(int format) { return format == 32 ? sizeof(long) : format / 8; }   /* Xlib: format 32 = longs */
static prop_t *find_prop(XID w, Atom a) { for (prop_t *p = props; p; p = p->next) if (p->win == w && p->atom == a) return p; return NULL; }
int XChangeProperty(Display *d, Window w, Atom prop, Atom type, int format, int mode, const unsigned char *data, int n)
{
    L(); prop_t *p = find_prop(w, prop);
    if (!p) { p = calloc(1, sizeof *p); p->win = w; p->atom = prop; p->next = props; props = p; }
    int unit = item_size(format), old = mode == PropModeReplace ? 0 : (int)p->n * unit, bytes = n * unit;
    unsigned char *nd = malloc(old + bytes + 1);
    memcpy(nd + (mode == PropModePrepend ? 0 : old), data, bytes);
    if (old) memcpy(nd + (mode == PropModePrepend ? bytes : 0), p->data, old);
    nd[old + bytes] = 0; free(p->data); p->data = nd; p->n = (old + bytes) / unit; p->type = type; p->format = format;
    win_t *r = find_win(w);
    if (r) {
        XEvent ev; memset(&ev, 0, sizeof ev); ev.xproperty.type = PropertyNotify; ev.xproperty.atom = prop;
        ev.xproperty.state = PropertyNewValue; ev.xproperty.time = now_ms(); send_to(r, PropertyChangeMask, &ev);
    }
    U(); return 0;
}
int XGetWindowProperty(Display *d, Window w, Atom prop, long off, long len, Bool del, Atom req, Atom *type, int *format, unsigned long *n, unsigned long *after, unsigned char **data)
{
    L(); prop_t *p = find_prop(w, prop);
    *type = p ? p->type : None; *format = p ? p->format : 0; *n = p ? p->n : 0; *after = 0; *data = NULL;
    if (p) { int bytes = p->n * item_size(p->format); *data = malloc(bytes + 1); memcpy(*data, p->data, bytes + 1); }
    U(); return Success;
}
int XStoreName(Display *d, Window w, const char *name) { return 0; }
void XSetWMProperties(Display *d, Window w, XTextProperty *name, XTextProperty *icon, char **argv, int argc, XSizeHints *sh, XWMHints *wh, XClassHint *ch) { }
Status XSetWMProtocols(Display *d, Window w, Atom *p, int n) { return 1; }
int XSetClassHint(Display *d, Window w, XClassHint *h) { return 0; }
XSizeHints *XAllocSizeHints(void) { return calloc(1, sizeof(XSizeHints)); }
XWMHints *XAllocWMHints(void) { return calloc(1, sizeof(XWMHints)); }
XClassHint *XAllocClassHint(void) { return calloc(1, sizeof(XClassHint)); }
Status XStringListToTextProperty(char **list, int count, XTextProperty *t)
{
    size_t len = 0;
    for (int i = 0; i < count; i++) len += strlen(list[i]) + 1;
    char *v = malloc(len + 1), *o = v;
    for (int i = 0; i < count; i++) o = stpcpy(o, list[i]) + 1;
    *o = 0; t->value = (unsigned char *)v; t->encoding = XA_STRING; t->format = 8; t->nitems = len ? len - 1 : 0;
    return 1;
}
int XSetSelectionOwner(Display *d, Atom sel, Window w, Time t) { if (sel < MAXATOM) sel_owner[sel] = w; return 0; }
Window XGetSelectionOwner(Display *d, Atom sel) { return sel < MAXATOM ? sel_owner[sel] : None; }
/* nobody owns anything: a failed SelectionNotify, which the player handles */
int XConvertSelection(Display *d, Atom sel, Atom target, Atom prop, Window req, Time t)
{
    L();
    if (find_win(req)) {
        XEvent ev; memset(&ev, 0, sizeof ev); ev.xselection.type = SelectionNotify; ev.xselection.display = the_dpy; ev.xselection.requestor = req;
        ev.xselection.selection = sel; ev.xselection.target = target; ev.xselection.property = None; ev.xselection.time = t; push(&ev);
    }
    U(); return 0;
}

/* ---------------------------------------------------------------- display */
Display *XOpenDisplay(const char *name)
{
    L();
    if (the_dpy) { U(); return the_dpy; }
    /* PortMaster's control.txt sets DISPLAY_WIDTH/HEIGHT; the launcher must pass them through $ESUDO (sudo drops them) */
    const char *dw = getenv("DISPLAY_WIDTH"), *dh = getenv("DISPLAY_HEIGHT");
    scr_w = dw ? atoi(dw) : 0; scr_h = dh ? atoi(dh) : 0;
    if (scr_w <= 0 || scr_h <= 0) { fprintf(stderr, "[xstub] DISPLAY_WIDTH/DISPLAY_HEIGHT not set: 640x480 assumed\n"); scr_w = 640; scr_h = 480; }
    /* XSTUB_SCREEN=WxH: the screen the game sees, when it should draw smaller than the display (glxsdl centres it) */
    const char *ss = getenv("XSTUB_SCREEN");
    int sw, sh;
    if (ss && sscanf(ss, "%dx%d", &sw, &sh) == 2 && sw > 0 && sh > 0) { scr_w = sw; scr_h = sh; }
    t0ms = now_ms();
    pipe2(evpipe, O_NONBLOCK | O_CLOEXEC);
    static const char *pre[] = { "PRIMARY", "SECONDARY", "ARC", "ATOM", "BITMAP", "CARDINAL", "COLORMAP", "CURSOR",
        "CUT_BUFFER0", "CUT_BUFFER1", "CUT_BUFFER2", "CUT_BUFFER3", "CUT_BUFFER4", "CUT_BUFFER5", "CUT_BUFFER6",
        "CUT_BUFFER7", "DRAWABLE", "FONT", "INTEGER", "PIXMAP", "POINT", "RECTANGLE", "RESOURCE_MANAGER", "RGB_COLOR_MAP",
        "RGB_BEST_MAP", "RGB_BLUE_MAP", "RGB_DEFAULT_MAP", "RGB_GRAY_MAP", "RGB_GREEN_MAP", "RGB_RED_MAP", "STRING",
        "VISUALID", "WINDOW", "WM_COMMAND", "WM_HINTS", "WM_CLIENT_MACHINE", "WM_ICON_NAME", "WM_ICON_SIZE", "WM_NAME",
        "WM_NORMAL_HINTS", "WM_SIZE_HINTS", "WM_ZOOM_HINTS", "MIN_SPACE", "NORM_SPACE", "MAX_SPACE", "END_SPACE",
        "SUPERSCRIPT_X", "SUPERSCRIPT_Y", "SUBSCRIPT_X", "SUBSCRIPT_Y", "UNDERLINE_POSITION", "UNDERLINE_THICKNESS",
        "STRIKEOUT_ASCENT", "STRIKEOUT_DESCENT", "ITALIC_ANGLE", "X_HEIGHT", "QUAD_WIDTH", "WEIGHT", "POINT_SIZE",
        "RESOLUTION", "COPYRIGHT", "NOTICE", "FONT_NAME", "FAMILY_NAME", "FULL_NAME", "CAP_HEIGHT", "WM_CLASS",
        "WM_TRANSIENT_FOR" };
    for (int i = 0; i < 68; i++) atoms[i + 1] = (char *)pre[i];

    Display *d = calloc(1, sizeof *d);
    d->fd = evpipe[0];
    d->proto_major_version = 11; d->vendor = "xstub"; d->release = 12000000; d->vnumber = XlibSpecificationRelease;
    d->resource_base = 0x400000; d->resource_mask = 0x1fffff; d->resource_id = 1;
    d->byte_order = LSBFirst; d->bitmap_unit = 32; d->bitmap_pad = 32; d->bitmap_bit_order = LSBFirst;
    the_format.depth = 24; the_format.bits_per_pixel = 32; the_format.scanline_pad = 32;
    d->nformats = 1; d->pixmap_format = &the_format;
    d->display_name = ":0"; d->nscreens = 1; d->min_keycode = 8; d->max_keycode = 255;
    d->bufptr = d->buffer = malloc(4096); d->bufmax = d->buffer + 4096;
    the_visual.visualid = 0x21; the_visual.class = TrueColor;
    the_visual.red_mask = 0xff0000; the_visual.green_mask = 0xff00; the_visual.blue_mask = 0xff;
    the_visual.bits_per_rgb = 8; the_visual.map_entries = 256;
    the_depth.depth = 24; the_depth.nvisuals = 1; the_depth.visuals = &the_visual;
    the_screen.display = d; the_screen.root = ROOT_WIN; the_screen.width = scr_w; the_screen.height = scr_h;
    the_screen.mwidth = scr_w * 254 / 960; the_screen.mheight = scr_h * 254 / 960;   /* ~96 dpi */
    the_screen.ndepths = 1; the_screen.depths = &the_depth; the_screen.root_depth = 24; the_screen.root_visual = &the_visual;
    the_screen.default_gc = calloc(1, sizeof(struct _XGC));
    the_screen.cmap = CMAP; the_screen.white_pixel = 0xffffff; the_screen.max_maps = the_screen.min_maps = 1;
    the_screen.backing_store = NotUseful;
    d->screens = &the_screen;
    the_dpy = d;

    nwins = 1; wins[0].id = ROOT_WIN; wins[0].w = scr_w; wins[0].h = scr_h; wins[0].mapped = 1;
    /* look like an EWMH window manager: _NET_SUPPORTING_WM_CHECK on the root and on a hidden WM window, _NET_SUPPORTED
       listing the state atoms the player asks for (otherwise Unity says "Current window manager doesn't support
       fullscreen" and re-maps its window every frame) */
    Window wm = new_win(ROOT_WIN, -1, -1, 1, 1, 0)->id;
    Atom check = XInternAtom(d, "_NET_SUPPORTING_WM_CHECK", False), utf8 = XInternAtom(d, "UTF8_STRING", False);
    Atom wm_name = XInternAtom(d, "_NET_WM_NAME", False);
    XChangeProperty(d, ROOT_WIN, check, XA_WINDOW, 32, PropModeReplace, (unsigned char *)&wm, 1);
    XChangeProperty(d, wm, check, XA_WINDOW, 32, PropModeReplace, (unsigned char *)&wm, 1);
    XChangeProperty(d, wm, wm_name, utf8, 8, PropModeReplace, (unsigned char *)"xstub", 5);
    static const char *sup[] = { "_NET_SUPPORTED", "_NET_SUPPORTING_WM_CHECK", "_NET_WM_NAME", "_NET_WM_STATE", "_NET_WM_STATE_FULLSCREEN",
        "_NET_WM_STATE_ABOVE", "_NET_ACTIVE_WINDOW", "_NET_WM_WINDOW_TYPE", "_NET_WM_WINDOW_TYPE_NORMAL", "_NET_WM_ALLOWED_ACTIONS",
        "_NET_WM_ACTION_FULLSCREEN", "_NET_WM_ACTION_CLOSE", "_NET_CLOSE_WINDOW", "_NET_WM_PID", "_NET_CLIENT_LIST", "_NET_NUMBER_OF_DESKTOPS", "_NET_CURRENT_DESKTOP" };
    Atom supa[17];
    for (int i = 0; i < 17; i++) supa[i] = XInternAtom(d, sup[i], False);
    XChangeProperty(d, ROOT_WIN, supa[0], XA_ATOM, 32, PropModeReplace, (unsigned char *)supa, 17);
    scan_keyboards();
    U(); return d;
}
int XCloseDisplay(Display *d) { return 0; }
int XFlush(Display *d) { return 0; }
int XBell(Display *d, int pct) { return 0; }
int XFree(void *p) { free(p); return 1; }
int XForceScreenSaver(Display *d, int m) { return 0; }
XErrorHandler XSetErrorHandler(XErrorHandler h) { return NULL; }
int XGetErrorText(Display *d, int code, char *buf, int len) { snprintf(buf, len, "xstub error %d", code); return 0; }
XVisualInfo *XGetVisualInfo(Display *d, long mask, XVisualInfo *tpl, int *n)
{
    XVisualInfo *v = calloc(1, sizeof *v);
    v->visual = &the_visual; v->visualid = the_visual.visualid; v->depth = 24; v->class = TrueColor;
    v->red_mask = 0xff0000; v->green_mask = 0xff00; v->blue_mask = 0xff; v->colormap_size = 256; v->bits_per_rgb = 8;
    *n = 1; return v;
}

/* ---------------------------------------------------------------- events */
Status XSendEvent(Display *d, Window w, Bool prop, long mask, XEvent *ev)
{
    L();
    if (ev->type != ClientMessage) {
        if (find_win(w)) { XEvent e = *ev; e.xany.send_event = True; e.xany.display = the_dpy; push(&e); }
    } else if (is_atom(ev->xclient.message_type, "_NET_ACTIVE_WINDOW")) {
        XSetInputFocus(d, ev->xclient.window, RevertToParent, CurrentTime);
    } else if (is_atom(ev->xclient.message_type, "_NET_WM_STATE")) {
        /* add (1) / remove (0) / toggle (2) up to two states: update the state property, and the size as a WM would */
        win_t *r = find_win(ev->xclient.window);
        Atom state = XInternAtom(d, "_NET_WM_STATE", False), fs = XInternAtom(d, "_NET_WM_STATE_FULLSCREEN", False);
        for (int k = 1; k <= 2 && r; k++) {
            Atom a = ev->xclient.data.l[k], cur[16];
            if (!a) continue;
            prop_t *p = find_prop(r->id, state);
            int n = p ? (p->n > 16 ? 16 : (int)p->n) : 0, has = 0, m = 0;
            if (n) memcpy(cur, p->data, n * sizeof(Atom));
            for (int i = 0; i < n; i++) has |= cur[i] == a;
            int want = ev->xclient.data.l[0] == 1 || (ev->xclient.data.l[0] != 0 && !has);
            if (want && !has && n < 16) cur[n++] = a;
            if (!want) { for (int i = 0; i < n; i++) if (cur[i] != a) cur[m++] = cur[i]; n = m; }
            XChangeProperty(d, r->id, state, XA_ATOM, 32, PropModeReplace, (unsigned char *)cur, n);
            if (a == fs && want && (r->w != scr_w || r->h != scr_h || r->x || r->y)) { r->x = r->y = 0; r->w = scr_w; r->h = scr_h; configured(r); }
        }
    }
    U(); return 1;
}
int XPending(Display *d) { L(); read_keyboards(); int n = qlen; U(); return n; }
int XEventsQueued(Display *d, int mode) { L(); if (mode != QueuedAlready) read_keyboards(); int n = qlen; U(); return n; }
int XNextEvent(Display *d, XEvent *ev) { L(); read_keyboards(); while (!take(ev, NULL, NULL)) { U(); wait_event(); L(); } U(); return 0; }
static const long type_masks[LASTEvent] = { [KeyPress] = KeyPressMask, [KeyRelease] = KeyReleaseMask, [ButtonPress] = ButtonPressMask,
    [ButtonRelease] = ButtonReleaseMask, [MotionNotify] = PointerMotionMask, [EnterNotify] = EnterWindowMask, [LeaveNotify] = LeaveWindowMask,
    [FocusIn] = FocusChangeMask, [FocusOut] = FocusChangeMask, [Expose] = ExposureMask, [VisibilityNotify] = VisibilityChangeMask,
    [DestroyNotify] = StructureNotifyMask, [UnmapNotify] = StructureNotifyMask, [MapNotify] = StructureNotifyMask,
    [ReparentNotify] = StructureNotifyMask, [ConfigureNotify] = StructureNotifyMask, [PropertyNotify] = PropertyChangeMask };
struct match { Window w; int type; long mask; };
static int m_type(XEvent *e, void *a) { struct match *m = a; return e->xany.window == m->w && e->type == m->type; }
static int m_mask(XEvent *e, void *a) { struct match *m = a; return e->xany.window == m->w && e->type < LASTEvent && (type_masks[e->type] & m->mask); }
Bool XCheckTypedWindowEvent(Display *d, Window w, int type, XEvent *ev) { struct match m = { w, type, 0 }; L(); read_keyboards(); int r = take(ev, m_type, &m); U(); return r; }
Bool XCheckWindowEvent(Display *d, Window w, long mask, XEvent *ev) { struct match m = { w, 0, mask }; L(); read_keyboards(); int r = take(ev, m_mask, &m); U(); return r; }

/* ---------------------------------------------------------------- pointer, cursors, pixmaps, images, fonts (none shown) */
int XGrabPointer(Display *d, Window w, Bool oe, unsigned mask, int pm, int km, Window conf, Cursor c, Time t) { return GrabSuccess; }
int XUngrabPointer(Display *d, Time t) { return 0; }
int XWarpPointer(Display *d, Window src, Window dst, int sx, int sy, unsigned sw, unsigned sh, int dx, int dy) { return 0; }
Bool XQueryPointer(Display *d, Window w, Window *root, Window *child, int *rx, int *ry, int *wx, int *wy, unsigned *mask)
{
    *root = ROOT_WIN; *child = None; *rx = *ry = *wx = *wy = 0; *mask = modstate; return True;
}
Cursor XCreateFontCursor(Display *d, unsigned shape) { return next_id++; }
Cursor XCreatePixmapCursor(Display *d, Pixmap src, Pixmap mask, XColor *fg, XColor *bg, unsigned x, unsigned y) { return next_id++; }
int XFreeCursor(Display *d, Cursor c) { return 0; }
int XDefineCursor(Display *d, Window w, Cursor c) { return 0; }
int XUndefineCursor(Display *d, Window w) { return 0; }
Pixmap XCreatePixmap(Display *d, Drawable dr, unsigned w, unsigned h, unsigned depth) { return next_id++; }
Pixmap XCreateBitmapFromData(Display *d, Drawable dr, const char *data, unsigned w, unsigned h) { return next_id++; }
int XFreePixmap(Display *d, Pixmap p) { return 0; }
GC XCreateGC(Display *d, Drawable dr, unsigned long mask, XGCValues *v) { GC g = calloc(1, sizeof(struct _XGC)); g->gid = next_id++; return g; }
int XPutImage(Display *d, Drawable dr, GC g, XImage *i, int sx, int sy, int dx, int dy, unsigned w, unsigned h) { return 0; }
/* XImage: the player fills it through the XPutPixel/XDestroyImage macros (box64 bridges these function pointers) */
static unsigned char *img_row(XImage *i, int x, int y) { return i->data && x >= 0 && y >= 0 && x < i->width && y < i->height ? (unsigned char *)i->data + y * i->bytes_per_line : NULL; }
static unsigned long img_get(XImage *i, int x, int y)
{
    unsigned char *p = img_row(i, x, y);
    return !p ? 0 : i->bits_per_pixel == 32 ? ((unsigned *)p)[x] : i->bits_per_pixel == 16 ? ((unsigned short *)p)[x] :
           i->bits_per_pixel == 8 ? p[x] : (p[x / 8] >> (x % 8)) & 1;
}
static int img_put(XImage *i, int x, int y, unsigned long v)
{
    unsigned char *p = img_row(i, x, y);
    if (!p) return 0;
    if (i->bits_per_pixel == 32) ((unsigned *)p)[x] = v;
    else if (i->bits_per_pixel == 16) ((unsigned short *)p)[x] = v;
    else if (i->bits_per_pixel == 8) p[x] = v;
    else if (v) p[x / 8] |= 1 << (x % 8); else p[x / 8] &= ~(1 << (x % 8));
    return 0;
}
static int img_destroy(XImage *i) { free(i->data); free(i); return 1; }
static XImage *img_sub(XImage *i, int x, int y, unsigned w, unsigned h) { return NULL; }
static int img_add(XImage *i, long v) { return 0; }
XImage *XCreateImage(Display *d, Visual *v, unsigned depth, int fmt, int off, char *data, unsigned w, unsigned h, int pad, int bpl)
{
    XImage *i = calloc(1, sizeof *i);
    i->width = w; i->height = h; i->xoffset = off; i->format = fmt; i->data = data; i->byte_order = LSBFirst;
    i->bitmap_unit = 32; i->bitmap_bit_order = LSBFirst; i->bitmap_pad = pad ? pad : 32; i->depth = depth;
    i->bits_per_pixel = depth == 1 ? 1 : depth <= 8 ? 8 : depth <= 16 ? 16 : 32;
    i->bytes_per_line = bpl ? bpl : (int)((w * i->bits_per_pixel + i->bitmap_pad - 1) / i->bitmap_pad * (i->bitmap_pad / 8));
    if (depth >= 24) { i->red_mask = 0xff0000; i->green_mask = 0xff00; i->blue_mask = 0xff; }
    i->f.create_image = XCreateImage; i->f.destroy_image = img_destroy; i->f.get_pixel = img_get; i->f.put_pixel = img_put;
    i->f.sub_image = img_sub; i->f.add_pixel = img_add;
    return i;
}
char **XListFonts(Display *d, const char *pat, int max, int *n) { *n = 0; return NULL; }
int XFreeFontNames(char **l) { return 1; }
char **XGetFontPath(Display *d, int *n) { *n = 0; return NULL; }
int XFreeFontPath(char **l) { return 1; }

/* box64's libX11 wrapper dereferences these at load time */
static void noop_lock(LockInfoPtr l) { }
void (*_XLockMutex_fn)(LockInfoPtr) = noop_lock;
void (*_XUnlockMutex_fn)(LockInfoPtr) = noop_lock;
