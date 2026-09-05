import Utils

class FadeView(object):
    def __init__(self):
        self.fade_out_start = None
        self.i = 0

    def thread(self):
        while True:
            yield None
            if self.fade_out_start == None:
                # Treat DELAY == None separately -- means "don't end
                # intentionally"
                if self.DELAY != None:
                    self.color = Utils.fade_in_color(self.i, self.FADE_IN,
                                                     self.DELAY)
                else:
                    try: 
                        self.color = Utils.fade_in_color(self.i, self.FADE_IN,
                                                         1)
                    except IndexError:
                        pass
            else:
                diff = self.i - self.fade_out_start
                self.color = Utils.fade_out_color(diff, self.FADE_OUT)
            self.draw()
            self.i += 1

    def fade_out(self):
        self.fade_out_start = self.i
