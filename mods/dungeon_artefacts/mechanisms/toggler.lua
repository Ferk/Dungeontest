



-- A table with nodes that will be considered the same for the toggler
-- (so, even if the node gets swapped to a different state it still can be toggled)
mechanisms.toggler_alias_table = {}

mechanisms.toggler_alias_table["mechanisms:toggler_on"] = "mechanisms:toggler"


mechanisms.register_punchstate("mechanisms:toggler", {
	on_unmark_node = function(punchdata, node)
		-- if the node punched is toggled already, remove it
		-- otherwise toggle it (allowing us to save the node as off)
		if node.name == "mechanisms:toggled_node" then
			node.name = punchdata.name
			minetest.swap_node(punchdata, node)
			return true -- remove mark
		else
			node.name = "mechanisms:toggled_node"
			minetest.swap_node(punchdata, node)
			return false -- do not remove mark
		end
	end,

	on_mark_node = function(punchdata, node)
		punchdata.name = mechanisms.toggler_alias_table[node.name] or node.name
		print("added node at " .. minetest.pos_to_string(punchdata))
		return true
	end
})


function toggle_nodes(pos, toggler)
	local meta = minetest.get_meta(pos)
	local togglenodes = meta:get_string("togglenodes")

	togglenodes = togglenodes and minetest.deserialize(togglenodes)
	if togglenodes then
		for k,v in pairs(togglenodes) do
			local p = mechanisms.relative_to_absolute(toggler, pos, v)
			local node = minetest.get_node(p)
			if node.name ~= v.name and mechanisms.toggler_alias_table[node.name] ~= v.name then
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

	local state = mechanisms.end_player_punchstate(name, "mechanisms:toggler")
	if state then
		-- A punch state is already defined, save it!
		pos = minetest.string_to_pos(state.id)
		local meta = minetest.get_meta(pos)

		local togglenodes = {}
		for k,v in pairs(state.nodes) do
			local node = mechanisms.absolute_to_relative(node, pos, v)
			node.name = v.name
			table.insert(togglenodes, node)
		end

		minetest.chat_send_player(name, "Saved " .. #togglenodes .. " toggling nodes")
		minetest.log("action", name .. "saved toggler data with " .. #togglenodes .. " toggleable nodes")
		meta:set_string("togglenodes", minetest.serialize(togglenodes))
	else
		-- no punchstate defined, create it!
		local meta = minetest.get_meta(pos)
		local togglenodes = meta:get_string("togglenodes")
		local punchs = {}

		togglenodes = togglenodes and minetest.deserialize(togglenodes)
		if togglenodes then
			for k,v in pairs(togglenodes) do
				local node = mechanisms.relative_to_absolute(node, pos, v)
				node.name = v.name
				table.insert(punchs, node)
			end
		else
			togglenodes = { }
		end

		minetest.chat_send_player(name, "Node toggler edit mode! Punch nodes to assign them to this toggler,"
			.." then right click again with the tome to save status. " .. #togglenodes .. " nodes are currently assigned.")
		minetest.log("action", "Loading toggler data with " .. #togglenodes .. " toggleable nodes")

		mechanisms.begin_player_punchstate(name, {
			name = "mechanisms:toggler",
			id = minetest.pos_to_string(pos),
			nodes = punchs,
		})
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
		paramtype = "light",
		paramtype2 = "facedir",
		walkable = false,
		light_source = default.LIGHT_MAX-7,
		sunlight_propagates = true,
		drop = "",
		groups = {creative_breakable=1, not_in_creative_inventory=1},
	})
else
	minetest.register_alias("mechanisms:toggled_node","air")

	minetest.register_node(":air", {
		drawtype = "airlike",
		paramtype = "light",
		paramtype2 = "facedir",
		walkable = false,
		sunlight_propagates = true,
	})
end
