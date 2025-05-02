## 1c: Variant on the basic layout template with big credits blocks on each row.
# With dividers on the role category. These are only some examples of role categories.
# A person can be credited more than once when they fulfilled roles in multiple categories.
define gui.credits_category_header = "#000000"
define gui.credits_name = "#000000"
define gui.credits_role = "#000000"

# Credits Screen 
screen template_1c():
    tag menu

    ## This use statement includes the game_menu screen inside this one. The
    ## vbox child is then included inside the viewport inside the game_menu
    ## screen.
    use game_menu(_("Cute Fame: Halloween Bash Credits"), scroll="viewport"):

        style_prefix "about"

        # vbox for credits
        vbox:
            # spacing between each element
            spacing 50

            # "Creator" divider
            text "Creator:" style "credits_category_header" 

            # Credit block
            hbox:
                add "credits/cutefame.png" # zoom 0.5 -> if images are not resized properly you can do it with zoom

                null width 50 # manual horizontal spacing

                vbox:
                    null height 10 # yalign 0.5 is an alternative option, but yalign is more suited when there is equal amount of elements in this vbox
                    text "Fame/Cute Fame Studio" style "credits_name"
                    null height 10  # manual vertical spacing
                    text "Manager, Script Writer & Programmer" style "credits_role"
                    null height 30
                    hbox:
                        add "credits/itchio.png"
                        textbutton _("https://cutefame.itch.io/" ) action OpenURL("https://cutefame.itch.io/" ) style "credits_url_button" text_style "credits_url_text"  
                    hbox:
                        add "credits/worldwideweb.png"
                        textbutton _("https://cutefame.net") action OpenURL("https://cutefame.net") style "credits_url_button" text_style "credits_url_text"                      

            null height 25  # manual extra vertical spacing
            
            # Credit block
            text "Composer:" style "credits_category_header" 
            
            hbox:
                add "credits/jasminecomposer.png"

                null width 50  

                vbox:
                    null height 10
                    text "Jasmine G. Crawshaw" style "credits_name"
                    null height 10
                    text "Creator of soundtrack." style "credits_role"
                    null height 30
                    hbox:
                        add "credits/twitter.png"
                        textbutton _("https://twitter.com/") action OpenURL("https://twitter.com/") style "credits_url_button" text_style "credits_url_text"  
            
            # "Writing" divider
            text "Artist:" style "credits_category_header" 

            # Credit block
            hbox:
                add "credits/pawfulltrust.png"

                null width 50  

                vbox:
                    null height 10
                    text "Pawfulltrust" style "credits_name"
                    null height 10
                    text "Artist, Sub Script Writer" style "credits_role"
                    null height 30
                    hbox:
                        add "credits/twitter.png"
                        textbutton _("https://twitter.com/pawfulltrust") action OpenURL("https://twitter.com/pawfulltrust") style "credits_url_button" text_style "credits_url_text"  
                    hbox:
                        add "credits/worldwideweb.png"
                        textbutton _("https://linktr.ee/pawfulltrust") action OpenURL("https://linktr.ee/pawfulltrust") style "credits_url_button" text_style "credits_url_text"       

            # "Voice Actor" divider
            text "Voice Actor:" style "credits_category_header" 

            # Credit block
            hbox:
                add "credits/toxicromeova.png"

                null width 50  

                vbox:
                    null height 10
                    text "ToXiCRomeoVA" style "credits_name"
                    null height 10
                    text "Voice Actor (Has one sound clip.)" style "credits_role"
                    null height 30
                    hbox:
                        add "credits/twitter.png"
                        textbutton _("https://twitter.com/ToXiCRomeoVA") action OpenURL("https://twitter.com/ToXiCRomeoVA") style "credits_url_button" text_style "credits_url_text"  

            # null height 25  # manual extra vertical spacing

            # "Composer" divider
            # Credit block
            # hbox:
            #     add "logo"

            #     null width 50  

            #     vbox:
            #         null height 10
            #         text "Artist Name" style "credits_name"
            #         null height 10
            #         text "BG Artist" style "credits_role"
            #         null height 30
            #         hbox:
            #             add "twitter-original"
            #             textbutton _("https://www.twitter.com/gaming_v_potato/") action OpenURL("https://www.twitter.com/gaming_v_potato/") style "credits_url_button" text_style "credits_url_text"             

            # null height 25  # manual extra vertical spacing

            # # "Audio" divider
            # text "Audio:" style "credits_category_header" 

            # # Credit block
            # hbox:
            #     add "logo"

            #     null width 50  

            #     vbox:
            #         null height 10
            #         text "Musician Name" style "credits_name"
            #         null height 10
            #         text "OST Composer" style "credits_role"
            #         null height 30
            #         hbox:
            #             add "twitter-original"
            #             textbutton _("https://www.twitter.com/gaming_v_potato/") action OpenURL("https://www.twitter.com/gaming_v_potato/") style "credits_url_button" text_style "credits_url_text"  

           # null height 25  # manual extra vertical spacing

            # "Programmming" divider
            # text "Programming:" style "credits_category_header" 

            # Credit block
            # hbox:
            #     add "logo"

            #     null width 50  

            #     vbox:
            #         null height 10
            #         text "Programmer Name" style "credits_name"
            #         null height 10
            #         text "GUI Programmer" style "credits_role"
            #         null height 30
            #         hbox:
            #             add "twitter-original"
            #             textbutton _("https://www.twitter.com/gaming_v_potato/") action OpenURL("https://www.twitter.com/gaming_v_potato/") style "credits_url_button" text_style "credits_url_text"  

            # null height 25  # manual extra vertical spacing

            # # "VA" divider
            # text "VA:" style "credits_category_header" 

            # # Credit block
            # hbox:
            #     add "logo"

            #     null width 50  

            #     vbox:
            #         null height 10
            #         text "Voice Actor #1 Name" style "credits_name"
            #         null height 10
            #         text "Protagonist's Voice" style "credits_role"
            #         null height 30
            #         hbox:
            #             add "twitter-original"
            #             textbutton _("https://www.twitter.com/gaming_v_potato/") action OpenURL("https://www.twitter.com/gaming_v_potato/") style "credits_url_button" text_style "credits_url_text"  

            # # Credit block
            # hbox:
            #     add "logo"

            #     null width 50  

            #     vbox:
            #         null height 10
            #         text "Voice Actor #2 Name" style "credits_name"
            #         null height 10
            #         text "Antagonist's Voice" style "credits_role"
            #         null height 30
            #         hbox:
            #             add "twitter-original"
            #             textbutton _("https://www.twitter.com/gaming_v_potato/") action OpenURL("https://www.twitter.com/gaming_v_potato/") style "credits_url_button" text_style "credits_url_text"            

            # # Credit block
            # hbox:
            #     add "logo"

            #     null width 50  

            #     vbox:
            #         null height 10
            #         text "Voice Actor #3 Name" style "credits_name"
            #         null height 10
            #         text "Protagonist's Voice" style "credits_role"
            #         null height 30
            #         hbox:
            #             add "twitter-original"
            #             textbutton _("https://www.twitter.com/gaming_v_potato/") action OpenURL("https://www.twitter.com/gaming_v_potato/") style "credits_url_button" text_style "credits_url_text"  

            # # Credit block
            # hbox:
            #     add "logo"

            #     null width 50  

            #     vbox:
            #         null height 10
            #         text "Voice Actor #4 Name" style "credits_name"
            #         null height 10
            #         text "Antagonist's Voice" style "credits_role"
            #         null height 30
            #         hbox:
            #             add "twitter-original"
            #             textbutton _("https://www.twitter.com/gaming_v_potato/") action OpenURL("https://www.twitter.com/gaming_v_potato/") style "credits_url_button" text_style "credits_url_text"  

            # # Credit block
            # hbox:
            #     add "logo"

            #     null width 50  

            #     vbox:
            #         null height 10
            #         text "Voice Actor #5 Name" style "credits_name"
            #         null height 10
            #         text "Protagonist's Voice" style "credits_role"
            #         null height 30
            #         hbox:
            #             add "twitter-original"
            #             textbutton _("https://www.twitter.com/gaming_v_potato/") action OpenURL("https://www.twitter.com/gaming_v_potato/") style "credits_url_button" text_style "credits_url_text"  