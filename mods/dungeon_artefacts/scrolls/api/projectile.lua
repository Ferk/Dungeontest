


minetest.register_entity("scrolls:magic_projectile", {
	physical = false,
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"scrolls_fireball.png"},
	hit_entity = function() end,
	hit_mob = function() end,
	drop = false,
	collisionbox = {0, 0, 0, 0, 0, 0}, -- remove box around projectiles
	timer = 0,

	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if not self.direction or self.timer > 60 then self.object:remove() return end

		local pos = self.object:getpos()
		local node = minetest.get_node_or_nil(self.object:getpos())
		if node then node = node.name else node = "air" end

		if self.hit_node
		and minetest.registered_nodes[node]
		and minetest.registered_nodes[node].walkable then
			self.hit_node(self, pos, node)
			if self.drop == true then
				pos.y = pos.y + 1
				self.lastpos = (self.lastpos or pos)
				minetest.add_item(self.lastpos, self.object:get_luaentity().name)
			end
			self.object:remove()
			return
		end

		local engage = 1 / self.speed -- clear entity before arrow becomes active
		if self.hit_entity
		and self.timer > engage then
			for _,obj in pairs(minetest.get_objects_inside_radius(vector.add(pos,self.direction), 1.0)) do
				if obj:is_player() or (
					obj:get_luaentity().name ~= "__builtin:item"
					and obj:get_luaentity().name ~= "gauges:hp_bar"
					and obj:get_luaentity().name ~= "signs:text"
					) then
					print("HITT!!!")
					self.hit_entity(self, obj)
					self.object:remove()
					return
				end
			end
		end
		self.lastpos = pos
	end,

	initialize = function(self, params)
		if params.properties then
			self.object:set_properties(params.properties)
		end
		self.speed = params.speed or 6
		self.direction = params.direction
		if params.direction then
			self.object:setvelocity(vector.multiply(params.direction, self.speed))
		end
		self.hit_node = params.hit_node
		self.hit_entity = params.hit_entity
	end
})

function scrolls.shoot_projectile(pos, params)
	local obj = minetest.add_entity(pos, "scrolls:magic_projectile")
	if params then
		obj:get_luaentity():initialize(params)
	end
end


function scrolls.replace_air_in_radius(pos, radius, node, chance)
	for dx = -radius, radius do
		for dy = -radius, radius do
			for dz = -radius, radius do
				if chance and math.random(chance) == 1 then
					local p = { x = pos.x+dx, y = pos.y+dy, z = pos.z+dz}
					local n = minetest.get_node(p).name
					if (n == "air") then
							minetest.set_node(p, node)
					end
				end
			end
		end
	end
end
