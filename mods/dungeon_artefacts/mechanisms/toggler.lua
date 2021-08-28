



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
		return true
	end
})


mechanisms.register_punchstate("mechanisms:switcher", {
	on_unmark_node = function(punchdata, node)
		-- if the node punched is toggled already, remove it
		-- otherwise toggle it (allowing us to save the node as off)
		local meta = minetest.get_meta(punchdata)
		local disabled = meta:get_int("disabled")
		if disabled == 1 then
		   meta:set_int("disabled", nil)
		   return true -- remove mark
		else
		   meta:set_int("disabled", 1)
		   return false, "mechanisms_mark_off.png" -- do not remove mark, mark it as off
		end
	end,

	on_mark_node = function(punchdata, node)
		-- only mark mechanisms
		local def = minetest.registered_nodes[node.name]
		if def and def.groups and def.groups.mechanism then
			return true, "mechanisms_mark_on.png" -- mark it as on
		end
		return false
	end,

	get_mark_texture = function(pos)
		local meta = minetest.get_meta(pos)
		if meta and meta:get_int("disabled") == 0 then
			return "mechanisms_mark_on.png"
		else
			return "mechanisms_mark_off.png"
		end
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

function switch_mechanisms(pos, toggler)
	local meta = minetest.get_meta(pos)
	local switching = meta:get_string("switching")

	switching = switching and minetest.deserialize(switching)
	if switching then
		-- add a delay to prevent lockups
		minetest.after(1, function()
			for k,v in pairs(switching) do
				local p = mechanisms.relative_to_absolute(toggler, pos, v)
				local meta = minetest.get_meta(p)
				local disabled = meta:get_int("disabled")
				if disabled ~= 0 then
					meta:set_int("disabled", 1)
				else
					meta:set_int("disabled", nil)
				end
				
				local node = minetest.get_node(p)
				local def = node and minetest.registered_nodes[node.name]
				if def and def.on_switch then
					def.on_switch(p, node, disabled ~= 0, meta)
				end
			end
		end)
	end
end


function toggler_save_punchstate(state, node, meta_field_name)
	local pos = minetest.string_to_pos(state.id)
	local meta = minetest.get_meta(pos)
	node = node or minetest.get_node(pos)
	
	local togglenodes = {}
	for k,v in pairs(state.nodes) do
		local node = mechanisms.absolute_to_relative(node, pos, v)
		node.name = v.name
		table.insert(togglenodes, node)
	end
	meta:set_string(meta_field_name or "togglenodes", minetest.serialize(togglenodes))
	
	return #togglenodes
end

function toggler_load_punchstate(pos, node, meta_field_name, punchstate_name)
	local meta = minetest.get_meta(pos)
	local togglenodes = meta:get_string(meta_field_name or "togglenodes")
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
		name = punchstate_name or "mechanisms:toggler",
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
		minetest.show_formspec(name, "mechanisms:toggler",
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

function toggler_edit_switcher(pos, node, player)
	local name = player:get_player_name()

	local state = mechanisms.end_player_punchstate(name, "mechanisms:toggler")
	if state then
		-- A punch state is already defined, save it!
	    local count = toggler_save_punchstate(state, node, "togglenodes")
		minetest.chat_send_player(name, "Saved " .. count .. " toggling nodes")
		minetest.log("action", name .. "saved toggler data with " .. count .. " toggleable nodes")
		
	else
		state = mechanisms.end_player_punchstate(name, "mechanisms:switcher")
		if state then 
			-- A punch state is already defined, save it!
			local count = toggler_save_punchstate(state, node, "switching")
			minetest.chat_send_player(name, "Saved " .. count .. " switching mechanisms")
			minetest.log("action", name .. "saved toggler data with " .. count .. " switcheable mechanisms")
		else
			formspec_context[name] = {
				pos = pos,
				node = node,
			}
			minetest.show_formspec(name, "mechanisms:toggler",
								   "size[4,6]" ..
									   "label[0,0; Toggler / Switcher]"..
									   "textarea[0.5,1;4,2;;"..
									   "This is both a toggler and a switcher!\n"..
									   "You can set mechanisms that will get switched on/off when this mechanism "..
									   "is activated. Switched off mechanisms might not carry out any action even "..
									   "when activated.\n"..
									   "You can also set a group of nodes to be toggled, these nodes will disappear/appear "..
									   "when this mechanism is activated."..
									   ";]"..
									   "button_exit[0.5,4.5;3,1;switchedit;Set mechanisms to switch]" ..
									   "button_exit[0.5,5.5;3,1;toggledit;Set nodes to toggle]")
		end
	end
end
-- Register callback
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mechanisms:toggler" then

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
		
		elseif fields.switchedit then
		   	local switchmechs, punchstate = toggler_load_punchstate(pos, context.node, "switching", "mechanisms:switcher")
			mechanisms.begin_player_punchstate(name, punchstate)

			minetest.chat_send_player(name, "Mechanism switcher edit mode! Punch mechanisms to assign them to this toggler,"
									  .." then right click again with the tome to save status. "
									  .. #switchmechs .. " mechanisms are currently assigned.")
			minetest.log("action", "Loading toggler data with " .. #switchmechs .. " switching mechanisms")

		   
		end
		formspec_context[name] = nil
	else
	   return false
	end
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
		end
	end,
	groups = {creative_breakable=1, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

if minetest.settings:get_bool("creative_mode") then
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
	groups = { creative_breakable = 1, mechanism = 1, },
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
	groups = {creative_breakable=1, mechanism=1, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})


-- Dungeon lever
minetest.register_node("mechanisms:lever_up", {
	description = "Dungeon Lever",
	drawtype = "nodebox",
	tiles = {
			"mechanisms_switch_top.png^[transformFY",
			"mechanisms_switch_top.png",
			"mechanisms_switch_side_up.png^[transformFX",
			"mechanisms_switch_side_up.png",
			"mechanisms_switch_back.png",
			"mechanisms_switch_front_up.png"
			},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {creative_breakable=1, mechanism=1},
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.3125, 0.375, 0.3125, 0.3125, 0.5},
			{-0.0625, -0.0625, 0.25, 0.0625, 0.0625, 0.5},
			{-0.0625, 0, 0.1875, 0.0625, 0.125, 0.3125},
			{-0.0625, 0.0625, 0.125, 0.0625, 0.1875, 0.25},
			{-0.0625, 0.125, 0.0625, 0.0625, 0.25, 0.1875},
			{-0.0625, 0.1875, 0, 0.0625, 0.3125, 0.125},
			{-0.0625, 0.25, -0.0625, 0.0625, 0.375, 0.0625},
			{0.0625, -0.125, 0.1875, 0.125, 0.125, 0.375},
			{-0.125, -0.125, 0.1875, -0.0625, 0.125, 0.375},
		}
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		-- If the player is holding the Tome of DungeonMaking, allow setup
		if itemstack:get_name() == "dmaking:tome" then
			toggler_edit_switcher(pos, node, player)
			
		else
			minetest.swap_node(pos, {name = "mechanisms:lever_down", param2=node.param2})
			minetest.sound_play("default_hard_footstep", {pos=pos})
			local meta = minetest.get_meta(pos)
			if meta:get_int("disabled") == 0 then
				toggle_nodes(pos, node)
				switch_mechanisms(pos, node)
			end
		end
	end,
	-- -- Don't toggle this state, we'll consider this the initial (off) state 
	-- on_switch = function(pos, node, disabled, meta)
	--    toggle_nodes(pos, node)
	--    switch_mechanisms(pos, node)
	-- end

})
--Switch Down
minetest.register_node("mechanisms:lever_down", {
	description = "Dungeon Lever",
	drawtype = "nodebox",
	tiles = {
			"mechanisms_switch_top.png^[transformFY",
			"mechanisms_switch_top.png",
			"mechanisms_switch_side_down.png^[transformFX",
			"mechanisms_switch_side_down.png",
			"mechanisms_switch_back.png",
			"mechanisms_switch_front_down.png"
			},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {creative_breakable=1, mechanism=1},
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.3125, 0.375, 0.3125, 0.3125, 0.5},
			{-0.0625, -0.0625, 0.25, 0.0625, 0.0625, 0.5},
			{-0.0625, -0.125, 0.1875, 0.0625, -0, 0.3125},
			{-0.0625, -0.1875, 0.125, 0.0625, -0.0625, 0.25},
			{-0.0625, -0.25, 0.0625, 0.0625, -0.125, 0.1875},
			{-0.0625, -0.3125, 0, 0.0625, -0.1875, 0.125},
			{-0.0625, -0.375, -0.0625, 0.0625, -0.25, 0.0625},
			{-0.125, -0.125, 0.1875, -0.0625, 0.125, 0.375},
			{0.0625, -0.125, 0.21875, 0.125, 0.125, 0.375},
		}
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		-- If the player is holding the Tome of DungeonMaking, allow setup
		if itemstack:get_name() == "dmaking:tome" then
			toggler_edit_switcher(pos, node, player)

		else
			minetest.swap_node(pos, {name = "mechanisms:lever_up", param2=node.param2})
			minetest.sound_play("default_hard_footstep", {pos=pos})
			local meta = minetest.get_meta(pos)
			if meta:get_int("disabled") == 0 then
				toggle_nodes(pos, node)
				switch_mechanisms(pos, node)
			end
		end
	end,
	on_switch = function(pos, node, disabled, meta)
	   toggle_nodes(pos, node)
	   switch_mechanisms(pos, node)
	end
})
