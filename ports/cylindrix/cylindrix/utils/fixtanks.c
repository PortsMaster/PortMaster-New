/* Reads in the cooked binary tanks.tbf file and converts it to
   a text YAML file.
   Note: the reason this exists is so cylindrix will run on 64 bit and big endian platforms.
*/
#include <stdio.h>
#include <stdlib.h>

typedef float Float_Point[3];

typedef float Float_Vector[3];

typedef struct {
    Float_Point position;  /* absolute x-y-z position */
    Float_Vector front;    /* the direction considered forward */
    Float_Vector up;       /* the direction considered up */
} Orientation;

typedef struct {
    float min_x;
    float max_x;
    float min_y;
    float max_y;
    float min_z;
    float max_z;
} BoundingBox;

typedef struct {
    int min_x;
    int max_x;
    int min_y;
    int max_y;
    int min_z;
    int max_z;
} MagicBoundingBox;

typedef int Edge[2];

typedef struct {
    int edge;   /* NOTE: was pointer */
    int edges;
} EdgeTable;

enum VehicleType { Wasp, Beetle, Flea, Mosquito, Spider, Dragonfly, Roach,
                   Locust };

typedef enum { RED_TEAM, BLUE_TEAM, NO_TEAM } team_type;

enum VehicleMode { Air, Surface, Landing };

typedef struct {

    /* General information about this vehicle */

    enum VehicleType vtype;         /* type of vehicle */
    team_type team;                 /* Team that this vehicle is on */
    enum VehicleMode vehicle_mode;  /* Is the vehicle on the surface? */
    short alive;                    /* Is the vehicle still alive? */
    float surface_rad;              /* radius at which vehicle skims the surface */

    /* Information about this vehicles 3d object */
    int obj;                  /* the 3d-object centered at the origin */ /* NOTE: was a pointer */
    int world_obj;            /* the 3d-object in world coordinates */ /* NOTE: was a pointer */
    int collision_obj;        /* 3d-object used for collisions centered at the origin */ /* NOTE: was a pointer */
    int world_collision_obj;  /* 3d-object used for collisions in world coords */ /* NOTE: was a pointer */

    BoundingBox box;                 /* the x-y-z extents of the vehicles collision_obj */
    MagicBoundingBox mbox;           /* the x-y-z extents in fixed-point */
    EdgeTable collision_edges;       /* all the edges in the vehicle collision obj */

    Orientation orient;  /* the vehicles current orientation */

    /* Information about this vehicles movement and rotation */

    Float_Vector vel;  /* current velocity */

    float air_forward_speed;      /* current air speed (units per frame) */
    float air_max_forward_speed;  /* maximum air speed (units per frame) */
    float air_inc_forward_speed;  /* incremental forward thrust */
    float air_max_sidestep_speed;  /* maximum sidesteping speed */
    float air_inc_sidestep_speed;  /* incremental sidesteping speed */

    float air_rise_rot_speed;  /* current rotation speed about the right axis */
    float air_spin_rot_speed;  /* current rotation speed about the front axis */
    float air_inc_rot_speed;  /* incremental rotation speed */
    float air_max_rot_speed;  /* rotation speed (radians per frame) */

    float surface_max_speed;  /* max surface speed of vehicle (units per frame) */
    float surface_inc_speed;  /* incremental surface speed */
    float surface_inc_sidestep_speed;  /* incremental sidesteping speed */

    float surface_rot_speed;      /* current rotation speed */
    float surface_inc_rot_speed;  /* incremental rotation speed */
    float surface_max_rot_speed;  /* max surface rotation speed (radians per frame) */

    /* Information about this vehicles weapons */

    int target;  /* point that the missiles are locked on */ /* NOTE: was a pointer */

    float laser_speed;             /* speed of lasers */
    short laser_life;              /* frames a laser remains active */
    short laser_damage;            /* Number of hit points each laser takes off */
    short laser_reload_time;       /* time it takes to reload in frames */
    short frames_till_fire_laser;  /* number of frames until we can shoot */

    float missile_speed;             /* speed of missiles */
    float turning_angle;             /* radians that a missile can turn per frame */
    short missile_life;              /* frames that a missile remains active */
    short missile_damage;            /* damage done on collision in hitpoints */
    short missile_reload_time;       /* time it takes a missile to be reloaded */
    short frames_till_fire_missile;  /* time till we can fire another missile */
    short missile_generation_time;   /* time it takes a missile to be created */
    short frames_till_new_missile;   /* time left until a new missile is generated */
    short max_missile_storage;       /* maximum number of missiles that can be held */
    short missiles_stored;           /* current number of stored missiles */

    short max_projectiles;        /* max number of active projectiles */
    int projectile_list;  /* linked list of active projectiles */ /* NOTE: was a pointer */

    /* Information about this vehicles hitpoints */

    int max_hitpoints;      /* maximum hitpoints allowed */
    int current_hitpoints;  /* current number of hitpoints */

    short ramming_active;    /* ramming on indicator */
    short ramming_damage;    /* hitpoints of damage resulting from one ram */

    short double_lasers_active;  /* does this vehicle shoot two lasers? */

    short mine_reload_time;          /* time it takes to reload a mine */
    short mine_damage;               /* amount of damage a mine will inflect */
    short mine_life;                 /* number of frames a mine will remain active */

    short cs_missile_reload_time;    /* time to reload a cs_missile */
    short cs_missile_life;           /* time a cs_missile remains active */
    float cs_missile_speed;          /* speed of a cs_missile in units per frame */

    short controls_scrambled;        /* true when hit by a cs_missile */
    short frames_till_unscramble;    /* number of frames till controls will be normal */
    short scramble_life;             /* total number of frames controls will be scrambled */

    short traitor_missile_reload_time; /* time to reload a traitor_missile */
    short traitor_missile_life;        /* time a traitor_missile remains active */
    float traitor_missile_speed;       /* speed of a traitor_missile */

    short traitor_life;                   /* amount of time a vehicle is a traitor */
    short traitor_active;                 /* true when hit by a traitor_missile */
    short frames_till_traitor_deactivate; /* frames left for this vehicle to be a traitor */

    short anti_missile_active;       /* TRUE if anti-missile system is on */

    short cloaking_active;        /* TRUE if clocking is enabled */
    short cloak_reload_time;      /* number of frames till x key becomes active again */
    short frames_till_cloak;      /* number of frames till x key becomes active again (decrements every frame) */
    short cloak_time;             /* number of frames cloaking remains active until you suck another missile */
    short frames_till_cloak_suck; /* number of frames until cloak will suck a missile (decrements every frame) */

    short decoy_life;         /* time a decoy ships remains active */
    short decoy_reload_time;  /* number of frames till you can shoot a missile or another decoy */

} Vehicle;

int s_count;
#define DUMP_ITEM(fmt, item, comment)							\
	do							                                \
    {                                                           \
        s_count = fprintf(file_out, "  %s: ", #item);			\
        s_count += fprintf(file_out, fmt, v->item);             \
        while (s_count < 40)                                    \
        {                                                       \
            fprintf(file_out, " ");                             \
            s_count++;                                          \
        }                                                       \
        fprintf(file_out, "# %s\n", comment);       			\
	} while(0)													\

void main(int argc, char* argv[])
{
	FILE* file_in = fopen(argv[1], "rb");
	if (!file_in)
	{
		fprintf(stderr, "failed to open file \"%s\"\n", argv[1]);
		exit(1);
	}

	FILE* file_out = fopen("new_tanks.yaml", "w");
	if (!file_out)
	{
		fprintf(stderr, "failed to open file \"new_tanks.yaml\"\n", argv[1]);
		exit(1);
	}

	/* debug stuff remove */
	printf("sizeof(Vehicle) = %ld\n", sizeof(Vehicle));
	printf("sizeof(enum VehicleType) = %ld\n", sizeof(enum VehicleType));
	printf("sizeof(team_type) = %ld\n", sizeof(team_type));
	printf("sizeof(short) = %ld\n", sizeof(short));
	
	float temp = 0.3f;
	printf("%.5f in hex = %x\n", temp, *(unsigned int*)&temp);
	temp = 0.1f;
	printf("%.5f in hex = %x\n", temp, *(unsigned int*)&temp);
	temp = -0.0f;
	printf("%.5f in hex = %x\n", temp, *(unsigned int*)&temp);
	temp = 0.97f;
	printf("%.5f in hex = %x\n", temp, *(unsigned int*)&temp);
	temp = 0.0f;
	printf("%.5f in hex = %x\n", temp, *(unsigned int*)&temp);
	*(unsigned int*)&temp = 0x411b3333;
	printf("%.5f in hex = %x\n", temp, *(unsigned int*)&temp);

	Vehicle vehicles[100];
	Vehicle* v = vehicles;

	/* more debug dump stuff */
	printf("\n");
	printf("vtype offset = %d bytes\n", (char*)&v->vtype - (char*)v);
	printf("vehicle_mode offset = %d bytes\n", (char*)&v->vehicle_mode - (char*)v);
	printf("alive offset = %d bytes\n", (char*)&v->alive - (char*)v);
	printf("surface_radius offset = %d bytes\n", (char*)&v->surface_rad - (char*)v);
	printf("surface_radius offset = %x hex\n", (char*)&v->air_forward_speed - (char*)v, (char*)&v->air_forward_speed - (char*)v);

	while (fread(v, sizeof(Vehicle), 1, file_in) > 0)
	{
		fprintf(file_out, "-\n");
		DUMP_ITEM("%d", vtype, "type of vehicle");
		DUMP_ITEM("%.5f", surface_rad, "radius at which vehicle skims the surface");

		DUMP_ITEM("%.5f", air_forward_speed, "current air speed (units per frame)");
		DUMP_ITEM("%.5f", air_max_forward_speed, "maximum air speed (units per frame)");
		DUMP_ITEM("%.5f", air_inc_forward_speed, "incremental forward thrust");
		DUMP_ITEM("%.5f", air_max_sidestep_speed, "maximum sidesteping speed");
		DUMP_ITEM("%.5f", air_inc_sidestep_speed, "incremental sidesteping speed");
   		DUMP_ITEM("%.5f", air_rise_rot_speed, "current rotation speed about the right axis");
   		DUMP_ITEM("%.5f", air_spin_rot_speed, "current rotation speed about the front axis");
   		DUMP_ITEM("%.5f", air_inc_rot_speed, "incremental rotation speed");
   		DUMP_ITEM("%.5f", air_max_rot_speed, "rotation speed (radians per frame)");

		DUMP_ITEM("%.5f", surface_max_speed, "max surface speed of vehicle (units per frame)");
   		DUMP_ITEM("%.5f", surface_inc_speed, "incremental surface speed");
   		DUMP_ITEM("%.5f", surface_inc_sidestep_speed, "incremental sidesteping speed");

   		DUMP_ITEM("%.5f", surface_rot_speed, "current rotation speed");
   		DUMP_ITEM("%.5f", surface_inc_rot_speed, "incremental rotation speed");
   		DUMP_ITEM("%.5f", surface_max_rot_speed, "max surface rotation speed (radians per frame)");
		

   		DUMP_ITEM("%.5f", laser_speed, "speed of lasers");
		DUMP_ITEM("%hd", laser_life, "frames a laser remains active");
		DUMP_ITEM("%hd", laser_damage, "Number of hit points each laser takes off");
		DUMP_ITEM("%hd", laser_reload_time, "time it takes to reload in frames");
		DUMP_ITEM("%hd", frames_till_fire_laser, "number of frames until we can shoot");

		DUMP_ITEM("%.5f", missile_speed, "speed of missiles");
		DUMP_ITEM("%.5f", turning_angle, "radians that a missile can turn per frame");
		DUMP_ITEM("%hd", missile_life, "frames that a missile remains active");
		DUMP_ITEM("%hd", missile_damage, "damage done on collision in hitpoints");
		DUMP_ITEM("%hd", missile_reload_time, "time it takes a missile to be reloaded");
		DUMP_ITEM("%hd", frames_till_fire_missile, "time till we can fire another missile");
		DUMP_ITEM("%hd", missile_generation_time, "time it takes a missile to be created");
		DUMP_ITEM("%hd", frames_till_new_missile, "time left until a new missile is generated");
		DUMP_ITEM("%hd", max_missile_storage, "maximum number of missiles that can be held");
		DUMP_ITEM("%hd", missiles_stored, "current number of stored missiles");

		DUMP_ITEM("%hd", max_projectiles, "max number of active projectiles");

		DUMP_ITEM("%d", max_hitpoints, "maximum hitpoints allowed");
		DUMP_ITEM("%d", current_hitpoints, "current number of hitpoints");

		DUMP_ITEM("%hd", ramming_active, "ramming on indicator");
		DUMP_ITEM("%hd", ramming_damage, "hitpoints of damage resulting from one ram");

		DUMP_ITEM("%hd", double_lasers_active, "does this vehicle shoot two lasers?");

		DUMP_ITEM("%hd", mine_reload_time, "time it takes to reload a mine");
		DUMP_ITEM("%hd", mine_damage, "amount of damage a mine will inflect");
		DUMP_ITEM("%hd", mine_life, "number of frames a mine will remain active");

		DUMP_ITEM("%hd", cs_missile_reload_time, "time to reload a cs_missile");
		DUMP_ITEM("%hd", cs_missile_life, "time a cs_missile remains active");
		DUMP_ITEM("%.5f", cs_missile_speed, "speed of a cs_missile in units per frame");

		DUMP_ITEM("%hd", controls_scrambled, "true when hit by a cs_missile");
		DUMP_ITEM("%hd", frames_till_unscramble, "number of frames till controls will be normal");
		DUMP_ITEM("%hd", scramble_life, "total number of frames controls will be scrambled");

		DUMP_ITEM("%hd", traitor_missile_reload_time, "time to reload a traitor_missile");
		DUMP_ITEM("%hd", traitor_missile_life, "time a traitor_missile remains active");
		DUMP_ITEM("%.5f", traitor_missile_speed, "speed of a traitor_missile");

		DUMP_ITEM("%hd", traitor_life, "amount of time a vehicle is a traitor");
		DUMP_ITEM("%hd", traitor_active, "true when hit by a traitor_missile");
		DUMP_ITEM("%hd", frames_till_traitor_deactivate, "frames left for this vehicle to be a traitor");

		DUMP_ITEM("%hd", anti_missile_active, "TRUE if anti-missile system is on");

		DUMP_ITEM("%hd", cloaking_active, "TRUE if clocking is enabled");
		DUMP_ITEM("%hd", cloak_reload_time, "number of frames till x key becomes active again");
		DUMP_ITEM("%hd", frames_till_cloak, "number of frames till x key becomes active again (decrements every frame)");
		DUMP_ITEM("%hd", cloak_time, "number of frames cloaking remains active until you suck another missile");
		DUMP_ITEM("%hd", frames_till_cloak_suck, "number of frames until cloak will suck a missile (decrements every frame)");

		DUMP_ITEM("%hd", decoy_life, "time a decoy ships remains active");
    	DUMP_ITEM("%hd", decoy_reload_time, "number of frames till you can shoot a missile or another decoy");

		v++;
	}
}
