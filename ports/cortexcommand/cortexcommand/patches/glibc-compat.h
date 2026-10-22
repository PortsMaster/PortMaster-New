/* Bind symbols to older versions so the build runs on glibc 2.34 / GCC 11 era libstdc++. */
#include <features.h>
#if defined(__aarch64__) && defined(__GLIBC__)
__asm__(".symver hypot,hypot@GLIBC_2.17");
__asm__(".symver hypotf,hypotf@GLIBC_2.17");
#ifdef __cplusplus
__asm__(".symver _ZNSt18condition_variable4waitERSt11unique_lockISt5mutexE,_ZNSt18condition_variable4waitERSt11unique_lockISt5mutexE@GLIBCXX_3.4.11");
#endif
#endif
