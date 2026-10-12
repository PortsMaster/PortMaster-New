/* Bind hypot/hypotf to their pre-2.35 symbol versions so the build runs on glibc 2.34. */
#include <features.h>
#if defined(__aarch64__) && defined(__GLIBC__)
__asm__(".symver hypot,hypot@GLIBC_2.17");
__asm__(".symver hypotf,hypotf@GLIBC_2.17");
#endif
