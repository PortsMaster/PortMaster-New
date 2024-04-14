-- compatibility layer with the new mcl2 hopper API
function mcl_util.select_stack(src_inventory, src_list, dst_inventory, dst_list, condition)
	local src_size = src_inventory:get_size(src_list)
	local stack
	for i = 1, src_size do
		stack = src_inventory:get_stack(src_list, i)
		if not stack:is_empty() and dst_inventory:room_for_item(dst_list, stack) and ((condition == nil or condition(stack))) then
			return i
		end
	end
	return nil
end

minetest.register_on_mods_loaded(function()
	for nname, def in pairs(minetest.registered_nodes) do
		if not def._on_hopper_out and def._mcl_hoppers_on_try_pull then
			minetest.override_item(nname, {
				_on_hopper_out = function(node_pos, hopper_pos)
					local hinv = minetest.get_meta(hopper_pos):get_inventory()
					local inv, list, stack = def._mcl_hoppers_on_try_pull(node_pos, hopper_pos, hinv, "main")
					if stack and mcl_util.move_item(inv, list, stack, hinv, "main") and ( def._mcl_hoppers_after_pull == nil or def._mcl_hoppers_after_pull(node_pos)) then
						return true
					end
					return true
				end,
			})
		end
		if not def._on_hopper_in and def._mcl_hoppers_on_try_push then
			minetest.override_item(nname, {
				_on_hopper_in = function(hopper_pos, node_pos)
					local hinv = minetest.get_meta(hopper_pos):get_inventory()
					local inv, list, stack = def._mcl_hoppers_on_try_push(node_pos, hopper_pos, hinv, "main")
					if stack and mcl_util.move_item(hinv, "main", stack, inv, list) and ( def._mcl_hoppers_after_push == nil or def._mcl_hoppers_after_push(node_pos)) then
						return true
					end
					return true
				end,
			})
		end
	end
end)
