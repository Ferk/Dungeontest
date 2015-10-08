
--------------
-- Chat commands

local modpath = minetest.get_modpath(minetest.get_current_modname())


local function split_roompath(roompath)
    local split = string.split(roompath, "/", nil, 1)
    local dir, roomname
    if #split == 2 then
        dir = split[1]
        roomname = split[2]
    else
        dir = "."
        roomname = roompath
    end
    return dir, roomname
end


minetest.register_chatcommand("save", {
	params = "<text>",
	description = "Saves the room",
	func = function(name, param)
		local roompath = param or "draft"
		local player = minetest.get_player_by_name(name)

		local roomconf = Settings(modpath .. "/roomdata/" .. roompath .. ".conf")
		local roomdata = roomconf:to_table()

        roomdata.path = modpath .. "/roomdata/" .. roompath

		if dungeon_rooms.save_roomdata(player:getpos(), roomdata) then
			minetest.chat_send_player(name, "room saved: " .. (roomdata.name or roompath))
		else
			minetest.chat_send_player(name, "room couldn't be saved")
		end
	end,
})

minetest.register_chatcommand("load", {
	params = "<text>",
	description = "Loads the room",
	func = function(name, param)
		local roompath = param or "draft"
		local player = minetest.get_player_by_name(name)
		local pos = player:getpos()
		-- clear metadata before loading the schematic, otherwise the previous meta will be stored!
		dungeon_rooms.clear_room_meta(pos)

        local roomconf = Settings(modpath .. "/roomdata/" .. roompath .. ".conf")
        local roomdata = roomconf:to_table()
        roomdata.path = modpath .. "/roomdata/" .. roompath

        print("Loading roomdata " .. roompath .. ": " .. dump(roomdata))

		if dungeon_rooms.place_roomdata(pos, roomdata) then
			minetest.chat_send_player(name, "room loaded: " .. (roomdata.name or roompath))
		else
			minetest.chat_send_player(name, "room couldn't be loaded")
		end
	end,
})

-- Mostly for testing and for converting all rooms to same format when developing
-- a change in the map storage
minetest.register_chatcommand("rewrite_all", {
	params = "",
	description = "Loads and saves all rooms",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local pos = player:getpos()
		for i, pool in pairs(dungeon_rooms.rooms) do
			for i = 1, #pool do
				local roomdata = pool[i]
				dungeon_rooms.clear_room_meta(pos)
				dungeon_rooms.place_roomdata(pos, roomdata, 0)
				dungeon_rooms.save_roomdata(pos, roomdata)
				minetest.chat_send_player(name, "rewritten room: " .. roomname)
			end
		end
	end,
})

minetest.register_chatcommand("clear", {
	params = "",
	description = "Clears the room",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		dungeon_rooms.clear_room(player:getpos())
		minetest.chat_send_player(name, "room cleared")
	end,
})


minetest.register_chatcommand("reset", {
	params = "",
	description = "Re-generates the room",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
        local pos = player:getpos()

        dungeon_rooms.clear_room_meta(pos)
		local room = dungeon_rooms.room_at(pos)
		local center = {
			x = room.maxp.x - math.floor(dungeon_rooms.room_area.x/2),
			y = room.maxp.y - math.floor(dungeon_rooms.room_area.y/2),
			z = room.maxp.z - math.floor(dungeon_rooms.room_area.z/2),
		}
		local roomdata, rotation = dungeon_rooms.spawn_room(center)
		minetest.chat_send_player(name, "room regenerated: " .. roomdata.name ..
								  " (angle:" .. rotation .. ")")
	end,
})


minetest.register_chatcommand("rotate", {
	params = "<angle>",
	description = "Rotate the current Dungeon room around the Y axis by angle <angle> (90 degree increment)",
	func = function(name, param)
		local angle = tonumber(param) % 360
		if angle % 90 ~= 0 then
			minetest.chat_send_player(name, "invalid usage: angle must be multiple of 90")
			return nil
		end
		if angle < 0 then
			angle = angle + 360
		end
		local player = minetest.get_player_by_name(name)
		local minp, maxp = dungeon_rooms.get_room_limits(player:getpos())
		if dungeon_rooms.rotate(minp, maxp, angle) then
		   minetest.chat_send_player(name, "room successfully rotated " .. angle .. " degrees")
		else
		   minetest.chat_send_player(name, "an error occurred rotating the room " .. angle .. " degrees")
		end
	end
})
