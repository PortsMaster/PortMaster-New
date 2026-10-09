/*
 * The other two libraries the player links, as stand-ins with only what it imports (build.sh builds this file as both
 * libXcursor.so.1 and libGLU.so.1): cursors made from images that are never shown, and GL error strings for its log.
 */
#include <X11/Xlib.h>
#include <X11/Xcursor/Xcursor.h>
#include <stdlib.h>

XcursorImage *XcursorImageCreate(int width, int height)
{
    XcursorImage *i = calloc(1, sizeof *i);
    i->version = XCURSOR_IMAGE_VERSION; i->size = width > height ? width : height; i->width = width; i->height = height;
    i->pixels = calloc((size_t)width * height, sizeof(XcursorPixel));
    return i;
}
XcursorCursors *XcursorCursorsCreate(Display *d, int n) { XcursorCursors *c = calloc(1, sizeof *c); c->dpy = d; c->cursors = calloc(n, sizeof(Cursor)); return c; }
void XcursorCursorsDestroy(XcursorCursors *c) { if (c) { free(c->cursors); free(c); } }
Cursor XcursorImageLoadCursor(Display *d, const XcursorImage *i) { static Cursor next = 0x600001; return next++; }

const unsigned char *gluErrorString(unsigned e)
{
    static const char *s[] = { "invalid enumerant", "invalid value", "invalid operation", "stack overflow", "stack underflow",
                               "out of memory", "invalid framebuffer operation" };
    return (const unsigned char *)(e == 0 ? "no error" : e >= 0x500 && e <= 0x506 ? s[e - 0x500] : "unknown error");
}
