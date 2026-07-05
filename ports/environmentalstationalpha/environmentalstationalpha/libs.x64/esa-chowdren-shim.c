/*
 * esa-chowdren-shim.c
 *
 * Environmental Station Alpha's Linux Chowdren build can fail to present a
 * usable window under Sway/Xwayland, and by default it tries to store save and
 * config data under ~/MMFApplications instead of beside the packaged game.
 *
 * This preload shim addresses those two runtime issues:
 * - it nudges the real top-level X11 window through the startup focus path ESA
 *   seems to require under Xwayland
 * - it remaps MMFApplications file activity into ./savedata beside the invoked
 *   Chowdren binary
 *
 * SPDX-License-Identifier: MIT
 */

#define _GNU_SOURCE

#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <dirent.h>
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <pthread.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static int (*real_access_fn)(const char *pathname, int mode);
static size_t (*real_fwrite_fn)(const void *ptr, size_t size, size_t nmemb, FILE *stream);
static FILE *(*real_fopen_fn)(const char *pathname, const char *mode);
static FILE *(*real_fopen64_fn)(const char *pathname, const char *mode);
static FILE *(*real_freopen_fn)(const char *pathname, const char *mode, FILE *stream);
static int (*real_mkdir_fn)(const char *pathname, mode_t mode);
static int (*real_open_fn)(const char *pathname, int flags, ...);
static DIR *(*real_opendir_fn)(const char *name);
static int (*real___xstat_fn)(int version, const char *path, struct stat *buffer);
static int (*real_remove_fn)(const char *pathname);
static int (*real_rmdir_fn)(const char *pathname);
static int (*real_scandir_fn)(
    const char *dirp,
    struct dirent ***namelist,
    int (*filter)(const struct dirent *),
    int (*compar)(const struct dirent **, const struct dirent **));
static Status (*real_XGetWindowAttributes)(
    Display *display,
    Window window,
    XWindowAttributes *window_attributes_return);
static Status (*real_XQueryTree)(
    Display *display,
    Window window,
    Window *root_return,
    Window *parent_return,
    Window **children_return,
    unsigned int *nchildren_return);
static Status (*real_XSendEvent)(
    Display *display,
    Window window,
    Bool propagate,
    long event_mask,
    XEvent *event_send);
static int (*real_XFlush)(Display *display);
static int (*real_XInstallColormap)(Display *display, Colormap colormap);
static int (*real_XSetTransientForHint)(Display *display, Window window, Window prop_window);
static Window (*real_XCreateWindow)(
    Display *display,
    Window parent,
    int x,
    int y,
    unsigned int width,
    unsigned int height,
    unsigned int border_width,
    int depth,
    unsigned int class,
    Visual *visual,
    unsigned long valuemask,
    XSetWindowAttributes *attributes);
static int (*real_XRaiseWindow)(Display *display, Window window);
static void *(*real_dlsym_fn)(void *handle, const char *symbol);

static pthread_mutex_t state_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t savedata_log_lock = PTHREAD_MUTEX_INITIALIZER;
static Display *tracked_display;
static Window tracked_window;
static Colormap tracked_colormap;
static bool focus_thread_started;
static pthread_once_t savedata_path_once = PTHREAD_ONCE_INIT;
static char savedata_root[PATH_MAX];

/* The primary shim surface is intentionally tiny: one focus fix and one
 * savedata remap, each controlled by an env var. */
static bool shim_focus_fix_enabled(void)
{
    const char *value = getenv("ESA_SHIM_FOCUS");
    return value != NULL && value[0] != '\0' && strcmp(value, "0") != 0;
}

static bool shim_savedata_enabled(void)
{
    const char *value = getenv("ESA_SHIM_SAVEDATA");
    return value != NULL && value[0] != '\0' && strcmp(value, "0") != 0;
}

static int ensure_directory_recursive(const char *path);
static int ensure_parent_directory(const char *path);
static const char *maybe_remap_savedata_path(const char *path, char *buffer, size_t buffer_size);
static void maybe_log_savedata_destination(const char *remapped_path);

Window XCreateWindow(
    Display *display,
    Window parent,
    int x,
    int y,
    unsigned int width,
    unsigned int height,
    unsigned int border_width,
    int depth,
    unsigned int class,
    Visual *visual,
    unsigned long valuemask,
    XSetWindowAttributes *attributes);

static void load_base_symbols(void)
{
    /* Resolve the underlying libc/libX11 entry points lazily so the shim can
     * forward calls without recursing back into its own interposed symbols. */
    if (real_dlsym_fn == NULL) {
        real_dlsym_fn = dlvsym(RTLD_NEXT, "dlsym", "GLIBC_2.2.5");
    }
    if (real_access_fn == NULL) {
        real_access_fn = real_dlsym_fn(RTLD_NEXT, "access");
    }
    if (real_fwrite_fn == NULL) {
        real_fwrite_fn = real_dlsym_fn(RTLD_NEXT, "fwrite");
    }
    if (real_fopen_fn == NULL) {
        real_fopen_fn = real_dlsym_fn(RTLD_NEXT, "fopen");
    }
    if (real_fopen64_fn == NULL) {
        real_fopen64_fn = real_dlsym_fn(RTLD_NEXT, "fopen64");
    }
    if (real_freopen_fn == NULL) {
        real_freopen_fn = real_dlsym_fn(RTLD_NEXT, "freopen");
    }
    if (real_mkdir_fn == NULL) {
        real_mkdir_fn = real_dlsym_fn(RTLD_NEXT, "mkdir");
    }
    if (real_open_fn == NULL) {
        real_open_fn = real_dlsym_fn(RTLD_NEXT, "open");
    }
    if (real_opendir_fn == NULL) {
        real_opendir_fn = real_dlsym_fn(RTLD_NEXT, "opendir");
    }
    if (real___xstat_fn == NULL) {
        real___xstat_fn = real_dlsym_fn(RTLD_NEXT, "__xstat");
    }
    if (real_remove_fn == NULL) {
        real_remove_fn = real_dlsym_fn(RTLD_NEXT, "remove");
    }
    if (real_rmdir_fn == NULL) {
        real_rmdir_fn = real_dlsym_fn(RTLD_NEXT, "rmdir");
    }
    if (real_scandir_fn == NULL) {
        real_scandir_fn = real_dlsym_fn(RTLD_NEXT, "scandir");
    }
}

static void load_focus_symbols(void)
{
    load_base_symbols();

    if (real_XGetWindowAttributes == NULL) {
        real_XGetWindowAttributes = real_dlsym_fn(RTLD_NEXT, "XGetWindowAttributes");
    }
    if (real_XQueryTree == NULL) {
        real_XQueryTree = real_dlsym_fn(RTLD_NEXT, "XQueryTree");
    }
    if (real_XSendEvent == NULL) {
        real_XSendEvent = real_dlsym_fn(RTLD_NEXT, "XSendEvent");
    }
    if (real_XFlush == NULL) {
        real_XFlush = real_dlsym_fn(RTLD_NEXT, "XFlush");
    }
    if (real_XInstallColormap == NULL) {
        real_XInstallColormap = real_dlsym_fn(RTLD_NEXT, "XInstallColormap");
    }
    if (real_XSetTransientForHint == NULL) {
        real_XSetTransientForHint = real_dlsym_fn(RTLD_NEXT, "XSetTransientForHint");
    }
    if (real_XCreateWindow == NULL) {
        real_XCreateWindow = real_dlsym_fn(RTLD_NEXT, "XCreateWindow");
    }
    if (real_XRaiseWindow == NULL) {
        real_XRaiseWindow = real_dlsym_fn(RTLD_NEXT, "XRaiseWindow");
    }
}

static bool resolve_invoked_binary_dir(char *buffer, size_t buffer_size)
{
    char cmdline[4096];
    ssize_t bytes_read = -1;

    /* Prefer /proc/self/cmdline so the savedata root follows the launched
     * Chowdren path even when argv[0] was rewritten by a launcher script. */
    if (real_open_fn != NULL) {
        int fd = real_open_fn("/proc/self/cmdline", O_RDONLY);
        if (fd >= 0) {
            bytes_read = read(fd, cmdline, sizeof(cmdline) - 1);
            close(fd);
        }
    }

    if (bytes_read > 0) {
        cmdline[bytes_read] = '\0';

        const char *argv0 = NULL;
        const char *candidate = NULL;
        size_t index = 0;

        while (index < (size_t)bytes_read) {
            const char *argument = &cmdline[index];
            size_t length = strlen(argument);
            if (length == 0) {
                break;
            }

            if (argv0 == NULL) {
                argv0 = argument;
            } else if (candidate == NULL && real_access_fn(argument, F_OK) == 0) {
                candidate = argument;
                break;
            }

            index += length + 1;
        }

        if (candidate == NULL) {
            candidate = argv0;
        }

        if (candidate != NULL && candidate[0] != '\0') {
            char resolved[PATH_MAX];
            const char *chosen = realpath(candidate, resolved);
            if (chosen == NULL) {
                chosen = candidate;
            }

            const char *slash = strrchr(chosen, '/');
            if (slash != NULL) {
                size_t directory_length = (size_t)(slash - chosen);
                if (directory_length == 0) {
                    directory_length = 1;
                }
                if (directory_length < buffer_size) {
                    memcpy(buffer, chosen, directory_length);
                    buffer[directory_length] = '\0';
                    return true;
                }
            }
        }
    }

    char executable_path[PATH_MAX];
    ssize_t executable_length = readlink("/proc/self/exe", executable_path, sizeof(executable_path) - 1);
    if (executable_length <= 0) {
        return false;
    }

    executable_path[executable_length] = '\0';
    char *slash = strrchr(executable_path, '/');
    if (slash == NULL) {
        return false;
    }
    if (slash == executable_path) {
        slash[1] = '\0';
    } else {
        *slash = '\0';
    }

    if (snprintf(buffer, buffer_size, "%s", executable_path) >= (int)buffer_size) {
        return false;
    }

    return true;
}

static void initialize_savedata_root(void)
{
    savedata_root[0] = '\0';

    if (!shim_savedata_enabled()) {
        return;
    }

    char executable_dir[PATH_MAX];
    if (!resolve_invoked_binary_dir(executable_dir, sizeof(executable_dir))) {
        fprintf(stderr, "[esa-chowdren-shim] could not resolve executable directory for savedata remap\n");
        return;
    }

    if (snprintf(savedata_root, sizeof(savedata_root), "%s/savedata", executable_dir)
        >= (int)sizeof(savedata_root)) {
        savedata_root[0] = '\0';
        fprintf(stderr, "[esa-chowdren-shim] savedata path was too long\n");
        return;
    }

    if (ensure_directory_recursive(savedata_root) != 0 && errno != EEXIST) {
        fprintf(
            stderr,
            "[esa-chowdren-shim] could not create %s: %s\n",
            savedata_root,
            strerror(errno));
        savedata_root[0] = '\0';
        return;
    }
}

static const char *savedata_root_path(void)
{
    pthread_once(&savedata_path_once, initialize_savedata_root);
    return savedata_root[0] != '\0' ? savedata_root : NULL;
}

static const char *find_mmf_suffix(const char *path)
{
    static const char needle[] = "MMFApplications";
    const size_t needle_length = sizeof(needle) - 1;

    if (path == NULL) {
        return NULL;
    }

    const char *match = path;
    while ((match = strstr(match, needle)) != NULL) {
        bool start_ok = (match == path) || match[-1] == '/' || match[-1] == '\\';
        char after = match[needle_length];
        bool end_ok = after == '\0' || after == '/' || after == '\\';
        if (start_ok && end_ok) {
            return match + needle_length;
        }
        match += needle_length;
    }

    return NULL;
}

static const char *maybe_remap_savedata_path(const char *path, char *buffer, size_t buffer_size)
{
    const char *root = savedata_root_path();
    const char *suffix = find_mmf_suffix(path);

    /* Only MMFApplications paths are rewritten; everything else is passed
     * through unchanged. */
    if (root == NULL || suffix == NULL) {
        return path;
    }

    size_t offset = 0;
    int written = snprintf(buffer, buffer_size, "%s", root);
    if (written < 0 || (size_t)written >= buffer_size) {
        errno = ENAMETOOLONG;
        return NULL;
    }
    offset = (size_t)written;

    if (*suffix != '\0' && offset < buffer_size && suffix[0] != '/' && suffix[0] != '\\') {
        buffer[offset++] = '/';
    }

    while (*suffix != '\0' && offset + 1 < buffer_size) {
        buffer[offset++] = *suffix == '\\' ? '/' : *suffix;
        ++suffix;
    }

    if (*suffix != '\0') {
        errno = ENAMETOOLONG;
        return NULL;
    }

    buffer[offset] = '\0';
    maybe_log_savedata_destination(buffer);
    return buffer;
}

static void maybe_log_savedata_destination(const char *remapped_path)
{
    if (remapped_path == NULL || remapped_path[0] == '\0') {
        return;
    }

    char line[PATH_MAX + 64];
    int line_length = snprintf(
        line,
        sizeof(line),
        "[esa-chowdren-shim] savedata remap: %s\n",
        remapped_path);
    if (line_length <= 0) {
        return;
    }

    size_t bytes_to_write = (size_t)line_length;
    if (bytes_to_write >= sizeof(line)) {
        bytes_to_write = sizeof(line) - 1;
    }

    /* The game writes logs from multiple contexts, so serialize shim-authored
     * remap lines to keep them readable. */
    pthread_mutex_lock(&savedata_log_lock);
    if (real_fwrite_fn != NULL) {
        real_fwrite_fn(line, 1, bytes_to_write, stdout);
    }
    pthread_mutex_unlock(&savedata_log_lock);
}

static bool mode_writes_file(const char *mode)
{
    return mode != NULL && strpbrk(mode, "wax+") != NULL;
}

static int ensure_directory_recursive(const char *path)
{
    if (path == NULL || path[0] == '\0') {
        return 0;
    }

    char buffer[PATH_MAX];
    if (snprintf(buffer, sizeof(buffer), "%s", path) >= (int)sizeof(buffer)) {
        errno = ENAMETOOLONG;
        return -1;
    }

    for (char *cursor = buffer + 1; *cursor != '\0'; ++cursor) {
        if (*cursor != '/') {
            continue;
        }

        *cursor = '\0';
        if (buffer[0] != '\0' && real_mkdir_fn(buffer, 0777) != 0 && errno != EEXIST) {
            return -1;
        }
        *cursor = '/';
    }

    if (real_mkdir_fn(buffer, 0777) != 0 && errno != EEXIST) {
        return -1;
    }

    return 0;
}

static int ensure_parent_directory(const char *path)
{
    if (path == NULL) {
        errno = EINVAL;
        return -1;
    }

    char buffer[PATH_MAX];
    if (snprintf(buffer, sizeof(buffer), "%s", path) >= (int)sizeof(buffer)) {
        errno = ENAMETOOLONG;
        return -1;
    }

    char *slash = strrchr(buffer, '/');
    if (slash == NULL) {
        return 0;
    }
    if (slash == buffer) {
        return 0;
    }

    *slash = '\0';
    return ensure_directory_recursive(buffer);
}

static bool is_toplevel_window(Display *display, Window window)
{
    Window root = 0;
    Window parent = 0;
    Window *children = NULL;
    unsigned int child_count = 0;
    bool is_toplevel = false;

    if (real_XQueryTree(display, window, &root, &parent, &children, &child_count) != 0) {
        is_toplevel = (parent == root);
    }

    if (children != NULL) {
        XFree(children);
    }

    return is_toplevel;
}

static void send_net_active_window(Display *display, Window window)
{
    /* Ask the window manager to treat ESA's real Xwayland window as the active
     * toplevel instead of leaving it stuck in a half-created state. */
    Atom net_active_window = XInternAtom(display, "_NET_ACTIVE_WINDOW", False);

    if (net_active_window == None) {
        return;
    }

    XEvent event;
    memset(&event, 0, sizeof(event));
    event.xclient.type = ClientMessage;
    event.xclient.serial = 0;
    event.xclient.send_event = True;
    event.xclient.display = display;
    event.xclient.window = window;
    event.xclient.message_type = net_active_window;
    event.xclient.format = 32;
    event.xclient.data.l[0] = 1;
    event.xclient.data.l[1] = CurrentTime;
    event.xclient.data.l[2] = 0;
    event.xclient.data.l[3] = 0;
    event.xclient.data.l[4] = 0;

    real_XSendEvent(
        display,
        DefaultRootWindow(display),
        False,
        SubstructureRedirectMask | SubstructureNotifyMask,
        &event);
}

static void send_visibility_events(Display *display, Window window)
{
    XEvent expose_event;
    memset(&expose_event, 0, sizeof(expose_event));
    expose_event.xexpose.type = Expose;
    expose_event.xexpose.display = display;
    expose_event.xexpose.window = window;
    expose_event.xexpose.x = 0;
    expose_event.xexpose.y = 0;
    expose_event.xexpose.width = 160;
    expose_event.xexpose.height = 128;
    expose_event.xexpose.count = 0;
    real_XSendEvent(display, window, False, ExposureMask, &expose_event);

    XEvent visibility_event;
    memset(&visibility_event, 0, sizeof(visibility_event));
    visibility_event.xvisibility.type = VisibilityNotify;
    visibility_event.xvisibility.display = display;
    visibility_event.xvisibility.window = window;
    visibility_event.xvisibility.state = VisibilityUnobscured;
    real_XSendEvent(display, window, False, VisibilityChangeMask, &visibility_event);
}

static void send_focus_event(Display *display, Window window)
{
    XEvent focus_event;
    memset(&focus_event, 0, sizeof(focus_event));
    focus_event.xfocus.type = FocusIn;
    focus_event.xfocus.display = display;
    focus_event.xfocus.window = window;
    focus_event.xfocus.mode = NotifyNormal;
    focus_event.xfocus.detail = NotifyNonlinear;
    real_XSendEvent(display, window, False, FocusChangeMask, &focus_event);
}

static void *focus_window_thread(void *unused)
{
    (void)unused;

    pthread_mutex_lock(&state_lock);
    Display *display = tracked_display;
    Window window = tracked_window;
    pthread_mutex_unlock(&state_lock);

    if (display == NULL || window == 0) {
        return NULL;
    }

    /* ESA often needs repeated nudges during its first few seconds under
     * Xwayland before it starts drawing reliably. */
    for (int i = 0; i < 120; ++i) {
        XLockDisplay(display);
        if (tracked_colormap != 0) {
            real_XInstallColormap(display, tracked_colormap);
        }
        real_XSetTransientForHint(display, window, DefaultRootWindow(display));
        real_XRaiseWindow(display, window);
        send_net_active_window(display, window);
        send_visibility_events(display, window);
        send_focus_event(display, window);
        real_XFlush(display);
        XUnlockDisplay(display);
        usleep(50 * 1000);
    }

    return NULL;
}

static void maybe_track_window(Display *display, Window window)
{
    XWindowAttributes attributes;

    if (!shim_focus_fix_enabled() || display == NULL || window == 0) {
        return;
    }

    XLockDisplay(display);
    bool ok = real_XGetWindowAttributes(display, window, &attributes) != 0;
    bool toplevel = ok && is_toplevel_window(display, window);
    XUnlockDisplay(display);

    /* Ignore helper/pop-up windows and wait for the real top-level game
     * window before starting the focus thread. */
    if (!ok || !toplevel || attributes.override_redirect || attributes.class != InputOutput) {
        return;
    }

    if (attributes.width < 64 || attributes.height < 64) {
        return;
    }

    pthread_mutex_lock(&state_lock);

    if (tracked_window == 0) {
        tracked_display = display;
        tracked_window = window;
        tracked_colormap = attributes.colormap;
    }

    if (!focus_thread_started && tracked_window == window) {
        pthread_t thread;
        focus_thread_started = true;
        if (pthread_create(&thread, NULL, focus_window_thread, NULL) == 0) {
            pthread_detach(thread);
        } else {
            focus_thread_started = false;
        }
    }

    pthread_mutex_unlock(&state_lock);
}

__attribute__((constructor)) static void initialize_chowdren_shim(void)
{
    if (shim_focus_fix_enabled()) {
        load_focus_symbols();
        XInitThreads();
    }
    fprintf(
        stderr,
        "[esa-chowdren-shim] initialized (focus=%d savedata=%d)\n",
        shim_focus_fix_enabled() ? 1 : 0,
        shim_savedata_enabled() ? 1 : 0);
}

void *dlsym(void *handle, const char *symbol)
{
    if (real_dlsym_fn == NULL) {
        real_dlsym_fn = dlvsym(RTLD_NEXT, "dlsym", "GLIBC_2.2.5");
    }
    load_base_symbols();

    /* Chowdren resolves XCreateWindow dynamically, so the focus fix has to
     * interpose dlsym as well as the symbol itself. */
    if (strcmp(symbol, "XCreateWindow") == 0) {
        return shim_focus_fix_enabled() ? (void *)XCreateWindow : real_dlsym_fn(handle, symbol);
    }
    return real_dlsym_fn(handle, symbol);
}

int access(const char *pathname, int mode)
{
    load_base_symbols();

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(pathname, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return -1;
    }

    return real_access_fn(target, mode);
}

FILE *fopen(const char *pathname, const char *mode)
{
    load_base_symbols();

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(pathname, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return NULL;
    }

    if (target != pathname && mode_writes_file(mode) && ensure_parent_directory(target) != 0) {
        return NULL;
    }

    return real_fopen_fn(target, mode);
}

FILE *fopen64(const char *pathname, const char *mode)
{
    load_base_symbols();

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(pathname, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return NULL;
    }

    if (target != pathname && mode_writes_file(mode) && ensure_parent_directory(target) != 0) {
        return NULL;
    }

    return real_fopen64_fn(target, mode);
}

FILE *freopen(const char *pathname, const char *mode, FILE *stream)
{
    load_base_symbols();

    if (pathname == NULL) {
        return real_freopen_fn(pathname, mode, stream);
    }

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(pathname, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return NULL;
    }

    if (target != pathname && mode_writes_file(mode) && ensure_parent_directory(target) != 0) {
        return NULL;
    }

    return real_freopen_fn(target, mode, stream);
}

int mkdir(const char *pathname, mode_t mode)
{
    load_base_symbols();

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(pathname, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return -1;
    }

    if (target != pathname && ensure_parent_directory(target) != 0) {
        return -1;
    }

    return real_mkdir_fn(target, mode);
}

int open(const char *pathname, int flags, ...)
{
    load_base_symbols();

    mode_t mode = 0;
    bool has_mode = (flags & O_CREAT) != 0;

    va_list args;
    va_start(args, flags);
    if (has_mode) {
        mode = (mode_t)va_arg(args, int);
    }
    va_end(args);

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(pathname, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return -1;
    }

    if (target != pathname
        && (flags & (O_CREAT | O_WRONLY | O_RDWR | O_APPEND | O_TRUNC)) != 0
        && ensure_parent_directory(target) != 0) {
        return -1;
    }

    if (has_mode) {
        return real_open_fn(target, flags, mode);
    }
    return real_open_fn(target, flags);
}

DIR *opendir(const char *name)
{
    load_base_symbols();

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(name, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return NULL;
    }

    return real_opendir_fn(target);
}

int __xstat(int version, const char *path, struct stat *buffer)
{
    load_base_symbols();

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(path, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return -1;
    }

    return real___xstat_fn(version, target, buffer);
}

int remove(const char *pathname)
{
    load_base_symbols();

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(pathname, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return -1;
    }

    return real_remove_fn(target);
}

int rmdir(const char *pathname)
{
    load_base_symbols();

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(pathname, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return -1;
    }

    return real_rmdir_fn(target);
}

int scandir(
    const char *dirp,
    struct dirent ***namelist,
    int (*filter)(const struct dirent *),
    int (*compar)(const struct dirent **, const struct dirent **))
{
    load_base_symbols();

    char rewritten_path[PATH_MAX];
    const char *target = maybe_remap_savedata_path(dirp, rewritten_path, sizeof(rewritten_path));
    if (target == NULL) {
        return -1;
    }

    return real_scandir_fn(target, namelist, filter, compar);
}

Window XCreateWindow(
    Display *display,
    Window parent,
    int x,
    int y,
    unsigned int width,
    unsigned int height,
    unsigned int border_width,
    int depth,
    unsigned int class,
    Visual *visual,
    unsigned long valuemask,
    XSetWindowAttributes *attributes)
{
    load_focus_symbols();

    /* Track the actual game toplevel as it is created, then let the background
     * focus thread drive the startup workaround. */
    Window window = real_XCreateWindow(
        display,
        parent,
        x,
        y,
        width,
        height,
        border_width,
        depth,
        class,
        visual,
        valuemask,
        attributes);

    if (!shim_focus_fix_enabled()) {
        return window;
    }

    if (parent == DefaultRootWindow(display) && class == InputOutput) {
        maybe_track_window(display, window);
    }

    return window;
}
