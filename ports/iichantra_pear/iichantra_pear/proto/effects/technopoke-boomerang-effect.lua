--forbidden
texture = "technopoke_projectiles";
FunctionName = "CreateSprite";

physic = 1;
phys_ghostlike = 1;

z = 0.0;

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComRealW; param = 11 },
			{ com = constants.AnimComRealH; param = 11 },
			{ dur = 50; num = 0 },
			{ dur = 50; num = 1 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ dur = 100; num = 2 },
			{ dur = 100; num = 3 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComPushInt; param = 0 },
			{ com = constants.AnimComCreateEnemyBullet; txt = "technopoke-boomerang"; param = 3 },
			{ dur = 100; num = 4 },
			{ com = constants.AnimComDestroyObject; param = 1}
		}
	}
}
