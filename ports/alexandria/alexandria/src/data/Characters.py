class Character(object):
    color = (0, 0, 0)
    picture = None

Narrator=Character

class Officer(Character):
    color = (16, 0, 0)

class Lisa(Officer):
    picture = 'general'

class Engineer(Officer):
    picture = 'engineer'

class Communications(Officer):
    picture = 'comm'

class Lieutenant(Officer):
    picture = 'lieutenant'

class SrEngineer(Officer):
    picture = 'srengineer'

class Heather(Character):
    # bartender
    picture = 'bartender'

class Scientist(Character):
    color = (0, 16, 0)

class Thaddeus(Scientist):
    picture = 'thaddeus'

class Scientist2(Scientist):
    # ???
    picture = 'scientist4'

class Scientist3(Scientist):
    # ???
    picture = 'scientist3'

class Patty(Scientist):
    picture = 'patty'

class Pilot(Character):
    color = (16, 16, 16)

class Tanya(Pilot):
    picture = 'tanya'

class Chet(Pilot):
    picture = 'chet'

class Buster(Pilot):
    picture = 'buster'

class Pilot4(Pilot):
    pass
