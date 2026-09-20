#ifndef Py_PYCONFIG_H
#define Py_PYCONFIG_H

/* Define if C doubles are 64-bit IEEE 754 binary format, stored with the most
   significant byte first */
#define DOUBLE_IS_BIG_ENDIAN_IEEE754

/* Define this if you have the type _Bool. */
#define HAVE_C99_BOOL 1

/* Define to 1 if you have the declaration of `isinf', and to 0 if you don't.
   */
#define HAVE_DECL_ISINF 1

/* Define to 1 if you have the declaration of `isnan', and to 0 if you don't.
   */
#define HAVE_DECL_ISNAN 1

/* Define if your compiler provides int32_t. */
#define HAVE_INT32_T

/* Define if your compiler provides int64_t. */
#define HAVE_INT64_T

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Defined to enable large file support when an off_t is bigger than a long
   and long long is available and at least as big as an off_t. You may need to
   add some flags for configuration and compilation to enable this mode. (For
   Solaris and Linux, the necessary defines are already defined.) */
#define HAVE_LARGEFILE_SUPPORT

/* Define this if you have the type long double. */
#define HAVE_LONG_DOUBLE

/* Define this if you have the type long long. */
#define HAVE_LONG_LONG

#define PY_FORMAT_LONG_LONG "ll"

/* Define to 1 if you have the `memmove' function. */
#define HAVE_MEMMOVE 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1


/* Define if your compiler supports function prototype */
#define HAVE_PROTOTYPES

/* Define if your compiler supports variable length function prototypes (e.g.
   void fprintf(FILE *, char *, ...);) *and* <stdarg.h> */
#define HAVE_STDARG_PROTOTYPES

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the `strdup' function. */
#define HAVE_STRDUP 1

/* Define to 1 if you have the `strftime' function. */
#define HAVE_STRFTIME 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define if your compiler provides uint32_t. */
#define HAVE_UINT32_T

/* Define if your compiler provides uint64_t. */
#define HAVE_UINT64_T

/* Define to 1 if the system has the type `uintptr_t'. */
#define HAVE_UINTPTR_T 1

/* Define if the compiler provides a wchar.h header file. */
#define HAVE_WCHAR_H

/* Define if you want to have a Unicode type. */
#define Py_USING_UNICODE
#define Py_UNICODE_SIZE 2
#define PY_UNICODE_TYPE wchar_t
#define HAVE_USABLE_WCHAR_T

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Define if you want to compile in Python-specific mallocs */
#define WITH_PYMALLOC

/* Define to activate features from IEEE Stds 1003.1-2001 */
#define _POSIX_C_SOURCE

#define VA_LIST_IS_ARRAY

#define SIZEOF_LONG 8
#define SIZEOF_SIZE_T 8
#define SIZEOF_LONG_LONG 16
#define SIZEOF_VOID_P 8
#define SIZEOF_INT 8
#define SIZEOF_FPOS_T 8

#define HAVE_ERRNO_H

#define WORDS_BIGENDIAN

#define DONT_HAVE_STAT
#define DONT_HAVE_FSTAT

#endif /*Py_PYCONFIG_H*/

