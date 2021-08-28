

function dmaking.show_map(player)

	local name = player:get_player_name() or "singleplayer"
	local pos = player:get_pos()

	local current_room = dungeon_rooms.get_room_details(dungeon_rooms.room_at(pos))
	local first_room = {
		x = math.floor(current_room.x/dungeon_rooms.total_size.x) * dungeon_rooms.total_size.x,
		z = math.floor(current_room.z/dungeon_rooms.total_size.z) * dungeon_rooms.total_size.x,
		level = current_room.level,
	}

	if pos.y > dungeon_rooms.origin.y then
		minetest.chat_send_player(name, "You check the map but it's empty! it seems to have no power outside the Dungeon")
		return false
	end

	local formspec = "size[5,5]"
		.."background[-0.5,-0.5;6,6.5;dmaking_parchment_bg.png]"
		.."label[1.5,0;Map of Level " .. current_room.level .. "]"
		.."label[0.5,0.5;" .. current_room.leveldata.name .."]"

		for x= 0, dungeon_rooms.total_size.x-1 do
			for z= 0, dungeon_rooms.total_size.z-1 do
				local room = current_room.leveldata.rooms[x] and current_room.leveldata.rooms[x][z]
				if room then

					if not room.x or not room.z then
						room.x = first_room.x + x
						room.z = first_room.z + z
						room.level = first_room.level
					end
					local layout, rotation = dungeon_rooms.calculate_room_layout(room)

					local transform = ""
					-- The formspecs rotate in the oposite direction than the schematics rotate...
					local rotation = type(rotation) ~= "string" and (360 - rotation) % 360 or 0
					if rotation ~= 0 then
						transform = "^[transformR" .. rotation
					end

					local ladder = dungeon_rooms.is_room_ladder(room)
					if ladder then
						transform = transform .. "^dmaking_layout_" .. ladder .. ".png"
					end

					if room == current_room then
						transform = transform .. "^dmaking_red_dot.png"
					end

					formspec = formspec
						.."image[".. (3.5 - 0.75*(room.z -first_room.z)) .."," .. (4.25 - 0.8*(room.x -first_room.x))
						..";1,1;dmaking_layout_" .. layout .. ".png" .. transform .. "]"
				end
			end
		end

	minetest.show_formspec(name, "dmaking:map", formspec)
end




minetest.register_node("dmaking:map", {
	description = "Dungeon Map",
	drawtype = "signlike",
	tiles = {"dmaking_parchment.png^dmaking_parchment_map.png"},
	wield_image = "dmaking_parchment.png^dmaking_parchment_map.png",
	inventory_image = "dmaking_parchment.png^dmaking_parchment_map.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	selection_box = {
		type="wallmounted",
		wall_top = {-0.44, 0.49, -0.44, 0.44, 0.5, 0.44},
		wall_bottom = {-0.44, -0.5, -0.44, 0.44, -0.49, 0.44},
		wall_side = {-0.5, -0.44, -0.44, -0.49, 0.44, 0.44},
	},
	groups = {attached_node=1, creative_breakable=1},
	walkable = false,
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext","Dungeon Level map")
	end,
	on_rightclick = function(pos, node, player)
		dmaking.show_map(player)
	end
})
