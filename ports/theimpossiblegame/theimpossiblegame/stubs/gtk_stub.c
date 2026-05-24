/*
 * gtk_stub.c — Minimal GTK stub for The Impossible Game
 *
 * The game binary links against libgtk-x11-2.0.so.0 but this stub is only
 * needed for the binary to load and start execution. It does not appear to
 * actually call any GTK functions at runtime.
 *
 * Build (x86 32-bit):
 *   gcc -m32 -shared -fPIC -o libgtk-x11-2.0.so.0 gtk_stub.c
 */
