from chowdren.writers.objects import ObjectWriter

from chowdren.common import get_animation_name, to_c, make_color

from chowdren.writers.events import (ConditionMethodWriter,
    ActionMethodWriter, ExpressionMethodWriter, make_table,
    TrueCondition, FalseCondition, EmptyAction)

class SteamObject(ObjectWriter):
    class_name = 'SteamObject'
    update = False
    filename = 'steamext'

    def write_init(self, writer):
        pass

actions = make_table(ActionMethodWriter, {
    0 : 'update', # general_frame_update_0
    1 : 'find_board', # leaderboards_uploading_find_boards_1
    2 : 'upload_crystal', # leaderboards_uploading_upload_crystals_2
    3 : 'upload_time', # leaderboards_uploading_upload_time_3
    6 : 'unlock_achievement', # achievements_simple_unlock_6
    7 : 'clear_achievement', # achievements_simple_lock_7
    11 : 'upload("./records.dat")', # cloud_simple_upload_records_dat_11
    13 : 'upload("./control_gamepad.cfg")', # cloud_simple_upload_gamepad_cfg_13
    14 : 'upload("./control_keyboard.cfg")', # cloud_simple_upload_keyboard_cfg_14
    15 : 'download("./records.dat")', # cloud_simple_download_records_dat_15
    17 : 'download("./control_gamepad.cfg")', # cloud_simple_download_gamepad_cfg_17
    18 : 'download("./control_keyboard.cfg")', # cloud_simple_download_keyboard_cfg_18
    27 : 'upload("./file" + number_to_string(%s) + ".sav")', # cloud_simple_upload_adventure_27
    29 : 'download("./file" + number_to_string(%s) + ".sav")' # cloud_simple_download_adventure_29
})

conditions = make_table(ConditionMethodWriter, {
})

expressions = make_table(ExpressionMethodWriter, {
})

def get_object():
    return SteamObject