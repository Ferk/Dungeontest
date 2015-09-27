--- Serialization and deserialiation of regions into files.
-- @module dungeon_rooms.serialization



-- Saves schematic in the Minetest Schematic (and metadata) to disk.
-- Takes the same arguments as minetest.create_schematic
-- @param minp Lowest position (in all 3 coordinates) of the area to save
-- @param maxp Highest position (in all 3 coordinates) of the area to save
-- @param probability_list = {{pos={x=,y=,z=},prob=}, ...} list of probabilities for the nodes to be loaded (if nil, always load)
-- @param filename (without externsion) with the path to save the shcematic and metadata to
-- @param slice_prob_list = {{ypos=,prob=}, ...} list of probabilities for the slices to be loaded (if nil, always load)
-- @return The number of nodes with metadata.
function dungeon_rooms.save_region(minp, maxp, probability_list, filename, slice_prob_list)

	local success = minetest.create_schematic(minp, maxp, probability_list, filename .. ".mts", slice_prob_list)
	if not success then
		minetest.log("error", "Problem loading schematic: " .. filename)
		return false
	end

	dungeon_rooms.keep_loaded(minp, maxp)
	local pos = {x=minp.x, y=0, z=0}
	local count = 0
	local nodes = {}
	local get_node, get_meta = minetest.get_node, minetest.get_meta
	while pos.x <= maxp.x do
		pos.y = minp.y
		while pos.y <= maxp.y do
			pos.z = minp.z
			while pos.z <= maxp.z do
				local node = get_node(pos)
				if node.name ~= "air" and node.name ~= "ignore" then
					local meta = get_meta(pos):to_table()

					local meta_empty = true
					-- Convert metadata item stacks to item strings
					for name, inventory in pairs(meta.inventory) do
						for index, stack in ipairs(inventory) do
							meta_empty = false
							inventory[index] = stack.to_string and stack:to_string() or stack
						end
					end
					if meta.fields and #meta.fields ~= 0 then
						meta_empty = false
					end

					if not meta_empty then
						count = count + 1
						nodes[count] = {
							x = pos.x - minp.x,
							y = pos.y - minp.y,
							z = pos.z - minp.z,
							meta = meta,
						}
					end
				end
				pos.z = pos.z + 1
			end
			pos.y = pos.y + 1
		end
		pos.x = pos.x + 1
	end
	if count > 0 then

		local result = {
			size = {
				x = maxp.x - minp.x,
				y = maxp.y - minp.y,
				z = maxp.z - minp.z,
			},
			nodes = nodes,
		}

		-- Serialize entries
		result = minetest.serialize(result)

		local file, err = io.open(filename..".meta", "wb")
		if err ~= nil then
			error("Couldn't write to \"" .. filename .. "\"")
		end
		file:write(minetest.compress(result))
		file:flush()
		file:close()
	end
	return success, count
end



-- Places the schematic specified in the given position.
-- @param minp Lowest position (in all 3 coordinates) of the area to load
-- @param filename without extension, but with path of the file to load
-- @param rotation can be 0, 90, 180, 270, or "random".
-- @param replacements = {["old_name"] = "convert_to", ...}
-- @param force_placement is a boolean indicating whether nodes other than air and ignore are replaced by the schematic
-- @return boolean indicating success or failure
function dungeon_rooms.load_region(minp, filename, rotation, replacements, force_placement)

	if rotation == "random" then
		rotation = {nil, 90, 180, 270}
		rotation = rotation[math.random(1,4)]
	end

	local success = minetest.place_schematic(minp, filename .. ".mts", tostring(rotation), replacements, force_placement)

	if not success then
		minetest.log("error", "Problem loading schematic: " .. filename)
		return false
	end

	local f, err = io.open(filename..".meta", "rb")
	if not f then
		minetest.log("action", "Schematic without metadata loaded: " .. filename)
		return {}
	end
	local data = minetest.deserialize(minetest.decompress(f:read("*a")))
	f:close()
	if not data then return end

	local get_meta = minetest.get_meta
	if not rotation or rotation == 0 then
		for i, entry in ipairs(data.nodes) do
			entry.x, entry.y, entry.z = minp.x + entry.x, minp.y + entry.y, minp.z + entry.z
			if entry.meta then get_meta(entry):from_table(entry.meta) end
		end
	elseif rotation == 90 then
		for i, entry in ipairs(data.nodes) do
			entry.x, entry.y, entry.z = minp.x + entry.z, minp.y + entry.y, minp.z + entry.x
			if entry.meta then get_meta(entry):from_table(entry.meta) end
		end
	else
		local maxp_x, maxp_y, maxp_z = minp.x + data.size.x, minp.y + data.size.y, minp.z + data.size.z
		if rotation == 180 then
			for i, entry in ipairs(data.nodes) do
				entry.x, entry.y, entry.z = maxp_x - entry.x, maxp_y - entry.y, maxp_z - entry.z
				if entry.meta then get_meta(entry):from_table(entry.meta) end
			end
		elseif rotation == 270 then
			for i, entry in ipairs(data.nodes) do
				entry.x, entry.y, entry.z = maxp_x - entry.z, maxp_y - entry.y, maxp_z - entry.x
				if entry.meta then get_meta(entry):from_table(entry.meta) end
			end
		else
			minetest.log("error", "Unsupported rotation angle: " ..  (rotation or "nil"))
			return false
		end
	end
	return true
end


--- Rotates a region clockwise around an axis.
-- @param pos1
-- @param pos2
-- @param axis Axis ("x", "y", or "z").
-- @param angle Angle in degrees (90 degree increments only).
-- @return The number of nodes rotated.
-- @return The new first position.
-- @return The new second position.
function dungeon_rooms.rotate(pos1, pos2, axis, angle)

	local other1, other2 = dungeon_rooms.get_axis_others(axis)

	local count
	if angle == 90 then
		dungeon_rooms.flip(pos1, pos2, other1)
		pos1, pos2 = dungeon_rooms.transpose(pos1, pos2, other1, other2)
	elseif angle == 180 then
		dungeon_rooms.flip(pos1, pos2, other1)
		dungeon_rooms.flip(pos1, pos2, other2)
	elseif angle == 270 then
		dungeon_rooms.flip(pos1, pos2, other2)
		pos1, pos2 = dungeon_rooms.transpose(pos1, pos2, other1, other2)
	else
		error("Unsupported rotation angle: " .. (angle or "nil"))
	end
	return pos1, pos2
end




--- Transposes a region between two axes.
-- @return The number of nodes transposed.
-- @return The new transposed position 1.
-- @return The new transposed position 2.
function dungeon_rooms.transpose(pos1, pos2, axis1, axis2)

	local compare
	local extent1, extent2 = pos2[axis1] - pos1[axis1], pos2[axis2] - pos1[axis2]

	if extent1 > extent2 then
		compare = function(extent1, extent2)
			return extent1 > extent2
		end
	else
		compare = function(extent1, extent2)
			return extent1 < extent2
		end
	end

	-- Calculate the new position 2 after transposition
	local new_pos2 = {x=pos2.x, y=pos2.y, z=pos2.z}
	new_pos2[axis1] = pos1[axis1] + extent2
	new_pos2[axis2] = pos1[axis2] + extent1

	local upper_bound = {x=pos2.x, y=pos2.y, z=pos2.z}
	if upper_bound[axis1] < new_pos2[axis1] then upper_bound[axis1] = new_pos2[axis1] end
	if upper_bound[axis2] < new_pos2[axis2] then upper_bound[axis2] = new_pos2[axis2] end
	dungeon_rooms.keep_loaded(pos1, upper_bound)

	local pos = {x=pos1.x, y=0, z=0}
	local get_node, get_meta, set_node = minetest.get_node,
			minetest.get_meta, minetest.set_node
	while pos.x <= pos2.x do
		pos.y = pos1.y
		while pos.y <= pos2.y do
			pos.z = pos1.z
			while pos.z <= pos2.z do
				local extent1, extent2 = pos[axis1] - pos1[axis1], pos[axis2] - pos1[axis2]
				if compare(extent1, extent2) then -- Transpose only if below the diagonal
					local node1 = get_node(pos)
					local meta1 = get_meta(pos):to_table()
					local value1, value2 = pos[axis1], pos[axis2] -- Save position values
					pos[axis1], pos[axis2] = pos1[axis1] + extent2, pos1[axis2] + extent1 -- Swap axis extents
					local node2 = get_node(pos)
					local meta2 = get_meta(pos):to_table()
					set_node(pos, node1)
					get_meta(pos):from_table(meta1)
					pos[axis1], pos[axis2] = value1, value2 -- Restore position values
					set_node(pos, node2)
					get_meta(pos):from_table(meta2)
				end
				pos.z = pos.z + 1
			end
			pos.y = pos.y + 1
		end
		pos.x = pos.x + 1
	end
	return pos1, new_pos2
end


--- Flips a region along `axis`.
-- @return The number of nodes flipped.
function dungeon_rooms.flip(pos1, pos2, axis)

	dungeon_rooms.keep_loaded(pos1, pos2)

	--- TODO: Flip the region slice by slice along the flip axis using schematic method.
	local pos = {x=pos1.x, y=0, z=0}
	local start = pos1[axis] + pos2[axis]
	pos2[axis] = pos1[axis] + math.floor((pos2[axis] - pos1[axis]) / 2)
	local get_node, get_meta, set_node = minetest.get_node,
			minetest.get_meta, minetest.set_node
	while pos.x <= pos2.x do
		pos.y = pos1.y
		while pos.y <= pos2.y do
			pos.z = pos1.z
			while pos.z <= pos2.z do
				local node1 = get_node(pos)
				local meta1 = get_meta(pos):to_table()
				local value = pos[axis] -- Save position
				pos[axis] = start - value -- Shift position
				local node2 = get_node(pos)
				local meta2 = get_meta(pos):to_table()
				set_node(pos, node1)
				get_meta(pos):from_table(meta1)
				pos[axis] = value -- Restore position
				set_node(pos, node2)
				get_meta(pos):from_table(meta2)
				pos.z = pos.z + 1
			end
			pos.y = pos.y + 1
		end
		pos.x = pos.x + 1
	end
	return
end


--- Gets other axes given an axis.
-- @raise Axis must be x, y, or z!
function dungeon_rooms.get_axis_others(axis)
	if axis == "x" then
		return "y", "z"
	elseif axis == "y" then
		return "x", "z"
	elseif axis == "z" then
		return "x", "y"
	else
		error("Axis must be x, y, or z!")
	end
end

function dungeon_rooms.keep_loaded(pos1, pos2)
	local manip = minetest.get_voxel_manip()
	manip:read_from_map(pos1, pos2)
end
