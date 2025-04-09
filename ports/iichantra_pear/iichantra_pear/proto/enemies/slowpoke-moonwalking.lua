parent = "enemies/slowpoke"

facing = constants.facingMoonwalking;
color = { 1, 0.8, 0.8, 1 }

faction_id = 1;
faction_hates = { -1, -2 };

animations =
{
	{
		name = "shoot";
		frames = 
		{
			{ com = constants.AnimComPushInt; param = 640; },
			{ com = constants.AnimComJumpIfTargetClose; param = 3; },
			{ com = constants.AnimComSetAnim; txt = "move" },
			{ dur = 0 },
			{ dur = 100; num = 8; com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComRealH; param = 51; },
			{ dur = 100; num = 9; com = constants.AnimComFaceTarget; },
			{ dur = 100; num = 10; com = constants.AnimComRealH; param = 72; },
			{ dur = 100; num = 11; com = constants.AnimComRealH; param = 71; },
			{ dur = 500; num = 12; com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComRealH; param = 70; },
			{ com = constants.AnimComAdjustAim; },
			{ com = constants.AnimComPushInt; 20 },
			{ com = constants.AnimComPushInt; param = -10; },
			{ dur = 100; num = 13; com = constants.AnimComAimedShot; txt = "slowpoke-homing-projectile"; },
			{ dur = 100; num = 14; com = constants.AnimComRealH; param = 62; },
			{ dur = 100; num = 15; com = constants.AnimComRealH; param = 51; },
			{ com = constants.AnimComRealH; param = 46; },
			{ com = constants.AnimComSetAnim; txt = "reinit"; }

		}
	}
}