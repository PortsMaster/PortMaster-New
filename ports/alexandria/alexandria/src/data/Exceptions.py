class GameOverException(Exception):
    def __init__(self, failgoal = None):
        self.failgoal = failgoal

class ReturnToBase(Exception):
    def __init__(self, level):
        self.level = level
