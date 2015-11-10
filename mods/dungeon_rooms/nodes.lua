
minetest.register_node("dungeon_rooms:wall", {
	description = "Dungeon Wall",
	tiles = {"dungeon_rooms_wall.png"},
	groups = {creative_breakable=1},
	on_blast = function() end,
	is_ground_content = false,
	light_source = 5,
})


minetest.register_node("dungeon_rooms:wall_decoration", {
	description = "Dungeon Wall decoration",
	tiles = {"dungeontest_wall_decor.png"},
	is_ground_content = true,
	groups = {creative_breakable=1},
	sounds = default.node_sound_stone_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	    local room = dungeon_rooms.room_at(pos)
	    local roomseed = dungeon_rooms.seed_for_room(room)
	    local roomtype, rotation, Xdoor = dungeon_rooms.get_room_details(room)

	    local infostring = string.format("Level: %d Room: %d,%d (type:%d rot:%d door:%s seed:%d)", room.level, room.x, room.z, roomtype, rotation, Xdoor and "X" or "Z", roomseed)
	    local meta = minetest.get_meta(pos)
	    meta:set_string("infotext", infostring)
	end
})

--- doors

doors.register_door("dungeon_rooms:door", {
	description = "Dungeon Door",
	inventory_image = "dungeon_rooms_door.png",
	groups = {creative_breakable=1, door=1},
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
	groups = {creative_breakable=1, door=1},
	sounds = default.node_sound_wood_defaults(),
	sound_open = "doors_door_open",
	sound_close = "doors_door_close",
    	on_open = dungeon_rooms.spawn_ladder
})

-- wall pillars and other nodeboxes

castle.register_pillar("dungeon_rooms:pillar", {
    description = "Dungeon Pillar",
    tile = "dungeon_rooms_wall.png",
    groups = {creative_breakable=1},
})
stairs.register_stair_and_slab("wall", "dungeon_rooms:wall",
		{cracky = 3},
		{"dungeon_rooms_wall.png"},
		"Dungeon Stair",
		"Dungeon Slab",
		default.node_sound_stone_defaults())

-- spawner nodes


minetest.register_node("dungeon_rooms:room_spawner", {
	description = "Room Spawner",
	tiles = {"dungeontest_wall_decor.png"},
	is_ground_content = false,
    	groups = {not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_abm( {
	nodenames = {"dungeon_rooms:room_spawner"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.set_node(pos, {name="air"})
		dungeon_rooms.spawn_room(pos)
	end,
})
