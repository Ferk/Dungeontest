--- Serialization and deserialiation of regions into files.
-- @module dungeon_rooms.serialization


function dungeon_rooms.keep_loaded(pos1, pos2)
	local manip = minetest.get_voxel_manip()
	manip:read_from_map(pos1, pos2)
end

--- Saves the region defined by positions `minp` and `maxp`
-- into an mts file and a meta file (only created if any nodes contain metadata)
-- @return The number of nodes with metadata.
function dungeon_rooms.save_region(minp, maxp, probability_list, filename, slice_prob_list)

	minetest.create_schematic(minp, maxp, probability_list, filename .. ".mts", slice_prob_list)

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
	return count
end



--- Loads the nodes represented by string `value` at position `origin_pos`.
-- @return The number of nodes deserialized.
function dungeon_rooms.load_region(minp, filename, rotation, replacements, force_placement)

	if rotation == "random" then
		rotation = {nil, 90, 180, 270}
		rotation = rotation[math.random(1,4)]
	end

	local success = minetest.place_schematic(minp, filename .. ".mts", tostring(rotation), replacements, force_placement)

	if not success then
		minetest.log("error", "Problem loading schematic!!!")
		return
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
			error("Invalid rotation value: " ..  (rotation or "nil"))
		end
	end
	return
end
