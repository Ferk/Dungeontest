

-- Table containing the pools of room schematics for each layout
dungeon_rooms.rooms = {}

local modpath = minetest.get_modpath(minetest.get_current_modname())

dungeon_rooms.roomdata_directory = modpath .. "/roomdata"

function dungeon_rooms.load_roomdata_from_dir(dirpath)
	local roomdirs = minetest.get_dir_list(dirpath, true)

	for d = 1, #roomdirs do
		local dir = roomdirs[d]
		dungeon_rooms.rooms[dir] = {}
		local roomfiles = minetest.get_dir_list(dirpath .. "/" .. dir, false)
		for f = 1, #roomfiles do
			local filesplit = string.split(roomfiles[f], ".")
			-- Only add one room per mts, ignore other files for now
			if filesplit[2] == "conf" then

				local roomdata = Settings(dirpath .. "/" .. dir .. "/" .. roomfiles[f]):to_table()

				roomdata.name = roomdata.name or filesplit[1]
				roomdata.path = dirpath .. "/" .. dir .. "/" .. filesplit[1]
				roomdata.minlevel = roomdata.minlevel and tonumber(roomdata.minlevel)
				roomdata.maxlevel = roomdata.maxlevel and tonumber(roomdata.maxlevel)
				roomdata.groups = roomdata.groups and string.split(roomdata.groups, ",") or {}

				if roomdata.rarity then
					roomdata.rarity = tonumber(roomdata.rarity)
				else
					 roomdata.rarity = 0.5
				end

				table.insert(dungeon_rooms.rooms[dir], roomdata)
			end
		end
		minetest.debug("Pool '" .. dir .."' has " .. #dungeon_rooms.rooms[dir] .. " rooms loaded")
	end

end


-- Save the schematic and metadata of the room in the given position, with the given name
-- TODO: Also save things like rarity and min/max level
function dungeon_rooms.save_roomdata(pos, roomdata)
	local minp, maxp = dungeon_rooms.get_room_limits(pos)
	return dungeon_rooms.save_region(minp, maxp, nil, roomdata.path)
end


-- Place the schematics of the given roomdata in the room of the given position, with the given rotation
function dungeon_rooms.place_roomdata(pos, roomdata, rotation)
	local minp, maxp = dungeon_rooms.get_room_limits(pos)
	if roomdata and roomdata.path then
		return dungeon_rooms.load_region(minp, roomdata.path, rotation, nil, true)
	else
		return nil
	end
end

-- Get a random roomdata from the given pool adecuate to the given level
function dungeon_rooms.random_roomdata(room_details)
	local pool = dungeon_rooms.rooms[room_details.layout]
	local level = room_details.level

	if not pool then
		minetest.log("error","No rooms in pool " .. room_details.layout)
	end

	local sum = 0
	local cumulate = {}
	local randoms = {}

	local candidates = {}
		local raresum = 0

	for r=1, #pool do
		local roomdata = pool[r]
		if (not roomdata.minlevel or roomdata.minlevel <= level) and
			(not roomdata.maxlevel or roomdata.maxlevel >= level) and
			(not room_details.groups or table.hasCommonElement(roomdata.groups, room_details.groups)) then
				-- It's a candidate!
				table.insert(candidates, roomdata)
				raresum = raresum + roomdata.rarity
		end
	end

	local rarepick = math.random() * raresum
	local rarecount = 0

	for c=1, #candidates do
		local roomdata = candidates[c]
		rarecount = rarecount + roomdata.rarity
		if rarecount >= rarepick then
			return roomdata
		end
	end

	minetest.log("error","No roomdata of layout '" .. room_details.layout .. "' matching the criteria for this level")

  local k, first = next(pool, nil)
	return first or {}
end

-- table.indexOf( array, object ) returns the index
-- of object in array. Returns 'nil' if not in array.
table.indexOf = function( t, object )
	local result

	if "table" == type( t ) then
		for i=1,#t do
			if object == t[i] then
				result = i
				break
			end
		end
	end

	return result
end

table.hasCommonElement = function(t1,t2)
	if "table" == type( t2 ) then
		for i=1,#t2 do
			local index = table.indexOf(t1,t2[i])
			if index then
				return index, i
			end
		end
	end
end


-- load all room data
dungeon_rooms.load_roomdata_from_dir(modpath .. "/roomdata");
