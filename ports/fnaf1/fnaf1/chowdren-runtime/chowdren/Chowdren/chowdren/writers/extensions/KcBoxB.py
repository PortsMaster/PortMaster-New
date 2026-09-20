from KcBoxA import SystemBox, actions, conditions, expressions

class BackgroundSystemBox(SystemBox):
    def is_static_background(self):
        return False

def get_object():
    return BackgroundSystemBox