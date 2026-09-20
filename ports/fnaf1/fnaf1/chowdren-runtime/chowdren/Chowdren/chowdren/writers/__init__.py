class BaseWriter(object):
    def __init__(self, converter, data):
        self.converter = converter
        self.data = data