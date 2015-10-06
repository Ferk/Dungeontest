

dungeon_chests = {}

dungeon_chests.types = {}

function dungeon_chests.register_chest(type, def)
	dungeon_chests.types[type] = def;
end

dungeon_chests.register_chest("tnt", {
	on_open = function(pos, node, player, itemstack, pointed_thing)
		minetest.chat_send_player(player:get_player_name(), " - TNT Trap! -")
		minetest.sound_play("tnt_ignite", {pos=pos})
		minetest.set_node(pos, {name="tnt:tnt_burning"})
		minetest.get_node_timer(pos):start(4)
		return false
	end
})

dungeon_chests.register_chest("fire", {
	on_open = function(pos, node, player, itemstack, pointed_thing)
		minetest.chat_send_player(player:get_player_name(), " - Fire Trap! -")
		minetest.set_node(pos, {name="fire:basic_flame"})
		return false
	end
})

dungeon_chests.register_chest("mimic", {
	on_open = function(pos, node, player, itemstack, pointed_thing)
		minetest.chat_send_player(player:get_player_name(), " - It's a Mimic! -")
		minetest.set_node(pos, {name="air"})
		minetest.add_entity(pos, "dungeon_chests:mimic")
		return false
	end
})


dungeon_chests.register_chest("treasure", {
	on_open = function(pos, node, player, itemstack, pointed_thing)
		minetest.chat_send_player(player:get_player_name(), "You found a treasure!")


		-- Base preciousness relates to heigh (the deeper down, the more precious)
		local basepr = -pos.y / 32
		if basepr < 0 then
			basepr = 0.01
		end

		-- chance for rarer items to start appearing
		local rare_chance = 4
		
		-- determine a random amount of treasures
		local common_amount = math.random(1, 3)
		local rare_amount = 0
		while math.random(rare_chance) == 1 do
			rare_amount = rare_amount + 1
		end

		-- 
		local minpr = basepr
		local maxpr = basepr*1.5+2.1

		local tr_common = treasurer.select_random_treasures(common_amount,
														   basepr, 2.1+basepr*1.2)

		local tr_rare = treasurer.select_random_treasures(rare_amount,
														   basepr*2, 2.1+basepr*2.2)

		
		-- Get the inventory of the chest to place the treasures in
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		
		for i=1,#tr_common do
			inv:set_stack("main",i,treasures[i])
		end
		for i=1,#tr_rare do
			inv:set_stack("main",i,treasures[i])
		end
		
		return true
	end
})


-- TODO: I should have chests that contain random loot based on level!




------ Chest node

local chest_context = {}

minetest.register_node("dungeon_chests:chest", {
	description = "Dungeon Chest",
	tiles = {"dungeon_chest_top.png", "dungeon_chest_top.png", "dungeon_chest_side.png",
		"dungeon_chest_side.png", "dungeon_chest_back.png", "dungeon_chest_front.png"},
	paramtype2 = "facedir",
	groups = { creative_breakable = 1 },
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_blast = function() end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Chest")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*3)
	end,
	can_dig = function(pos,player) return minetest.setting_getbool("creative_mode")	end,
	after_place_node = function(pos, player, itemstack, pointed_thing)
		local name = player:get_player_name()
		chest_context[name] = {pos = pos}
		minetest.show_formspec(name, "dungeon_chests:settype",
			"size[4,3]" ..
			"field[1,0.5;3,1;type;Dungeon Chest Type;]" ..
			"button_exit[1,1;2,1;exit;Save]")
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local type = meta:get_string("chesttype")

		local def = dungeon_chests.types[type]
		if def and def.on_open then
			shallopen = def.on_open(pos, node, player, itemstack, pointed_thing)
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
			" rearranged stuff in a chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local inam = stack:get_name()
		minetest.log("action", player:get_player_name().. " put " .. inam .. " in a chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local inam = stack:get_name()
		minetest.log("action", player:get_player_name().. " took " .. inam .. " from a chest at "..minetest.pos_to_string(pos))
	end,
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "dungeon_chests:settype" and fields.type then

		local name = player:get_player_name()
		minetest.chat_send_player(name, "Chest type set to: " .. (fields.type or "default"))
		local context = chest_context[name]
		local meta = context.meta or minetest.get_meta(context.pos)
		meta:set_string("chesttype", fields.type)

		local def = dungeon_chests.types[fields.type]

		if def and def.on_construct then
			def.on_construct(pos, node, player, itemstack, pointed_thing)
		end

		if def and def.formspec ~= "default" then
			meta:set_string("formspec", def.formspec)
		else
			meta:set_string("formspec", "size[8,8]"..
				default.gui_bg..
				default.gui_bg_img..
				default.gui_slots..
				"list[current_name;main;0,0.3;8,3;]"..
				"list[current_player;main;0,3.85;8,1;]"..
				"list[current_player;main;0,5.08;8,3;8]"..
				"listring[current_name;main]"..
				"listring[current_player;main]"..
				default.get_hotbar_bg(0,4.85))
		end

		-- release context
		chest_context[name] = nil
		return true
	--elseif formname == "dungeon_chests:openchest" then
	end

	-- Not my formname
	return false
end)


dofile(minetest.get_modpath(minetest.get_current_modname()).."/mimic.lua")
