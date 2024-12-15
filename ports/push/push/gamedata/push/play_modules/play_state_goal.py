import pyxel
import ease
import tween
from hz3 import State
import const

# PlayState:ゴールステート
class GoalState(State):
    def __init__(self, id:str, play):
        super().__init__(id)

        from s_play import Play
        self.play: Play = play

        # 遷移用Tween作成
        self.tw = tween.Tween()

    def enter(self):
        # クリアしたレベルを記録
        self.play.game_data.data_dict["level_states"][self.play.game_data.data_dict["cur_level_index"]] = 1

        # 次のレベル番号へ
        self.play.game_data.data_dict["cur_level_index"] += 1

        self.play.game_data.save()
        
        # ジングル再生開始まで30フレーム待機
        self.tw.append_interval(20)
        self.tw.append_callback(lambda: pyxel.play(0, const.SOUND_SUCCESS))
        # ディザー値変更開始まで30フレーム待機
        self.tw.append_interval(50)
        # ディザー値変更
        self.tw.append(1, 0, 20, ease.linear, self.on_value_changed)
        # Tween実行
        self.tw.play()
        # Tween完了時処理
        self.tw.completed(lambda: self.tween_completed())


    def tween_completed(self):
        # Tween実行完了
        levels_count = len(self.play.map_json)

        is_all_clear = True
        for i in range(levels_count):
            if self.play.game_data.data_dict["level_states"][i] < 1:
                is_all_clear = False
                break

        if is_all_clear:
            if self.play.game_data.data_dict["is_all_clear"]:
                # 既に全クリしている場合
                if self.play.game_data.data_dict["cur_level_index"] > levels_count - 1:
                    # 最後のレベルをクリア後した
                    self.play.game_data.data_dict["cur_level_index"] = 0
                    self.play.game_data.save()
                    self.play.statemachine.transition("allclear")
                else:
                    self.statemachine.transition("init")
            else:
                # すべてのレベルをクリアした
                self.play.game_data.data_dict["is_all_clear"] = True
                self.play.game_data.data_dict["cur_level_index"] = 0
                self.play.game_data.save()
                self.play.statemachine.transition("allclear")
        else:
            # すべてのレベルをクリアしていない
            if self.play.game_data.data_dict["cur_level_index"] > levels_count - 1:
                # 最後のレベルをクリア後した
                self.play.game_data.data_dict["cur_level_index"] = 0
                self.play.game_data.save()
                self.play.statemachine.transition("levels")
            else:
                # 最後のレベルではない場合、次のレベルへ
                self.statemachine.transition("init")


    def exit(self):
        # Tween停止
        self.tw.stop()


    def update(self):
        # Tween更新
        self.tw.update()


    def on_value_changed(self, value):
        """Tweenの値取得用

        Args:
            value (float): 1.0→0.0へ変化
        """        

        # ディザーの値調整
        self.play.dither = value