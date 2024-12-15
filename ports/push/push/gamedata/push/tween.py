
class Tween:
    def __init__(self):
        self.data_list = []
        self.is_playing = False
        self.current_data = None
        self.current_time = 0
        self.on_value_changed = None
        self.on_completed = None


    def append(self, start_value, end_value, duration, ease: callable, on_value_changed: callable):
        data = TweenData()
        data.start_value = start_value
        data.end_value = end_value
        data.duration = duration
        data.ease = ease
        data.on_value_changed = on_value_changed
        self.data_list.append(data)
        return self
    

    def append_interval(self, duration):
        data = IntervalData()
        data.duration = duration
        self.data_list.append(data)
        return self


    def append_callback(self, callback:callable):
        data = CallbackData()
        data.callback = callback
        self.data_list.append(data)
        return self


    def update(self):
        if self.is_playing:
            if len(self.data_list) < 1:
                # リストが空であれば停止
                self.stop()

                if callable(self.on_completed):
                    # 完了イベント実行
                    self.on_completed()
            else:
                # リストが空ではない場合
                if self.current_data == None:
                    # 現在のデータが空の場合先頭のデータを取得
                    self.current_data:TweenData = self.data_list[0]
                
                data = self.current_data
                if self.current_time == data.duration:
                    # 終了
                    self.data_list.remove(self.current_data)
                    self.current_data = None
                    self.current_time = 0
                else:
                    # 処理
                    if type(data) == TweenData:
                        self.current_time += 1
                        if self.current_time > data.duration:
                            self.current_time = data.duration
                        
                        data.value = data.start_value + data.ease(self.current_time / data.duration) * (data.end_value - data.start_value)
                        if callable(data.on_value_changed):
                            # 値変更イベント実行
                            data.on_value_changed(data.value)
                    elif type(data) == IntervalData:
                        self.current_time += 1
                    elif type(data) == CallbackData:
                        data.callback()
                        self.current_time = data.duration


    def play(self):
        self.is_playing = True
        return self


    def pause(self):
        self.is_playing = False


    def stop(self):
        self.is_playing = False
        self.data_list.clear()


    def completed(self, on_completed):
        self.on_completed = on_completed
        return self


class TweenData():
    def __init__(self):
        self.value = 0
        self.start_value = 0
        self.end_value = 0
        self.duration = 0
        self.ease = None
        self.on_value_changed = None
    

class IntervalData():
    def __init__(self):
        self.duration = 0


class CallbackData():
    def __init__(self):
        self.duration = 3
        self.callback = None