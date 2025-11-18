--Clear THEME-Dir stack
THEME_Clear();

--Add hyperspace folder to the Dir stack. Each file is searched in this folder first
THEME_AddDir("hyperspace");

--If a file is not found in hyperspace, the search is continued in the spacy subdirs
THEME_AddDir("spacy");

--And otherwise the file in the parent directory (i.e. without any theme subdir is taken)
