
-- Definitions made by this mod that other mods can use too
dungeon_rooms = {}

dungeon_rooms.seed = 1

local modpath = minetest.get_modpath(minetest.get_current_modname())

dungeon_rooms.rooms = {}
dungeon_rooms.rooms[0] = {
	"0/treasure",
}
dungeon_rooms.rooms[1] = {
	"1/corridor1",
	"1/corridor1a",
	"1/corridorb",
	"1/parkour_lava",
	"1/blockmess",
}
dungeon_rooms.rooms[2] = {
	"2/corridor2"
}
dungeon_rooms.rooms[3] = {
	"3/corridor3"
}
dungeon_rooms.rooms[4] = {
	"test",
	"standard",
	"treasure",
	"parkour_lava",
	"blockmess",
	"corridor",
	"aquarium",
	"battle",
	"kitchen"
}

dungeon_rooms.stairsdown = {
	"down/stairsdown",
}

dungeon_rooms.stairsup = {
	"up/stairsup",
}

dungeon_rooms.stairs_distance = 5




-- Return the global coordinates of a relative position on a room
local function roomp2pos(roomp, room)
	return {
		x = room.maxp.x + roomp.x,
		y = room.maxp.y + roomp.y,
		z = room.maxp.z + roomp.z,
	}
end

-- Returns the coordinates relative to the room the given position is
local function pos2roomp(pos)
	local roomp = {
		x = (x - dungeon_rooms.origin.x) % dungeon_rooms.room_area.x,
		y = (y - dungeon_rooms.origin.y) % dungeon_rooms.room_area.y,
		z = (z - dungeon_rooms.origin.z) % dungeon_rooms.room_area.z,
	}
	return roomp
end

function dungeon_rooms.get_level(pos)
	return math.floor((dungeon_rooms.origin.y - pos.y) / dungeon_rooms.room_area.y /2)
end

-- calculates a seed for each room based on the world seed,
-- tries to do it without causing obvious patterns to form
function dungeon_rooms.seed_for_room(room)
	local hash = 17
	hash = hash * 31 + room.level
	hash = hash * 31 + room.x
	hash = hash * 31 + room.z
	hash = hash * 31 + dungeon_rooms.seed
	return hash
end

function dungeon_rooms.get_room_details(room)
	local rotation, roomtype, doorp

	-- Is there a door on -X?
	math.randomseed(dungeon_rooms.seed_for_room({x=room.x-1, level=room.level, z=room.z}))
	local mXdoor = (math.random() < 0.5)
	-- Is there a door on -Z?
	math.randomseed(dungeon_rooms.seed_for_room({x=room.x, level=room.level, z=room.z-1}))
	local mZdoor = not (math.random() < 0.5)
	-- My door, should it be on X or Z?
	math.randomseed(dungeon_rooms.seed_for_room(room))
	local Xdoor = (math.random() < 0.5)

	if Xdoor then
		rotation=0
		if not mXdoor and not mZdoor then
			roomtype=0
		elseif mXdoor and not mZdoor then
			roomtype=1
		elseif not mXdoor and mZdoor then
			roomtype=2
		elseif mXdoor and mZdoor then
			roomtype=3
		end
	else
		if not mXdoor and not mZdoor then
			roomtype=0
			rotation=90
		elseif mXdoor and not mZdoor then
			roomtype=2
			rotation=180
		elseif not mXdoor and mZdoor then
			roomtype=1
			rotation=90
		elseif mXdoor and mZdoor then
			roomtype=3
			rotation=90
		end
	end

	return roomtype, rotation, Xdoor
end

-- Returns nil if room is not a stairs
-- 1 for stairs up
-- 2 for stairs down
function dungeon_rooms.is_room_stairs(room)
	if room.x % dungeon_rooms.stairs_distance == 0 and
		room.z % dungeon_rooms.stairs_distance == 0
	then
		if room.x % 2 == 0 and (room.z + room.level/2) % 2 == 0
		then
			return 1 -- stairsup
		else
			return 2 -- stairsdown
		end
	else
		return nil
	end
end

function dungeon_rooms.spawn_room(center)

	local doorp = {
		x = center.x,
		y = center.y,
		z = center.z,
	}

	local room = dungeon_rooms.room_at(center)
	local roomtype, rotation, Xdoor = dungeon_rooms.get_room_details(room)

	if Xdoor then
		doorp.x = doorp.x + dungeon_rooms.room_area.x/2;
		doorp.param2 = minetest.dir_to_wallmounted({x=-1,y=0,z=0})
	else
		doorp.z = doorp.z + dungeon_rooms.room_area.z/2;
		doorp.param2 = minetest.dir_to_wallmounted({x=1,y=0,z=0})
	end

	minetest.log("action","lvl:"..room.level.." room "..room.x..","..room.z.." ("..center.x..","..center.y..","..center.z..") type " .. roomtype .. " door:" .. (Xdoor and "X" or "Z").. "("..doorp.x..","..doorp.y..","..doorp.z..") "..dungeon_rooms.seed_for_room(room))

	minetest.set_node(doorp,{ name="dungeon_rooms:door_b_1", param2=doorp.param2 })
	doorp.y = doorp.y+1
	minetest.set_node(doorp,{ name="dungeon_rooms:door_t_1", param2=doorp.param2 })

	local roompool
	local isStairs = dungeon_rooms.is_room_stairs(room)
	if isStairs == 1
	then
		roompool = dungeon_rooms.stairsup
	elseif isStairs == 2
	then
		roompool = dungeon_rooms.stairsdown
	else
		-- only if not stairs will rotation be random
		--rotation="random"

		-- TODO: schematics based on roomtype
		roompool = dungeon_rooms.rooms[roomtype]
		--roompool = dungeon_rooms.rooms[4]
	end

	load_room(center, roompool[math.random(1, #roompool)], rotation)
end



function dungeon_rooms.spawn_entrance(pos)
	minetest.log("action","spawning dungeon entrance at "..pos.x..","..pos.y..","..pos.z)
	local filename = modpath .. "/schems/dungeon_entrance.mts"
	minetest.place_schematic({
			x = pos.x - 3,
			y = pos.y,
			z = pos.z - 3,
		}, filename, nil, nil, true)

	while  pos.y > dungeon_rooms.origin.y do
		minetest.set_node(pos, {name="default:ladder", param2=minetest.dir_to_wallmounted({x=1,y=0,z=0})})
		pos.y = pos.y - 1
	end
	minetest.set_node(pos, {name="default:ladder", param2=minetest.dir_to_wallmounted({x=1,y=0,z=0})})
end

function dungeon_rooms.spawn_ladder(pos, node)
	local ladderLength = 1 + dungeon_rooms.room_area.y + (pos.y - dungeon_rooms.origin.y) % dungeon_rooms.room_area.y
	minetest.log("action","spawning ladder down ".. pos.y .. " to " .. pos.y-ladderLength)
	for j = pos.y-ladderLength, pos.y do
		minetest.set_node({x=pos.x, y=j, z=pos.z}, {name="default:ladder", param2=minetest.dir_to_wallmounted({x=1,y=0,z=0})})
	end
end




function dungeon_rooms.room_at(pos)
	local room = {
		level = math.floor((dungeon_rooms.origin.y - pos.y) / dungeon_rooms.room_area.y),
		x = math.floor((pos.x - dungeon_rooms.origin.x) / dungeon_rooms.room_area.x),
		z = math.floor((pos.z - dungeon_rooms.origin.z) / dungeon_rooms.room_area.z)
	}
	room.maxp = {
		x = dungeon_rooms.origin.x + (dungeon_rooms.room_area.x*(room.x+1)),
		z = dungeon_rooms.origin.z + (dungeon_rooms.room_area.z*(room.z+1)),
		y = dungeon_rooms.origin.y - (dungeon_rooms.room_area.y*room.level)
	}
	return room
end


function dungeon_rooms.internal_room_at(pos)
	local room = dungeon_rooms.room_at(pos)
	local maxp = { x = room.maxp.x-1, y = room.maxp.y-1, z = room.maxp.z-1 }
	local minp = {
		x = maxp.x + 2 - dungeon_rooms.room_area.x,
		y = maxp.y + 2 - dungeon_rooms.room_area.y,
		z = maxp.z + 2 - dungeon_rooms.room_area.z,
	}
	return minp, maxp
end

function save_room(pos, name)
	local minp, maxp = dungeon_rooms.internal_room_at(pos)
	dungeon_rooms.save_region(minp, maxp, nil, modpath .. "/roomdata/" .. name)
end

function load_room(pos, name, rotation)
	local minp, maxp = dungeon_rooms.internal_room_at(pos)
	minetest.log("action","loading " .. name);
	dungeon_rooms.load_region(minp, modpath .. "/roomdata/" .. name, rotation, nil, true)
end


function clear_room(pos)
	local minp, maxp = dungeon_rooms.internal_room_at(pos)
	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				minetest.set_node({x=x,y=y,z=z}, {name="air"})
			end
		end
	end
end


minetest.register_chatcommand("save", {
	params = "<text>",
	description = "Saves the room",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		save_room(player:getpos(), param)
		minetest.chat_send_player(name, "room saved")
	end,
})

minetest.register_chatcommand("load", {
	params = "<text>",
	description = "Loads the room",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local pos = player:getpos()
		load_room(pos, param or "test")
		minetest.chat_send_player(name, "room loaded")
	end,
})

minetest.register_chatcommand("clear", {
	params = "",
	description = "Clears the room",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		clear_room(player:getpos())
		minetest.chat_send_player(name, "room cleared")
	end,
})


minetest.register_chatcommand("reset", {
	params = "",
	description = "Re-generates the room",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)

		local room = dungeon_rooms.room_at(player:getpos())
		local center = {
			x = room.maxp.x - math.floor(dungeon_rooms.room_area.x/2),
			y = room.maxp.y - math.floor(dungeon_rooms.room_area.y/2),
			z = room.maxp.z - math.floor(dungeon_rooms.room_area.z/2),
		}
		dungeon_rooms.spawn_room(center)
		minetest.chat_send_player(name, "room regenerated")
	end,
})


--------------



dofile(modpath.."/nodes.lua")
dofile(modpath.."/serialization.lua")
dofile(modpath.."/mapgen.lua")
--dofile(modpath.."/hud.lua")
