/* ########## active / inactive ######## */

#define INACTIVE	0
#define ACTIVE 		1

/* ########## mias ######## */

#define MIA_NORMAL		0
#define MIA_AQUA		1

/* ########## objectives ########## */

#define OBJ_OPTIONAL	0
#define OBJ_REQUIRED 	1

/* ########## switch defs ######### */

#define SWT_NORMAL		0
#define SWT_TOGGLE		1
#define SWT_TIMED		2
#define SWT_PRESSURE	3
#define SWT_RESET		4
#define SWT_WATERLEVEL	5
#define SWT_USED		6

/* ########### trains and doors ######### */

#define TR_TRAIN 		0

#define TR_DOOR 		1
#define TR_LOCKED_DOOR 	2
#define TR_GOLD_DOOR 	3
#define TR_SILVER_DOOR 	4
#define TR_BRONZE_DOOR 	5

#define TR_SLIDEDOOR			6
#define TR_LOCKED_SLIDEDOOR 	7
#define TR_GOLD_SLIDEDOOR 		8
#define TR_SILVER_SLIDEDOOR 	9
#define TR_BRONZE_SLIDEDOOR 	10

#define TR_AT_END			0
#define TR_AT_START 		1

#define TR_DOOR_CLOSED		0
#define TR_DOOR_OPEN		1

/* ########### spawn point types ######## */

#define SPW_HAZARD	0
	#define HAZARD_LAVABALL			0
	#define HAZARD_ROCKFALL 		1
	#define HAZARD_BOMBS			2
	#define HAZARD_EXPLOSION		3
	#define HAZARD_POWERBULLETS		4
	#define HAZARD_STALAGTITES		5

#define SPW_ENEMY		1

#define SPW_ITEM		2

#define SPW_BOSSBULLET	3
	#define BOSSBULLET1		1
	#define BOSSBULLET2		2
	#define BOSSBULLET3		3
	#define BOSSBULLET4		4
	#define BOSSBULLET5		5

#define SPW_NOSUBTYPE	-1

/* ########### traps ################ */

#define TRAP_FIRSTACTION		0
#define TRAP_WAIT1				1
#define TRAP_SECONDACTION		2
#define TRAP_WAIT2				3

#define TRAP_TYPE_SPIKE			0
#define TRAP_TYPE_MINE			1
#define TRAP_TYPE_SWING			2
#define TRAP_TYPE_CRUSHER		3
#define TRAP_TYPE_BARRIER		4
#define TRAP_TYPE_FLAME			5

/* ########### entity flags ######### */

#define ENT_NONE 			0
#define ENT_INANIMATE 		1
#define ENT_MULTIEXPLODE	( 2 << 0 )
#define ENT_DYING 			( 2 << 1 )
#define ENT_WEIGHTLESS		( 2 << 2 )
#define ENT_NOCOLLISIONS	( 2 << 3 )
#define ENT_BOUNCES			( 2 << 4 )
#define ENT_AIMS			( 2 << 5 )
#define ENT_SPAWNED			( 2 << 6 )
#define ENT_ALWAYSFIRES		( 2 << 7 )
#define ENT_FLIES			( 2 << 8 )
#define ENT_COLLECTABLE		( 2 << 9 )
#define ENT_EXPLODES		( 2 << 10 )
#define ENT_FIRETRAIL		( 2 << 11 )
#define ENT_SPARKS			( 2 << 12 )
#define ENT_PUFFS			( 2 << 13 )
#define ENT_ONFIRE			( 2 << 14 )
#define ENT_JUMPS			( 2 << 15 )
#define ENT_NOMOVE			( 2 << 16 )
#define ENT_SWIMS			( 2 << 17 )
#define ENT_BULLET			( 2 << 18 )
#define ENT_TELEPORTING		( 2 << 19 )
#define ENT_IMMUNE			( 2 << 20 )
#define ENT_STATIC			( 2 << 21 )
#define ENT_SLIDES			( 2 << 22 )
#define ENT_RAPIDFIRE		( 2 << 23 )
#define ENT_IMMUNEEXPLODE	( 2 << 24 )
#define ENT_ALWAYSCHASE		( 2 << 25 )
#define ENT_NOJUMP			( 2 << 26 )
#define ENT_GALDOV			( 2 << 27 )
#define ENT_PARTICLETRAIL	( 2 << 28 )
#define ENT_BOSS			( 2 << 29 )
#define ENT_GALDOVFINAL		( 2 << 30 )
