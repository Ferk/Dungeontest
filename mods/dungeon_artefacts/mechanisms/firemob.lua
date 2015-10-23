

minetest.register_entity("mechanisms:firemob", {
	hp_max = 1,
	physical = true,
	collide_with_objects = false,
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"mechanisms_fireball.png"},
	spritediv = {x=3, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	automatic_rotate = true,
	speed = 3,
	damage = 4,

	on_step = function(self, dtime)

		-- every 1 second
		self.timer = (self.timer or 0) + dtime
		if self.timer < 0.5 then return end
		self.timer = 0
		self.frame = ((self.frame or 0) + 1) % 3
		self.object:setsprite({x=self.frame,y=0}, 1, 0.2, false)

		local p = self.object:getpos()
		local v = self.object:getvelocity()
		local changeDir = false
		local waypoint = self.waypoint_index and self.waypoints[self.waypoint_index]

		if waypoint and vector.distance(p, waypoint) < 1 then
			changeDir = true
		elseif v.x == 0 and v.y == 0 and v.z == 0 then
			changeDir = true
		elseif not waypoint then
			local nextp = {
				x = math.floor(p.x + v.x + 0.5),
				y = math.floor(p.y + v.y + 0.5),
				z = math.floor(p.z + v.z + 0.5),
			}
			local nextnode = minetest.get_node(nextp).name
			if not minetest.registered_nodes[nextnode].walkable then
				changeDir = true
			end
		end

		if changeDir then
			if self.waypoints then
				self.waypoint_index = (self.waypoint_index or 0) + 1
				if self.waypoint_index >= #self.waypoints then
					self.waypoint_index = 1
				end
				waypoint = self.waypoints[self.waypoint_index]
				v = vector.direction(p, waypoint)
				v = vector.multiply(v, self.speed)
			else
				local rand = math.random(4)
				v = ({{ x=self.speed, y=0, z=0 },
					 { x=0, y=0, z=self.speed },
					 { x=-self.speed, y=0, z=0 },
					 { x=0, y=0, z=-self.speed }
				 })[rand]
			end
			self.object:setvelocity(v)
		end

		for _,obj in ipairs(minetest.get_objects_inside_radius(p, 1.5)) do
			if obj:is_player() then
				obj:punch(self.object, 1.0,  {
					full_punch_interval=1.0,
					damage_groups = {fleshy=self.damage}
				}, vector.direction(obj:getpos(), p))
			end
		end

		return
	end,
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal=1})
		if staticdata and staticdata ~= "" then
			local data = minetest.deserialize(staticdata)
			self.waypoints = data.waypoints
			self.waypoint_index = (data.waypoint_index or 1) - 1
		end
	end,
	get_staticdata = function(self)
		if self.waypoints then
			return minetest.serialize({
				waypoints = self.waypoints,
				waypoint_index = self.waypoint_index
			})
		end
		return ""
	end
})



mechanisms.register_punchstate("mechanisms:firemob", {
	on_punchnode_select = function(pos, node, puncher, pointed_thing)
		-- instead of the punched node, select the one above, as if it was placed
		return pointed_thing.above
	end
})

local function toggle_punch_node_selection(pos, node, player)
	local name = player:get_player_name()
	local state = mechanisms.end_player_punchstate(name, "mechanisms:firemob")
	if state then
		-- A punch state is already defined, save it!
		pos = minetest.string_to_pos(state.id)
		local meta = minetest.get_meta(pos)

		local waypoints = {}
		for k,v in pairs(state.nodes) do
			local node = mechanisms.absolute_to_relative(node, pos, v)
			table.insert(waypoints, node)
		end

		minetest.chat_send_player(name, "Saved " .. #waypoints .. " waypoints")
		minetest.log("action", name .. "saved firemob data with " .. #waypoints .. " waypoints")
		meta:set_string("waypoints", minetest.serialize(waypoints))
	else
		-- no punchstate defined, create it!
		local meta = minetest.get_meta(pos)
		local waypoints = meta:get_string("waypoints")
		local punchs = {}
		waypoints = waypoints and minetest.deserialize(waypoints)
		if waypoints then
			for k,v in pairs(waypoints) do
				local node = mechanisms.relative_to_absolute(node, pos, v)
				node.name = v.name
				table.insert(punchs, node)
			end
		else
			waypoints = { }
		end

		minetest.chat_send_player(name, "Fireball mob edit mode! Punch nodes to assign waypoints,"
			.." then right click again with the tome to save status. " .. #waypoints .. " waypoints are currently assigned.")
		minetest.log("action", "Loading data with " .. #waypoints .. " waypoints")

		mechanisms.begin_player_punchstate(name, {
			name = "mechanisms:firemob",
			id = minetest.pos_to_string(pos),
			nodes = punchs,
		})
	end
end

minetest.register_node("mechanisms:firemob", {
	description = "Will-o'-the-Wisp",
	drawtype = "plantlike",
	tiles = {"mechanisms_fireball_inv.png"},
	inventory_image = "mechanisms_fireball_inv.png",
	wield_image = "mechanisms_fireball_inv.png",
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	sunlight_propagates = true,
	groups = {creative_breakable=1},
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		-- If the player is holding the Tome of DungeonMaking, allow setup
		if itemstack:get_name() == "dmaking:tome" then
			toggle_punch_node_selection(pos, node, player)
		else
			minetest.registered_nodes["mechanisms:firemob"].on_dungeon_generation(pos)
		end
	end,
	on_dungeon_generation = function(pos)

		local meta = minetest.get_meta(pos)
		local metawp = minetest.deserialize(meta:get_string("waypoints"))
		local waypoints = nil
		local node = minetest.get_node(pos)

		if metawp then
			waypoints = {[1] = pos}
			for k,v in pairs(metawp) do
				table.insert(waypoints, mechanisms.relative_to_absolute(node, pos, v))
			end
			table.insert(waypoints, pos)
		end

		minetest.set_node(pos, {name="air"});
		local ent = minetest.add_entity(pos, "mechanisms:firemob"):get_luaentity()
		ent.waypoints = waypoints
	end
});
