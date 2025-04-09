textbox("into first include level")
hide_textbox()

include("textbox-test.gd")

# return before the end to force return to included script
return()

textbox("back to first include level")
hide_textbox()
