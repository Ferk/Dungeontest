

-- Table containing the pools of room schematics for each layout
dungeon_rooms.rooms = {}

local modpath = minetest.get_modpath(minetest.get_current_modname())



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

                if roomdata.rarity then
                    roomdata.rarity = tonumber(roomdata.rarity)
                else
                     roomdata.rarity = 0.5
                end

                table.insert(dungeon_rooms.rooms[dir], roomdata)
            end
        end
        minetest.log("debug", "Pool '" .. dir .."' has " .. #dungeon_rooms.rooms[dir] .. " rooms loaded")
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
function dungeon_rooms.random_roomdata(poolname, level)
    local pool = dungeon_rooms.rooms[poolname]

    if not pool then
        minetest.log("error","No rooms in pool " .. poolname)
    end

	local sum = 0
	local cumulate = {}
	local randoms = {}

	local candidates = {}
    local raresum = 0

	for r=1, #pool do
        local roomdata = pool[r]
        if (not roomdata.minlevel or roomdata.minlevel <= level) and
            (not roomdata.maxlevel or roomdata.maxlevel >= level) then
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
    minetest.log("error","No roomdata for level ".. level .." in pool " .. poolname)

    return {}
end



-- load all room data
dungeon_rooms.load_roomdata_from_dir(modpath .. "/roomdata");
