/* Keep the binary at GLIBC_2.34: bind hypot to its pre-2.35 symbol version. */
__asm__(".symver hypot_glibc217, hypot@GLIBC_2.17");
double hypot_glibc217(double x, double y);
double __wrap_hypot(double x, double y) { return hypot_glibc217(x, y); }
