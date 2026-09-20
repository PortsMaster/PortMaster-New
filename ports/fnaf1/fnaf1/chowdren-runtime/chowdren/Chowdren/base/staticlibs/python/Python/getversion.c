
/* Return the full version string. */

#include "Python.h"

#include "patchlevel.h"

const char *
Py_GetVersion(void)
{
	static char version[250];
	PyOS_snprintf(version, sizeof(version), "%.80s", PY_VERSION);
	return version;
}
