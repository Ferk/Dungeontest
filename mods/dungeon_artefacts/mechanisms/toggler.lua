

local punching_state = {}




function absolute_to_relative(node, node_pos, pos)
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

function relative_to_absolute(node, node_pos, pos)
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


function toggle_nodes(pos, toggler)
	local meta = minetest.get_meta(pos)
	local togglenodes = meta:get_string("togglenodes")

	togglenodes = togglenodes and minetest.deserialize(togglenodes)
	if togglenodes then
		for k,v in pairs(togglenodes) do
			local p = relative_to_absolute(toggler, pos, v)
			local node = minetest.get_node(p)
			if node.name ~= v.name then
				node.name = v.name
			else
				node.name = "mechanisms:toggled_node"
			end
			minetest.swap_node(p, node)
		end
	end
end

function toggle_punch_node_selection(pos, node, player)
	local name = player:get_player_name()


	if punching_state[name] then
		pos = minetest.string_to_pos(punching_state[name].id)
		local meta = minetest.get_meta(pos)




		mechanisms.end_marking(name, positions)
		local togglenodes = {}
		for k,v in pairs(punching_state[name].nodes) do
			local node = absolute_to_relative(node, pos, v)
			node.name = v.name
			table.insert(togglenodes, node)
		end

		minetest.log("action", "Saving toggler data with " .. #togglenodes .. " toggleable nodes")
		meta:set_string("togglenodes", minetest.serialize(togglenodes))

		punching_state[name] = nil
	else
		local meta = minetest.get_meta(pos)
		local togglenodes = meta:get_string("togglenodes")
		local punchs = {}

		togglenodes = togglenodes and minetest.deserialize(togglenodes)
		if togglenodes then
			for k,v in pairs(togglenodes) do
				local node = relative_to_absolute(node, pos, v)
				node.name = v.name
				table.insert(punchs, node)
			end
		else
			togglenodes = { }
		end

		minetest.log("action", "Loading toggler data with " .. #togglenodes .. " toggleable nodes")
		punching_state[name] = {
			id = minetest.pos_to_string(pos),
			nodes = punchs,
		}
		mechanisms.start_marking(name, punchs)
	end
end

minetest.register_node("mechanisms:toggler", {
	description = "Dungeon Button",
	drawtype = "nodebox",
	tiles = {
	"default_stone.png",
	"default_stone.png",
	"default_stone.png",
	"default_stone.png",
	"default_stone.png",
	"dungeontest_wall_decor.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -6/16, 5/16, 6/16, 6/16, 8/16 },
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -6/16, -6/16, 7/16, 6/16, 6/16, 8/16 },	-- the thin plate behind the button
			{ -4/16, -4/16, 5/16, 4/16, 4/16, 7/16 },	-- the button itself
		}
	},
	groups = { creative_breakable = 1 },
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		-- If the player is holding the Tome of DungeonMaking, allow setup
		if itemstack.name == "dmaking:tome" then
			toggle_punch_node_selection(pos, node, player)

		else
			minetest.swap_node(pos, {name = "mechanisms:toggler_on", param2=node.param2})
			minetest.sound_play("default_hard_footstep", {pos=pos})
			toggle_nodes(pos, node)
			--minetest.after(1, mesecon.button_turnoff, pos)
		end
	end,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mechanisms:toggler_on", {
	description = "Dungeon Button",
	drawtype = "nodebox",
	tiles = {
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"dungeontest_wall_decor.png"
		},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	light_source = default.LIGHT_MAX-7,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = { -6/16, -6/16, 5/16, 6/16, 6/16, 8/16 }
	},
	node_box = {
	type = "fixed",
		fixed = {
			{ -6/16, -6/16,  7/16, 6/16, 6/16, 8/16 },
			{ -4/16, -4/16,  6.8/16, 4/16, 4/16, 7/16 }
		}
	},
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		-- If the player is holding the Tome of DungeonMaking, allow setup
		if itemstack:get_name() == "dmaking:tome" then
			toggle_punch_node_selection(pos, node, player)

		else
			minetest.swap_node(pos, {name = "mechanisms:toggler", param2=node.param2})
			minetest.sound_play("default_hard_footstep", {pos=pos})
			toggle_nodes(pos, node)
			--minetest.after(1, mesecon.button_turnoff, pos)
		end
	end,
	groups = {creative_breakable=1, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

if minetest.setting_getbool("creative_mode") then
	minetest.register_node("mechanisms:toggled_node", {
		description = "Hidden node",
		drawtype = "nodebox",
		tiles = {
			"mechanisms_toggled.png",
			"mechanisms_toggled.png",
			"mechanisms_toggled.png",
			"mechanisms_toggled.png",
			"mechanisms_toggled.png",
			"mechanisms_toggled.png",
		},
		walkable = false,
		light_source = default.LIGHT_MAX-7,
		sunlight_propagates = true,
		drop = "",
		groups = {creative_breakable=1, not_in_creative_inventory=1},
	})
else
	minetest.register_alias("mechanisms:toggled_node","air")
end

-- handles set up punches
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)

	local name = puncher:get_player_name(); if name==nil then return end
	local state = punching_state[name]
	if not state then
		return
	elseif state.nodes then
		local punchs = state.nodes
		local already_punched = false

		for k,p in pairs(punchs) do
			if p.x==pos.x and p.y==pos.y and p.z==pos.z then
				already_punched = k
				break
			end
		end

		if already_punched then
			punchs[already_punched] = nil
			mechanisms.unmark_pos(name, pos)
			print("removed node at " .. minetest.pos_to_string(pos))
		else
			pos.name = node.name
			table.insert(punchs, pos)
			mechanisms.mark_pos(name, pos)
			print("added node at " .. minetest.pos_to_string(pos))
		end
	end
end)
