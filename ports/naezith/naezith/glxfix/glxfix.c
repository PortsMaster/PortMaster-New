/* glxfix: x86_64 preload for Remnants of Naezith under box64 + Westonpack crusty_glx.
 *
 * SFML 2.5 picks its window visual with glXGetConfig(GLX_DOUBLEBUFFER) on every X visual, but
 * crusty's glXGetConfig returns its answer instead of writing it to *value, so SFML (whose
 * variable is uninitialized) skips every visual and calls XCreateColormap with a NULL visual.
 * The X server rejects visual id 0 with BadMatch and the game exits. SFML loads the glX functions
 * with dlsym, so they cannot be replaced from here; instead XCreateColormap gets the screen's
 * default visual whenever it is handed none. The window itself is created with CopyFromParent
 * (also valid), and crusty draws the GL output regardless of the visual. MIT license. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stddef.h>

typedef struct _XDisplay Display;
typedef struct Visual Visual;
typedef unsigned long XID;

extern Visual *XDefaultVisual(Display *dpy, int screen);
extern int XDefaultScreen(Display *dpy);

XID XCreateColormap(Display *dpy, XID window, Visual *visual, int alloc) {
    static XID (*real)(Display *, XID, Visual *, int);
    if (!real) real = (XID (*)(Display *, XID, Visual *, int))dlsym(RTLD_NEXT, "XCreateColormap");
    if (!visual) visual = XDefaultVisual(dpy, XDefaultScreen(dpy));
    return real(dpy, window, visual, alloc);
}
