--forbidden
name = "gui";
--texture = "interface";
texture = "interface_hw";
FunctionName = "CreateSprite";

z = 0.9;
image_width = 512;
image_height = 512;
frames_count = 13;

animations =
{
	{
		name = "menu_bkg";
		frames =
		{
			{ num = 1 }
		}
	},
		{
		name = "gui-blue";
		frames =
		{
			{ num = 2; dur = 150 },
			{ num = 3; dur = 150 },
			{ num = 4; dur = 150 },
			{ num = 3; dur = 150 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "gui-red";
		frames =
		{
			{ dur = 0 },
			{ num = 7; dur = 10000 },
			{ com = constants.AnimComPushInt; param = 0028 },
			{ com = constants.JumpRandom; param = 0 },
			{ num = 5; dur = 200 },
			{ num = 6; dur = 10 },
			{ num = 5; dur = 100 },
			{ num = 6; dur = 10 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "window";
		frames =
		{
			{ num = 8 }
		}
	},
	{
		name = "snd_bkg";
		frames =
		{
			{ num = 9 }
		}
	},
	{
		name = "snd_main";
		frames =
		{
			{ num = 10 }
		}
	},
	{
		name = "snd_block";
		frames =
		{
			{ num = 11 }
		}
	},
	{
		name = "gui_score";
		frames =
		{
			{ num = 12 }
		}
	},
	{
		name = "gui_main";
		frames =
		{
			{ num = 13 }
		}
	},
	{
		name = "co";
		frames =
		{
			{ num = 14 }
		}
	},
	{
		name = "life";
		frames =
		{
			{ num = 15 }
		}
	},
	{
		name = "sync_bar";
		frames =
		{
			{ num = 16 }
		}
	},
	{
		name = "sync_red";
		frames =
		{
			{ num = 17, dur = 100 },
			{ num = 19, dur = 100 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "sync_red_extra";
		frames =
		{
			{ num = 18, dur = 100 },
			{ num = 19, dur = 100 },
			{ com = constants.AnimComLoop }
		}
	},
	{
		name = "sync_yellow";
		frames =
		{
			{ num = 19, dur = 100 },
		}
	},
	{
		name = "sync_green";
		frames =
		{
			{ num = 20, dur = 100 },
		}
	},
	{
		name = "square";
		frames =
		{
			{ num = 21 }
		}
	},
	{
		name = "circle";
		frames =
		{
			{ num = 22 }
		}
	},
	{
		name = "triangle";
		frames =
		{
			{ num = 23 }
		}
	},
	{
		name = "diamond";
		frames =
		{
			{ num = 24 }
		}
	},
	{
		name = "line";
		frames =
		{
			{ num = 25 }
		}
	},
	{
		name = "overcharged";
		frames =
		{
			{ num = 26 }
		}
	},
	{
		name = "mikuru_beam";
		frames =
		{
			{ num = 27 }
		}
	},
	{
		name = "grenade";
		frames =
		{
			{ num = 28 }
		}
	},
	{
		name = "rocketlauncher";
		frames =
		{
			{ num = 29 }
		}
	},
	{
		name = "flamer";
		frames =
		{
			{ num = 30 }
		}
	},
	{
		name = "spread";
		frames =
		{
			{ num = 31 }
		}
	},
	{
		name = "bouncy";
		frames =
		{
			{ num = 32 }
		}
	},
	{
		name = "wave";
		frames =
		{
			{ num = 33 }
		}
	},
	{
		name = "twinshot";
		frames =
		{
			{ num = 34 }
		}
	},
	{
		name = "fragmentation";
		frames =
		{
			{ num = 35 }
		}
	},
	{
		name = "bonus_ammo";
		frames =
		{
			{ num = 36 }
		}
	},
	{
		name = "bonus_sync";
		frames =
		{
			{ num = 37 }
		}
	},
	{
		name = "bonus_speed";
		frames =
		{
			{ num = 38 }
		}
	},
	{
		name = "bonus_invul";
		frames =
		{
			{ num = 39 }
		}
	},
	{
		name = "bonus_health";
		frames =
		{
			{ num = 40 }
		}
	},
	{
		name = "boss_health_bar";
		frames =
		{
			{ num = 41 }
		}
	},
	{
		name = "game_over";
		frames =
		{
			{ num = 42 }
		}
	}
}
