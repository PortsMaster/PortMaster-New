
local padding = 2
local top_padding = 20
local terrace_max_ext = 6

-------------------------------------------------------------------------------
-- function to fill empty space below baseplate when building on a hill
-------------------------------------------------------------------------------
function mcl_villages.ground(pos, pr) -- role model: Wendelsteinkircherl, Brannenburg
	local p2 = vector.new(pos)
	local cnt = 0
	local mat = "mcl_core:dirt"
	p2.y = p2.y-1
	while true do
		cnt = cnt+1
		if cnt > 20 then break end
		if cnt>pr:next(2,4) then
			mat = "mcl_core:stone"
		end
		core.swap_node(p2, {name=mat})
		p2.y = p2.y-1
	end
end

-- Empty space above ground
local function overground(pos, fwidth, fdepth, fheight, grid)

	if not grid then
		local y = math.ceil(pos.y + 1)
		local radius_base = math.max(fwidth, fdepth)
		local radius = math.round((radius_base / 2) + padding)
		local dome = fheight + top_padding

		for count2 = 1, fheight + top_padding do
			if radius_base > 3 then
				if count2 > dome then
					radius = radius - 1
				elseif count2 <= terrace_max_ext then
					radius = radius + 1
				end
			end

			mcl_util.circle_bulk_set_node_vm(radius, pos, y, "air")

			y = y + 1
		end
	else
		local count = 1

		-- Must treat as square because rotation is random
		local adjust = math.round(math.max(fwidth, fdepth) / 2)

		for y_adj = 1, fheight + top_padding do
			local pos1 = vector.offset(pos, -(adjust + count), y_adj, -(adjust + count))
			local pos2 = vector.offset(pos, adjust + count, y_adj, adjust + count)
			mcl_util.bulk_set_node_vm(pos1, pos2, "air")

			-- Grid layout requires minimal terracing
			if count <= padding then
				count = count + 1
			end
		end

		-- clean out stumps and leaves
		local pos1 = vector.offset(pos, -(adjust + count), 1, -(adjust + count))
		local pos2 = vector.offset(pos, adjust + count, fheight + top_padding, adjust + count)
		mcl_util.replace_node_vm(pos1, pos2, "group:tree", "air", true)
		mcl_util.replace_node_vm(pos1, pos2, "group:leaves", "air", true)
	end
end

function mcl_villages.terraform_new(settlement_info, grid)
	local fheight, fwidth, fdepth

	-- Do ground first so that we can clear overhang for lower buildings
	for _, schematic_data in ipairs(settlement_info) do
		local pos = vector.copy(schematic_data["pos"])
		fwidth = schematic_data["size"]["x"]
		fdepth = schematic_data["size"]["z"]

		if not schematic_data["no_ground_turnip"] then
			mcl_util.create_ground_turnip(pos, fwidth, fdepth)
		end
	end

	for _, schematic_data in ipairs(settlement_info) do
		local pos = vector.copy(schematic_data["pos"])

		fwidth = schematic_data["size"]["x"]
		fdepth = schematic_data["size"]["z"]
		fheight = schematic_data["size"]["y"]

		if  not schematic_data["no_clearance"] then
			overground(pos, fwidth, fdepth, fheight, grid)
		end
	end
end
