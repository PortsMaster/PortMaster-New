#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ
#ПРОЧЬ ИЗ МОЕЙ ГОЛОВЫ

################################################################################
## Инициализация
################################################################################

init offset = -1


################################################################################
## Стили
################################################################################

init python:
    style.input.size = 45
    style.input_prompt.size = 45

style default:
    properties gui.text_properties()
    language gui.language

style input:
    properties gui.text_properties("input", accent=True)
    adjust_spacing False

style hyperlink_text:
    properties gui.text_properties("hyperlink", accent=True)
    hover_underline True

style gui_text:
    properties gui.text_properties("interface")


style button:
    properties gui.button_properties("button")

style button_text is gui_text:
    properties gui.text_properties("button")
    yalign 0.5


style label_text is gui_text:
    properties gui.text_properties("label", accent=True)

style prompt_text is gui_text:
    properties gui.text_properties("prompt")


style bar:
    ysize gui.bar_size
    left_bar Frame("gui/bar/left.png", gui.bar_borders, tile=gui.bar_tile)
    right_bar Frame("gui/bar/right.png", gui.bar_borders, tile=gui.bar_tile)

style vbar:
    xsize gui.bar_size
    top_bar Frame("gui/bar/top.png", gui.vbar_borders, tile=gui.bar_tile)
    bottom_bar Frame("gui/bar/bottom.png", gui.vbar_borders, tile=gui.bar_tile)

style scrollbar:
    ysize gui.scrollbar_size
    base_bar Frame("gui/scrollbar/horizontal_[prefix_]bar.png", gui.scrollbar_borders, tile=gui.scrollbar_tile)
    thumb Frame("gui/scrollbar/horizontal_[prefix_]thumb.png", gui.scrollbar_borders, tile=gui.scrollbar_tile)

style vscrollbar:
    xsize gui.scrollbar_size
    base_bar Frame("gui/scrollbar/vertical_[prefix_]bar.png", gui.vscrollbar_borders, tile=gui.scrollbar_tile)
    thumb Frame("gui/scrollbar/vertical_[prefix_]thumb.png", gui.vscrollbar_borders, tile=gui.scrollbar_tile)

style slider:
    ysize gui.slider_size
    base_bar Frame("gui/slider/horizontal_[prefix_]bar.png", gui.slider_borders, tile=gui.slider_tile)
    thumb "gui/slider/horizontal_[prefix_]thumb.png"

style vslider:
    xsize gui.slider_size
    base_bar Frame("gui/slider/vertical_[prefix_]bar.png", gui.vslider_borders, tile=gui.slider_tile)
    thumb "gui/slider/vertical_[prefix_]thumb.png"


style frame:
    padding gui.frame_borders.padding
    background Frame("gui/frame.png", gui.frame_borders, tile=gui.frame_tile)



################################################################################
## Внутриигровые экраны
################################################################################


## Экран разговора #############################################################
##
## Экран разговора используется для показа диалога игроку. Он использует два
## параметра — who и what — что, соответственно, имя говорящего персонажа и
## показываемый текст. (Параметр who может быть None, если имя не задано.)
##
## Этот экран должен создать текст с id "what", чтобы Ren'Py могла показать
## текст. Здесь также можно создать наложения с id "who" и id "window", чтобы
## применить к ним настройки стиля.
##
## https://www.renpy.org/doc/html/screen_special.html#say

screen say(who, what):
    style_prefix "say"

    window:
        id "window"

        if who is not None:

            window:
                id "namebox"
                style "namebox"
                text who id "who"

        text what id "what"


    ## Если есть боковое изображение ("голова"), показывает её поверх текста.
    ## По стандарту не показывается на варианте для мобильных устройств — мало
    ## места.
    if not renpy.variant("small"):
        add SideImage() xalign 0.0 yalign 1.0


## Делает namebox доступным для стилизации через объект Character.
init python:
    config.character_id_prefixes.append('namebox')

style window is default
style say_label is default
style say_dialogue is default
style say_thought is say_dialogue

style namebox is default
style namebox_label is say_label


style window:
    xalign 0.5
    xfill True
    yalign gui.textbox_yalign
    ysize gui.textbox_height

    background Image("gui/textbox.png", xalign=0.5, yalign=1.0)

style namebox:
    xpos gui.name_xpos
    xanchor gui.name_xalign
    xsize gui.namebox_width
    ypos gui.name_ypos
    ysize gui.namebox_height

    background Frame("gui/namebox.png", gui.namebox_borders, tile=gui.namebox_tile, xalign=gui.name_xalign)
    padding gui.namebox_borders.padding

style say_label:
    properties gui.text_properties("name", accent=True)
    xalign gui.name_xalign
    yalign 0.5

style say_dialogue:
    properties gui.text_properties("dialogue")

    xpos gui.dialogue_xpos
    xsize gui.dialogue_width
    ypos gui.dialogue_ypos

screen lang_choice:
    textbutton "{font=122.ttf}English{/font}":
        text_size 40
        xalign 0.5
        yalign 0.28
        action [Language("english"), Return()]        
        
        
        
        
        
        
## Экран ввода #################################################################
##
## Этот экран используется, чтобы показывать renpy.input. Это параметр запроса,
## используемый для того, чтобы дать игроку ввести в него текст.
##
## Этот экран должен создать наложение ввода с id "input", чтобы принять
## различные вводимые параметры.
##
## https://www.renpy.org/doc/html/screen_special.html#input

screen input(prompt):
    style_prefix "input"

    window at truecenter:

        xminimum 1000

        vbox:
            xalign 0.5
            xpos 500
            yalign 0.5
            ypos 500

            text prompt style "input_prompt"
            input id "input"

style input_prompt is default

style input_prompt:
    xalign gui.dialogue_text_xalign
    properties gui.text_properties("input_prompt")

style input:
    xalign gui.dialogue_text_xalign
    xmaximum gui.dialogue_width


## Экран выбора ################################################################
##
## Этот экран используется, чтобы показывать внутриигровые выборы,
## представленные оператором menu. Один параметр, вложения, список объектов,
## каждый с заголовком и полями действия.
##
## https://www.renpy.org/doc/html/screen_special.html#choice

screen choice(items):
    style_prefix "choice"

    vbox:
        for i in items:
            textbutton i.caption action i.action


## Когда этот параметр True, заголовки меню будут проговариваться рассказчиком.
## Когда False, заголовки меню будут показаны как пустые кнопки.
define config.narrator_menu = True


style choice_vbox is vbox
style choice_button is button
style choice_button_text is button_text

style choice_vbox:
    xalign 0.5
    ypos 330
    yanchor 0.5

    spacing gui.choice_spacing

style choice_button is default:
    properties gui.button_properties("choice_button")

style choice_button_text is default:
    properties gui.button_text_properties("choice_button")



screen input(prompt):
    style_prefix "input"
    
    

    window:

        vbox:
            xalign gui.dialogue_text_xalign
            xpos gui.dialogue_xpos
            xsize gui.dialogue_width
            ypos gui.dialogue_ypos

            text prompt style "input_prompt"
            input id "input"

style input_prompt is default

style input_prompt:
    xalign gui.dialogue_text_xalign
    properties gui.text_properties("input_prompt")

style input:
    xalign gui.dialogue_text_xalign
    xmaximum gui.dialogue_width


################################################################################
## Экраны Главного и Игрового меню
################################################################################

## Экран навигации #############################################################
##
## Этот экран включает в себя главное и игровое меню, и обеспечивает навигацию к
## другим меню и к началу игры.

image mm:
    "mm1.png"
    pause 0.5
    "mm2.png"
    pause 0.5
    repeat

screen main_menu():

    # This ensures that any other menu screen is replaced.
    tag menu

    add "mm"

    imagebutton auto "bt_%s.png" focus_mask True action Start() #hovered Play("sound", "narr.wav")

## Экран игрового меню #########################################################
##
## Всё это показывает основную, обобщённую структуру экрана игрового меню. Он
## вызывается с экраном заголовка и показывает фон, заголовок и навигацию.
##
## Параметр scroll может быть None, или "viewport", или "vpgrid", когда этот
## экран предназначается для использования с более чем одним дочерним экраном,
## включённым в него.
screen keymap_screen():
    key "V" action ShowMenu('preferences')
    key "v" action ShowMenu('preferences')

screen preferences:
    
    key "V" action Return()
    key "v" action Return()
    add "images/bg.png"
    #label "Громкость":
        #xalign 0.5
        #yalign 0.3
        #text_size 150
    hbox:
        xalign 0.5
        yalign 0.5
        bar value Preference("music volume") style "pref_slider"
init -2 python:
    style.pref_slider.left_bar = "images/bar_empty.png" # весь слайдер окрашенный в цвет, что слева от бегунка
    style.pref_slider.right_bar = "images/bar_full.png" # весь слайдер окрашенный в цвет, что справа от бегунка
    style.pref_slider.xmaximum = 837 # ширина слайдера (ширина картинок bar_left.png и bar_right.png)
    style.pref_slider.ymaximum = 48 # высота слайдера
    style.pref_slider.thumb = None # рисунок бегунка
    #style.pref_slider.thumb_offset = 2 # половина ширины бегунка
    #add "images/bar1.png"


## Экран Об игре ###############################################################
##
## Этот экран показывает авторскую информацию об игре и Ren'Py.
##
## В этом экране нет ничего особенного, и он служит только примером того, каким
## можно сделать свой экран.
