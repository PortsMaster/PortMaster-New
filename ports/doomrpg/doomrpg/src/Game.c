
#include <SDL.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "DoomRPG.h"
#include "DoomCanvas.h"
#include "Entity.h"
#include "EntityDef.h"
#include "EntityMonster.h"
#include "Game.h"
#include "Render.h"
#include "Hud.h"
#include "Menu.h"
#include "Combat.h"
#include "CombatEntity.h"
#include "MenuSystem.h"
#include "Player.h"
#include "Sound.h"
#include "SDL_Video.h"


// #define CONFIG_VERSION 22 // Original Brew Version

#define CONFIG_VERSION 23 // New

static void Game_log(const char* format, ...) {
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
}

int Game_getResourceMapID(Game_t* game, char* mapName)
{
	for (int i = 0; i < MAPFILE_MAX; i++) {

		if (!SDL_strcmp(game->mapFiles[i], mapName)) {
			return i + MAP_INTRO;
		}
	}
	printf("ERROR: Cannot determine resource ID for '%s'", mapName);

	return MAP_INTRO;
}

Game_t* Game_init(Game_t* game, DoomRPG_t* doomRpg)
{
	int i;
	EntityMonster_t* entityMonst;

	printf("Game_init\n");

	if (game == NULL)
	{
		game = SDL_malloc(sizeof(Game_t));
		if (game == NULL) {
			return NULL;
		}
	}
	SDL_memset(game, 0, sizeof(Game_t));

	SDL_memset(game->entities, 0, (sizeof(Entity_t) * 400));
	SDL_memset(game->entityMonsters, 0, (sizeof(EntityMonster_t) * 100));

	game->activeMonsters = NULL;
	game->combatMonsters = NULL;
	game->inactiveMonsters = NULL;
	game->spawnMonster = NULL;
	game->passCode = NULL;
	game->newMapName[0] = '\0';
	game->fileMapName[0] = '\0';
	game->waitTime = 0;
	game->activePortal = false;
	game->disableAI = 0;
	game->soundMonster = NULL;
	game->doomRpg = doomRpg;

	i = 0;
	do {
		game->entities[i].doomRpg = doomRpg;
	} while (++i < 400);

	i = 0;
	do {

		entityMonst = &game->entityMonsters[i];
		entityMonst->doomRpg = doomRpg;
		entityMonst->ce.doomRpg = doomRpg;
	} while (++i < 100);

	strncpy(game->mapNames[MAPNAME_ENTRANCE], "Entrance", 24);
	strncpy(game->mapNames[MAPNAME_JUNCTION], "Junction", 24);
	strncpy(game->mapNames[MAPNAME_S01], "Sector 1", 24);
	strncpy(game->mapNames[MAPNAME_S02], "Sector 2", 24);
	strncpy(game->mapNames[MAPNAME_S03], "Sector 3", 24);
	strncpy(game->mapNames[MAPNAME_S04], "Sector 4", 24);
	strncpy(game->mapNames[MAPNAME_S05], "Sector 5", 24);
	strncpy(game->mapNames[MAPNAME_S06], "Sector 6", 24);
	strncpy(game->mapNames[MAPNAME_S07], "Sector 7", 24);
	strncpy(game->mapNames[MAPNAME_JUNCTION_DESTROYED], "Junction", 24);
	strncpy(game->mapNames[MAPNAME_REACTOR], "Reactor", 24);

	strncpy(game->mapFiles[MAPFILE_INTRO], "/intro.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_L01], "/level01.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_L02], "/level02.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_L03], "/level03.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_L04], "/level04.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_L05], "/level05.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_L06], "/level06.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_L07], "/level07.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_JUNCTION], "/junction.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_JUNCTION_DESTROYED], "/junction_destroyed.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_ITEMS], "/items.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_REACTOR], "/reactor.bsp", 24);
	strncpy(game->mapFiles[MAPFILE_END_GAME], "/endgame.bsp", 24);

	return game;
}

void Game_activate(Game_t* game, Entity_t* entity)
{
	EntityMonster_t* monster;

	monster = entity->monster;
	if ((entity->info & 0x80000) == 0) {
		if (monster->nextOnList) {
			if (entity == game->inactiveMonsters && monster->nextOnList == game->inactiveMonsters) {
				game->inactiveMonsters = NULL;
			}
			else {
				if (entity == game->inactiveMonsters) {
					game->inactiveMonsters = monster->nextOnList;
				}
				monster->nextOnList->monster->prevOnList = monster->prevOnList;
				monster->prevOnList->monster->nextOnList = monster->nextOnList;
			}
		}
		if (game->activeMonsters == NULL) {
			monster->nextOnList = entity;
			monster->prevOnList = entity;
			game->activeMonsters = entity;
		}
		else {
			monster->prevOnList = game->activeMonsters->monster->prevOnList;
			monster->nextOnList = game->activeMonsters;
			game->activeMonsters->monster->prevOnList->monster->nextOnList = entity;
			game->activeMonsters->monster->prevOnList = entity;
		}
		entity->info |= 0x80000;

		// Check Sight Sound
		if (EntityMonster_getSoundID(entity->monster, 1)) {
			if ((game->soundMonster == NULL) || (game->soundMonster->def->eSubType < entity->def->eSubType)) {
				game->soundMonster = entity;
			}
		}
	}
	else {
		//printf("activate: already active\event");
	}
}

void Game_advanceTurn(Game_t* game)
{
	Player_updateBerserkerTics(game->doomRpg->player);
	game->monstersTurn = true;
	game->ignoreMonsterAI = false;
	game->doomRpg->doomCanvas->skipCheckState = true;
}

GameSprite_t* Game_gsprite_allocAnim(Game_t* game, int index, int x, int y)
{
	int i, j, time, upTime;
	GameSprite_t* gSpr;

	for (i = 0; i < MAX_CUSTOM_SPRITES && (game->gsprites[i].flags & 0x1) != 0x0; ++i) {}

	if (i == MAX_CUSTOM_SPRITES) {

		time = 0;
		i = 0;
		for (j = 0; j < MAX_CUSTOM_SPRITES; ++j)
		{
			upTime = DoomRPG_GetUpTimeMS() - game->gsprites[j].time;
			if (time < upTime) {
				time = upTime;
				i = j;
			}
		}
	}

	gSpr = &game->gsprites[i];
	gSpr->frame = -1;
	gSpr->index = index;
	gSpr->sprite = game->doomRpg->render->customSprites[i];
	gSpr->sprite->x = x;
	gSpr->sprite->y = y;
	gSpr->flags = 1;

	switch (gSpr->index)
	{

	case 1:
		gSpr->sprite->info = 180;
		game->f684l = 1;
		Sound_playSound(game->doomRpg->sound, 5061, 0, 4);
		DoomCanvas_startShake(game->doomRpg->doomCanvas, 200, 2, 0);
		break;

	case 2:
		gSpr->sprite->info = 1207;
		game->f684l = 1;
		Sound_playSound(game->doomRpg->sound, 5066, 0, 2);
		break;

	case 4:
		gSpr->sprite->info = 181;
		DoomCanvas_startShake(game->doomRpg->doomCanvas, 450, 2, 0);
		break;

	case 5:
		gSpr->sprite->info = 182;
		break;

	case 6:
		gSpr->sprite->info = 184;
		break;

	case 7:
		gSpr->sprite->info = 185;
		break;

	case 8:
		gSpr->sprite->info = 186;
		break;

	case 9:
		gSpr->sprite->info = 187;
		break;

	case 10:
		gSpr->sprite->info = 188;
		break;

	case 11:
		gSpr->sprite->info = 189;
		break;

	case 12:
		gSpr->sprite->info = 190;
		break;

	case 13:
		gSpr->sprite->info = 191;
		break;
	}

	gSpr->sprite->info |= 0x80000000;
	gSpr->time = upTime = DoomRPG_GetUpTimeMS();

	if ((game->gSpriteDurationTime == 0) || (upTime < game->gSpriteDurationTime)) {
		if (gSpr->index == 9) {
			upTime += 10;
		}
		else {
			upTime += 150;
		}
		game->gSpriteDurationTime = upTime;
	}

	Render_relinkSprite(game->doomRpg->render, gSpr->sprite);
	game->activeSprites = 1;

	return gSpr;
}

void Game_gsprite_clear(Game_t* game)
{
	for (int i = 0; i < MAX_CUSTOM_SPRITES; i++) {
		game->gsprites[i].flags = 0;
		game->gsprites[i].sprite = NULL;
	}
	game->activeSprites = 0;
	game->f684l = 0;
}

void Game_gsprite_update(Game_t* game)
{
	GameSprite_t* gSprite;
	int i, uptime, time, v19, rndRadius, active;

	//printf("game->activeSprites %d\event", game->activeSprites);
	if (!game->activeSprites) {
		return;
	}

	active = 0;

	game->gSpriteDurationTime = 0;
	for (i = 0; i < MAX_CUSTOM_SPRITES; ++i) {
		
		gSprite = &game->gsprites[i];
		
		
		if ((gSprite->flags & 1) != 0 && (gSprite->flags & 2) == 0 && gSprite->index != 3) {
			++active;

			uptime = DoomRPG_GetUpTimeMS() - gSprite->time;
			if (uptime >= 0) {
				time = (gSprite->index == 9) ? 750 : 450;

				if (uptime < time) {

					time = (gSprite->index == 9) ? 10 : 150;
					v19 = ((uptime / time) & 0xff) % 3;

					gSprite->sprite->info &= 0xFFFFE1FF;
					gSprite->sprite->info |= v19 << 9;

					if (gSprite->frame != v19) {
						gSprite->frame = v19;
						DoomCanvas_updateViewTrue(game->doomRpg->doomCanvas);
					}

					if ((game->gSpriteDurationTime == 0) || ((time * (v19 + 1) + gSprite->time) < game->gSpriteDurationTime)) {
						game->gSpriteDurationTime = time * (v19 + 1) + gSprite->time;
					}
				}
				else {
					gSprite->sprite->info |= 0x10000;

					if (((gSprite->flags & 4) == 0) && (gSprite->index == 1)) {
						rndRadius = (DoomRPG_randNextInt(&game->doomRpg->random) & 0xff) / 11;
						Game_radiusHurtEntities(game, gSprite->sprite->x, gSprite->sprite->y, rndRadius + 5, rndRadius + 5, 0, 0);
					}

					gSprite->flags = gSprite->flags & 0xFFFFFFFC | 2;
					DoomCanvas_updateViewTrue(game->doomRpg->doomCanvas);
				}
			}
		}
	}

	if (active != 0) {
		active = 1;
	}

	game->activeSprites = (byte)active;

	if ((game->activeSprites == 0) && (game->f684l != 0)) {
		Player_selectWeapon(game->doomRpg->player, game->doomRpg->player->weapon);
		game->f684l = 0;
	}
}

void Game_hurtEntityAt(Game_t* game, int i, int i2, int i3, int i4, int z, int z2)
{
	Entity_t* entity;
	Sprite_t* sprite;
	char text[128];
	int soundId;

	if ((game->doomRpg->doomCanvas->viewX >> 6) != (i >> 6) || (game->doomRpg->doomCanvas->viewY >> 6) != (i2 >> 6)) {
		entity = Game_findMapEntityXYFlag(game, i, i2, 22151);
		if (entity && (entity->info & 0x40000) != 0) {
			if (entity->monster) {

				if (z) {
					Game_gsprite_allocAnim(game, 4, entity->monster->x, entity->monster->y);
				}

				Entity_pain(entity, i3, i4);

				if (CombatEntity_getHealth(&entity->monster->ce) <= 0) {
					SDL_snprintf(text, sizeof(text), "%s took %d damage! %s died!", entity->def->name, (i3 + i4), entity->def->name);
					Hud_addMessage(game->doomRpg->hud, text);
					Entity_died(entity);
					return;
				}
				SDL_snprintf(text, sizeof(text), "%s took %d damage!", entity->def->name, (i3 + i4));
				Hud_addMessage(game->doomRpg->hud, text);

				// Pain Sound
				soundId = EntityMonster_getSoundRnd(entity->monster, 6);
				if (soundId != 0) {
					Sound_playSound(game->doomRpg->sound, soundId, 0, 2);
					return;
				}
			}
			else if (entity->def->eType != 10) {
				if (entity->def->eType != 12 || entity->def->eSubType != 3) {
					if (entity->def->eType != 12 || entity->def->eSubType != 4) {

						if (z) {
							sprite = &game->doomRpg->render->mapSprites[(entity->info & 65535) - 1];
							Game_gsprite_allocAnim(game, 4, sprite->x, sprite->y);
						}

						Entity_died(entity);
					}
				}
			}

		}
	}
	else if (!z) {
		Player_painEvent(game->doomRpg->player, NULL);
		if (z2) {
			i3 = (i3 * 192) >> 8;
			i4 = (i4 * 192) >> 8;
		}
		if (i3 + i4 > 0) {
			Player_pain(game->doomRpg->player, i3, i4);
		}
	}
}

void Game_deactivate(Game_t* game, Entity_t* entity)
{
	EntityMonster_t* monster;

	monster = entity->monster;
	if (entity->info & 0x80000) {

		if (monster->nextOnList) {
			if (entity == game->activeMonsters && monster->nextOnList == game->activeMonsters) {
				game->activeMonsters = NULL;
			}
			else {
				if (entity == game->activeMonsters) {
					game->activeMonsters = monster->nextOnList;
				}
				monster->nextOnList->monster->prevOnList = monster->prevOnList;
				monster->prevOnList->monster->nextOnList = monster->nextOnList;
			}
		}

		if (game->inactiveMonsters == NULL) {
			monster->nextOnList = entity;
			monster->prevOnList = entity;
			game->inactiveMonsters = entity;
		}
		else {
			monster->prevOnList = game->inactiveMonsters->monster->prevOnList;
			monster->nextOnList = game->inactiveMonsters;
			game->inactiveMonsters->monster->prevOnList->monster->nextOnList = entity;
			game->inactiveMonsters->monster->prevOnList = entity;
		}
		entity->info &= -524289;
	}
	else {
		//printf("deactivate: already inactive\event");
	}
}

void Game_radiusHurtEntities(Game_t* game, int i, int i2, int i3, int i4, int z, int z2)
{
	if (!z) {
		Game_hurtEntityAt(game, i - 64, i2, i3, i4, z, z2);
		Game_hurtEntityAt(game, i + 64, i2, i3, i4, z, z2);
		Game_hurtEntityAt(game, i, i2 - 64, i3, i4, z, z2);
		Game_hurtEntityAt(game, i, i2 + 64, i3, i4, z, z2);
		int i5 = i3 >> 1;
		int i6 = i4 >> 1;
		if (i5 != 0 || i6 != 0) {
			Game_hurtEntityAt(game, i - 64, i2 + 64, i5, i6, z, z2);
			Game_hurtEntityAt(game, i + 64, i2 + 64, i5, i6, z, z2);
			Game_hurtEntityAt(game, i + 64, i2 - 64, i5, i6, z, z2);
			Game_hurtEntityAt(game, i - 64, i2 - 64, i5, i6, z, z2);
			return;
		}
		return;
	}
	Game_hurtEntityAt(game, i - 64, i2, i3, i4, z, z2);
	Game_hurtEntityAt(game, i + 64, i2, i3, i4, z, z2);
	Game_hurtEntityAt(game, i, i2 - 64, i3, i4, z, z2);
	Game_hurtEntityAt(game, i, i2 + 64, i3, i4, z, z2);
	Game_hurtEntityAt(game, i - 64, i2 + 64, i3, i4, z, z2);
	Game_hurtEntityAt(game, i + 64, i2 + 64, i3, i4, z, z2);
	Game_hurtEntityAt(game, i + 64, i2 - 64, i3, i4, z, z2);
	Game_hurtEntityAt(game, i - 64, i2 - 64, i3, i4, z, z2);
	int i7 = i3 >> 1;
	int i8 = i4 >> 1;
	Game_hurtEntityAt(game, i - 128, i2 - 128, i7, i8, z, z2);
	Game_hurtEntityAt(game, i - 64, i2 - 128, i7, i8, z, z2);
	Game_hurtEntityAt(game, i, i2 - 128, i7, i8, z, z2);
	Game_hurtEntityAt(game, i + 64, i2 - 128, i7, i8, z, z2);
	Game_hurtEntityAt(game, i + 128, i2 - 128, i7, i8, z, z2);
	Game_hurtEntityAt(game, i - 128, i2 + 128, i7, i8, z, z2);
	Game_hurtEntityAt(game, i - 64, i2 + 128, i7, i8, z, z2);
	Game_hurtEntityAt(game, i, i2 + 128, i7, i8, z, z2);
	Game_hurtEntityAt(game, i + 64, i2 + 128, i7, i8, z, z2);
	Game_hurtEntityAt(game, i + 128, i2 + 128, i7, i8, z, z2);
	Game_hurtEntityAt(game, i - 128, i2 - 64, i7, i8, z, z2);
	Game_hurtEntityAt(game, i - 128, i2, i7, i8, z, z2);
	Game_hurtEntityAt(game, i - 128, i2 + 64, i7, i8, z, z2);
	Game_hurtEntityAt(game, i + 128, i2 - 64, i7, i8, z, z2);
	Game_hurtEntityAt(game, i + 128, i2, i7, i8, z, z2);
	Game_hurtEntityAt(game, i + 128, i2 + 64, i7, i8, z, z2);

}

void Game_endMonstersTurn(Game_t* game)
{
	game->monstersTurn = false;
}

Entity_t* Game_getEntityByIndex(Game_t* game, int indx)
{
	if (indx != -1) {
		return &game->entities[indx];
	}
	return NULL;
}

void Game_eventFlagsForMovement(Game_t* game, int i, int i2, int i3, int i4)
{
	int i5 = 0;
	int i6 = 0;
	if (i == -1 && i2 == -1) {
		i5 = 240;
		i6 = 15;
	}
	else if (i < i3) {
		i5 = 32;
		i6 = 8;
	}
	else if (i > i3) {
		i5 = 128;
		i6 = 2;
	}
	else if (i2 > i4) {
		i5 = 16;
		i6 = 4;
	}
	else if (i2 < i4) {
		i5 = 64;
		i6 = 1;
	}
	game->eventFlags[0] = i5;
	game->eventFlags[1] = i6;
}

Entity_t* Game_findMapEntityXYFlag(Game_t* game, int x, int y, int flags)
{
	Entity_t* entity;

	if ((flags & 0x100) && (x >> 6) == (game->doomRpg->doomCanvas->destX >> 6) && (y >> 6) == (game->doomRpg->doomCanvas->destY >> 6)) {
		return &game->entities[1];
	}
	for (entity = Game_findMapEntityXY(game, x, y); entity != NULL; entity = entity->nextOnTile) {
		if ((flags & (1 << entity->def->eType)) != 0) {
			return entity;
		}
	}
	return NULL;
}

Entity_t* Game_findMapEntityXY(Game_t* game, int x, int y)
{
	int srcX = x >> 6;
	int srcY = y >> 6;
	if (srcX < 0 || srcX >= 32 || srcY < 0 || srcY >= 32) {
		return NULL;
	}
	return game->entityDb[(srcY * 32) + srcX];
}

void Game_changeMap(Game_t* game)
{
	int mapNameId;

	if (game->changeMapParam != 0) {

		game->spawnParam = (game->changeMapParam << 1) >> 9;
		mapNameId = Game_getResourceMapID(game->doomRpg->game, game->doomRpg->render->mapStringsIDs[game->changeMapParam & 0xff]);

		if ((game->changeMapParam & CHANGEMAP_SHOWSTATS_BIT) != 0) {
			Player_addLevelStats(game->doomRpg->player, true);
			game->doomRpg->menu->mapNameId = mapNameId;
			//if (Render.mapStrings[game->changeMapParam].toString().compareTo("/endgame.bsp") == 0)
			if(mapNameId == MAP_END_GAME){
				MenuSystem_setMenu(game->doomRpg->menuSystem, MENU_MAP_STATS_OVERALL);
			}
			else {
				MenuSystem_setMenu(game->doomRpg->menuSystem, MENU_MAP_STATS);
			}
		}
		else {
			Player_addLevelStats(game->doomRpg->player, false);
			DoomCanvas_loadMap(game->doomRpg->doomCanvas, mapNameId);
		}
		game->changeMapParam = 0;
	}
}

void Game_givemap(Game_t* game)
{
	int i, j, count;
	Render_t* render = game->doomRpg->render;
	
	count = render->linesLength;
	for (i = 0; i < count; i++) {
		if ((render->lines[i].flags & 32) == 0) {
			render->lines[i].flags |= 128;
		}
	}
	count = render->numMapSprites;
	for (i = 0; i < count; i++) {
		render->mapSprites[i].info |= 0x10000000;
	}

	for (i = 0; i < 32; i++) {
		for (j = 0; j < 32; j++) {
			if (render->mapFlags[(i * 32) + j] & BIT_AM_ENTRANCE) {
				render->mapFlags[(i * 32) + j] |= BIT_AM_VISITED;
			}
		}
	}
}

boolean Game_checkConfigVersion(Game_t* game)
{
	SDL_RWops* configFile, * playerFile, * player2File, * worldFile;
	SDL_RWops* rw;
	int version, rnt;

	configFile = NULL;
	playerFile = NULL;
	player2File = NULL;
	worldFile = NULL;

	rnt = false;
	configFile = SDL_RWFromFile("Config", "r");
	if (configFile) {
		playerFile = SDL_RWFromFile("Player", "r");
		if (playerFile) {
			player2File = SDL_RWFromFile("Player2", "r");
			if (player2File) {
				worldFile = SDL_RWFromFile("World", "r");
				if (worldFile) {

					rw = SDL_RWFromFile("Config", "r");
					version = File_readInt(rw);
					if (version == CONFIG_VERSION) {
						rnt = true;
					}
					SDL_RWclose(rw);
				}
			}
		}
	}

	if (configFile) {
		SDL_RWclose(configFile);
	}
	if (playerFile) {
		SDL_RWclose(playerFile);
	}
	if (player2File) {
		SDL_RWclose(player2File);
	}
	if (worldFile) {
		SDL_RWclose(worldFile);
	}

	return rnt;
}

int Game_findEntity(Game_t* game, Entity_t* entity)
{
	int i;

	if (entity) {
		for (i = 0; i < game->numEntities; i++) {
			if (entity == &game->entities[i]) {
				return i;
			}
		}
	}
	return -1;
}

void Game_linkEntity(Game_t* game, Entity_t* entity, int x, int y)
{
    if (x < 0 || x >= 32 || y < 0 || y >= 32) {
        Game_log("Error: Attempt to link entity to invalid coordinates (%d, %d)\n", x, y);
        return;
    }

    Entity_t* entDb;
    int linkIndex = (y * 32) + x;

    entDb = game->entityDb[linkIndex];
    entity->nextOnTile = entDb;
    if (entity->nextOnTile) {
        entDb->prevOnTile = entity;
    }

    entity->prevOnTile = NULL;
    entity->linkIndex = linkIndex;
    game->entityDb[linkIndex] = entity;
    entity->info |= 0x4000000;
}

void Game_loadConfig(Game_t* game)
{
	SDL_RWops* rw;
	int version;
	byte boolData;
	int intData;
	
	printf("loadConfig\n");

	rw = SDL_RWFromFile("Config", "r");
	if (rw) {
		version = File_readInt(rw);
		if (version == CONFIG_VERSION) {
			boolData = File_readByte(rw);
			if (game) {
				game->doomRpg->doomCanvas->vibrateEnabled = boolData != 0 ? true : false;
			}

			intData = File_readInt(rw);
			if (game) {
				game->doomRpg->sound->volume = intData;
			}

			intData = File_readInt(rw);
			if (game) {
				DoomCanvas_setAnimFrames(game->doomRpg->doomCanvas, intData);
			}

			intData = File_readInt(rw);
			if (game) {
				game->doomRpg->player->totalDeaths = intData;
			}

			// New
			boolData = File_readByte(rw);
			sdlVideo.fullScreen = boolData != 0 ? true : false;

			// New
			boolData = File_readByte(rw);
			sdlVideo.vSync = boolData != 0 ? true : false;

			// New
			boolData = File_readByte(rw);
			sdlVideo.integerScaling = boolData != 0 ? true : false;

			// New
			boolData = File_readByte(rw);
			sdlVideo.displaySoftKeys = boolData != 0 ? true : false;
			
			// New
			intData = File_readInt(rw);
			sdlVideo.resolutionIndex = intData;

			// New
			intData = File_readInt(rw);
			if (game) {
				game->doomRpg->doomCanvas->mouseSensitivity = intData;
			}

			// New
			boolData = File_readByte(rw);
			if (game) {
				game->doomRpg->doomCanvas->mouseYMove = boolData != 0 ? true : false;
			}

			// New
			intData = File_readInt(rw);
			sdlController.deadZoneLeft = intData;

			// New
			intData = File_readInt(rw);
			sdlController.deadZoneRight = intData;

			// New
			boolData = File_readByte(rw);
			if (game) {
				game->doomRpg->doomCanvas->sndPriority = boolData != 0 ? true : false;
			}

			// New
			boolData = File_readByte(rw);
			if (game) {
				game->doomRpg->doomCanvas->renderFloorCeilingTextures = boolData != 0 ? true : false;
			}

			// New
			if (game) {
				for (int i = 0; i < 12; i++) {
					for (int j = 0; j < KEYBINDS_MAX; j++) {
						keyMapping[i].keyBinds[j] = File_readInt(rw);
					}
				}
				SDL_memcpy(keyMappingTemp, keyMapping, sizeof(keyMapping));
			}

		}
		else {
			printf("loadConfig: save version mismatch (expected %d found %d)\n", CONFIG_VERSION, version);
		}
	}
	else {
		printf("loadConfig: (%s)\n", SDL_GetError());
	}

	if (rw) {
		SDL_RWclose(rw);
	}
}

void Game_loadMapEntities(Game_t* game)
{
	Render_t* render;
	Sprite_t* sprite;
	Line_t* line;
	EntityDef_t* ent,* ent1, * ent2;
	Entity_t* entity;
	int i, info, update, x, y, cnt;

	render = game->doomRpg->render;

	game->activePortal = false;
	game->powerCouplingDeaths = 0;
	game->powerCouplingIndex = 0;
	game->powerCouplingHealth[0] = 300;
	game->powerCouplingHealth[1] = 300;
	game->spawnMonster = NULL;
	game->soundMonster = NULL;

	game->entityMemory = DoomRPG_freeMemory();
	game->numEntities = 10;
	game->numMonsters = 0;
	game->doomRpg->combat->kronosTeleporterDest = false;

	printf("loadMapEntities: Loading entities...\n");

	game->numEntities = 0;

	game->entities[game->numEntities++].def = EntityDef_find(game->doomRpg->entityDef, 9, 0);
	game->entities[game->numEntities++].def = EntityDef_find(game->doomRpg->entityDef, 8, 0);
	ent1 = EntityDef_find(game->doomRpg->entityDef, 14, 0);
	ent2 = EntityDef_find(game->doomRpg->entityDef, 15, 0);

	cnt = 0;
	update = 0;
	for (i = 0; i < render->numMapSprites; i++) {
		sprite = &render->mapSprites[i];

		if (sprite->info & 0x1000000) {
			sprite->info &= -16777217;
		}
		else {

			if (++update == 40) {
				DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
				update = 0;
			}

			info = sprite->info & 511;
			if (sprite->info & 0x40000) {
				info += 305;
			}

			ent = EntityDef_lookup(game->doomRpg->entityDef, info);
			if (ent || (sprite->info & 0x20000) != 0)
			{
				entity = &game->entities[game->numEntities++];
				entity->info = (i + 1) & 65535;
				if (ent) {
					entity->def = ent;
					if (entity->def->eType == 1) {
						entity->monster = &game->entityMonsters[game->numMonsters];
						//entity->monster.ce = ceMonsters[numMonsters];
						EntityMonster_reset(entity->monster);
						game->numMonsters++;
						entity->info |= 0x80000;
						Game_deactivate(game, entity);
					}
					Entity_initspawn(entity);
					sprite->ent = entity;
				}
				else if (info == 216) {
					entity->def = ent2;
				}
				else {
					entity->def = ent1;
				}

				x = sprite->x;
				y = sprite->y;
				if (sprite->info & 0x200000) {
					x -= 64;
				}
				else if (sprite->info & 0x100000) {
					y -= 64;
				}
				else if (sprite->info & 0x80000) {
					y += 32;
				}
				else if (sprite->info & 0x400000) {
					x += 32;
				}
				if ((sprite->info & 0x10000) == 0) {
					Game_linkEntity(game, entity, x >> 6, y >> 6);
				}
				cnt++;
			}
		}
	}

	game->firstDropIndex = game->numEntities;
	for (i = 0; i < 8; i++) {
		cnt++;
		game->entities[game->numEntities++].info = (render->firstDropSprite + i + 1) & 65535;
		render->dropSprites[i]->info |= 65536;
	}
	printf("Loaded %d entities from mapSprites (total:%d)\n", cnt, render->numMapSprites);

	cnt = 0;
	game->firstSpecialEntityIndex = game->numEntities;
	for (i = 0; i < render->linesLength; i++) {

		line = &render->lines[i];

		ent = EntityDef_lookup(game->doomRpg->entityDef, 305 + line->texture);
		if (ent == NULL && (line->flags & 24)) {
			ent = game->entities[0].def;
		}

		if (ent) {
			entity = &game->entities[game->numEntities++];
			entity->def = ent;
			entity->info = ((i + 1) & 65535) | 0x200000;
			Entity_initspawn(entity);

			x = line->vert1.x + ((line->vert2.x - line->vert1.x) / 2);
			y = line->vert1.y + ((line->vert2.y - line->vert1.y) / 2);
			if ((line->flags & 0x800) != 0) {
				y--;
			}
			else if ((line->flags & 0x2000) != 0) {
				x++;
			}
			else if ((line->flags & 0x1000) != 0) {
				y++;
			}
			else if ((line->flags & 0x4000) != 0) {
				x--;
			}
			Game_linkEntity(game, entity, x >> 6, y >> 6);
			cnt++;
		}
	}
	printf("Loaded %d entities from mapLines\n", cnt);

	game->lastSpecialEntityIndex = game->numEntities - 1;
	for (i = 0; i < (sizeof(game->entityDb) / sizeof(Entity_t*)); i++) {
		if ((game->entityDb[i] == NULL || !(game->entityDb[i]->info & 0x200000)) && (render->mapFlags[i] & BIT_AM_WALL)) {
			game->entityDb[i] = &game->entities[0];
		}
	}
	game->entityMemory -= DoomRPG_freeMemory();

	printf("loadMapEntities: numMonsters: %d\n", game->numMonsters);
	printf("entityMemory: %d\n", game->entityMemory);
}

void Game_loadPlayerState(Game_t* game, char* fileName)
{
	SDL_RWops* rw;
	byte bData;
	short len, sData;
	int data, i;

	rw = SDL_RWFromFile(fileName, "r");
	if (rw) {
		printf("loadPlayerState storeName:%s\n", fileName);
		len = File_readShort(rw);
		SDL_memset(game->fileMapName, 0, sizeof(game->fileMapName));
		SDL_RWread(rw, &game->fileMapName, len, 1);

		data = File_readInt(rw);
		game->doomRpg->doomCanvas->viewX = data;
		game->doomRpg->doomCanvas->destX = data;

		data = File_readInt(rw);
		game->doomRpg->doomCanvas->viewY = data;
		game->doomRpg->doomCanvas->destY = data;

		data = File_readInt(rw);
		game->doomRpg->doomCanvas->viewAngle = data;
		game->doomRpg->doomCanvas->destAngle = data;

		data = File_readInt(rw);
		game->doomRpg->player->ce.param1 = data;

		data = File_readInt(rw);
		game->doomRpg->player->ce.param2 = data;

		data = File_readInt(rw);
		game->doomRpg->player->keys = data;

		data = File_readInt(rw);
		game->doomRpg->player->weapons = data;

		data = File_readInt(rw);
		game->doomRpg->player->weapon = data;

		data = File_readInt(rw);
		game->doomRpg->player->credits = data;

		data = File_readInt(rw);
		game->doomRpg->player->level = data;

		data = File_readInt(rw);
		game->doomRpg->player->currentXP = data;

		data = File_readLong(rw);
		game->doomRpg->player->totalTime = data;

		data = File_readLong(rw);
		game->doomRpg->player->time = DoomRPG_GetUpTimeMS() - data;

		data = File_readInt(rw);
		game->doomRpg->player->totalMoves = data;

		data = File_readInt(rw);
		game->doomRpg->player->moves = data;

		data = File_readInt(rw);
		game->doomRpg->player->xpGained = data;

		data = File_readInt(rw);
		game->doomRpg->player->completedLevels = data;

		data = File_readInt(rw);
		game->doomRpg->player->killedMonstersLevels = data;

		data = File_readInt(rw);
		game->doomRpg->player->foundSecretsLevels = data;

		data = File_readInt(rw);
		game->doomRpg->player->disabledWeapons = data;

		data = File_readInt(rw);
		game->doomRpg->player->berserkerTics = data;

		sData = File_readShort(rw);
		game->doomRpg->player->prevCeilingColor = sData;

		sData = File_readShort(rw);
		game->doomRpg->player->prevFloorColor = sData;

		data = File_readInt(rw);
		game->doomRpg->player->dogFamiliar = Game_getEntityByIndex(game, data);

		for (i = 0; i < 6; i++) {
			bData = File_readByte(rw);
			game->doomRpg->player->ammo[i] = bData;
		}

		for (i = 0; i < 5; i++) {
			bData = File_readByte(rw);
			game->doomRpg->player->inventory[i] = bData;
		}

		len = File_readShort(rw);
		SDL_memset(game->doomRpg->player->NotebookString, 0, sizeof(game->doomRpg->player->NotebookString));
		SDL_RWread(rw, &game->doomRpg->player->NotebookString, len, 1);
	}

	SDL_RWclose(rw);
}

void Game_loadState(Game_t* game, int i)
{
	DoomCanvas_t* doomCanvas;

	doomCanvas = game->doomRpg->doomCanvas;

	//printf("load %s\event", (codeId == 1) ? "Player2" : "Player");
	Game_loadPlayerState(game, (i == 1) ? "Player2" : "Player");

	game->activeLoadType = i;
	game->doomRpg->player->nextLevelXP = Player_calcLevelXP(game->doomRpg->player, game->doomRpg->player->level);

	if (i == 2) {
		DoomCanvas_loadMap(doomCanvas, doomCanvas->loadMapID);
	}
	else {

		if (!(doomCanvas->viewX == 0 || doomCanvas->viewY == 0)) {
			game->spawnParam = ((doomCanvas->viewX >> 6) & 31) | (((doomCanvas->viewY >> 6) & 31) << 5) | ((doomCanvas->viewAngle & 255) << 10);
		}

		//printf("load %s\event", game->fileMapName);
		DoomCanvas_loadMap(game->doomRpg->doomCanvas, Game_getResourceMapID(game, game->fileMapName));
		game->fileMapName[0] = '\0';
	}
	game->isSaved = false;
	game->isLoaded = true;
}

void Game_loadWorldState(Game_t* game)
{
    SDL_RWops* rw;
    Entity_t* entity;
    Sprite_t* sprite;
    Line_t* line;
    byte bData;
    int data, data2, i, cnt;
    unsigned int anim, frame;
    int x, y;
    short fColor, cColor;

    Game_log("Entering Game_loadWorldState\n");

    rw = SDL_RWFromFile("World", "rb");
    if (!rw) {
        Game_log("Failed to open World file: %s\n", SDL_GetError());
        return;
    }

    Game_log("World file opened successfully\n");

    // Map Entities
    cnt = File_readInt(rw);
    Game_log("Number of entities to load: %d\n", cnt);

    if (cnt > game->numEntities) {
        Game_log("Error: File contains more entities (%d) than the game can handle (%d)\n", cnt, game->numEntities);
        cnt = game->numEntities;  // Limit to prevent overrun
    }

    for (i = 0; i < cnt; i++) {
        Game_log("Loading entity %d\n", i);

        entity = &game->entities[i];
        Game_unlinkEntity(game, entity);

        entity->info = File_readInt(rw);
        entity->linkIndex = (short)File_readShort(rw);

        Game_log("Entity %d: info = 0x%x, linkIndex = %d\n", i, entity->info, entity->linkIndex);

        if ((entity->info & 0xffff) != 0) {
            if ((entity->info & 0x200000) == 0) {
                int spriteIndex = (entity->info & 0xffff) - 1;
                if (spriteIndex < 0 || spriteIndex >= game->doomRpg->render->numMapSprites) {
                    Game_log("Error: Invalid sprite index %d for entity %d\n", spriteIndex, i);
                    continue;
                }
                sprite = &game->doomRpg->render->mapSprites[spriteIndex];

                sprite->info = (sprite->info & 0xFFFF) | (File_readShort(rw) << 16);
                sprite->x = File_readInt(rw);
                sprite->y = File_readInt(rw);
                sprite->info = (sprite->info & 0xFFFFE1FF) | (File_readByte(rw) << 9);

                Game_log("Sprite for entity %d: info = 0x%x, x = %d, y = %d\n", i, sprite->info, sprite->x, sprite->y);

                if (entity->monster != NULL) {
                    entity->monster->ce.mType = File_readByte(rw);
                    entity->monster->ce.param1 = File_readInt(rw);
                    entity->monster->ce.param2 = File_readInt(rw);
                    entity->monster->x = sprite->x;
                    entity->monster->y = sprite->y;
                    if ((entity->info & 0x80000) != 0) {
                        entity->info &= 0xFFF7FFFF;
                        Game_activate(game, entity);
                    }
                    Game_log("Monster data loaded for entity %d\n", i);
                }
                else if (i >= game->firstDropIndex && i < game->firstDropIndex + 8) {
                    data = File_readByte(rw);
                    if (data != -1) {
                        data2 = File_readByte(rw);
                        entity->def = EntityDef_find(game->doomRpg->entityDef, (byte)data, (byte)data2);
                        if (entity->def == NULL) {
                            Game_log("Error: Failed to find EntityDef for drop item entity %d\n", i);
                        } else {
                            sprite->ent = entity;
                            sprite->info = (sprite->info & 0xFFFFFE00) | entity->def->tileIndex;
                        }
                    }
                    Game_log("Drop item data loaded for entity %d\n", i);
                }
                else if ((entity->info & 0x8000000) != 0) {
                    data = File_readByte(rw);
                    data2 = File_readByte(rw);
                    entity->def = EntityDef_find(game->doomRpg->entityDef, (byte)data, (byte)data2);
                    if (entity->def == NULL) {
                        Game_log("Error: Failed to find EntityDef for special entity %d\n", i);
                    } else {
                        sprite->info = (sprite->info & 0xFFFFFE00) | entity->def->tileIndex;
                    }
                    Game_log("Special entity data loaded for entity %d\n", i);
                }
                else {
                    sprite->info = (sprite->info & 0xFFFFFE00) | File_readShort(rw);
                }

                if ((entity->info & 0x4000000) != 0) {
                    int linkX, linkY;
                    if ((sprite->info & 0x780000) != 0) {
                        linkX = entity->linkIndex % 32;
                        linkY = entity->linkIndex / 32;
                    } else {
                        linkX = sprite->x >> 6;
                        linkY = sprite->y >> 6;
                    }
                    if (linkX >= 0 && linkX < 32 && linkY >= 0 && linkY < 32) {
                        Game_linkEntity(game, entity, linkX, linkY);
                    } else {
                        Game_log("Error: Invalid link coordinates (%d, %d) for entity %d\n", linkX, linkY, i);
                    }
                }

                Render_relinkSprite(game->doomRpg->render, sprite);
            }
            else {
                int lineIndex = (entity->info & 0xffff) - 1;
                if (lineIndex < 0 || lineIndex >= game->doomRpg->render->linesLength) {
                    Game_log("Error: Invalid line index %d for entity %d\n", lineIndex, i);
                    continue;
                }
                line = &game->doomRpg->render->lines[lineIndex];

                line->flags = File_readInt(rw);
                if ((line->flags & 28) != 0) {
                    line->texture = (short)File_readShort(rw);
                    line->vert1.x = File_readInt(rw);
                    line->vert1.y = File_readInt(rw);
                    line->vert2.x = File_readInt(rw);
                    line->vert2.y = File_readInt(rw);

                    if ((line->flags & 0x40) != 0) {
                        line->vert2.z = -8;
                    }

                    if (line->texture == 10 || line->texture == 9) {
                        Game_setLineLocked(game, lineIndex, (line->flags & 1024) != 0, true);
                    }
                }
                if ((entity->info & 0x4000000) != 0) {
                    int linkX = entity->linkIndex % 32;
                    int linkY = entity->linkIndex / 32;
                    if (linkX >= 0 && linkX < 32 && linkY >= 0 && linkY < 32) {
                        Game_linkEntity(game, entity, linkX, linkY);
                    } else {
                        Game_log("Error: Invalid link coordinates (%d, %d) for line entity %d\n", linkX, linkY, i);
                    }
                }
                Game_log("Line data loaded for entity %d\n", i);
            }
        }
    }
		
    // Map Lines
    cnt = File_readInt(rw);
    Game_log("Loading %d map lines\n", cnt);
    if (cnt > game->doomRpg->render->linesLength) {
        Game_log("Error: File contains more map lines (%d) than the game can handle (%d)\n", cnt, game->doomRpg->render->linesLength);
        cnt = game->doomRpg->render->linesLength;
    }
    for (i = 0; i < cnt; i++) {
        bData = File_readBoolean(rw);
        if (bData) {
            game->doomRpg->render->lines[i].flags |= 0x80;
        }
    }
		
    // Map Sprites
    cnt = File_readInt(rw);
    Game_log("Loading %d map sprites\n", cnt);
    if (cnt > game->doomRpg->render->numMapSprites) {
        Game_log("Error: File contains more map sprites (%d) than the game can handle (%d)\n", cnt, game->doomRpg->render->numMapSprites);
        cnt = game->doomRpg->render->numMapSprites;
    }
    for (i = 0; i < cnt; i++) {
        bData = File_readBoolean(rw);
        if (bData) {
            game->doomRpg->render->mapSprites[i].info |= 0x10000000;
        }
    }

    // Map Flags
    Game_log("Loading map flags\n");
    for (i = 0; i < sizeof(game->doomRpg->render->mapFlags); i++) {
        if (File_readBoolean(rw)) {
            game->doomRpg->render->mapFlags[i] |= BIT_AM_VISITED;
        }
    }

    // Power Coupling
    Game_log("Loading power coupling data\n");
    game->powerCouplingHealth[0] = File_readInt(rw);
    game->powerCouplingHealth[1] = File_readInt(rw);
    game->powerCouplingDeaths = File_readInt(rw);
    game->powerCouplingIndex = File_readInt(rw);
    game->activePortal = File_readBoolean(rw);
    game->spawnCount = File_readInt(rw);
    game->spawnMonster = Game_getEntityByIndex(game, File_readInt(rw));
    if (game->powerCouplingDeaths == 2) {
        Entity_powerCouplingDied(game->doomRpg->game);
    }
    game->dropIndex = File_readInt(rw);
    game->doomRpg->combat->kronosTeleporterDest = File_readBoolean(rw);

    // GSprites
    cnt = File_readInt(rw);
    Game_log("Loading %d GSprites\n", cnt);
    for (i = 0; i < cnt; i++) {
        anim = File_readByte(rw);
        frame = File_readByte(rw);
        x = File_readInt(rw);
        y = File_readInt(rw);
        Game_gsprite_alloc(game, anim, frame & 0xff, x, y);
    }

    // Map Floor/Ceiling Color
    Game_log("Loading floor/ceiling colors\n");
    cColor = File_readShort(rw);
    fColor = File_readShort(rw);
    for (i = 0; i < game->doomRpg->render->screenWidth; i++) {
        game->doomRpg->render->ceilingColor[i] = cColor;
        game->doomRpg->render->floorColor[i] = fColor;
    }

    // Map Tile Events
    Game_log("Loading tile events\n");
    for (i = 0; i < game->doomRpg->render->numTileEvents; i++) {
        game->doomRpg->render->tileEvents[i] = (game->doomRpg->render->tileEvents[i] & 0xE1ffffff) | (File_readByte(rw) << 25);
        int index = ((game->doomRpg->render->tileEvents[i] & 0x7FC00) >> 10) * BYTE_CODE_MAX;
        int count = File_readInt(rw);
        if (count < 0 || count > BYTE_CODE_MAX) {
            Game_log("Warning: Invalid count %d for tile event %d. Skipping.\n", count, i);
            continue;
        }
        for (int j = 0; j < count; j++) {
            int codeIndex = File_readInt(rw);
            if (codeIndex >= 0 && codeIndex < BYTE_CODE_MAX) {
                game->doomRpg->render->mapByteCode[index + (codeIndex * BYTE_CODE_MAX) + BYTE_CODE_ARG2] = 0;
            } else {
                Game_log("Warning: Invalid byte code index %d for tile event %d\n", codeIndex, i);
            }
        }
    }
	
    Game_log("Exiting Game_loadWorldState\n");

    SDL_RWclose(rw);
}

void Game_monsterAI(Game_t* game)
{
	Entity_t* actMonst, * next;

	if (!game->disableAI) {
		Game_updateSpawnPortals(game);
		game->combatMonsters = NULL;
		if (game->activeMonsters) {
			actMonst = game->activeMonsters;
			do {
				next = actMonst->monster->nextOnList;
				Entity_aiThink(actMonst);
				actMonst = next;
			} while (actMonst != game->activeMonsters);
		}
	}
}

void Game_monsterLerp(Game_t* game)
{
	Entity_t* actMonst;
	boolean z = false;

	if (game->interpolatingMonsters && (!game->disableAI)) {
		if (game->activeMonsters) {
			actMonst = game->activeMonsters;
			do {
				if (Entity_renderOnlyStateMonsters(actMonst)) {
					z = true;
				}
				actMonst = actMonst->monster->nextOnList;
			} while (actMonst != game->activeMonsters);
		}
		game->interpolatingMonsters = z;
	}
}

boolean Game_performDoorEvent(Game_t* game, int codeId, int arg1, int flags)
{
	Entity_t* entity;
	Line_t* line;
	int j, sound;

	line = &game->doomRpg->render->lines[arg1];

	if ((line->flags & 1024) != 0) {
		return false;
	}

	if (codeId == 15 /* EV_OPENLINE */ && (line->flags & 64) != 0) {
		return false;
	}

	if (codeId == 16 /* EV_CLOSELINE */ && (line->flags & 64) == 0) {
		return false;
	}

	if ((line->flags & 88) == 64 && codeId == 6 /*EV_MOVELINE*/ && flags == 1280) {
		return false;
	}

	line->flags ^= 64;

	DoomCanvas_updatePlayerDoors(game->doomRpg->doomCanvas, line);

	for (j = game->firstSpecialEntityIndex; j <= game->lastSpecialEntityIndex; j++) {
		entity = &game->entities[j];
		if ((entity->info & 65535) - 1 == arg1) {
			if ((line->flags & 64) != 0) {
				Game_unlinkEntity(game, entity);
				break;
			}
			else {
				Game_linkEntity(game, entity, entity->linkIndex % 32, entity->linkIndex / 32);
				break;
			}
		}
	}

	if (!(line->flags & 64)) { // Door Close
		sound = 5064;
	}

	if ((line->flags & 64)) { // Door Open
		sound = 5063;
	}

	Sound_playSound(game->doomRpg->sound, sound, 0, 2);
	return true;

}

void Game_deleteSaveFiles(Game_t* game)
{
	printf("Removing saved state...\n");
	remove("Config");
	remove("Player");
	remove("Player2");
	remove("World");
}

void Game_remove(Game_t* game, Entity_t* entity)
{
	Line_t *line;
	if ((entity->info & 65535) != 0) {
		if ((entity->info & 0x200000) != 0) {
			line = &game->doomRpg->render->lines[(entity->info & 65535) - 1];
			Game_executeTile(game, 
				line->vert1.x + ((line->vert2.x - line->vert1.x) / 2), 
				line->vert1.y + ((line->vert2.y - line->vert1.y) / 2), 256);
		}
		else {
			game->doomRpg->render->mapSprites[(entity->info & 65535) - 1].info |= 0x10000;
		}
	}
	Game_unlinkEntity(game, entity);
}

boolean Game_executeEvent(Game_t* game, int event, int codeId, int arg1, int arg2, int flags)
{
	DoomCanvas_t* doomCanvas;
	Sprite_t* sprite;
	Entity_t* entity, *entNext;
	char *str;
	short color;
	int b, j;
	//printf("Game_executeEvent %d, %d, %d, %d, %d\event", codeId, arg1, flags, arg2, flags);

	doomCanvas = game->doomRpg->doomCanvas;

	switch (codeId) {

		// 2 ChangeMap(int numLevel)
		case EV_CHANGEMAP: { // EV_CHANGEMAP
			game->changeMapParam = arg1;
			break;
		}

		// 27 SaveGame(byte levelID, byte x, byte y, byte angle)
		case EV_SAVEGAME: { // EV_SAVEGAME
			int i11 = arg1 >> 8;
			game->newDestX = i11 & 255;
			game->newDestX = 32 + (game->newDestX << 6);
			game->newDestY = (i11 >> 8) & 255;
			game->newDestY = 32 + (game->newDestY << 6);
			game->newAngle = (i11 >> 16) & 255;
			strncpy(game->newMapName, game->doomRpg->render->mapStringsIDs[arg1 & 255], sizeof(game->newMapName));
			break;
		}

		// 1 Goto(byte x, byte y, byte angle)
		case EV_GOTO: { // EV_GOTO
			doomCanvas->destX = ((arg1 & 255) * 64) + 32;
			doomCanvas->destY = (((arg1 >> 8) & 255) * 64) + 32;
			doomCanvas->destAngle = doomCanvas->viewAngle = (arg1 >> 16) & 255;
			doomCanvas->viewX = game->doomRpg->doomCanvas->destX - (doomCanvas->viewCos >> 16);
			doomCanvas->viewY = game->doomRpg->doomCanvas->destY - ((-doomCanvas->viewSin) >> 16);
			DoomCanvas_updateViewTrue(game->doomRpg->doomCanvas);
			Game_eventFlagsForMovement(game, -1, -1, -1, -1);
			break;
		}

		// 3 Trigger(byte x, byte y)
		case EV_TRIGGER: { // EV_TRIGGER
			if (!Game_executeTile(game, 64 * (arg1 & 255), 64 * ((arg1 >> 8) & 255), 256)) {
				printf("Warning: GAME_EV_TRIGGER could not find entity at x:%d y:%d", 64 * (arg1 & 255), 64 * ((arg1 >> 8) & 255));
			}
			break;
		}

		// 10 Password(byte passCodeID, byte stringID)
		case EV_PASSWORD: {  // EV_PASSWORD
			game->passCode = game->doomRpg->render->mapStringsIDs[arg1 & 255];
			game->tileEvent = event;
			DoomCanvas_startDialogPassword(doomCanvas, game->doomRpg->render->mapStringsIDs[(arg1 >> 8) & 255]);
			game->saveTileEvent = true;
			game->skipAdvanceTurn = true;
			break;
		}

		// 4 Message(byte stringID)
		case EV_MESSAGE: { // EV_MESSAGE
			Hud_addMessage(game->doomRpg->hud, game->doomRpg->render->mapStringsIDs[arg1]);
			return true;
		}

		// 24 ForceMessage(byte stringID)
		case EV_FORCEMESSAGE: {  // EV_FORCEMESSAGE
			if (game->doomRpg->render->mapStringsIDs[arg1][0] != '\0') {
				game->doomRpg->hud->statBarMessage = game->doomRpg->render->mapStringsIDs[arg1];
			}
			else {
				game->doomRpg->hud->statBarMessage = NULL;
			}
			break;
		}

		// 5 Pain(int damage)
		case EV_PAIN: { // EV_PAIN
			Hud_addMessage(game->doomRpg->hud, "Pain!");
			Player_painEvent(game->doomRpg->player, NULL);
			Player_pain(game->doomRpg->player, arg1, 0);
			break;
		}

		// 5 MoveLine(int lineIndex)
		// 15 OpenLine(int lineIndex)
		// 16 CloseLine(int lineIndex)
		// 17 MoveLine2(int lineIndex)

		// EV_*LINE
		case EV_MOVELINE:	 // EV_MOVELINE ?
		case EV_OPENLINE: // EV_OPENLINE
		case EV_CLOSELINE: // EV_CLOSELINE
		case EV_MOVELINE2: // EV_MOVELINE2 ?
		{
			//printf("EV_%dLINE\n", i2);
			if (!Game_performDoorEvent(game, codeId, arg1, flags)) {
				return false;
			}
			break;
		}

		// 7 Show(short thingIndex, byte flags)
		case EV_SHOW: { // EV_SHOW
			//printf("sprite:%d\n", arg1 & 65535);
			sprite = &game->doomRpg->render->mapSprites[arg1 & 65535];
			sprite->info = (sprite->info & 0xFFFEE1FF) | (((arg1 >> 16) & 255) << 9);
			if (sprite->ent) {
				entity = Game_findMapEntityXYFlag(game, sprite->x, sprite->y, 4098);
				if (entity) {
					Entity_died(entity);
				}
				entity = Game_findMapEntityXYFlag(game, sprite->x, sprite->y, 4098);
				if (entity) {
					Entity_died(entity);
				}
				Game_linkEntity(game, sprite->ent, sprite->x >> 6, sprite->y >> 6);
			}
			break;
		}

		// 18 Hide(byte x, byte y)
		case EV_HIDE: { // EV_HIDE
			entity = Game_findMapEntityXY(game, (arg1 & 255) << 6, ((arg1 >> 8) & 255) << 6);
			for (entity; entity != NULL; entity = entNext) {
				entNext = entity->nextOnTile;
				if ((entity->info & 0x200000) == 0x0 && entity->def->eType != 1) {
					game->doomRpg->render->mapSprites[(entity->info & 0xFFFF) - 1].info |= 0x10000;
					Game_unlinkEntity(game, entity);
				}
			}
			break;
		}

		case EV_DIALOG:	 // EV_DIALOG
		case EV_DIALOGNOBACK: // EV_DIALOGNOBACK
		{
			DoomCanvas_startDialog(doomCanvas, game->doomRpg->render->mapStringsIDs[arg1], codeId == 8);
			game->saveTileEvent = true;
			game->tileEvent = event;
			game->skipAdvanceTurn = true;
			break;
		}

		case EV_GIVEMAP: { // EV_GIVEMAP
			Game_givemap(game);
			break;
		}

		case EV_CHANGESTATE: // EV_CHANGESTATE
		case EV_NEXTSTATE: // EV_NEXTSTATE
		case EV_PREVSTATE: // EV_PREVSTATE
		{
			// Find the event index using bitwise operations
			b = Render_findEventIndex(game->doomRpg->render, (arg1 & 255) + (((arg1 >> 8) & 255) * 32));

			if (b != -1) {
				int event = game->doomRpg->render->tileEvents[b];
				int eventState = (event & 0x1E000000) >> 25;

				// Handle different event types
				if (codeId == 11) {
					// Set currentState based on extracted bits from arg1
					eventState = (byte)((arg1 >> 16) & 255);
				}
				else if (codeId == 19 && eventState < 9) {
					// Increment currentState for EV_NEXTSTATE event
					++eventState;
				}
				else if (codeId == 20 && eventState > 0) {
					// Decrement currentState for EV_PREVSTATE event
					--eventState;
				}

				// Update the event with the new currentState
				game->doomRpg->render->tileEvents[b] = (event & 0xE1FFFFFF) | (eventState << 25);
			}
			break;
		}

		case EV_LOCK: { // EV_LOCK
			Game_setLineLocked(game, arg1, true, false);
			break;
		}

		case EV_UNLOCK: { // EV_UNLOCK
			Game_setLineLocked(game, arg1, false, false);
			break;
		}

		case EV_TOGGLELOCK: { // EV_TOGGLELOCK
			if ((game->doomRpg->render->lines[arg1].flags & 0x400) != 0x0) {
				Game_setLineLocked(game, arg1, false, false);
				break;
			}
			Game_setLineLocked(game, arg1, true, false);
			break;
		}

		// EV_{ INC,DEC }STAT
		case EV_INCSTAT: // EV_INCSTAT
		case EV_DECSTAT: // EV_DECSTAT
		{
			int i9 = (arg1 >> 8) & 255;
			Player_addStatusItem(game->doomRpg->player, arg1 & 255, codeId == 21 ? i9 : -i9);
			break;
		}

		case EV_REQSTAT: { // EV_REQSTAT

			if (!Player_checkStatusItem(game->doomRpg->player, arg1 & 255, (arg1 >> 8) & 255)) {
				game->saveTileEvent = true;
				game->tileEvent = 0;
				str = game->doomRpg->render->mapStringsIDs[arg1 >> 16];
				if (str[0] != '\0') {
					DoomCanvas_startDialog(game->doomRpg->doomCanvas, str, false);
				}
			}

			break;
		}

		case EV_ANIM: { // EV_ANIM
			Game_gsprite_allocAnim(game, (arg1 >> 16) & 255, ((arg1 & 255) << 6) + 32, (((arg1 >> 8) & 255) << 6) + 32);
			break;
		}

		case EV_ABORTMOVE: { // EV_ABORTMOVE
			game->doomRpg->doomCanvas->abortMove = true;
			break;
		}

		case EV_SCREENSHAKE: { // EV_SCREENSHAKE
			int i12 = arg1 >> 12;
			DoomCanvas_startShake(game->doomRpg->doomCanvas, arg1 & 4095, i12 >> 12, i12 & 4095);
			break;
		}

		case EV_CHANGEFLOORCOLOR: { // EV_CHANGEFLOORCOLOR
			color = Render_RGB888_To_RGB565(game->doomRpg->render, arg1);
			if (game->doomRpg->player->berserkerTics != 0) {
				game->doomRpg->player->prevFloorColor = color;

				color = (((color & 0x7BDE) + 0xF800) >> 1);
			}

			for (j = 0; j < game->doomRpg->render->screenWidth; j++) {
				game->doomRpg->render->floorColor[j] = color;
			}

			break;
		}

		case EV_CHANGECEILCOLOR: { // EV_CHANGECEILCOLOR
			color = Render_RGB888_To_RGB565(game->doomRpg->render, arg1);
			if (game->doomRpg->player->berserkerTics != 0) {
				game->doomRpg->player->prevCeilingColor = color;

				color = (((color & 0x7BDE) + 0xF800) >> 1);
			}

			for (j = 0; j < game->doomRpg->render->screenWidth; j++) {
				game->doomRpg->render->ceilingColor[j] = color;
			}

			break;
		}

		case EV_ENABLEWEAPONS: { // EV_ENABLEWEAPONS
			if (arg1 != 0) {
				Player_restoreWeapons(game->doomRpg->player);
			}
			else {
				Player_removeWeapons(game->doomRpg->player);
			}
			break;
		}

		case EV_OPENSTORE: { // EV_OPENSTORE
			game->doomRpg->menuSystem->f749g = arg1;
			MenuSystem_setMenu(game->doomRpg->menuSystem, MENU_STORE_CONFIRM);
			break;
		}

		case EV_CHANGESPRITE: { // EV_CHANGESPRITE
			int n18 = arg1 & 0x1F;
			int n19 = (arg1 >> 5) & 0x1F;
			byte b3 = (arg1 >> 10) & 0x7;
			int n20 = (arg1 >> 13);
			for (entity = Game_findMapEntityXY(game, n18 << 6, n19 << 6); entity != NULL; entity = entity->nextOnTile) {
				if ((entity->info & 0x200000) == 0x0 && entity->def->eType != 1) {
					sprite = &game->doomRpg->render->mapSprites[(entity->info & 0xFFFF) - 1];
					sprite->info = ((sprite->info & 0xFFFFE000) | n20 | b3 << 9 | 0x80000000);
					Game_unlinkEntity(game, entity);
				}
			}
			break;
		}

		case EV_SPAWNPARTICLES: { // EV_SPAWNPARTICLES
			int i19 = (arg1 >> 24) & 31;
			int i20 = arg1 >> 29;
			int i21 = 0xff000000 | ((arg1 & 255) << 16) | (((arg1 >> 8) & 255) << 8) | ((arg1 >> 16) & 255);
			if (i19 == 0) {
				game->doomRpg->combat->f340c = false;
				Combat_spawnBloodParticles(game->doomRpg->combat, i20, i21, 30);
			}
			else if (i19 == 1) {
				Combat_spawnParticlesFire(game->doomRpg->combat, i20, i21);
			}
			else if (i19 == 2) {
				Combat_spawnParticlesJammedDoor(game->doomRpg->combat, i21);
			}
			else if (i19 == 3) {
				Combat_spawnCaptureDogParticles(game->doomRpg->combat, i21);
			}
			DoomCanvas_setState(game->doomRpg->doomCanvas, ST_PARTICLE);
			break;
		}

		case EV_REFRESHVIEW: { // EV_REFRESHVIEW
			DoomCanvas_updateViewTrue(doomCanvas);
			doomCanvas->skipCheckState = true;
			DoomCanvas_checkFacingEntity(doomCanvas);
			break;
		}

		case EV_WAIT: { // EV_WAIT
			game->saveTileEvent = true;
			game->tileEvent = event;
			game->waitTime = doomCanvas->time + arg1;
			break;
		}

		case EV_ACTIVE_PORTAL: { // EV_ACTIVE_PORTAL
			game->activePortal = true;
			game->spawnMonster = NULL;
			game->spawnCount = (DoomRPG_randNextInt(&game->doomRpg->random) & 255) % 3;
			int i22 = game->numEntities;
			int i23 = 0;
			for (int i24 = 0; i24 < i22; i24++) {
				entity = &game->entities[i24];
				if (entity->def != NULL && entity->def->eType == 12 && entity->def->eSubType == 4) {
					entity->info |= 0x40000;
					++i23;
					if (i23 == 2) {
						return true;
					}
				}
			}
			break;
		}

		case EV_CHECK_COMPLETED_LEVEL: { // EV_CHECK_COMPLETED_LEVEL
			int n27;
			for (n27 = ((arg1 & -65536) >> 16) - 1; n27 < MAP_ITEMS && (game->doomRpg->player->completedLevels & 1 << n27) == 0x0; ++n27) {}
			
			if (n27 == MAP_ITEMS) {
				DoomCanvas_startDialog(doomCanvas, game->doomRpg->render->mapStringsIDs[arg1 & 65535], false);
				game->saveTileEvent = true;
				game->tileEvent = event;
				game->skipAdvanceTurn = true;
			}

			break;
		}

		case EV_NOTE: { // EV_NOTE
			str = game->doomRpg->player->NotebookString;
			SDL_snprintf(str, sizeof(game->doomRpg->player->NotebookString),
				"%s%s||", str, game->doomRpg->render->mapStringsIDs[arg1]);
			break;
		}

		case EV_CHECK_KEY: { // EV_CHECK_KEY
			if (arg1 == 0 && (game->doomRpg->player->keys & 0x1) == 0x0) {
				Hud_addMessage(game->doomRpg->hud, "Need Green Key");
			}
			else if (arg1 == 1 && (game->doomRpg->player->keys & 0x2) == 0x0) {
				Hud_addMessage(game->doomRpg->hud, "Need Yellow Key");
			}
			else if (arg1 == 2 && (game->doomRpg->player->keys & 0x4) == 0x0) {
				Hud_addMessage(game->doomRpg->hud, "Need Blue Key");
			}
			else {
				if (arg1 != 3 || (game->doomRpg->player->keys & 0x8) != 0x0) {
					return false;
				}
				Hud_addMessage(game->doomRpg->hud, "Need Red Key");
			}

			Sound_playSound(game->doomRpg->sound, 5065, 0, 2);
			game->saveTileEvent = true;
			break;
		}

		case EV_PLAYSOUND: { // EV_PLAYSOUND
			Sound_playSound(game->doomRpg->sound, arg1 & 0xffff, 0, 3);
			break;
		}


		default:
			//printf("\event------------------------\event\event\event");
			//printf("[%d] no inplementado\event", arg1);
			//printf("\event\event\event------------------------\event");
			break;
	}

	return true;
}

boolean Game_executeTile(Game_t* game, int x, int y, int flags)
{
	int posX, posY, posIndex;
	int b;
	//printf("Game_executeTile\event");

	if (game->f658b) {
		return false;
	}

	game->skipAdvanceTurn = false;
	posX = x >> 6;
	posY = y >> 6;
	if (posX < 0 || posX >= 32 || posY < 0 || posY >= 32) {
		return false;
	}
	posIndex = posY * 32 + posX;

	if (game->doomRpg->render->mapFlags[posIndex] & BIT_AM_EVENTS) {
		b = Render_findEventIndex(game->doomRpg->render, posIndex);
		if (b != -1) {
			if (Game_runEvent(game, game->doomRpg->render->tileEvents[b], 0, flags)) {
				return true;
			}
		}
	}

	return false;
}

boolean Game_runEvent(Game_t* game, int event, int index, int flags)
{
	//printf("Game_runEvent %d, %d, %d\event", event, index, flags);

	boolean b = false;

	// Extract the eventState field from bits 25 to 28
	int eventState = (event & 0x1E000000) >> 25;

	// Extract the eventflags field from bits 29 to 31
	int eventflags = (event & 0xE0000000) >> 29;

	// Extract the commandCount field from bits 19 to 24
	int commandCount = ((event & 0x1F80000) >> 19) * BYTE_CODE_MAX;

	// Extract the commandIndex field from bits 10 to 18
	int commandIndex = ((event & 0x7FC00) >> 10) * BYTE_CODE_MAX;

	if ((eventflags & EVENT_FLAG_BLOCKINPUT) != 0x0 && (flags & 0x400) != 0x0) {
		return false;
	}

	game->saveTileEvent = false;
	int n7;
	if (eventState == 0) {
		n7 = 0;
	}
	else if (eventState == 1) {
		n7 = 0x10000;
	}
	else {
		n7 = 0x10000 << (eventState - 1);
	}
	if ((game->doomRpg->player->keys & 0x8) != 0x0) {
		flags |= 0x8000;
	}
	else if ((game->doomRpg->player->keys & 0x4) != 0x0) {
		flags |= 0x4000;
	}
	else if ((game->doomRpg->player->keys & 0x1) != 0x0) {
		flags |= 0x2000;
	}
	else if ((game->doomRpg->player->keys & 0x2) != 0x0) {
		flags |= 0x1000;
	}

	int n8 = flags & 0xF000;
	int* code = game->doomRpg->render->mapByteCode;
	for (int i = index * BYTE_CODE_MAX; i < commandCount; i += BYTE_CODE_MAX) {
		int arg2 = code[commandIndex + i + BYTE_CODE_ARG2];

		//printf("n7 %x\n", n7);
		//printf("arg2 %x\n", arg2);
		if (n7 != 0) {
			if ((arg2 & n7) == 0x0) {
				continue;
			}
		}
		else if ((arg2 & 0x1FF0000) != 0x0) {
			continue;
		}
		if ((arg2 & 0xF000) == 0x0 || (arg2 & 0xF000) == n8) {
			if ((flags & arg2) != 0x0) {
				if (Game_executeEvent(game, event, code[commandIndex + i + BYTE_CODE_ID], code[commandIndex + i + BYTE_CODE_ARG1], arg2, flags)) {
					b = true;
					if ((arg2 & 0x200) != 0x0) { // #define ARG2_FLAG_MODIFYWORLD 512
						code[commandIndex + i + BYTE_CODE_ARG2] = 0;
					}
				}
				if (game->saveTileEvent) {
					game->tileEventIndex = i / BYTE_CODE_MAX;
					game->tileEventFlags = flags;
					game->saveTileEvent = false;
					break;
				}
			}
		}
	}
	return b;
}

void Game_saveConfig(Game_t* game, int num)
{
	SDL_RWops* rw;
	int version;
	//printf("saveConfig %d\event", num);

	rw = SDL_RWFromFile("Config", "w");

	version = CONFIG_VERSION;
	File_writeInt(rw, version);
	File_writeByte(rw, game->doomRpg->doomCanvas->vibrateEnabled);
	File_writeInt(rw, game->doomRpg->sound->volume);
	File_writeInt(rw, game->doomRpg->doomCanvas->animFrames);
	File_writeInt(rw, game->doomRpg->player->totalDeaths);

	// New
	File_writeByte(rw, sdlVideo.fullScreen);
	File_writeByte(rw, sdlVideo.vSync);
	File_writeByte(rw, sdlVideo.integerScaling);
	File_writeByte(rw, sdlVideo.displaySoftKeys);
	File_writeInt(rw, sdlVideo.resolutionIndex);
	File_writeInt(rw, game->doomRpg->doomCanvas->mouseSensitivity);
	File_writeByte(rw, game->doomRpg->doomCanvas->mouseYMove);
	File_writeInt(rw, sdlController.deadZoneLeft);
	File_writeInt(rw, sdlController.deadZoneRight);
	File_writeByte(rw, game->doomRpg->doomCanvas->sndPriority);
	File_writeByte(rw, game->doomRpg->doomCanvas->renderFloorCeilingTextures);

	for (int i = 0; i < 12; i++) {
		for (int j = 0; j < KEYBINDS_MAX; j++) {
			File_writeInt(rw, keyMapping[i].keyBinds[j]);
		}
	}

	SDL_RWclose(rw);
}

void Game_savePlayerState(Game_t* game, char* fileName, char* fileMapName, int x, int y, int angle)
{
	SDL_RWops* rw;
	int len, i, time, indx;

	printf("savePlayerState storeName: %s mapName: %s viewX: %d viewY: %d viewAngle: %d\n", fileName, fileMapName, x, y, angle);

	rw = SDL_RWFromFile(fileName, "w");

	len = ((SDL_strlen(fileMapName) + 1) << 16) >> 16;
	File_writeShort(rw, len);
	SDL_RWwrite(rw, fileMapName, len, 1);

	// Player
	File_writeInt(rw, x);
	File_writeInt(rw, y);
	File_writeInt(rw, angle);
	File_writeInt(rw, game->doomRpg->player->ce.param1);
	File_writeInt(rw, game->doomRpg->player->ce.param2);
	File_writeInt(rw, game->doomRpg->player->keys);
	File_writeInt(rw, game->doomRpg->player->weapons);
	File_writeInt(rw, game->doomRpg->player->weapon);
	File_writeInt(rw, game->doomRpg->player->credits);
	File_writeInt(rw, game->doomRpg->player->level);
	File_writeInt(rw, game->doomRpg->player->currentXP);
	File_writeLong(rw, game->doomRpg->player->totalTime);
	time = (DoomRPG_GetUpTimeMS() - game->doomRpg->player->time);
	File_writeLong(rw, time);
	File_writeInt(rw, game->doomRpg->player->totalMoves);
	File_writeInt(rw, game->doomRpg->player->moves);
	File_writeInt(rw, game->doomRpg->player->xpGained);
	File_writeInt(rw, game->doomRpg->player->completedLevels);
	File_writeInt(rw, game->doomRpg->player->killedMonstersLevels);
	File_writeInt(rw, game->doomRpg->player->foundSecretsLevels);
	File_writeInt(rw, game->doomRpg->player->disabledWeapons);
	File_writeInt(rw, game->doomRpg->player->berserkerTics);
	File_writeShort(rw, game->doomRpg->player->prevCeilingColor);
	File_writeShort(rw, game->doomRpg->player->prevFloorColor);
	indx = Game_findEntity(game, game->doomRpg->player->dogFamiliar);
	File_writeInt(rw, indx);

	for (i = 0; i < 6; i++) {
		File_writeByte(rw, game->doomRpg->player->ammo[i]);
	}

	for (i = 0; i < 5; i++) {
		File_writeByte(rw, game->doomRpg->player->inventory[i]);
	}

	len = ((SDL_strlen(game->doomRpg->player->NotebookString) + 1) << 16) >> 16;
	File_writeShort(rw, len);
	SDL_RWwrite(rw, game->doomRpg->player->NotebookString, len, 1);

	SDL_RWclose(rw);
}

void Game_saveState(Game_t* game, int mapId, int x, int y, int angleDir, boolean z)
{
	printf("Saving state on %d at x:%d y:%d dir:%d\n", mapId, x, y, angleDir);

	if (game->doomRpg->doomCanvas->imgFont.imgBitmap) {
		DoomRPG_setColor(game->doomRpg, 0xff000000);
		DoomRPG_fillRect(game->doomRpg, 0, 0, game->doomRpg->doomCanvas->displayRect.w, game->doomRpg->doomCanvas->displayRect.h);
		DoomRPG_setColor(game->doomRpg, 0xffffffff);
		DoomCanvas_drawString1(game->doomRpg->doomCanvas, "Saving...", game->doomRpg->doomCanvas->SCR_CX, game->doomRpg->doomCanvas->SCR_CY - 24, 17);
		DoomRPG_flushGraphics(game->doomRpg);
	}

	DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
	Game_saveConfig(game, z);
	DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
	Game_savePlayerState(game, "Player2", game->mapFiles[mapId-1], x, y, angleDir);
	DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
	Game_saveWorldState(game);
	if (!z) {
		if (game->newMapName && SDL_strcmp(game->newMapName, "")) {
			DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
			Game_savePlayerState(game, "Player", game->newMapName, game->newDestX, game->newDestY, game->newAngle);
			game->newMapName[0] = '\0';
		}
		else {
			DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
			Game_savePlayerState(game, "Player", "/junction.bsp", 0, 0, 0);
		}
	}
}

void Game_saveWorldState(Game_t* game)
{
	SDL_RWops* rw;
	Entity_t* entity;
	Sprite_t* sprite;
	Line_t* line;
	GameSprite_t* gSprite;
	int i, j;

	rw = SDL_RWFromFile("World", "wb");

	// Map Entities
	File_writeInt(rw, game->numEntities);
	for (i = 0; i < game->numEntities; i++) {
		entity = &game->entities[i];
		File_writeInt(rw, entity->info);
		File_writeShort(rw, entity->linkIndex);

		if ((entity->info & 0xffff) != 0) {
			if ((entity->info & 0x200000) == 0) {
				sprite = &game->doomRpg->render->mapSprites[(entity->info & 0xffff) - 1];
				File_writeShort(rw, (sprite->info & 0xFFFF0000) >> 16);
				File_writeInt(rw, sprite->x);
				File_writeInt(rw, sprite->y);
				File_writeByte(rw, (sprite->info & 0x1E00) >> 9);

				if (entity->monster != NULL) {
					File_writeByte(rw, entity->monster->ce.mType);
					File_writeInt(rw, entity->monster->ce.param1);
					File_writeInt(rw, entity->monster->ce.param2);

				}
				else if (i >= game->firstDropIndex && i < game->firstDropIndex + 8) {
					if (entity->def != NULL) {
						File_writeByte(rw, entity->def->eType);
						File_writeByte(rw, entity->def->eSubType);
					}
					else {
						File_writeByte(rw, -1);
					}
				}
				else if ((entity->info & 0x8000000) != 0x0) {
					File_writeByte(rw, entity->def->eType);
					File_writeByte(rw, entity->def->eSubType);
				}
				else {
					File_writeShort(rw, sprite->info & 0x1FF);
				}
			}
			else {
				line = &game->doomRpg->render->lines[(entity->info & 0xffff) - 1];
				File_writeInt(rw, line->flags);
				if ((line->flags & 0x1C) != 0) {
					File_writeShort(rw, line->texture);
					File_writeInt(rw, line->vert1.x);
					File_writeInt(rw, line->vert1.y);
					File_writeInt(rw, line->vert2.x);
					File_writeInt(rw, line->vert2.y);
				}
			}
		}
	}

	// Map Lines
	DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
	File_writeInt(rw, game->doomRpg->render->linesLength);
	for (i = 0; i < game->doomRpg->render->linesLength; i++) {
		File_writeBoolean(rw, (game->doomRpg->render->lines[i].flags & 0x80));
	}

	// Map Sprites
	DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
	File_writeInt(rw, game->doomRpg->render->numMapSprites);
	for (i = 0; i < game->doomRpg->render->numMapSprites; i++) {
		File_writeBoolean(rw, (game->doomRpg->render->mapSprites[i].info & 0x10000000));
	}

	// Map Flags
	DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
	for (i = 0; i < sizeof(game->doomRpg->render->mapFlags); i++) {
		File_writeBoolean(rw, (game->doomRpg->render->mapFlags[i] & BIT_AM_VISITED));
	}

	// Power Coupling
	DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
	File_writeInt(rw, game->powerCouplingHealth[0]);
	File_writeInt(rw, game->powerCouplingHealth[1]);
	File_writeInt(rw, game->powerCouplingDeaths);
	File_writeInt(rw, game->powerCouplingIndex);
	File_writeBoolean(rw, game->activePortal);
	File_writeInt(rw, game->spawnCount);
	File_writeInt(rw, Game_findEntity(game, game->spawnMonster));
	File_writeInt(rw, game->dropIndex);
	File_writeBoolean(rw, game->doomRpg->combat->kronosTeleporterDest);

	// GSprites
	DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);

	j = 0;
	for (i = 0; i < MAX_CUSTOM_SPRITES; i++) {
		gSprite = &game->gsprites[i];
		if ((gSprite->flags & 1) != 0 && (gSprite->flags & 2) == 0 && gSprite->index == 3) {
			j++;
		}
	}

	// GSprites
	DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
	File_writeInt(rw, j);
	for (i = 0; i < MAX_CUSTOM_SPRITES; i++) {
		gSprite = &game->gsprites[i];
		if ((gSprite->flags & 1) != 0 && (gSprite->flags & 2) == 0 && gSprite->index == 3) {
			File_writeByte(rw, gSprite->sprite->info & 511);
			File_writeByte(rw, (gSprite->sprite->info & 7680) >> 9);
			File_writeInt(rw, gSprite->sprite->x);
			File_writeInt(rw, gSprite->sprite->y);
		}
	}

	// Map Floor/Ceiling Color
	DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
	File_writeShort(rw, game->doomRpg->render->ceilingColor[0]);
	File_writeShort(rw, game->doomRpg->render->floorColor[0]);

	// Map Tile Events
	for (i = 0; i < game->doomRpg->render->numTileEvents; i++) {
		int event = game->doomRpg->render->tileEvents[i];
		int eventState = (event & 0x1E000000) >> 25;
		File_writeByte(rw, eventState);
		int numCodes = 0;
		int count = ((event & 0x1F80000) >> 19) * BYTE_CODE_MAX;
		int index = ((event & 0x7FC00) >> 10) * BYTE_CODE_MAX;
		for (int j = 0; j < count; j += BYTE_CODE_MAX) {
			if (game->doomRpg->render->mapByteCode[index + j + BYTE_CODE_ARG2] == 0) {
				numCodes++;
			}
		}
		File_writeInt(rw, numCodes);
		for (int k = 0; k < count; k += BYTE_CODE_MAX) {
			if (game->doomRpg->render->mapByteCode[index + k + BYTE_CODE_ARG2] == 0) {
				File_writeInt(rw, k / BYTE_CODE_MAX);
			}
		}

		DoomCanvas_updateLoadingBar(game->doomRpg->doomCanvas);
	}
	

	SDL_RWclose(rw);
}

void Game_setLineLocked(Game_t* game, int index, boolean z, boolean z2)
{
	Line_t* line;
	Entity_t* entity;
	int i;

	line = &game->doomRpg->render->lines[index];

	if (z) {
		line->flags |= 1024;
	}
	else {
		line->flags &= -1025;
	}

	if (z && (z2 || line->texture == 10)) {
		line->texture = 9;
		for (i = game->firstSpecialEntityIndex; i <= game->lastSpecialEntityIndex; i++) {
			entity = &game->entities[i];
			if ((entity->info & 65535) - 1 == index) {
				entity->def = EntityDef_find(game->doomRpg->entityDef, 0, 1);
				DoomCanvas_updateViewTrue(game->doomRpg->doomCanvas);
				return;
			}
		}
	}
	else if (!z && (z2 || line->texture == 9)) {
		line->texture = 10;
		Sound_playSound(game->doomRpg->sound, 5067, 0, 3);
		for (i = game->firstSpecialEntityIndex; i <= game->lastSpecialEntityIndex; i++) {
			entity = &game->entities[i];
			if ((entity->info & 65535) - 1 == index) {
				entity->def = EntityDef_find(game->doomRpg->entityDef, 0, 2);
				DoomCanvas_updateViewTrue(game->doomRpg->doomCanvas);
				return;
			}
		}
	}
}

boolean Game_snapMonsters(Game_t* game)
{
	Entity_t* actMonst;
	Sprite_t* spr;

	if (game->disableAI) {
		return false;
	}

	if (!game->monstersTurn) {
		return false;
	}

	if (!game->ignoreMonsterAI) {
		Game_monsterAI(game);
	}

	if (game->activeMonsters) {
		actMonst = game->activeMonsters;
		do {
			spr = &game->doomRpg->render->mapSprites[(actMonst->info & 65535) - 1];
			do {
				spr->x = actMonst->monster->x;
				spr->y = actMonst->monster->y;
			} while (Entity_aiMoveToGoal(actMonst));

			Render_relinkSprite(game->doomRpg->render, spr);
			DoomCanvas_updateViewTrue(game->doomRpg->doomCanvas);

			actMonst = actMonst->monster->nextOnList;
		} while (actMonst != game->activeMonsters);
	}

	if (game->combatMonsters) {
		Combat_performAttack(game->doomRpg->combat, game->combatMonsters, game->combatMonsters->monster->target);
		return true;
	}

	Game_endMonstersTurn(game);
	return false;
}

void Game_updateSpawnPortals(Game_t* game)
{
	Sprite_t* sprite;
	char text[64];
	int i;

	if (!game->activePortal) {
		return;
	}
	if (game->spawnMonster != NULL && CombatEntity_getHealth(&game->spawnMonster->monster->ce) > 0) {
		return;
	}
	if (game->spawnCount-- > 0) {
		return;
	}

	boolean z = false;
	game->spawnMonster = game->inactiveMonsters;
	if (game->spawnMonster != NULL) {
		i = 0;
		do {
			sprite = &game->doomRpg->render->mapSprites[(game->spawnMonster->info & 0xFFFF) - 1];

			if (CombatEntity_getHealth(&game->spawnMonster->monster->ce) > 0 && (sprite->info & 0x10000) == 0x0) {
				++i;
			}
			game->spawnMonster = game->spawnMonster->monster->nextOnList;
		} while (game->spawnMonster != game->inactiveMonsters);

		if (i == 0) {
			game->activePortal = false;
			return;
		}

		int rnd = (DoomRPG_randNextInt(&game->doomRpg->random) & 4095) % i;
		game->spawnMonster = game->inactiveMonsters;

		do {
			sprite = &game->doomRpg->render->mapSprites[(game->spawnMonster->info & 0xFFFF) - 1];
			if (CombatEntity_getHealth(&game->spawnMonster->monster->ce) > 0 && (sprite->info & 0x10000) == 0x0 && rnd-- == 0) {
				z = true;
				break;
			}
			game->spawnMonster = game->spawnMonster->monster->nextOnList;
		} while (game->spawnMonster != game->inactiveMonsters);

		//printf("portal wants to spawn at %d %d\event", 1056, 992);
		int a = 1056;
		if (Game_findMapEntityXYFlag(game, 1056, 992, 65415) != NULL) {
			a = 1056 - 64;
			//printf("portal wants to spawn at %d %d\event", 928, 992);
			if (Game_findMapEntityXYFlag(game, 928, 992, 65415) != NULL) {
				a = 1120;
				//printf("portal wants to spawn at %d %d\event", 1184, 992);
				if (Game_findMapEntityXYFlag(game, 1184, 992, 65415) != NULL) {
					z = false;
				}
			}
		}

		if (z) {
			//printf("portal spawning a monster...\event");
			Game_unlinkEntity(game, game->spawnMonster);
			game->spawnMonster->monster->x = a;
			game->spawnMonster->monster->y = 992;
			sprite->x = game->spawnMonster->monster->x;
			sprite->y = game->spawnMonster->monster->y;
			sprite->info &= 0xFFFEFFFF;
			Render_relinkSprite(game->doomRpg->render, sprite);
			Game_linkEntity(game, game->spawnMonster, a >> 6, 15);
			Game_gsprite_allocAnim(game, 2, a, 992);
			DoomCanvas_updateViewTrue(game->doomRpg->doomCanvas);
			SDL_snprintf(text, sizeof(text), "Portal spawns %s!", game->spawnMonster->def->name);
			Hud_addMessage(game->doomRpg->hud, text);
		}
		game->spawnCount = 1 + (DoomRPG_randNextInt(&game->doomRpg->random) & 3);
	}
}

void Game_spawnPlayer(Game_t* game)
{
	Render_t* render;
	DoomCanvas_t* doomCanvas;
	int angle, x, y;

	render = game->doomRpg->render;
	doomCanvas = game->doomRpg->doomCanvas;

	if (game->spawnParam == 0) {
		x = render->mapSpawnIndex % 32;
		y = render->mapSpawnIndex / 32;
		angle = render->mapSpawnDir;
	}
	else {
		x = game->spawnParam & 31;
		y = (game->spawnParam >> 5) & 31;
		angle = (game->spawnParam >> 10) & 255;
		game->spawnParam = 0;
	}

	doomCanvas->viewX = doomCanvas->destX = (x * 64) + 32;
	doomCanvas->viewY = doomCanvas->destY = (y * 64) + 32;
	doomCanvas->viewZ = 36;
	doomCanvas->destAngle = angle;
	doomCanvas->viewAngle = angle;
	render->viewZOld = 4;
	game->doomRpg->hud->isUpdate = true;
	DoomCanvas_checkFacingEntity(game->doomRpg->doomCanvas);
	if (!game->isLoaded) {
		Player_setup(game->doomRpg->player);
		Game_executeTile(game, doomCanvas->viewX, doomCanvas->viewY, 0x40f | DoomCanvas_flagForFacingDir(game->doomRpg->doomCanvas));
	}
}

GameSprite_t* Game_gsprite_alloc(Game_t* game, int amin, int frame, int x, int y)
{
	int i, j, time, upTime;
	GameSprite_t* gSpr;

	for (i = 0; i < MAX_CUSTOM_SPRITES && (game->gsprites[i].flags & 0x1) != 0x0; ++i) {}

	if (i == MAX_CUSTOM_SPRITES) {

		time = 0;
		i = 0;
		for (j = 0; j < MAX_CUSTOM_SPRITES; ++j)
		{
			upTime = DoomRPG_GetUpTimeMS() - game->gsprites[j].time;
			if (time < upTime) {
				time = upTime;
				i = j;
			}
		}
	}

	gSpr = &game->gsprites[i];
	gSpr->index = 3;
	gSpr->frame = frame;
	gSpr->flags = 1;
	gSpr->sprite = game->doomRpg->render->customSprites[i];
	gSpr->sprite->renderMode = 0;
	gSpr->sprite->info = amin | frame << 9 | 0x80000000;
	gSpr->sprite->x = x;
	gSpr->sprite->y = y;

	Render_relinkSprite(game->doomRpg->render, gSpr->sprite);

	//printf("sprite_alloc % d as % d on frame % d at % d % d\event", codeId, amin, frame, gSpr->sprite->x, gSpr->sprite->y);

	return gSpr;
}

boolean Game_touchTile(Game_t* game, int x, int y, int touched)
{
	Entity_t* nextOnTile;
	Entity_t* entity;
	boolean isTouched;

	isTouched = false;
	for (entity = Game_findMapEntityXY(game, x, y); entity != NULL; entity = nextOnTile) {
		nextOnTile = entity->nextOnTile;
		if (touched || entity->def->eType == 11 || entity->def->eType == 10) {
			Entity_touched(entity);
			isTouched = true;
		}
	}
	return isTouched;
}

void Game_trace(Game_t* game, int srcX, int srcY, int destX, int destY, Entity_t* entity, int flags)
{
	Entity_t* entityDb;
	Sprite_t* sprite;
	int sX, sY, dX, dY, pX, pY, cnt, sprInfo, sprX, sprY;
	int srcIndex, srcPitch, destIndex;
	byte eType;

	pX = 0;
	pY = 0;
	cnt = 0;

	sX = srcX >> 6;
	sY = srcY >> 6;
	dX = destX >> 6;
	dY = destY >> 6;

	if (sX < 0) {
		sX = 0;
	}
	else if (sX >= 32) {
		sX = 31;
	}

	if (sY < 0) {
		sY = 0;
	}
	else if (sY >= 32) {
		sY = 31;
	}

	if (dX < 0) {
		dX = 0;
	}
	else if (dX >= 32) {
		dX = 31;
	}

	if (dY < 0) {
		dY = 0;
	}
	else if (dY >= 32) {
		dY = 31;
	}

	if (sX > dX) {
		pX = -1;
		cnt = sX - dX + 1;
	}
	else if (sX < dX) {
		pX = 1;
		cnt = dX - sX + 1;
	}

	if (sY > dY) {
		pY = -1;
		cnt = sY - dY + 1;
	}
	else if (sY < dY) {
		pY = 1;
		cnt = dY - sY + 1;
	}

	game->numTraceEntities = 0;

	srcPitch = pY * 32 + pX;
	destIndex = (game->doomRpg->doomCanvas->destY >> 6) * 32 + (game->doomRpg->doomCanvas->destX >> 6);
	srcIndex = sY * 32 + sX;

	while (--cnt >= 0 && game->numTraceEntities < 8) {
		entityDb = game->entityDb[srcIndex];
		if (entityDb == &game->entities[0]) {
			game->traceEntities[game->numTraceEntities++] = entityDb;
			return;
		}
		if ((flags & 0x100) && (srcIndex == destIndex)) {
			game->traceEntities[game->numTraceEntities++] = &game->entities[1];
			return;
		}
		while (entityDb != NULL && cnt >= 0 && game->numTraceEntities < 8) {
			eType = entityDb->def->eType;

			if ((flags & 1 << eType)) {
				if (entityDb != entity) {
					if (eType == 14 || eType == 15) {
						sprite = &game->doomRpg->render->mapSprites[(entityDb->info & 65535) - 1];
						sprInfo = sprite->info;
						if (sprInfo & 0x20000) {
							sprX = sprite->x;
							sprY = sprite->y;
							if (sprInfo & 0x180000) {
								if ((srcY <= sprY && destY > sprY) || (srcY >= sprY && destY < sprY)) {
									cnt = -1;
								}
							}
							else if ((sprInfo & 0x600000) && ((srcX <= sprX && destX > sprX) || (srcX >= sprX && destX < sprX))) {
								cnt = -1;
							}
						}
						if (cnt != -1) {
							goto next;
						}
					}

					game->traceEntities[game->numTraceEntities++] = entityDb;
				}
			}

		next:
			entityDb = entityDb->nextOnTile;
		}
		srcIndex += srcPitch;
	}
}

void Game_unlinkEntity(Game_t* game, Entity_t* entity)
{
	if (entity == game->entityDb[entity->linkIndex]) {
		game->entityDb[entity->linkIndex] = entity->nextOnTile;
	}
	else if (entity->prevOnTile) {
		entity->prevOnTile->nextOnTile = entity->nextOnTile;
	}
	if (entity->nextOnTile) {
		entity->nextOnTile->prevOnTile = entity->prevOnTile;
	}
	entity->nextOnTile = NULL;
	entity->prevOnTile = NULL;
	entity->info &= -67108865;
}

void Game_unloadMapData(Game_t* game)
{
	int i;
	//printf("unloadMapData\event");

	Game_gsprite_clear(game);
	game->doomRpg->player->facingEntity = NULL;
	game->doomRpg->player->dogFamiliar = NULL;
	game->doomRpg->combat->curTarget = NULL;
	game->doomRpg->combat->curAttacker = NULL;

	for(i = 0; i < 8; i++) {
		game->doomRpg->doomCanvas->openDoors[i] = NULL;
	}
	game->doomRpg->doomCanvas->openDoorsCount = 0;

	game->doomRpg->doomCanvas->castEntity = NULL;
	game->inactiveMonsters = NULL;
	game->activeMonsters = NULL;
	game->combatMonsters = NULL;
	game->spawnMonster = NULL;
	game->tileEvent = 0;
	game->passCode = NULL;

	for (i = 0; i < 8; i++) {
		game->traceEntities[i] = NULL;
	}

	for (i = 0; i < 1024; i++) {
		game->entityDb[i] = NULL;
	}

	for (i = 0; i < game->numEntities; i++) {
		Entity_reset(&game->entities[i]);
	}
}

boolean Game_updateMonsters(Game_t* game)
{
	if (!(game->ignoreMonsterAI)) {
		Game_monsterAI(game);
		game->ignoreMonsterAI = true;
	}
	Game_monsterLerp(game);
	if (!game->interpolatingMonsters) {
		DoomCanvas_checkFacingEntity(game->doomRpg->doomCanvas);

		if (game->combatMonsters) {
			Combat_performAttack(game->doomRpg->combat, game->combatMonsters, game->combatMonsters->monster->target);
		}
		else {
			Game_endMonstersTurn(game);
			DoomCanvas_drawSoftKeys(game->doomRpg->doomCanvas, "Menu", "Map");
		}
	}
	return game->interpolatingMonsters;
}