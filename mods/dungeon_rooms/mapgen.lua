


-- origin point of the dungeon (will generate below this point)
-- the Y coordinate should be below -32 to avoid the mapchunk at ground level.
dungeon_rooms.origin = {x=0, y=-35, z=0}
-- Area of a dungeon room (needs to be on factors of 2!)
dungeon_rooms.room_area = {x=16, y=12, z=16}
-- Size of the dungeon
dungeon_rooms.total_size = {x=5, y=20, z=5}

minetest.register_on_mapgen_init(function(mgparams)
    minetest.log("action", "mgparams: "..mgparams.flags)
    minetest.set_mapgen_params({flags="nodungeons"})
    dungeon_rooms.seed = mgparams.seed
end)

minetest.register_on_generated(function(minp, maxp, seed)

	if (minp.y > dungeon_rooms.origin.y) then

        -- Chunks above will either be pure air or hard to predict mountains.
        -- lets just keep the entrance generation in ground-level chunks
        if (maxp.y > 80) then return end

        local cell_size = {
            x = dungeon_rooms.stairs_distance * dungeon_rooms.room_area.x,
            z = dungeon_rooms.stairs_distance * dungeon_rooms.room_area.z,
        }

        local next_entrance = {
            x = maxp.x - (maxp.x % cell_size.x) + (dungeon_rooms.room_area.x/2),
            z = maxp.z - (maxp.z % cell_size.z) + (dungeon_rooms.room_area.z/2),
        }

        if (minp.x < next_entrance.x) and (minp.z < next_entrance.z) then
            -- Put the entrance spawner on ground level
            local hm = minetest.get_mapgen_object("heightmap")
            local hz = (next_entrance.z - minp.z) * (maxp.x - minp.x)
            local hx = (next_entrance.x - minp.x) % (maxp.z - minp.z)
            next_entrance.y = hm[1 + hx + hz]

            if (next_entrance.y < maxp.y) and (next_entrance.y > minp.y) then
                minetest.log("action","Placing Dungeon entrance at " .. next_entrance.x .. ",".. next_entrance.z)
                minetest.set_node(next_entrance, {name="dungeon_rooms:entrance_spawner"})
            end
        end

		return
    else

        local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")

    	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
    	local data = vm:get_data()

    	local c_air = minetest.get_content_id("air")
    	local c_wall = minetest.get_content_id("dungeon_rooms:wall")
        local c_door = minetest.get_content_id("dungeon_rooms:door")
        local c_deco = minetest.get_content_id("dungeon_rooms:wall_decoration")

    	for x = minp.x, maxp.x do
    		for y = minp.y, math.min(maxp.y,dungeon_rooms.origin.y) do
    			for z = minp.z, maxp.z do

    				local pos = area:index(x, y, z)

    				local level = math.floor((dungeon_rooms.origin.y - y -1) / dungeon_rooms.room_area.y)

    				if(data[pos] == c_door) then
    					-- don't replace doors
    				elseif(level%2 == 1) then
                        -- even levels are pure wall as separators
    					data[pos] = c_wall
    				else

    					-- position relative to room's minp
    					local roomp = {
    						x = (x - dungeon_rooms.origin.x) % dungeon_rooms.room_area.x,
    						y = (y - dungeon_rooms.origin.y) % dungeon_rooms.room_area.y,
    						z = (z - dungeon_rooms.origin.z) % dungeon_rooms.room_area.z,
    					}

    					local halfarea = {
    						x = math.floor(dungeon_rooms.room_area.x / 2),
    						y = math.floor(dungeon_rooms.room_area.y / 2),
    						z = math.floor(dungeon_rooms.room_area.z / 2),
    					}

    					-- Center of the room will trigger special generation
    					if (roomp.y == halfarea.y) and (roomp.x == halfarea.x) and (roomp.z == halfarea.z) then
							data[pos] = minetest.get_content_id("dungeon_rooms:room_spawner")
                        else
    						data[pos] = c_wall
    					end
    				end
    			end
    		end
    	end

    	vm:set_data(data)
    	vm:write_to_map(data)
        vm:calc_lighting()
    	vm:update_liquids()
    end
end)
