
mechanisms.registered_punchstates = {}

mechanisms.punchstates = {}


function mechanisms.register_punchstate(name, def)
	mechanisms.registered_punchstates[name] = def
end

function mechanisms.end_player_punchstate(player_name, punchstate_name)
	local state = mechanisms.punchstates[player_name]
	if punchstate_name and state and punchstate_name ~= state.name then
		return nil
	elseif state and state.name then
		mechanisms.end_marking(state.name .. "_" .. player_name)
	end
	mechanisms.punchstates[player_name] = nil
	return state
end

function mechanisms.begin_player_punchstate(player_name, state)
	local def = mechanisms.registered_punchstates[state.name]
	if not def then
		return error("Unregistered punchstate: " .. state.name)
	end
	mechanisms.punchstates[player_name] = state
	mechanisms.start_marking(state.name .. "_" .. player_name, state.nodes or {}, def.get_mark_texture)
end

-- helper function
function mechanisms.absolute_to_relative(node, node_pos, pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local p = {
		x = pos.x - node_pos.x,
		z = pos.z - node_pos.z,
		y = pos.y - node_pos.y,
	}
	if dir.x > 0 and dir.z == 0 then
	elseif dir.x < 0 and dir.z == 0 then
		p.x, p.z = -p.x, -p.z
	elseif dir.z > 0 and dir.x == 0 then
		p.x, p.z = p.z, -p.x
	elseif dir.z < 0 and dir.x == 0 then
		p.x, p.z = -p.z, p.x
	end
	return p
end

function mechanisms.relative_to_absolute(node, node_pos, pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local p = {
		x = node_pos.x,
		z = node_pos.z,
		y = pos.y + node_pos.y,
	}
	if dir.x > 0 and dir.z == 0 then
		p.x = p.x + pos.x
		p.z = p.z + pos.z
	elseif dir.x < 0 and dir.z == 0 then
		p.x = p.x - pos.x
		p.z = p.z - pos.z
	elseif dir.z > 0 and dir.x == 0 then
		p.x = p.x - pos.z
		p.z = p.z + pos.x
	elseif dir.z < 0 and dir.x == 0 then
		p.x = p.x + pos.z
		p.z = p.z - pos.x
	end
	return p
end



-- handles set up punches
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)

	local name = puncher:get_player_name(); if name==nil then return end
	local state = mechanisms.punchstates[name]

	if not state then
		return
	elseif state.name then
		local selection = state.nodes or {}
		local def = mechanisms.registered_punchstates[state.name] or {}

		if def.on_punchnode_select then
			pos = def.on_punchnode_select(pos, node, puncher, pointed_thing)
		end

		local already_selected = false

		for k,p in pairs(selection) do
			if p.x==pos.x and p.y==pos.y and p.z==pos.z then
				already_selected = k
				break
			end
		end

		if already_selected then
		   local can_unmark, texture = true, nil
		   if def.on_unmark_node then
			  can_unmark, texture = def.on_unmark_node(selection[already_selected], node)
		   end
		   if can_unmark then
			  selection[already_selected] = nil
			  mechanisms.unmark_pos(state.name .. "_" .. name, pos)

		   elseif texture then -- if instead the texture changed, apply it
			  mechanisms.mark_pos(state.name .. "_" .. name, pos, texture)
		   end
		else
			local can_mark, texture = true, nil
			if def.on_mark_node then
				can_mark, texture = def.on_mark_node(pos, node)
			end
			if can_mark then
				table.insert(selection, pos)
				mechanisms.mark_pos(state.name .. "_" .. name, pos, texture)
			end
		end
	end
end)
