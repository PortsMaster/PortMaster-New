parent = "enemies/slowpoke-moonwalking"
offscreen_distance = 640
offscreen_behavior = constants.offscreenDestroy

faction_id = 1;
faction_hates = { -1, -2 };

animations =
{
	{
		name = "move";
		frames = 
		{
			{ dur = 400; num = 7},
			{ com = constants.AnimComSetAnim; txt = "shoot" }
		}
	}

}
