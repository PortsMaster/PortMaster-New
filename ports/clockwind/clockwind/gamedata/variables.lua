--Window variables (160 x 144)
TILE = 20

WINWIDTH = 320
WINHEIGHT = 180

--GAME VARIABLES
--Camera
CAMERA_LEFTEDGE = TILE*5
CAMERA_TOPEDGE = TILE*3
CAMERA_RIGHTEDGE = WINWIDTH-TILE*8.5
CAMERA_BOTTOMEDGE = WINHEIGHT-TILE*4

--GENERAL PHYSICS
GRAVITY = 2000
WATERGRAVITY = 200
MAXYSPEED = 500
FRICTION = 1500

--PLAYER VARIABLES
PLAYER_width = 18
PLAYER_height = 24

PLAYER_walkspeed = 100
PLAYER_walkacceleration = 520
PLAYER_walkfriction = 1400
PLAYER_gravity = GRAVITY
PLAYER_jumpforce = 340
PLAYER_jumpgravity = 2000
PLAYER_jumphighgravity = 1300
PLAYER_jumpfriction = 400

PLAYER_swimspeed = 80
PLAYER_swimacceleration = 480
PLAYER_swimfriction = 100
PLAYER_swimforce = 100
PLAYER_waterdampingx = 0.7
PLAYER_waterdampingy = 0.2
PLAYER_watergravity = WATERGRAVITY
PLAYER_waterjumpoutforce = 340

PLAYER_carryx = 0 --edge of thing being carried
PLAYER_carryy = 11 --bottom of thing being carried
PLAYER_grabrangex = -7 --how far player can grab things
PLAYER_grabrangew = 13
PLAYER_grabrangey = 0
PLAYER_grabrangeh = PLAYER_height+2

PLAYER_idleanimspeed = 6
PLAYER_walkanimspeed = 10
PLAYER_swimanimspeed = 8

PLAYER_respawntime = 0.05 --how long it takes to respawn

PLAYER_carwidth = 52
PLAYER_carheight = PLAYER_height
PLAYER_carspeed = 250
PLAYER_carblockbreakspeed = 200
PLAYER_caracceleration = 320
PLAYER_carjumpforce = 300
PLAYER_carjumpgravity = 2000
PLAYER_carjumphighgravity = 1300
PLAYER_flyspeed = 80
PLAYER_flyacceleration = 520
PLAYER_flytime = 4
PLAYER_caranimspeed = 12

--CARS
CAR_width = 52
CAR_height = 16

--DINOS
DINO1_width = 35
DINO1_height = 28
DINO1_speed = 46
DINO1_turntime = 0.4
DINO1_animdelay = 0.3

--SEED
SEED_tossforcex = 70
SEED_tossforcey = 120
SEED_tossforceyup = 400
SEED_bounceforce = 150

--BOMB
BOMB_tossforcex = 70
BOMB_tossforcey = 120
BOMB_bounceforce = 150
BOMB_animdelay = 0.08

--TREE
TREE_length = TILE*5.5
TREE_startlength = TILE

--BUSH
BUSH_length = TILE*4
BUSH_startlength = TILE
PISTON_speed = 330
PISTON_acceleration = 340
PISTON_retractspeed = 50
PISTON_timestop = 0.3
PISTON_length = TILE*4
PISTON_startlength = TILE

--WATER
WATERLEVEL_high = 3.5*TILE
WATERLEVEL_low = 19*TILE

--JELLY
JELLY_animdelay = 0.182

--GEAR
GEAR_speedslow = 0.4
GEAR_speedfast = 0.8
GEAR_shoveforce = 340

--BANDIT
BANDIT_width = 18
BANDIT_height = 32
BANDIT_speedslow = 20
BANDIT_speedfast = 60
BANDIT_animdelayslow = 0.3
BANDIT_animdelayfast = 0.1
BANDIT_carryx = -4 --edge of thing being carried
BANDIT_carryy = 22

--GOAL
GOAL_width = 15
GOAL_height = 25
GOAL_animdelay = 0.18
LEVEL_wintime = 3

TIMEPERIODS = 3
TIMETRAVELSPEED = 3
TIMETRAVELANIMTIME = 0.2 --how long time travel animation keeps on playing after button is let go
TIMETRAVELSLOWDOWN = 0.5
TIMEPERIODTRANSITIONTIME = 0.15