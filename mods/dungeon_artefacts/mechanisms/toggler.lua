



-- A table with nodes that will be considered the same for the toggler
-- (so, even if the node gets swapped to a different state it still can be toggled)
mechanisms.toggler_alias_table = {}

mechanisms.toggler_alias_table["mechanisms:toggler_on"] = "mechanisms:toggler"
mechanisms.toggler_alias_table["mechanisms:timed_toggler_on"] = "mechanisms:timed_toggler"


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

function toggler_save_punchstate(state, node)
	local pos = minetest.string_to_pos(state.id)
	local meta = minetest.get_meta(pos)
	node = node or minetest.get_node(pos)
	
	local togglenodes = {}
	for k,v in pairs(state.nodes) do
		local node = mechanisms.absolute_to_relative(node, pos, v)
		node.name = v.name
		table.insert(togglenodes, node)
	end
	meta:set_string("togglenodes", minetest.serialize(togglenodes))
	
	return #togglenodes
end

function toggler_load_punchstate(pos, node)
	local meta = minetest.get_meta(pos)
	local togglenodes = meta:get_string("togglenodes")
	local punchs = {}
	node = node or minetest.get_node(pos)

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
	local punchstate = {
		name = "mechanisms:toggler",
		id = minetest.pos_to_string(pos),
		nodes = punchs,
	}
	return togglenodes, punchstate
end


function toggle_punch_node_selection(pos, node, player)
	local name = player:get_player_name()

	local state = mechanisms.end_player_punchstate(name, "mechanisms:toggler")
	if state then
		-- A punch state is already defined, save it!
	   local count = toggler_save_punchstate(state, node)
		minetest.chat_send_player(name, "Saved " .. count .. " toggling nodes")
		minetest.log("action", name .. "saved toggler data with " .. count .. " toggleable nodes")

	else
		-- no punchstate defined, create it!
	   local togglenodes, punchstate = toggler_load_punchstate(pos, node)
	   mechanisms.begin_player_punchstate(name, punchstate)
	   
	   minetest.chat_send_player(name, "Node toggler edit mode! "..
								 "Punch nodes to assign them to this toggler, "..
								 "then right click again with the tome to save status. "..
								 #togglenodes .. " nodes are currently assigned.")
		minetest.log("action", "Loading toggler data with " .. #togglenodes .. " toggleable nodes")
	end
end

-------------------
-- Formspecs
-------------------
local formspec_context = {}

function toggler_edit_timed(pos, node, player)
	local name = player:get_player_name()

	local state = mechanisms.end_player_punchstate(name, "mechanisms:toggler")
	if state then
		-- A punch state is already defined, save it!
	    local count = toggler_save_punchstate(state)
		minetest.chat_send_player(name, "Saved " .. count .. " toggling nodes")
		minetest.log("action", name .. "saved toggler data with " .. count .. " toggleable nodes")
	else
		formspec_context[name] = {
			pos = pos,
		}
		minetest.show_formspec(name, "mechanisms:timed_toggler",
							   "size[4,6]" ..
								  "label[0,0; Timed Toggler]"..
								  "textarea[0.5,1;3,2;;"..
								  "This toggler is timed! when activated it'll start ticking, "..
								  "after a given timeout it'll toggle back to the original state.\n"..
								  "You can set a group of nodes that will disappear/appear when "..
								  "the toggler state changes."..
								  ";]"..
								  "field[0.7,3.5.5;3,1;timeout;Timeout;10]" ..
								  "button_exit[0.5,4.5;3,1;exit;Save & exit]" ..
								  "button_exit[0.5,5.5;3,1;toggledit;Set nodes to toggle (punch them!)]")
	end
end


-- Register callback
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mechanisms:timed_toggler" then
		local name = player:get_player_name()
		local context = formspec_context[name]

		if not context or not context.pos then
		   return false
		end
		local pos = context.pos
		
		if fields.timeout then
			local meta = minetest.get_meta(pos)
			meta:set_int("timeout",fields.timeout)
			minetest.chat_send_player(name, "Saved timeout of " .. fields.timeout .. " seconds")
		end
		if fields.toggledit then
			local togglenodes, punchstate = toggler_load_punchstate(pos)
			mechanisms.begin_player_punchstate(name, punchstate)

			minetest.chat_send_player(name, "Node toggler edit mode! Punch nodes to assign them to this toggler,"
									  .." then right click again with the tome to save status. "
									  .. #togglenodes .. " nodes are currently assigned.")
			minetest.log("action", "Loading toggler data with " .. #togglenodes .. " toggleable nodes")
	   end

	   return true
	else
	   return false
	end

	-- Send message to player.


	-- Return true to stop other minetest.register_on_player_receive_fields
	-- from receiving this submission.
	return true
end)

-------------------
-- Nodes
-------------------

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
		if itemstack:get_name() == "dmaking:tome" then
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



minetest.register_node("mechanisms:timed_toggler", {
	description = "Timed Dungeon Button",
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
		if itemstack:get_name() == "dmaking:tome" then
			toggler_edit_timed(pos, node, player)

		else
			minetest.swap_node(pos, {name = "mechanisms:timed_toggler_on", param2=node.param2})
			minetest.sound_play("default_hard_footstep", {pos=pos})
			local meta = minetest.get_meta(pos)
			local timeout = meta:get_int("timeout")
			toggle_nodes(pos, node, meta)
			if timeout <= 0 then timeout = 10 end

			local ticking = minetest.sound_play("mechanisms_ticking", {pos = pos,5, loop=true})
			minetest.get_node_timer(pos):start(timeout)
			minetest.after(timeout, function()
				minetest.sound_stop(ticking)
			end)
		end
	end,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mechanisms:timed_toggler_on", {
	description = "Timed Dungeon Button",
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
	on_timer = function (pos, elapsed)
	   local node = minetest.get_node(pos)
	   node.name = "mechanisms:timed_toggler"
	   minetest.swap_node(pos, node)
	   minetest.sound_play("default_hard_footstep", {pos=pos})
	   toggle_nodes(pos, node)
	end,
	groups = {creative_breakable=1, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})


