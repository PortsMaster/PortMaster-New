
def overlap(x1, y1, w1, h1, x2, y2, w2, h2):
    return x1 < x2 + w2 and \
            x1 + w1 > x2 and \
            y1 < y2 + h2 and \
            y1 + h1 > y2
            
def contains_point(x, y, w, h, px, py):
    return x <= px and \
        x + w >= px and \
        y <= py and \
        y + h >= py

class Rect:
    def __init__(self, x, y, w, h):
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        
    def is_overlapping(self, x, y, w, h):
        return self.x < x + w and \
            self.x + self.w > x and \
            self.y < y + h and \
            self.y + self.h > y
        
    def is_overlapping_other(self, other):
        return self.x < other.x + other.w and \
            self.x + self.w > other.x and \
            self.y < other.y + other.h and \
            self.y + self.h > other.y
            