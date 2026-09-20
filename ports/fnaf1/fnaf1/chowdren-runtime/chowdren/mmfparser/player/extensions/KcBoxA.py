# Copyright (c) Mathias Kaerlev 2012.

# This file is part of Anaconda.

# Anaconda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Anaconda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

"""
KcBoxA.mfx
Active System Box object - ClickTeam (http: #www.clickteam.com)

Displays boxes, buttons, checkboxes or hyperlinks using system or
custom colors.

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, ObjectPlayer
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Set Dimensions

    Parameters:
    0: Width (TIME, Time)
    1: Height (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        width = self.evaluate_index(0)
        height = self.evaluate_index(1)
        instance.objectPlayer.set_size(width, height)

class Action1(Action):
    """
    Set Position

    Parameters:
    0: X (TIME, Time)
    1: Y (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        x = self.evaluate_index(0)
        y = self.evaluate_index(1)
        instance.set_position(x, y)

class Action2(Action):
    """
    State->Enable

    Parameters:
    0:  ((unknown 25003))
    """

    def execute(self, instance):
        instance.objectPlayer.set_enabled(True)

class Action3(Action):
    """
    State->Disable

    Parameters:
    0:  ((unknown 25004))
    """

    def execute(self, instance):
        instance.objectPlayer.set_enabled(False)

class Action4(Action):
    """
    State->Check

    Parameters:
    0:  ((unknown 25005))
    """

    def execute(self, instance):
        instance.objectPlayer.set_checked(True)

class Action5(Action):
    """
    State->Uncheck

    Parameters:
    0:  ((unknown 25057))
    """

    def execute(self, instance):
        instance.objectPlayer.set_checked(True)

class Action6(Action):
    """
    Set Fill color->None

    Parameters:
    0:  ((unknown 25007))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = None

class Action7(Action):
    """
    Set Fill color->3D Dark Shadow

    Parameters:
    0:  ((unknown 25008))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(0)

class Action8(Action):
    """
    Set Fill color->3D Face (Button Face)

    Parameters:
    0:  ((unknown 25009))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(1)

class Action9(Action):
    """
    Set Fill color->3D Hilight (Button Highlight)

    Parameters:
    0:  ((unknown 25010))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(2)

class Action10(Action):
    """
    Set Fill color->3D Light

    Parameters:
    0:  ((unknown 25011))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(3)

class Action11(Action):
    """
    Set Fill color->3D Shadow (Button Shadow)

    Parameters:
    0:  ((unknown 25012))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(4)

class Action12(Action):
    """
    Set Fill color->Active Window Caption

    Parameters:
    0:  ((unknown 25013))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(5)

class Action13(Action):
    """
    Set Fill color->MDI background

    Parameters:
    0:  ((unknown 25014))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(6)

class Action14(Action):
    """
    Set Fill color->Desktop

    Parameters:
    0:  ((unknown 25015))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(7)

class Action15(Action):
    """
    Set Fill color->Item selected in a control

    Parameters:
    0:  ((unknown 25016))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(8)

class Action16(Action):
    """
    Set Fill color->Inactive caption

    Parameters:
    0:  ((unknown 25017))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(9)

class Action17(Action):
    """
    Set Fill color->Tooltip background

    Parameters:
    0:  ((unknown 25018))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(10)

class Action18(Action):
    """
    Set Fill color->Menu background

    Parameters:
    0:  ((unknown 25019))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(11)

class Action19(Action):
    """
    Set Fill color->Scroll bar gray area

    Parameters:
    0:  ((unknown 25020))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(12)

class Action20(Action):
    """
    Set Fill color->Window background

    Parameters:
    0:  ((unknown 25021))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(13)

class Action21(Action):
    """
    Set Fill color->Window frame

    Parameters:
    0:  ((unknown 25022))
    """

    def execute(self, instance):
        instance.objectPlayer.fill = get_fill_color(14)

class Action22(Action):
    """
    Set Border color 1->None

    Parameters:
    0:  ((unknown 25023))
    """

    def execute(self, instance):
        instance.objectPlayer.border1 = None

class Action23(Action):
    """
    Set Border color 1->3D Dark Shadow

    Parameters:
    0:  ((unknown 25024))
    """

    def execute(self, instance):
        instance.objectPlayer.border1 = get_border_color(0)

class Action24(Action):
    """
    Set Border color 1->3D Face (Button Face)

    Parameters:
    0:  ((unknown 25025))
    """

    def execute(self, instance):
        instance.objectPlayer.border1 = get_border_color(1)

class Action25(Action):
    """
    Set Border color 1->3D Hilight (Button Highlight)

    Parameters:
    0:  ((unknown 25026))
    """

    def execute(self, instance):
        instance.objectPlayer.border1 = get_border_color(2)

class Action26(Action):
    """
    Set Border color 1->3D Light

    Parameters:
    0:  ((unknown 25027))
    """

    def execute(self, instance):
        instance.objectPlayer.border1 = get_border_color(3)

class Action27(Action):
    """
    Set Border color 1->3D Shadow (Button Shadow)

    Parameters:
    0:  ((unknown 25028))
    """

    def execute(self, instance):
        instance.objectPlayer.border1 = get_border_color(4)

class Action28(Action):
    """
    Set Border color 1->Active Window Border

    Parameters:
    0:  ((unknown 25029))
    """

    def execute(self, instance):
        instance.objectPlayer.border1 = get_border_color(5)

class Action29(Action):
    """
    Set Border color 1->Inactive border

    Parameters:
    0:  ((unknown 25030))
    """

    def execute(self, instance):
        instance.objectPlayer.border1 = get_border_color(6)

class Action30(Action):
    """
    Set Border color 1->Window frame

    Parameters:
    0:  ((unknown 25031))
    """

    def execute(self, instance):
        instance.objectPlayer.border1 = get_border_color(7)

class Action31(Action):
    """
    Set Border color 2->None

    Parameters:
    0:  ((unknown 25032))
    """

    def execute(self, instance):
        instance.objectPlayer.border2 = None

class Action32(Action):
    """
    Set Border color 2->3D Dark Shadow

    Parameters:
    0:  ((unknown 25033))
    """

    def execute(self, instance):
        instance.objectPlayer.border2 = get_border_color(0)

class Action33(Action):
    """
    Set Border color 2->3D Face (Button Face)

    Parameters:
    0:  ((unknown 25034))
    """

    def execute(self, instance):
        instance.objectPlayer.border2 = get_border_color(1)

class Action34(Action):
    """
    Set Border color 2->3D Hilight (Button Highlight)

    Parameters:
    0:  ((unknown 25035))
    """

    def execute(self, instance):
        instance.objectPlayer.border2 = get_border_color(2)

class Action35(Action):
    """
    Set Border color 2->3D Light

    Parameters:
    0:  ((unknown 25036))
    """

    def execute(self, instance):
        instance.objectPlayer.border2 = get_border_color(3)

class Action36(Action):
    """
    Set Border color 2->3D Shadow (Button Shadow)

    Parameters:
    0:  ((unknown 25037))
    """

    def execute(self, instance):
        instance.objectPlayer.border2 = get_border_color(4)

class Action37(Action):
    """
    Set Border color 2->Active Window Border

    Parameters:
    0:  ((unknown 25038))
    """

    def execute(self, instance):
        instance.objectPlayer.border2 = get_border_color(5)

class Action38(Action):
    """
    Set Border color 2->Inactive border

    Parameters:
    0:  ((unknown 25039))
    """

    def execute(self, instance):
        instance.objectPlayer.border2 = get_border_color(6)

class Action39(Action):
    """
    Set Border color 2->Window frame

    Parameters:
    0:  ((unknown 25040))
    """

    def execute(self, instance):
        instance.objectPlayer.border2 = get_border_color(7)

class Action40(Action):
    """
    Set Text color->None

    Parameters:
    0:  ((unknown 25041))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(None)

class Action41(Action):
    """
    Set Text color->3D Hilight (Button Highlight)

    Parameters:
    0:  ((unknown 25042))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(get_text_color(0))

class Action42(Action):
    """
    Set Text color->3D Shadow (Button Shadow)

    Parameters:
    0:  ((unknown 25043))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(get_text_color(1))

class Action43(Action):
    """
    Set Text color->Button text

    Parameters:
    0:  ((unknown 25044))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(get_text_color(2))

class Action44(Action):
    """
    Set Text color->Caption text

    Parameters:
    0:  ((unknown 25045))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(get_text_color(3))
class Action45(Action):
    """
    Set Text color->Grayed text

    Parameters:
    0:  ((unknown 25046))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(get_text_color(4))

class Action46(Action):
    """
    Set Text color->Text of item selected in a control

    Parameters:
    0:  ((unknown 25047))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(get_text_color(5))

class Action47(Action):
    """
    Set Text color->Inactive caption text

    Parameters:
    0:  ((unknown 25048))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(get_text_color(6))

class Action48(Action):
    """
    Set Text color->Tooltip text

    Parameters:
    0:  ((unknown 25049))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(get_text_color(7))

class Action49(Action):
    """
    Set Text color->Menu text

    Parameters:
    0:  ((unknown 25050))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(get_text_color(8))

class Action50(Action):
    """
    Set Text color->Window text

    Parameters:
    0:  ((unknown 25051))
    """

    def execute(self, instance):
        instance.objectPlayer.set_text_color(get_text_color(9))

class Action51(Action):
    """
    Set Fill color->Other

    Parameters:
    0: System color index (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        color = get_system_color(self.evaluate_expression(
            self.get_parameter(0)))
        instance.objectPlayer.fill = color

class Action52(Action):
    """
    Set Border color 1->Other

    Parameters:
    0: System color index (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        color = get_system_color(self.evaluate_expression(
            self.get_parameter(0)))
        instance.objectPlayer.border1 = color

class Action53(Action):
    """
    Set Border color 2->Other

    Parameters:
    0: System color index (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        color = get_system_color(self.evaluate_expression(
            self.get_parameter(0)))
        instance.objectPlayer.border2 = color

class Action54(Action):
    """
    Set Text color->Other

    Parameters:
    0: System color index (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        color = get_system_color(self.evaluate_expression(
            self.get_parameter(0)))
        instance.objectPlayer.set_text_color(color)

class Action55(Action):
    """
    Set text

    Parameters:
    0: Text (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_text(self.evaluate_expression(
            self.get_parameter(0)))

class Action56(Action):
    """
    Set tooltip text

    Parameters:
    0: Text (OBJECT, Object)
    1:  (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_tooltip(self.evaluate_expression(
            self.get_parameter(0)))

class Action57(Action):
    """
    Docking->Undock

    Parameters:
    0:  ((unknown 25058))
    """

    def execute(self, instance):
        instance.objectPlayer.undock()

class Action58(Action):
    """
    Docking->Dock to left

    Parameters:
    0:  ((unknown 25059))
    """

    def execute(self, instance):
        instance.objectPlayer.dock('left')

class Action59(Action):
    """
    Docking->Dock to right

    Parameters:
    0:  ((unknown 25060))
    """

    def execute(self, instance):
        instance.objectPlayer.dock('right')

class Action60(Action):
    """
    Docking->Dock to top

    Parameters:
    0:  ((unknown 25061))
    """

    def execute(self, instance):
        instance.objectPlayer.dock('top')

class Action61(Action):
    """
    Docking->Dock to bottom

    Parameters:
    0:  ((unknown 25006))
    """

    def execute(self, instance):
        instance.objectPlayer.dock('bottom')

class Action62(Action):
    """
    Image->Show

    Parameters:
    0:  ((unknown 25063))
    """

    def execute(self, instance):
        instance.objectPlayer.imageVisible = True

class Action63(Action):
    """
    Image->Hide

    Parameters:
    0:  ((unknown 25064))
    """

    def execute(self, instance):
        instance.objectPlayer.imageVisible = False

class Action64(Action):
    """
    State->Reset 'Clicked' state

    Parameters:
    0:  ((unknown 25065))
    """

    def execute(self, instance):
        instance.objectPlayer.clicked = None

class Action65(Action):
    """
    Set Hyperlink color->None

    Parameters:
    0:  ((unknown 25066))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(None)

class Action66(Action):
    """
    Set Hyperlink color->3D Hilight (Button Highlight)

    Parameters:
    0:  ((unknown 25067))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(get_text_color(0))

class Action67(Action):
    """
    Set Hyperlink color->3D Shadow (Button Shadow)

    Parameters:
    0:  ((unknown 25068))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(get_text_color(1))

class Action68(Action):
    """
    Set Hyperlink color->Button text

    Parameters:
    0:  ((unknown 25069))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(get_text_color(2))

class Action69(Action):
    """
    Set Hyperlink color->Caption text

    Parameters:
    0:  ((unknown 25070))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(get_text_color(3))

class Action70(Action):
    """
    Set Hyperlink color->Grayed text

    Parameters:
    0:  ((unknown 25071))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(get_text_color(4))

class Action71(Action):
    """
    Set Hyperlink color->Text of item selected in a control

    Parameters:
    0:  ((unknown 25072))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(get_text_color(5))

class Action72(Action):
    """
    Set Hyperlink color->Inactive caption text

    Parameters:
    0:  ((unknown 25073))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(get_text_color(6))

class Action73(Action):
    """
    Set Hyperlink color->Tooltip text

    Parameters:
    0:  ((unknown 25074))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(get_text_color(7))

class Action74(Action):
    """
    Set Hyperlink color->Menu text

    Parameters:
    0:  ((unknown 25075))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(get_text_color(8))

class Action75(Action):
    """
    Set Hyperlink color->Window text

    Parameters:
    0:  ((unknown 25076))
    """

    def execute(self, instance):
        instance.objectPlayer.set_hyperlink_color(get_text_color(9))

class Action76(Action):
    """
    Set Hyperlink color->Other

    Parameters:
    0: System color index (OBJECT, Object)
    1:  (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        color = get_system_color(self.evaluate_expression(self.get_parameter(
            0)))
        instance.objectPlayer.set_hyperlink_color(color)

class Action77(Action):
    """
    Attach menu option

    Parameters:
    0: Attach menu option (OBJECT, Object)
    1: Attach menu option (MENU, Int)
    """

    def execute(self, instance):
        pass # nahah!

def valid_click(click, loopCount):
    return click in xrange(loopCount, loopCount + 1)

class Condition0(Condition):
    """
    &Button->Is &clicked ?

    Parameters:
    0:  ((unknown 26002))
    """
    
    def created(self):
        if self.isTriggered:
            self.add_handlers(clicked = self.on_click)
    
    def on_click(self, instance):
        if self.isTriggered:
            self.generate()

    def check(self, instance):
        clicked = instance.objectPlayer.clicked
        if clicked is None:
            return False
        if not valid_click(clicked, self.eventPlayer.loopCount):
            return False
        return True

class Condition1(Condition):
    """
    Is &enabled ?

    Parameters:
    0:  ((unknown 26005))
    """

    def check(self, instance):
        return instance.enabled

class Condition2(Condition):
    """
    &Button->Is c&hecked ?

    Parameters:
    0:  ((unknown 26003))
    """

    def check(self, instance):
        return instance.checked

class Condition3(Condition):
    """
    &User clicks->With left button

    Parameters:
    0:  ((unknown 26004))
    """
    def created(self):
        if self.isTriggered:
            self.add_handlers(clicked = self.on_click)
    
    def on_click(self, instance):
        if self.isTriggered:
            self.generate()

    def check(self, instance):
        clicked = instance.objectPlayer.clicked
        if clicked is None:
            return False
        if not valid_click(clicked, self.eventPlayer.loopCount):
            return False
        return instance.objectPlayer.clickButton == LEFT

class Condition4(Condition):
    """
    &User clicks->With right button

    Parameters:
    0:  ((unknown 26001))
    """
    def created(self):
        if self.isTriggered:
            self.add_handlers(clicked = self.on_click)
    
    def on_click(self, instance):
        if self.isTriggered:
            self.generate()

    def check(self, instance):
        clicked = instance.objectPlayer.clicked
        if clicked is None:
            return False
        if not valid_click(clicked, self.eventPlayer.loopCount):
            return False
        return instance.objectPlayer.clickButton == RIGHT

class Condition5(Condition):
    """
    &Mouse is over object

    Parameters:
    0:  ((unknown 26006))
    """

    def check(self, instance):
        return instance.mouse_over()

class Condition6(Condition):
    """
    Is &image shown ?

    Parameters:
    0:  ((unknown 26007))
    """

    def check(self, instance):
        return instance.imageVisible

class Condition7(Condition):
    """
    Is &docked ?

    Parameters:
    0:  ((unknown 25000))
    """

    def check(self, instance):
        return instance.dock is not None

# Expressions

from mmfparser.player.common import make_color_number

class Expression0(Expression):
    """
    Current color->Fill color

    Parameters:
    0: (not found) ((unknown 27001))
    Return type: Int
    """

    def get(self, instance):
        if instance.objectPlayer.fill is None:
            return 0xFFFF
        return make_color_number(instance.objectPlayer.fill)

class Expression1(Expression):
    """
    Current color->Border color #1

    Parameters:
    0: (not found) ((unknown 27002))
    Return type: Int
    """

    def get(self, instance):
        if instance.objectPlayer.border1 is None:
            return 0xFFFF
        return make_color_number(instance.objectPlayer.border1)

class Expression2(Expression):
    """
    Current color->Border color #2

    Parameters:
    0: (not found) ((unknown 27003))
    Return type: Int
    """

    def get(self, instance):
        if instance.objectPlayer.border2 is None:
            return 0xFFFF
        return make_color_number(instance.objectPlayer.border2)

class Expression3(Expression):
    """
    Current color->Text color

    Parameters:
    0: (not found) ((unknown 27004))
    Return type: Int
    """

    def get(self, instance):
        if instance.objectPlayer.textColor is None:
            return 0xFFFF
        return make_color_number(instance.objectPlayer.textColor)

class Expression4(Expression):
    """
    System color->3D Dark Shadow

    Parameters:
    0: (not found) ((unknown 27005))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(0)

class Expression5(Expression):
    """
    System color->3D Face (Button Face)

    Parameters:
    0: (not found) ((unknown 27006))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(1)

class Expression6(Expression):
    """
    System color->3D Hilight (Button Highlight)

    Parameters:
    0: (not found) ((unknown 27007))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(2)

class Expression7(Expression):
    """
    System color->3D Light

    Parameters:
    0: (not found) ((unknown 27008))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(3)

class Expression8(Expression):
    """
    System color->3D Shadow (Button Shadow)

    Parameters:
    0: (not found) ((unknown 27009))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(4)

class Expression9(Expression):
    """
    System color->Active Window Border

    Parameters:
    0: (not found) ((unknown 27010))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(5)

class Expression10(Expression):
    """
    System color->Active Window Caption

    Parameters:
    0: (not found) ((unknown 27011))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(6)

class Expression11(Expression):
    """
    System color->MDI background

    Parameters:
    0: (not found) ((unknown 27012))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(7)

class Expression12(Expression):
    """
    System color->Desktop

    Parameters:
    0: (not found) ((unknown 27013))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(8)

class Expression13(Expression):
    """
    System color->Button text

    Parameters:
    0: (not found) ((unknown 27014))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(9)

class Expression14(Expression):
    """
    System color->Caption text

    Parameters:
    0: (not found) ((unknown 27015))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(10)

class Expression15(Expression):
    """
    System color->Grayed text

    Parameters:
    0: (not found) ((unknown 27016))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(11)

class Expression16(Expression):
    """
    System color->Item selected in a control

    Parameters:
    0: (not found) ((unknown 27017))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(12)

class Expression17(Expression):
    """
    System color->Text of item selected in a control

    Parameters:
    0: (not found) ((unknown 27018))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(13)

class Expression18(Expression):
    """
    System color->Inactive border

    Parameters:
    0: (not found) ((unknown 27019))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(14)

class Expression19(Expression):
    """
    System color->Inactive caption

    Parameters:
    0: (not found) ((unknown 27020))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(15)

class Expression20(Expression):
    """
    System color->Inactive caption text

    Parameters:
    0: (not found) ((unknown 27021))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(16)

class Expression21(Expression):
    """
    System color->Tooltip background

    Parameters:
    0: (not found) ((unknown 27022))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(17)

class Expression22(Expression):
    """
    System color->Tooltip text

    Parameters:
    0: (not found) ((unknown 27023))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(18)

class Expression23(Expression):
    """
    System color->Menu background

    Parameters:
    0: (not found) ((unknown 27024))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(19)

class Expression24(Expression):
    """
    System color->Menu text

    Parameters:
    0: (not found) ((unknown 27025))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(20)

class Expression25(Expression):
    """
    System color->Scroll bar gray area

    Parameters:
    0: (not found) ((unknown 27026))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(21)

class Expression26(Expression):
    """
    System color->Window background

    Parameters:
    0: (not found) ((unknown 27027))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(22)

class Expression27(Expression):
    """
    System color->Window frame

    Parameters:
    0: (not found) ((unknown 27028))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(23)

class Expression28(Expression):
    """
    System color->Window text

    Parameters:
    0: (not found) ((unknown 27029))
    Return type: Int
    """

    def get(self, instance):
        return get_expression_color(24)

class Expression29(Expression):
    """
    Text

    Parameters:
    0: (not found) ((unknown 27030))
    Return type: String
    """

    def get(self, instance):
        return instance.objectPlayer.label.text.encode('windows-1252')

class Expression30(Expression):
    """
    Tool tip text

    Parameters:
    0: (not found) ((unknown 27031))
    Return type: String
    """

    def get(self, instance):
        return instance.objectPlayer.tooltip

class Expression31(Expression):
    """
    Dimensions->Width

    Parameters:
    0: (not found) ((unknown 27032))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.width

class Expression32(Expression):
    """
    Dimensions->Height

    Parameters:
    0: (not found) ((unknown 27033))
    Return type: Int
    """

    def get(self, instance):
        return instance.objectPlayer.height

class Expression33(Expression):
    """
    Current color->Hyperlink color

    Parameters:
    0: (not found) ((unknown 27034))
    Return type: Int
    """

    def get(self, instance):
        if instance.objectPlayer.hyperlinkColor is None:
            return 0xFFFF
        return make_color_number(instance.objectPlayer.hyperlinkColor)

class Expression34(Expression):
    """
    Convert System Color To RGB

    Parameters:
    0: (not found) (Int)
    1: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        return get_system_color(self.next_argument())

class GetX(Expression):
    """
    Position->X Coordinate

    Parameters:
    0: (not found) ((unknown 27035))
    Return type: Int
    """

    def get(self, instance):
        return instance.x

class GetY(Expression):
    """
    Position->Y Coordinate

    Parameters:
    0: (not found) ((unknown 27036))
    Return type: Int
    """

    def get(self, instance):
        return instance.y

from mmfparser.data.font import LogFont
from pyglet import gl
from mmfparser.player.gui import draw_rectangle
from mmfparser.bitdict import BitDict
from mmfparser.player.common import get_color_number
from pyglet.window.mouse import LEFT, RIGHT
import math

COLORS = {
    0 : (0xC8, 0xC8, 0xC8),
    1 : (0x00,0x00,0x00),
    2 : (0x99,0xb4,0xd1),
    3 : (0xbf,0xcd,0xdb), #SystemColor.activeCaptionBorder,
    4 : (0xf0,0xf0,0xf0),
    5 : (0xff,0xff,0xff),
    6 : (0x64,0x64,0x64), #SystemColor.inactiveCaptionBorder,
    7 : (0x00,0x00,0x00),
    8 : (0x00,0x00,0x00),
    9 : (0x00,0x00,0x00),
    10 : (0xb4,0xb4,0xb4), #new
    11 : (0xf4,0xf7,0xfc), #new
    12 : (0xab,0xab,0xab), #mdi one, doesn't quite match. There is no java mdi background colour./ AppWorksapce
    13 : (0x33,0x99,0xff), #SystemColor.textText,
    14 : (0xff,0xff,0xff),  #new  #SystemColor.textHighlight,
    15 : (0xf0,0xf0,0xf0), #SystemColor.textHighlightText,
    16 : (0xa0,0xa0,0xa0), #SystemColor.textInactiveText,
    17 : (0x80,0x80,0x80),
    18 : (0x00,0x00,0x00),
    19 : (0x43,0x4e,0x54),
    20 : (0xff,0xff,0xff),
    21 : (0x69,0x69,0x69),
    22 : (0xe3,0xe3,0xe3),
    23 : (0x00,0x00,0x00),
    24 : (0xff,0xff,0xe1),
}

BORDER_INDEX = [
    21,
    15,
    20,
    22,
    16,
    10,
    11,
    6
]

FILL_INDEX = [
    21,
    15,
    20,
    22,
    16,
    2,
    12,
    1,
    13,
    3,
    24,
    4,
    0,
    5,
    6
]

TEXT_INDEX = [
    20,
    16,
    18,
    9,
    17,
    14,
    19,
    23,
    7,
    8
]

EXPRESSION_INDEX = [
    21,
    15,
    20,
    22,
    16,
    10,
    2,
    12,
    1,
    18,
    9,
    17,
    13,
    14,
    11,
    3,
    19,
    24,
    23,
    4,
    7,
    0,
    5,
    6,
    8
]

def get_fill_color(index):
    return COLORS[FILL_INDEX[index]]

def get_border_color(index):
    return COLORS[BORDER_INDEX[index]]

def get_text_color(index):
    return COLORS[TEXT_INDEX[index]]

def get_expression_color(index):
    return EXPRESSION_INDEX[index] | (1 << 31)

def get_system_color(index):
    if index == 0xFFFF:
        return None
    if index & (1 << 31) != 0:
        return get_color_number(index)
    try:
        return COLORS[index]
    except KeyError:
        return (0, 0, 0)

def read_system_color(reader):
    return get_system_color(reader.readInt(True))

FLAGS = BitDict(
    'AlignTop',
    'AlignVerticalCenter', 
    'AlignBottom', 
    None, 
    'AlignLeft', 
    'AlignHorizontalCenter', 
    'AlignRight', 
    None, 
    'Multiline', 
    'NoPrefix', 
    'EndEllipsis', 
    'PathEllipsis', 
    'Container', 
    'Contained', 
    'Hyperlink', 
    None, 
    'AlignImageTopLeft', 
    'AlignImageCenter', 
    'AlignImagePattern', 
    None, 
    'Button',
    'Checkbox',
    'ShowButtonBorder', 
    'ImageCheckbox',
    'HideImage',
    'ForceClipping',
    None,
    None,
    'ButtonPressed', 
    'ButtonHighlighted',
    'Disabled'
)

NONE, HYPERLINK, BUTTON, CHECKBOX = xrange(4)

class DefaultObject(ObjectPlayer):
    border1 = None
    border2 = None
    fill = None
    imageSprite = None
    margin = None
    over = False
    showBorder = False
    imageCheckbox = False
    displayType = None
    checked = False
    press = False
    # for image
    alignTopLeft = False
    alignCenter = False
    pattern = False
    enabled = True
    imageVisible = True
    clicked = None
    clickButton = None
    dock = None
    tooltip = None
    isBackground = False
    
    def created(self, data):
        self.width = data.readShort(True)
        self.height = data.readShort(True)
        self.flags = flags = FLAGS.copy()
        self.flags.setFlags(data.readInt())
        self.showBorder = flags['ShowButtonBorder']
        self.imageCheckbox = flags['ImageCheckbox']
        if flags['Hyperlink']:
            self.displayType = HYPERLINK
        elif flags['Button']:
            if flags['Checkbox']:
                self.displayType = CHECKBOX
            else:
                self.displayType = BUTTON
        else:
            self.displayType = NONE
        self.alignTopLeft = flags['AlignImageTopLeft']
        self.alignCenter = flags['AlignImageCenter']
        self.pattern = flags['AlignImagePattern']
        self.fill = read_system_color(data)
        self.border1 = read_system_color(data)
        self.border2 = read_system_color(data)
        image = data.readShort()
        if image != -1:
            self.imageSprite = sprite = self.make_sprite(
                self.make_image_handle(image))
            if self.alignCenter:
                sprite.shape.left = -sprite.width / 2
                sprite.shape.bottom = -sprite.height / 2
        data.skipBytes(2) # rData_wFree
        self.textColor = textColor = read_system_color(data)
        marginLeft = data.readShort()
        marginTop = data.readShort()
        marginRight = data.readShort()
        marginBottom = data.readShort()
        self.margin = (marginLeft, marginTop, marginRight, marginBottom)
        # XXX support unicode when the unicode build is out!
        logFont = self.font = LogFont(data, old = True)
        data.skipBytes(40) # file.readStringSize(40)
        data.adjust(8)
        text = data.readReader(data.readInt(True)).readString().rsplit('\\n', 1)
        if len(text) == 1:
            text, = text
            tooltip = None
        else:
            text, tooltip = text
        self.tooltip = tooltip
        width = self.width - marginLeft - marginRight
        height = self.height - marginTop - marginBottom
        
        self.label = self.create_label(logFont, text, textColor or (0, 0, 0), 
            width, height)
        self.set_position(0, 0)

        if flags['AlignTop']:
            verticalAlignment = 'top'
        elif flags['AlignVerticalCenter']:
            verticalAlignment = 'center'
        elif flags['AlignBottom']:
            verticalAlignment = 'bottom'
        
        if flags['AlignLeft']:
            horizontalAlignment = 'left'
        elif flags['AlignHorizontalCenter']:
            horizontalAlignment = 'center'
        elif flags['AlignRight']:
            horizontalAlignment = 'right'
            
        self.label.content_valign = verticalAlignment
        self.label.set_style('align', horizontalAlignment)

        version = data.readInt()
        self.hyperlinkColor = read_system_color(data)
        
        self.enable_mouse()
    
    def dock(self, val):
        # cannot be le bothered
        pass
    
    def undock(self):
        # dock(), me neither!
        pass
    
    def set_size(self, width, height):
        self.width = width
        self.height = height
        margin = self.margin
        self.label.width = width - margin[0] - margin[2]
        self.label.height = height - margin[1] - margin[3]
        self.set_position(self.x, self.y)
    
    def set_checked(self, value):
        self.checked = value
    
    def set_position(self, x, y):
        if self.imageSprite is not None:
            if self.alignTopLeft:
                self.imageSprite.xy = self.x, self.y
            elif self.alignCenter:
                self.imageSprite.xy = (x + self.width / 2, y - self.height / 2)
        self.label.x = x + self.margin[0]
        self.label.y = y - self.margin[1]
    
    def on_mouse_over(self):
        if not self.enabled:
            return
        self.over = True
        if self.displayType == HYPERLINK:
            self.label.underline = True
            self.label.set_rgb(self.hyperlinkColor)
            self.player.mouse.set_hand_cursor()
    
    def set_text_color(self, value):
        self.textColor = value
        if value is not None:
            self.label.set_rgb(value)
    
    def set_hyperlink_color(self, value):
        self.hyperlinkColor = value
        if value is not None and self.over and self.displayType == HYPERLINK:
            self.label.set_rgb(value)
    
    def set_text(self, value):
        self.label.text = value.decode('windows-1252')
    
    def set_tooltip(self, value):
        self.tooltip = value
            
    def on_mouse_left(self):
        if not self.enabled:
            return
        self.over = False
        if self.displayType == HYPERLINK:
            self.label.underline = False
            self.label.set_rgb(self.textColor)
            self.player.mouse.set_default_cursor()
    
    def on_mouse_release(self, button, modifiers):
        if not self.enabled:
            return
        if button == LEFT and self.displayType == CHECKBOX:
            self.checked = not self.checked
        self.clickButton = button
        self.clicked = self.player.eventPlayer.loopCount
        self.fire_handler('clicked')
    
    def is_pressed(self):
        return (self.over and self.player.mouse.left and self.enabled)
    
    def draw(self):
        gl.glDisable(gl.GL_TEXTURE_2D)
        border = True
        offset = False
        image = True
        color1 = self.border1
        color2 = self.border2
        if self.displayType == BUTTON:
            if not self.showBorder and not self.over:
                border = False
            if self.is_pressed():
                offset = True
                color1, color2 = color2, color1
        elif self.displayType == CHECKBOX:
            if not self.showBorder and not self.over:
                border = False
            value = self.checked or self.is_pressed()
            if self.imageCheckbox:
                if value:
                    border = True
                else:
                    image = False
            else:
                if value:
                    offset = True
                    color1, color2 = color2, color1
        elif self.displayType == HYPERLINK:
            if self.is_pressed():
                offset = True

        if not self.enabled:
            border = False
            offset = False

        draw_rectangle(self.x, self.y, 
            self.x + self.width, self.y - self.height, self.fill)
        gl.glPushAttrib(gl.GL_SCISSOR_BIT)
        gl.glPushMatrix()
        x, y, width, height = self.player.get_scissor_box(self.x, 
            self.y - self.height, self.width, self.height)
        gl.glScissor(x, y, width, height)
        gl.glEnable(gl.GL_SCISSOR_TEST)
        if offset:
            gl.glTranslatef(2, -2, 0)
        sprite = self.imageSprite
        if self.imageVisible and image and sprite is not None:
            if self.pattern:
                startX = self.x
                startY = self.y
                width = sprite.width
                height = sprite.height
                for y in xrange(int(math.ceil(float(self.height) / height))):
                    sprite.y = startY - y * height
                    for x in xrange(int(math.ceil(float(self.width) / width))):
                        sprite.x = startX + x * width
                        sprite.render()
            else:
                self.imageSprite.render()
        if self.displayType != HYPERLINK and self.textColor is not None:
            self.label.draw()
        gl.glPopMatrix()
        if self.displayType == HYPERLINK:
            if self.over:
                color = self.hyperlinkColor
            else:
                color = self.textColor
            if color is not None:
                self.label.draw()
        gl.glPopAttrib()
        
        gl.glDisable(gl.GL_TEXTURE_2D)
        if border:
            # top left
            draw_rectangle(self.x, self.y,
                self.x + self.width, self.y - 1, color1)
            draw_rectangle(self.x, self.y,
                self.x + 1, self.y - self.height, color1)
            # bottom right
            draw_rectangle(self.x + self.width, self.y - self.height,
                self.x, self.y - self.height + 1, color2)
            draw_rectangle(self.x + self.width, self.y - self.height,
                self.x + self.width - 1, self.y, color2)
    
    def set_enabled(self, value):
        if value == self.enabled:
            return
        self.enabled = value
        if value:
            self.imageSprite.alpha = 1.0
            self.label.opacity = 255
        else:
            self.imageSprite.alpha = 0.5
            self.label.opacity = 127

class KcBoxA(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : Action5,
        6 : Action6,
        7 : Action7,
        8 : Action8,
        9 : Action9,
        10 : Action10,
        11 : Action11,
        12 : Action12,
        13 : Action13,
        14 : Action14,
        15 : Action15,
        16 : Action16,
        17 : Action17,
        18 : Action18,
        19 : Action19,
        20 : Action20,
        21 : Action21,
        22 : Action22,
        23 : Action23,
        24 : Action24,
        25 : Action25,
        26 : Action26,
        27 : Action27,
        28 : Action28,
        29 : Action29,
        30 : Action30,
        31 : Action31,
        32 : Action32,
        33 : Action33,
        34 : Action34,
        35 : Action35,
        36 : Action36,
        37 : Action37,
        38 : Action38,
        39 : Action39,
        40 : Action40,
        41 : Action41,
        42 : Action42,
        43 : Action43,
        44 : Action44,
        45 : Action45,
        46 : Action46,
        47 : Action47,
        48 : Action48,
        49 : Action49,
        50 : Action50,
        51 : Action51,
        52 : Action52,
        53 : Action53,
        54 : Action54,
        55 : Action55,
        56 : Action56,
        57 : Action57,
        58 : Action58,
        59 : Action59,
        60 : Action60,
        61 : Action61,
        62 : Action62,
        63 : Action63,
        64 : Action64,
        65 : Action65,
        66 : Action66,
        67 : Action67,
        68 : Action68,
        69 : Action69,
        70 : Action70,
        71 : Action71,
        72 : Action72,
        73 : Action73,
        74 : Action74,
        75 : Action75,
        76 : Action76,
        77 : Action77,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
        6 : Condition6,
        7 : Condition7,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
        5 : Expression5,
        6 : Expression6,
        7 : Expression7,
        8 : Expression8,
        9 : Expression9,
        10 : Expression10,
        11 : Expression11,
        12 : Expression12,
        13 : Expression13,
        14 : Expression14,
        15 : Expression15,
        16 : Expression16,
        17 : Expression17,
        18 : Expression18,
        19 : Expression19,
        20 : Expression20,
        21 : Expression21,
        22 : Expression22,
        23 : Expression23,
        24 : Expression24,
        25 : Expression25,
        26 : Expression26,
        27 : Expression27,
        28 : Expression28,
        29 : Expression29,
        30 : Expression30,
        31 : Expression31,
        32 : Expression32,
        33 : Expression33,
        34 : GetX,
        35 : GetY,
        36 : Expression34,
    }

extension = KcBoxA()

def get_extension():
    return extension
