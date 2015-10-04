--- Serialization and deserialiation of regions into files.
-- @module dungeon_rooms.serialization


minetest.wallmounted_to_dir = minetest.wallmounted_to_dir or function(wallmounted)
   return ({[0]={x=0, y=1, z=0},
			{x=0, y=-1, z=0},
			{x=1, y=0, z=0},
			{x=-1, y=0, z=0},
			{x=0, y=0, z=1},
			{x=0, y=0, z=-1}})[wallmounted]
end

local function rotate_node_facedir(node, rotation)
   local def = minetest.registered_nodes[node.name]

   local param_to_dir, dir_to_param
   if def.paramtype2 == "facedir" then
	  param_to_dir, dir_to_param = minetest.facedir_to_dir, minetest.dir_to_facedir
   elseif def.paramtype2 == "wallmounted" then
	  param_to_dir, dir_to_param = minetest.wallmounted_to_dir, minetest.dir_to_wallmounted
   else
	  return node
   end

   local dir = param_to_dir(node.param2)
   local rot = { y = dir.y }
   if rotation == 90 then
	  rot.x, rot.z = dir.z, dir.x
   elseif rotation == 180 then
	  rot.x, rot.z = -dir.x, -dir.z
   elseif rotation == 270 then
	  rot.x, rot.z = -dir.z, -dir.x
   end

   node.param2 = dir_to_param(rot)

   return node
end



function core.dir_to_wallmounted(dir)
	if math.abs(dir.y) > math.max(math.abs(dir.x), math.abs(dir.z)) then
		if dir.y < 0 then
			return 1
		else
			return 0
		end
	elseif math.abs(dir.x) > math.abs(dir.z) then
		if dir.x < 0 then
			return 3
		else
			return 2
		end
	else
		if dir.z < 0 then
			return 5
		else
			return 4
		end
	end
end

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
					if meta.fields and next(meta.fields) ~= nil then
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
		minetest.log("action", "schematic + metadata saved: " .. filename)
	else
	   minetest.log("action", "schematic (no metadata) saved: " .. filename)
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
		--minetest.log("action", "Schematic without metadata loaded: " .. filename)
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
		local maxp_x, maxp_z = minp.x + data.size.x, minp.z + data.size.z
		if rotation == 180 then
			for i, entry in ipairs(data.nodes) do
				entry.x, entry.y, entry.z = maxp_x - entry.x, minp.y + entry.y, maxp_z - entry.z
				if entry.meta then get_meta(entry):from_table(entry.meta) end
			end
		elseif rotation == 270 then
			for i, entry in ipairs(data.nodes) do
				entry.x, entry.y, entry.z = maxp_x - entry.z, minp.y + entry.y, maxp_z - entry.x
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
-- @param rotation Angle in degrees (90 degree increments only).
-- @return true if successful, false on error
function dungeon_rooms.rotate(minp, maxp, rotation)

   rotation = rotation % 360
   if not rotation or rotation == 0 then return true end

   -- First load the schematic in a table
   local nodes = {}
   local pos = { x = minp.x }
   while pos.x <= maxp.x do
	  pos.y = minp.y
	  while pos.y <= maxp.y do
		 pos.z = minp.z
		 while pos.z <= maxp.z do
			-- Calculate coordinates relative to minp
			table.insert(nodes, {
				rx = pos.x - minp.x,
				rz = pos.z - minp.z,
				y = pos.y, -- this one will be fixed
				node = minetest.get_node(pos),
				meta = minetest.get_meta(pos):to_table(),
			})
			pos.z = pos.z + 1
		 end
		 pos.y = pos.y + 1
	  end
	  pos.x = pos.x + 1
	end

   -- Now apply the table rotated to the map
   if rotation == 90 then
	  for i, entry in ipairs(nodes) do
		 entry.node = rotate_node_facedir(entry.node, rotation)
		 entry.x, entry.z = minp.x + entry.rz, minp.z + entry.rx
		 minetest.set_node(entry, entry.node)
		 minetest.get_meta(entry):from_table(entry.meta)
	  end
   else
	  if rotation == 180 then
		 for i, entry in ipairs(nodes) do
			entry.node = rotate_node_facedir(entry.node, rotation)
			entry.x, entry.z = maxp.x - entry.rx, maxp.z - entry.rz
			minetest.set_node(entry, entry.node)
			minetest.get_meta(entry):from_table(entry.meta)
		 end
	  elseif rotation == 270 then
		 for i, entry in ipairs(nodes) do
			entry.node = rotate_node_facedir(entry.node, rotation)
			entry.x, entry.z = maxp.x - entry.rz, maxp.z - entry.rx
			minetest.set_node(entry, entry.node)
			minetest.get_meta(entry):from_table(entry.meta)
		 end
	  else
		 minetest.log("error", "Unsupported rotation angle: " ..  (rotation or "nil"))
		 return false
	  end
   end
   return true
end



function dungeon_rooms.keep_loaded(pos1, pos2)
	local manip = minetest.get_voxel_manip()
	manip:read_from_map(pos1, pos2)
end
