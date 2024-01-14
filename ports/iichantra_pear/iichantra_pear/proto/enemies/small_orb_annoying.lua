--forbidden
parent = "enemies/small_orb"

animations = 
{
	{ 
		name = "idle";
		frames = 
		{
			{ com = constants.AnimComStop },
			{ dur = 100; num = 0; com = constants.AnimComWaitForTarget; param = 3200; txt = "move" },
			{ com = constants.AnimComLoop }	
		}
	}
}



