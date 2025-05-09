## styles: change fonts, colours, et cetera over here

## style definitions

style about_header:
    size 60
    color "#000000"

style credits_category_header:
    size 50
    color "#000000"

# inherit style from text_button
style credits_url_button is text_button

#########################################################################################################################  

# style definitions only used by template 1

style credits_name:
    size 50
    bold True
    color "#000000"
style credits_role:
    size 30
    color "#000000"
# inherit style from hyperlink_text
style credits_url_text is hyperlink_text
style credits_url_text:
    size 18

#########################################################################################################################    

# style definitions only used by template 2

style credits_name_small:
    size 25
    bold True

style credits_role_small:
    size 20

# inherit from hyperlink_text
style credits_url_text_small is hyperlink_text
style credits_url_text_small:
    size 15