
-- Definitions made by this mod that other mods can use too
dungeon_rooms = {}

-- Will be set to the world's seed on mapgen init
dungeon_rooms.seed = 1


dungeon_rooms.stairs_distance = 5

-- Inverted chance for any room to be taken from the type4 pool
dungeon_rooms.generic_room_chance = 5



--------------

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/roomdata.lua")

--------------

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


--------------

-- Get the current Dungeon level at the given position
function dungeon_rooms.get_level(pos)
	return math.floor((dungeon_rooms.origin.y - pos.y) / dungeon_rooms.room_area.y /2)
end

-- calculates a seed for each room based on the world seed,
-- tries to do it without causing obvious patterns to form
function dungeon_rooms.seed_for_room(room)
	local rnd = PseudoRandom(room.level * room.x / room.z + dungeon_rooms.seed)
	return (rnd:next() * room.x - rnd:next() * room.z + rnd:next() * room.level)
end

-- Collect room details that are used to determine what type of room to spawn
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
			roomtype="0"
		elseif mXdoor and not mZdoor then
			roomtype="1"
		elseif not mXdoor and mZdoor then
			roomtype="2"
		elseif mXdoor and mZdoor then
			roomtype="3"
		end
	else
		if not mXdoor and not mZdoor then
			roomtype="0"
			rotation=270
		elseif mXdoor and not mZdoor then
			roomtype="2"
			rotation=180
		elseif not mXdoor and mZdoor then
			roomtype="1"
			rotation=90
		elseif mXdoor and mZdoor then
			roomtype="3"
			rotation=90
		end
	end

	return roomtype, rotation, Xdoor
end

-- Returns nil if room is not a stairs room
-- 1 for stairs up
-- 2 for stairs down
function dungeon_rooms.is_room_stairs(room)
	if room.x % dungeon_rooms.stairs_distance == 0 and
		room.z % dungeon_rooms.stairs_distance == 0
	then
		if room.x % 2 == (room.z + room.level/2) % 2
		then
			return 1 -- stairsup
		else
			return 2 -- stairsdown
		end
	else
		return nil
	end
end

-- Given the position of the center of a room, place doors and appropiate schematics to generate the room
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
		rotation = 0
		roompool = "up"

	elseif isStairs == 2
	then
		rotation = 0
		roompool = "down"

	elseif math.random(0, 5) == 0 then
		-- We may use any of the type 4 rooms randomly
		rotation = "random"
		roompool = "4"

	else
		roompool = roomtype
	end

	local chosen = dungeon_rooms.random_roomdata(roompool, room.level/2)
	dungeon_rooms.place_roomdata(center, chosen, rotation)

	return chosen, rotation
end


-- Places a dungeon entrance in the given position of the world
function dungeon_rooms.spawn_entrance(pos)
	local filename = modpath .. "/schems/dungeon_entrance.mts"

	-- It seems the chunk heighmap is unreliable, check we are really up
	pos.y = pos.y + 1
	local node = minetest.get_node(pos)
	while node.name ~= "air" do
		pos.y = pos.y + 1
		node = minetest.get_node(pos)
	end
	-- Also check we are not floating in the air
	while node.name == "air" do
		pos.y = pos.y - 1
		node = minetest.get_node(pos)
	end

	minetest.place_schematic({
			x = pos.x - 3,
			y = pos.y,
			z = pos.z - 3,
		}, filename, nil, nil, true)

	local ladderend = dungeon_rooms.origin.y -2
	while  pos.y >= ladderend do
		minetest.set_node(pos, {name="default:ladder", param2=minetest.dir_to_wallmounted({x=1,y=0,z=0})})
		pos.y = pos.y - 1
	end
	minetest.set_node(pos, {name="default:ladder", param2=minetest.dir_to_wallmounted({x=1,y=0,z=0})})
	print("ladderend: " .. minetest.pos_to_string(pos))
end

-- Places a ladder going down to the next dungeon level
function dungeon_rooms.spawn_ladder(pos, node)
	local ladderLength = 1 + dungeon_rooms.room_area.y + (pos.y - dungeon_rooms.origin.y) % dungeon_rooms.room_area.y
	minetest.log("action","spawning ladder down ".. pos.y .. " to " .. pos.y-ladderLength)
	for j = pos.y-ladderLength, pos.y do
		minetest.set_node({x=pos.x, y=j, z=pos.z}, {name="default:ladder", param2=minetest.dir_to_wallmounted({x=1,y=0,z=0})})
	end
end


-- Obtain the room that contains the given position in the world
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

-- Obtain the minp and maxp coordinates of the inside of a room that contains the given position
-- these are the limits used for save and loading the schematics
function dungeon_rooms.get_room_limits(pos)
	local room = dungeon_rooms.room_at(pos)
	local maxp = { x = room.maxp.x-1, y = room.maxp.y-1, z = room.maxp.z-1 }
	local minp = {
		x = maxp.x + 2 - dungeon_rooms.room_area.x,
		y = maxp.y + 2 - dungeon_rooms.room_area.y,
		z = maxp.z + 2 - dungeon_rooms.room_area.z,
	}
	return minp, maxp
end





-- Empties the schematic area (filling it with air)
function dungeon_rooms.clear_room(pos)
	local minp, maxp = dungeon_rooms.get_room_limits(pos)
	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				minetest.set_node({x=x,y=y,z=z}, {name="air"})
			end
		end
	end
end


-- Removes all metadata from the room (placing schematics does not clear the metadata!)
function dungeon_rooms.clear_room_meta(pos)
	local minp, maxp = dungeon_rooms.get_room_limits(pos)
	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				minetest.get_meta({x=x,y=y,z=z}):from_table(nil)
			end
		end
	end
end



--------------


dofile(modpath.."/nodes.lua")
dofile(modpath.."/serialization.lua")
dofile(modpath.."/mapgen.lua")
dofile(modpath.."/chatcommands.lua")
--dofile(modpath.."/hud.lua")

if minetest.setting_getbool("creative_mode") then
	dofile(modpath.."/inventory.lua")
end
