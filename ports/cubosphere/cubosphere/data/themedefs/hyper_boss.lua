--Clear THEME-Dir stack
THEME_Clear();

--Add hyper boss folder to the Dir stack. Each file is searched in this folder first
THEME_AddDir("hyper_boss");

--If a file is not found in hyperspace, the search is continued in the hyperspace subdirs
THEME_AddDir("hyperspace");

--And otherwise the file in the parent directory (i.e. without any theme subdir is taken)
