local TS = 16 -- texture size

mcl_paintings.paintings = {
	[1] = {
		[1] = {
			{ cx = 0, cy = 0 },
			{ cx = TS, cy = 0 },
			{ cx = 2*TS, cy = 0 },
			{ cx = 3*TS, cy = 0 },
			{ cx = 4*TS, cy = 0 },
			{ cx = 5*TS, cy = 0 },
			{ cx = 6*TS, cy = 0 },
		},
		[2] = {
			{ cx = 0, cy = 2*TS },
			{ cx = 2*TS, cy = 2*TS },
			{ cx = 4*TS, cy = 2*TS },
			{ cx = 6*TS, cy = 2*TS },
			{ cx = 8*TS, cy = 2*TS },
		},
		[3] = 2,
		[4] = 2,
	},
	[2] = {
		[1] = {
			{ cx = 0, cy = 4*TS },
			{ cx = TS, cy = 4*TS },
		},
		[2] = {
			{ cx = 0, cy = 8*TS },
			{ cx = 2*TS, cy = 8*TS },
			{ cx = 4*TS, cy = 8*TS },
			{ cx = 6*TS, cy = 8*TS },
			{ cx = 8*TS, cy = 8*TS },
			{ cx = 10*TS, cy = 8*TS },
		},
		[3] = 2,
		[4] = {
			{ cx = 0, cy = 6*TS },
		},
	},
	[3] = {
		[4] = {
			{ cx = 12*TS, cy = 4*TS },
			{ cx = 12*TS, cy = 7*TS },
		},
	},
	[4] = {
		[4] = {
			{ cx = 0, cy = 12*TS },
			{ cx = 4*TS, cy = 12*TS },
			{ cx = 8*TS, cy = 12*TS },
		},
	},
}
