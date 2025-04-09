--forbidden

parent = "enemies/slowpoke"

animations =
{
	{
		name = "die";
		frames = 
		{
			{ com = constants.AnimComCallFunction; txt = "boss_enemy_dead" },
			{ com = constants.AnimComSetShadow; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateParticles; txt = "pblood2" },
			{ com = constants.AnimComSetTouchable; param = 0; },
			{ com = constants.AnimComSetBulletCollidable; param = 0; },
			{ com = constants.AnimComPlaySound; txt = "slowpoke-death.ogg" },
			{ com = constants.AnimComMapVarAdd; param = 30*difficulty; txt = "score"; },
			{ com = constants.AnimComRealX; param = 11; },
			{ dur = 100; num = 17; com = constants.AnimComRealH; param = 45; },
			{ com = constants.AnimComRealX; param = 15; },
			{ dur = 100; num = 18; com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComRealX; param = 20; },
			{ dur = 100; num = 19; com = constants.AnimComRealH; param = 58; },
			{ com = constants.AnimComRealX; param = 28; },
			{ dur = 100; num = 20; com = constants.AnimComRealH; param = 48; },
			{ dur = 100; num = 21; com = constants.AnimComRealH; param = 30; },
			{ dur = 100; num = 22; com = constants.AnimComRealH; param = 22; },
			{ com = constants.AnimComSetZ; param = -450 },
			{ dur = 5000; num = 23; com = constants.AnimComRealH; param = 10; },
			{ dur = 1; num = 0; com = constants.AnimComJump; param = 20 },
			{}
		}
	}
}

