

dungeon_chests.register_chest("standard", {
    description = "Standard Chest",
    on_setup = function(pos, meta, player)
        print("set up standard chest")
        local inv = meta:get_inventory()
        inv:set_size("main", 8*3)
    end,
})


dungeon_chests.register_chest("tnt", {
    description = "TNT Trap",
	on_open = function(pos, node, player, itemstack, pointed_thing)
		minetest.chat_send_player(player:get_player_name(), " - TNT Trap! -")
		minetest.sound_play("tnt_ignite", {pos=pos})
		minetest.set_node(pos, {name="tnt:tnt_burning"})
		minetest.get_node_timer(pos):start(4)
		return false
	end
})

dungeon_chests.register_chest("fire", {
    description = "Fire Trap",
	on_open = function(pos, node, player, itemstack, pointed_thing)
		minetest.chat_send_player(player:get_player_name(), " - Fire Trap! -")
		minetest.set_node(pos, {name="fire:basic_flame"})
		return false
	end
})

dungeon_chests.register_chest("mimic", {
    description = "Mimic Trap",
	on_open = function(pos, node, player, itemstack, pointed_thing)
		minetest.chat_send_player(player:get_player_name(), " - It's a Mimic! -")
		minetest.set_node(pos, {name="air"})
		minetest.add_entity(pos, "dungeon_chests:mimic")
		return false
	end
})



dungeon_chests.register_chest("treasure_common", {
    description = "Common Treasure",
	on_open = function(pos, node, player, itemstack, pointed_thing, meta)

		local meta = meta or minetest.get_meta(pos)

		-- Return true (open inventory) right away if already discovered
		if meta:get_int("discovered") > 0 then
			return true
		end

		-- Base preciousness relates to heigh (the deeper down, the more precious)
		local basepr = -pos.y / 32
		if basepr < 0 then
			basepr = 0.01
		end

        -- chance for rarer items to start appearing
		local rare_chance = 4

        if minetest.setting_getbool("creative_mode") then
           minetest.chat_send_player(player:get_player_name(), "Treasure chest: preciousness " .. basepr ..", rare chance " .. rare_chance)
           return false
        end

   		meta:set_int("discovered", os.time())
   		minetest.chat_send_player(player:get_player_name(), "You discovered a treasure!")

        return dungeon_chests.set_treasure(meta, basepr, rare_chance)
	end
})

dungeon_chests.register_chest("treasure_rare", {
    description = "Rare Treasure",
	on_open = function(pos, node, player, itemstack, pointed_thing, meta)

		local meta = meta or minetest.get_meta(pos)

		-- Return true (open inventory) right away if already discovered
		if meta:get_int("discovered") > 0 then
			return true
		end

		-- Base preciousness relates to heigh (the deeper down, the more precious)
		local basepr = -pos.y / 32 * 1.2
		if basepr < 0 then
			basepr = 0.01
		end

        -- chance for rarer items to start appearing
		local rare_chance = 2

        if minetest.setting_getbool("creative_mode") then
           minetest.chat_send_player(player:get_player_name(), "Treasure chest: preciousness " .. basepr ..", rare chance " .. rare_chance)
           return false
        end

   		meta:set_int("discovered", os.time())
   		minetest.chat_send_player(player:get_player_name(), "You discovered a rare treasure!")

        return dungeon_chests.set_treasure(meta, basepr, rare_chance)
	end
})


function dungeon_chests.set_treasure(meta, base_preciousness, rare_chance)

    -- Get the inventory of the chest to place the treasures in
    local inv = meta:get_inventory()
    inv:set_size("main", 8*3)

    -- determine a random amount of treasures
    local common_amount = math.random(1, 5)
    local rare_amount = 0
    while math.random(rare_chance) == 1 do
        rare_amount = rare_amount + 1
    end

    --
    local minpr = base_preciousness*0.5
    local maxpr = base_preciousness*1.5+2.1

    local tr_common = treasurer.select_random_treasures(common_amount, nil, maxpr)
    local tr_rare = treasurer.select_random_treasures(rare_amount, minpr*2, maxpr*2)

    for i=1,#tr_common do
        inv:set_stack("main",i,tr_common[i])
    end
    for i=1,#tr_rare do
        inv:set_stack("main",i,tr_rare[i])
    end

    return true
end
