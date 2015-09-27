
dungeon_rooms.hud = {}

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = vector.round(player:getpos())
		local areaString

        if pos.y > dungeon_rooms.origin.y then
            areaString = ""
        else
            local room = dungeon_rooms.room_at(pos)
            local roomtype, rotation, Xdoor = dungeon_rooms.get_room_details(room)
            areaString = "Dungeon Level " .. (room.level/2) .. " ("..room.x..","..room.z..") type"..roomtype.." rot:"..rotation.." door:".. (Xdoor and "X" or "Z")
        end

        local hud = dungeon_rooms.hud[name]
		if not hud then
            minetest.log("action","creating hud:" .. areaString)
			hud = {}
			dungeon_rooms.hud[name] = hud
			hud.areasId = player:hud_add({
				hud_elem_type = "text",
				name = "Areas",
				number = 0xFFFFFF,
				position = {x=1, y=0},
				offset = {x=-12, y=6},
				text = areaString,
				scale = {x=200, y=60},
				alignment = {x=-1, y=1},
			})
			hud.oldAreas = areaString
			return
		elseif hud.oldAreas ~= areaString then
            minetest.log("action","updating hud:" .. areaString)
			player:hud_change(hud.areasId, "text", areaString)
			hud.oldAreas = areaString
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	dungeon_rooms.hud[player:get_player_name()] = nil
end)
