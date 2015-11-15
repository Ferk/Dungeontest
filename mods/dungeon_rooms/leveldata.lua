
-- Table containing a pool of levels
dungeon_rooms.levels = {}

-- Default level design
table.insert(dungeon_rooms.levels, {
	name = "Binary tree maze Level",
	rarity = 0.1,
	mindepth = 1,
	rooms = {
		default = {
			door = {"X","Z"},
		},
	}
});


-- Level design for the first level of the dungeon
local intro_level = {
	name = "Introductory Level",
	rarity = 10,
	maxdepth = 0,
	rooms = {
		default = {
			door = {"X","Z","-X","-Z"},
		},
	}
}
for i=0,4 do
	intro_level.rooms[i] = {}
end
for i=0,3 do
	intro_level.rooms[i][0] = {
		door = {"X","Z"},
	}
	intro_level.rooms[i][4] = {
		door = {"X","-Z"},
	}
	intro_level.rooms[0][i] = {
		door = {"X","Z"},
	}
	intro_level.rooms[4][i] = {
		door = {"-X","Z"},
	}
end
table.insert(dungeon_rooms.levels, intro_level)

--------------------
--------------------


local modpath = minetest.get_modpath(minetest.get_current_modname())

dungeon_rooms.leveldata_directory = modpath .. "/leveldata"

function dungeon_rooms.load_leveldata_from_dir(dirpath)

	local files = minetest.get_dir_list(dirpath, false)
	for f = 1, #files do
		local filesplit = string.split(files[f], ".")
		-- Only add one room per mts, ignore other files for now
		if filesplit[2] == "conf" then

			local confdata = Settings(dirpath .. "/" .. files[f]):to_table()

			confdata.name = confdata.name or filesplit[1]
			confdata.mindepth = confdata.mindepth and tonumber(roomdata.mindepth)
			confdata.maxdepth = confdata.maxdepth and tonumber(roomdata.maxdepth)

			if confdata.rarity then
				confdata.rarity = tonumber(confdata.rarity)
			else
				 confdata.rarity = 0.5
			end

			table.insert(dungeon_rooms.levels, confdata)
		end
	end
	minetest.log("debug", #dungeon_rooms.levels .. " levels loaded")

end


function dungeon_rooms.room_details_to_string(details)
	return "[".. details.data.name .." - layout " .. details.layout .. " door:" .. details.door .. "]"
end

function dungeon_rooms.get_room_it_leads_to(details)
	local room = {x=details.x, y=details.y, z=details.z, level=details.level}
	if details.door == "X" then
		room.x = room.x + 1
	elseif details.door == "-X" then
		room.x = room.x - 1
	elseif details.door == "Z" then
		room.z = room.z + 1
	elseif details.door == "-Z" then
		room.z = room.z - 1
	end
	return room
end

function dungeon_rooms.get_level_data(level, level_id)

	-- First we determine what level to use from the available ones
	local levelconf
	local sum = 0
	local cumulate = {}
	local randoms = {}

	local candidates = {}
	local raresum = 0
	for l=1, #dungeon_rooms.levels do
		levelconf = dungeon_rooms.levels[l]
		if (not levelconf.mindepth or levelconf.mindepth <= level) and
			(not levelconf.maxdepth or levelconf.maxdepth >= level) then
				-- It's a candidate!
				table.insert(candidates, levelconf)
				raresum = raresum + levelconf.rarity
		end
	end
	math.randomseed(dungeon_rooms.seed + (level_id or level))
	local rarepick = math.random() * raresum
	local rarecount = 0
	for c=1, #candidates do
		levelconf = candidates[c]
		rarecount = rarecount + levelconf.rarity
		if rarecount >= rarepick then
			minetest.log("action","chosen level " .. level .. ":" .. levelconf.name)
			break
		end
	end
	if not levelconf then
		minetest.log("error","No config available for level " .. level)
		levelconf = dungeon_rooms.levels[0]
	end

	-- Now we can obtain room configuration according to the level config
	local data = setmetatable({}, { __index=levelconf })
	data.id = level_id
	local rooms = {}
	for x= 0, dungeon_rooms.total_size.x-1 do
		rooms[x] = {}
		for z= 0, dungeon_rooms.total_size.z-1 do

			local roomcnf = levelconf.rooms[x] and levelconf.rooms[x][z] or levelconf.rooms.default
			local possible_doors = roomcnf.door
			local chosen = possible_doors[math.random(#possible_doors)]

			-- Choose a different door if a door was already placed there
			if (chosen == "-X" and rooms[x-1] and rooms[x-1][z].door == "X") or (chosen == "-Z" and rooms[x][z-1] and rooms[x][z-1].door == "Z") then
					local doors = {}
					for d=1,#possible_doors do
						if possible_doors[d] ~= chosen then
							table.insert(doors, possible_doors[d])
						end
					end
					if #doors > 0 then
						chosen = doors[math.random(#doors)]
					end
			end

			rooms[x][z] = {
				seed = math.random(99999999),
				door = chosen,
				leveldata = data -- reference to parent level data
			}

			if roomcnf.groups and #roomcnf.groups > 0 then
				rooms[x][z].groups = roomcnf.groups
			end
		end
	end
	data.rooms = rooms

	return data
end

local leveldata_queue = {count=0}
dungeon_rooms.get_room_config = setmetatable({}, {
	__call = function(memotable, room)
		-- identifier specific to the level
		local level_pos = {
			x = math.floor(room.x/dungeon_rooms.total_size.x),
			z = math.floor(room.z/dungeon_rooms.total_size.z),
			y = room.level,
		}
		local level_id = minetest.hash_node_position(level_pos)

		local leveldata = memotable[level_id]
		if leveldata == nil then
			leveldata = dungeon_rooms.get_level_data(room.level, level_id)
			memotable[level_id] = leveldata
			minetest.log("action", "New level data obtained for level " .. room.level)
		end

		-- Update the queue of strong links with last accessed levels
		table.insert(leveldata_queue, leveldata)
		leveldata_queue.count = leveldata_queue.count + 1
		if leveldata_queue.count > 20 then
			leveldata_queue[leveldata_queue.count - 20] = nil
		end
		return leveldata.rooms[room.x % dungeon_rooms.total_size.x][room.z % dungeon_rooms.total_size.z]
	end,
	__mode = "v",
});


-- Collect room details that are used to determine what type of room to spawn
--function dungeon_rooms.get_room_details(room)
function dungeon_rooms.get_room_details(room)
	local details = dungeon_rooms.get_room_config(room)
	setmetatable(details, {
		__index = room,
		__tostring = dungeon_rooms.room_details_to_string
	})
	-- My door, should it be on X or Z?
	--
	--details.Xdoor = (math.random() < 0.5)


	local isStairs = dungeon_rooms.is_room_stairs(room)
	if isStairs == 1
	then
		details.rotation = 0
		details.layout = "up"

	elseif isStairs == 2
	then
		details.rotation = 0
		details.layout = "down"

	elseif math.random(0, 5) == 0 then
		-- We may use any of the type 4 rooms randomly
		details.rotation = "random"
		details.layout = "4"

	else
		details.layout, details.rotation = dungeon_rooms.calculate_room_layout(details)
	end

	math.randomseed(details.seed)
	details.data = dungeon_rooms.random_roomdata(details)

	return details
end


function dungeon_rooms.calculate_room_layout(details)
	-- Is there a door on X?
	local Xdoor = details.door == "X" or (dungeon_rooms.get_room_config({x=details.x+1, level=details.level, z=details.z}).door == "-X")
	-- Is there a door on Z?
	local Zdoor = details.door == "Z" or (dungeon_rooms.get_room_config({x=details.x, level=details.level, z=details.z+1}).door == "-Z")
	-- Is there a door on -X?
	local mXdoor = details.door == "-X" or (dungeon_rooms.get_room_config({x=details.x-1, level=details.level, z=details.z}).door == "X")
	-- Is there a door on -Z?
	local mZdoor = details.door == "-Z" or(dungeon_rooms.get_room_config({x=details.x, level=details.level, z=details.z-1}).door == "Z")

	local layout, rotation

	if Xdoor then
		rotation=0
		if not Zdoor then
			if not mXdoor and not mZdoor then
				layout="0"
			elseif mXdoor and not mZdoor then
				layout="1"
			elseif not mXdoor and mZdoor then
				layout="2"
			elseif mXdoor and mZdoor then
				layout="3"
			end
		else
			if not mXdoor and not mZdoor then
				layout="2"
				rotation=270
			elseif mXdoor and not mZdoor then
				layout="3"
				rotation=180
			elseif not mXdoor and mZdoor then
				layout="3"
				rotation=270
			elseif mXdoor and mZdoor then
				layout="4"
				rotation="random"
			end
		end
	elseif Zdoor then
		if not mXdoor and not mZdoor then
			layout="0"
			rotation=270
		elseif mXdoor and not mZdoor then
			layout="2"
			rotation=180
		elseif not mXdoor and mZdoor then
			layout="1"
			rotation=90
		elseif mXdoor and mZdoor then
			layout="3"
			rotation=90
		end
	elseif mXdoor then
		if mZdoor then
			layout="2"
			rotation=90
		else
			layout="0"
			rotation=180
		end
	else
		layout="0"
		rotation=90
	end

	return layout, rotation
end

--dungeon_rooms.load_leveldata_from_dir(dungeon_rooms.leveldata_directory);
