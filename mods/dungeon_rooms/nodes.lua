

function onlyCreative(var)
    if minetest.setting_getbool("creative_mode") then
        return var
    else
        return nil
    end
end


minetest.register_node("dungeon_rooms:wall", {
	description = "Dungeon Wall",
	tiles = {"dungeon_rooms_wall.png"},
	groups = onlyCreative({cracky=2, stone=1}),
  on_blast = function() end,
  is_ground_content = false,
	light_source = 5,
})


minetest.register_node("dungeon_rooms:room_spawner", {
	description = "Room Spawner",
	tiles = {"dungeontest_wall_decor.png"},
	is_ground_content = true,
	groups = onlyCreative({cracky=2, stone=1}),
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_abm( {
	nodenames = {"dungeon_rooms:room_spawner"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.set_node(pos, {name="air"})
		dungeon_rooms.spawn_room(pos)
        local node = minetest.get_node(pos)
        if node.name == "dungeon_rooms:room_spawner" then
            minetest.log("action", "ERROR!!! NODE STILL HERE!?");
        end
	end,
})



minetest.register_node("dungeon_rooms:entrance_spawner", {
	description = "Entrance Spawner",
	tiles = {"dungeontest_wall_decor.png"},
	is_ground_content = true,
	groups = onlyCreative({cracky=2, stone=1}),
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_abm( {
	nodenames = {"dungeon_rooms:entrance_spawner"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		dungeon_rooms.spawn_entrance(pos)
	end,
})



minetest.register_node("dungeon_rooms:wall_decoration", {
	description = "Dungeon Wall decoration",
	tiles = {"dungeontest_wall_decor.png"},
	is_ground_content = true,
	groups = onlyCreative({cracky=2, stone=1}),
	sounds = default.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		--minetest.set_timeofday(0)
		--minetest.set_node(pos, {name="tutorial:night"})
        local room = dungeon_rooms.room_at(pos)
        local roomseed = dungeon_rooms.seed_for_room(room)
        local roomtype, rotation, Xdoor = dungeon_rooms.get_room_details(room)

        local infostring = string.format("Level: %d Room: %d,%d (seed:%d type:%d door:%s)", room.level, room.x, room.z, roomseed, roomtype, Xdoor and "X" or "Z")
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", infostring)

        --[[
        local formspec = ""..
        "size[12,6]"..
        "label[-0.15,-0.4;"..minetest.formspec_escape("hey").."]"..
        "tablecolumns[text]"..
        "tableoptions[background=#000000;highlight=#000000;border=false]"..
        "table[0,0.25;12,5.2;infosign_text;"..
        minetest.formspec_escape(infostring)..
        "]"..
        "button_exit[4.5,5.5;3,1;close;"..minetest.formspec_escape("Close").."]"
        meta:set_string("formspec", formspec)
        ]]
	end
})

--- doors

doors.register_door("dungeon_rooms:door", {
	description = "Dungeon Door",
	inventory_image = "dungeon_rooms_door.png",
	groups = onlyCreative({oddly_breakable_by_hand=1,door=1}) or {immortal=1,door=1},
    light_source = 4,
	tiles_bottom = {"dungeon_rooms_door_b.png", "doors_brown.png"},
	tiles_top = {"dungeon_rooms_door_t.png", "doors_brown.png"},
	sounds = default.node_sound_wood_defaults(),
	sunlight = false,
})

doors.register_trapdoor("dungeon_rooms:trapdoor", {
	description = "Dungeon Trapdoor",
	inventory_image = "doors_trapdoor.png",
	wield_image = "doors_trapdoor.png",
	tile_front = "doors_trapdoor.png",
	tile_side = "doors_trapdoor_side.png",
	--groups = {immortal=1, door=1},
    groups = onlyCreative({oddly_breakable_by_hand=1, door=1}) or {door=1},
	sounds = default.node_sound_wood_defaults(),
	sound_open = "doors_door_open",
	sound_close = "doors_door_close",
    on_open = dungeon_rooms.spawn_ladder
})

-- pillars

castle.register_pillar("dungeon_rooms:pillar", {
    description = "Dungeon Pillar",
    tile = "dungeon_rooms_wall.png",
    groups = onlyCreative({cracky=1}) or {immortal=1},
})
