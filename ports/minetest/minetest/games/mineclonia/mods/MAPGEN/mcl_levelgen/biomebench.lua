dofile ("init.lua")
mcl_levelgen.assign_biome_ids ({})

-- Number of quart positions per MapBlock.
local N = 4
local index = mcl_levelgen.biome_table_index
local seed = mcl_levelgen.ull (0, 3228473)
local level = mcl_levelgen.make_overworld_preset (seed)
local biomes = {}
print ("Generating biomes...")
local clock = os.clock ()
for i = 0, 50 do
	mcl_levelgen.generate_biomes_at_block (level, biomes, i, 0, i, 5, 24)
end
local fin = os.clock () - clock
print ("Generated biomes for 1250 MapBlocks in "
       .. math.floor (fin + 0.5) .. " seconds")
print ("Compressing biomes...")
local compressed = mcl_levelgen.encode_biomes (biomes, 2, 7, 5, 24, true)
print ("Testing biome compression routines...")
local w, h = 5, 24
for x = 0, 4 do
	for y = 0, 6 do
		for z = 0, 4 do
			local hash = x * h * w + y * w + z + 1
			local tbl = compressed[hash]
			local z_minecraft = 4 - z
			local qx, qy, qz = x * N, (y + 2) * N, z_minecraft * N

			for x = 0, N - 1 do
				for y = 0, N - 1 do
					for z = 0, N - 1 do
						local qzd = qz + (N - z - 1)
						local i = index (qx + x, qy + y, qzd,
								 w * N, h * N, w * N)
						local a = mcl_levelgen.index_biome_list (tbl, x, y, z)
						local b = biomes[i]
						assert (a == b)
					end
				end
			end
		end
	end
end
