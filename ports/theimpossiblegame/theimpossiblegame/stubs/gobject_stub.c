/*
 * gobject_stub.c — Minimal GObject stub for The Impossible Game
 *
 * The game binary links against libgobject-2.0.so.0 but does not appear
 * to call any GObject functions at runtime. It does not appear to
  * actually call any gobject functions at runtime.
 *
 * Build (x86 32-bit):
 *   gcc -m32 -shared -fPIC -o libgobject-2.0.so.0 gobject_stub.c
 */
