NOTE: These scripts are NOT DIRECTLY EXECUTABLE (well you can run them, but you won't see anything) 

\libs

These are "Libraries"; a collection of functions assigned to an object.


Example:
to use the text library, first load it into memory (at the beginning of your script)
 
dofile("../libs/db_text.lua") 

The text object [text.] is now available for use...

F.ex to write some black text at x=100, y=50 with the default 4x5 font, use:

text.black(100, 50, "HELLO WORLD!") 



