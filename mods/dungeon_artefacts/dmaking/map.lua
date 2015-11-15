

function dmaking.show_map(player)

	local name = player:get_player_name() or "singleplayer"
	local pos = player:getpos()

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
		--.."background[-1,-1;12,9;dmaking_map_bg.png]"
		.."label[1.5,0;Map of Level " .. current_room.level .. "]"
		.."label[0.5,0.5;" .. current_room.leveldata.name .."]"

		for x= 0, dungeon_rooms.total_size.x-1 do
			for z= 0, dungeon_rooms.total_size.z-1 do
				local room = current_room.leveldata.rooms[x] and current_room.leveldata.rooms[x][z]
				if room then

					if not room.layout then
						room.x = first_room.x + x
						room.z = first_room.z + z
						room.level = first_room.level
						room = dungeon_rooms.get_room_details(room)
					end

					-- The formspecs rotate in the oposite direction than the schematics rotate...
					local transformRotation = type(room.rotation) ~= "string" and (360 - room.rotation) % 360 or 0
					if transformRotation == 0 then
						transformRotation = ""
					else
						transformRotation = "^[transformR" .. transformRotation
					end

					if room == current_room then
						print("TRANS: " .. transformRotation)
					end

					formspec = formspec
						.."image[".. (3.5 - 0.75*(room.z -first_room.z)) .."," .. (4.25 - 0.8*(room.x -first_room.x)) .. ";1,1;dmaking_layout_" .. room.layout ..".png" .. transformRotation
						..( room == current_room and "^dmaking_red_dot.png" or "" )
						.."]"
				end
			end
		end

	minetest.show_formspec(name, "dmaking:map", formspec)
end
