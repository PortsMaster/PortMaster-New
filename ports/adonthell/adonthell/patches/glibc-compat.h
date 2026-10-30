/* Bind hypot/hypotf to GLIBC_2.17 so libpython runs on glibc 2.34. No includes: feature macros must stay unset. */
#if defined(__aarch64__) && defined(__linux__)
__asm__(".symver hypot,hypot@GLIBC_2.17");
__asm__(".symver hypotf,hypotf@GLIBC_2.17");
#endif
