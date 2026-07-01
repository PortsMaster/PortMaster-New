/* Reads in the cooked binary people.dat file and converts it to
   a text YAML file.
   Note: This is so cylindrix will run on 64 bit and big endian platforms.
*/
#include <stdio.h>
#include <stdlib.h>

#define NUMBER_CHARACTER_SOUNDS 7 /* Number of things a character can say */
typedef char string[80];

typedef enum { ATTACK, GET_ENERGY, PANIC, BEZERK,
               HIDE, GROUPUP, GET_PYLONS, PROTECT,
               KILL_RADAR_BASE, PROTECT_RADAR_BASE, EVADE } state_type;

struct character_t
{
	char            name[40];
	char            filename[15]; /* Name of the pcx file */
	string          sample_filenames[NUMBER_CHARACTER_SOUNDS];
	unsigned int    hack_padding[NUMBER_CHARACTER_SOUNDS];  /* NOTE: was SYS_SOUNDHANDLE */
	state_type      state;

	unsigned char   passive_aggressive;     /* 1-100...1-50 is passive 51-100 is aggressive */
	unsigned char   bravery_cowardice;      /* 1-100...same scheme */
	unsigned char   aerial_ground;          /* 1-100...same scheme */
	unsigned char   obedience_disobedience; /* 1-100...same scheme */
	unsigned char   pylon_grab;             /* 1-50 hates pylons...50-100 likes em */
	unsigned char   radar_kill;             /* 1-50 wont kill, 50-100 loves to kill */
	unsigned char   radar_protect;          /* 1-50 protects, 50-100 doesn't care */
	unsigned char   skill_level;            /* Skill level 1-5  */
	unsigned char   preferred_vehicle;      /* See vehicletype */
};

int s_count;

#define DUMP_ITEM(fmt, value, field_name)						\
	do															\
    {															\
		fprintf(file_out, "  %s: ", field_name);				\
		fprintf(file_out, fmt, value);							\
		fprintf(file_out, "\n");								\
	} while(0)													\

void main(int argc, char* argv[])
{
	FILE* file_in = fopen(argv[1], "rb");
	if (!file_in)
	{
		fprintf(stderr, "failed to open file \"%s\"\n", argv[1]);
		exit(1);
	}

	FILE* file_out = fopen("new_people.yaml", "w");
	if (!file_out)
	{
		fprintf(stderr, "failed to open file \"new_people.yaml\"\n", argv[1]);
		exit(1);
	}

	struct character_t characters[100];
	struct character_t* c = characters;
	while (fread(c, sizeof(struct character_t), 1, file_in) > 0)
	{
		fprintf(file_out, "-\n");
		
		DUMP_ITEM("%s", c->name, "name");
		DUMP_ITEM("%s", c->filename, "pcx_file");

		DUMP_ITEM("%s", c->sample_filenames[0], "greeting");
		DUMP_ITEM("%s", c->sample_filenames[1], "affirmation");
		DUMP_ITEM("%s", c->sample_filenames[2], "negation");
		DUMP_ITEM("%s", c->sample_filenames[3], "gloat");
		DUMP_ITEM("%s", c->sample_filenames[4], "despair");
		DUMP_ITEM("%s", c->sample_filenames[5], "death");
		DUMP_ITEM("%s", c->sample_filenames[6], "victory");

		DUMP_ITEM("%hhd", c->passive_aggressive, "passive_aggressive");

		DUMP_ITEM("%hhd", c->bravery_cowardice, "bravery_cowardice");
		DUMP_ITEM("%hhd", c->aerial_ground, "aerial_ground");
		DUMP_ITEM("%hhd", c->obedience_disobedience, "obedience_disobedience");
		DUMP_ITEM("%hhd", c->pylon_grab, "pylon_grab");
		DUMP_ITEM("%hhd", c->radar_kill, "radar_kill");
		DUMP_ITEM("%hhd", c->radar_protect, "radar_protect");
		DUMP_ITEM("%hhd", c->skill_level, "skill_level");
		DUMP_ITEM("%hhd", c->preferred_vehicle, "preferred_vehicle");

		c++;
	}
}
