
/* Readline interface for tokenizer.c and [raw_]input() in bltinmodule.c.
   By default, or when stdin is not a tty device, we have a super
   simple my_readline function using fgets.
   Optionally, we can use the GNU readline library.
   my_readline() has a different return value from GNU readline():
   - NULL if an interrupt occurred or if an error occurred
   - a malloc'ed empty string if EOF was read
   - a malloc'ed string ending in \n normally
*/

#include "Python.h"
#ifdef MS_WINDOWS
#define WIN32_LEAN_AND_MEAN
#include "windows.h"
#endif /* MS_WINDOWS */

#ifdef __VMS
extern char* vms__StdioReadline(FILE *sys_stdin, FILE *sys_stdout, char *prompt);
#endif


PyThreadState* _PyOS_ReadlineTState;

#ifdef WITH_THREAD
#include "pythread.h"
static PyThread_type_lock _PyOS_ReadlineLock = NULL;
#endif

int (*PyOS_InputHook)(void) = NULL;

#ifdef RISCOS
int Py_RISCOSWimpFlag;
#endif

/* This function restarts a fgets() after an EINTR error occurred
   except if PyOS_InterruptOccurred() returns true. */

static int
my_fgets(char *buf, int len, FILE *fp)
{
    return -2;
}


/* Readline implementation using fgets() */

char *
PyOS_StdioReadline(FILE *sys_stdin, FILE *sys_stdout, char *prompt)
{
    size_t n;
    char *p;
    n = 100;
    if ((p = (char *)PyMem_MALLOC(n)) == NULL)
        return NULL;
    fflush(sys_stdout);
#ifndef RISCOS
    if (prompt)
        fprintf(stderr, "%s", prompt);
#else
    if (prompt) {
        if(Py_RISCOSWimpFlag)
            fprintf(stderr, "\x0cr%s\x0c", prompt);
        else
            fprintf(stderr, "%s", prompt);
    }
#endif
    fflush(stderr);
    switch (my_fgets(p, (int)n, sys_stdin)) {
    case 0: /* Normal case */
        break;
    case 1: /* Interrupt */
        PyMem_FREE(p);
        return NULL;
    case -1: /* EOF */
    case -2: /* Error */
    default: /* Shouldn't happen */
        *p = '\0';
        break;
    }
    n = strlen(p);
    while (n > 0 && p[n-1] != '\n') {
        size_t incr = n+2;
        p = (char *)PyMem_REALLOC(p, n + incr);
        if (p == NULL)
            return NULL;
        if (incr > INT_MAX) {
            PyErr_SetString(PyExc_OverflowError, "input line too long");
        }
        if (my_fgets(p+n, (int)incr, sys_stdin) != 0)
            break;
        n += strlen(p+n);
    }
    return (char *)PyMem_REALLOC(p, n+1);
}


/* By initializing this function pointer, systems embedding Python can
   override the readline function.

   Note: Python expects in return a buffer allocated with PyMem_Malloc. */

char *(*PyOS_ReadlineFunctionPointer)(FILE *, FILE *, char *);


/* Interface used by tokenizer.c and bltinmodule.c */

char *
PyOS_Readline(FILE *sys_stdin, FILE *sys_stdout, char *prompt)
{
    PyErr_SetString(PyExc_RuntimeError,
                    "can't enter readline");
    return NULL;
}
