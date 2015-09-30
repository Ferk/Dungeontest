local tmp = {}

local modpath = minetest.get_modpath("altars")

gods = {}

dofile(modpath.."/eresh.lua")

table.insert(gods, {
	title = "Xom, god of chaos",
	texture = "altars_xom.png",
	particle = "altars_xom_particle.png",
})

table.insert(gods, {
	title = "Trog, god of rage",
	texture = "altars_trog.png",
	particle = "mobs_blood.png",
})



minetest.register_entity("altars:altar_top", {
	hp_max = 1,
	visual = "sprite",
	visual_size = {x=1.2, y=1.2},
	collisionbox = {-0.6, -0.5, -0.6, 0.6, 0.5, 0.6},
	physical = true,
	textures = {"air"},
	on_activate = function(self, staticdata)
		if tmp.nodename ~= nil and tmp.texture ~= nil then
			self.nodename = tmp.nodename
			tmp.nodename = nil
			self.texture = tmp.texture
			tmp.texture = nil
		elseif staticdata ~= nil and staticdata ~= "" then
			local data = staticdata:split(";")
			if data and data[1] and data[2] then
				self.nodename = data[1]
				self.texture = data[2]
			end
		end
		if self.texture ~= nil then
			self.object:set_properties({textures={self.texture}})
		end
	end,
	get_staticdata = function(self)
		if self.nodename ~= nil and self.texture ~= nil then
			return self.nodename..";"..self.texture
		end
		return ""
	end
})


local particle_effect = function(pos, godi, duration)
   if not godi or not gods[godi] then return end
   minetest.add_particlespawner(
	  {
		 amount = 50,
		 time = duration or 15,
		 minpos = {x=pos.x-0.5,y=pos.y, z=pos.z-0.5},
		 maxpos = {x=pos.x+0.5,y=pos.y+0.4,z=pos.z+0.5},
		 minvel = {x=-0.1, y=0.2, z=-0.1},
		 maxvel = {x=0.1,  y=0.4, z=0.1},
		 minacc = {x=0, y=0, z=0},
		 maxacc = {x=0, y=0.1,  z=0},
		 minexptime = 1,
		 maxexptime = 1.5,
		 minsize = 0.8,
		 maxsize = 1.25,
		 collisiondetection = true,
		 vertical = false,
		 texture = gods[godi].particle or "altars_particle.png",
	  })
end

local remove_top = function(pos)
   local objs = nil
   objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y+1,z=pos.z}, .5)
   if not objs then return end

   for _, obj in pairs(objs) do
	  if obj and obj:get_luaentity() and
		 obj:get_luaentity().name == "altars:altar_top" then
		 obj:remove()
	  end
   end
end


local update_top = function(pos, node)
	remove_top(pos, node)
	local meta = minetest.get_meta(pos)

	local godi = meta:get_int("god")

	if not godi or not gods[godi] then
	   -- assign a god at random
	   --godi = math.random(1, #gods)
       godi = 1 -- for now just use eresh always since the other ones do nothing
	   meta:set_int("god", godi)
	   meta:set_string("infotext", "Altar of " .. gods[godi].title)
	end

	pos.y = pos.y + 1
	tmp.nodename = node.name
	tmp.texture = gods[godi].texture

	particle_effect(pos,godi)

	local e = minetest.add_entity(pos, "altars:altar_top")
	local yaw = math.pi*2 - node.param2 * math.pi/2
	e:setyaw(yaw)
end


minetest.register_node("altars:altar_base", {
	description = "Altar of the Gods",
	tiles = {
		"ddecor_stone_tile.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.375, 0.375, -0.4, 0.375},
			{-0.1875, -0.5, -0.1875, 0.1875, 0.4, 0.1875},
			{-0.5, 0.25, -0.5, 0.5, 0.4, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5}
	},
	inventory_image = "altars_altar_base.png",
	groups = {creative_breakable=1},
	light_source = default.LIGHT_MAX - 2,
	after_place_node = function(pos, placer, itemstack)
	   local node = minetest.get_node(pos)
	   update_top(pos, node)
	end,
	on_rightclick = function(pos, node, player, itemstack)
        local meta = minetest.get_meta(pos)
        if minetest.setting_getbool("creative_mode") then
            meta:set_int("god", nil)
		    update_top(pos, node)
	    else
		    local god = gods[meta:get_int("god")]
		    if god then
			    if god.on_pray then
				    god.on_pray(pos, node, player, itemstack)
			    end
		    end
	   end
	end,
	on_destruct = function(pos)
	   remove_top(pos)
	end,
	on_blast = function() end

})



minetest.register_abm({
	nodenames = {"altars:altar_base"},
	interval = 15, chance = 1,
	action = function(pos, node, _, _)
		local meta = minetest.get_meta(pos)
		local godi = meta:get_int("god")
		particle_effect(pos,godi)

		local num = #minetest.get_objects_inside_radius(pos, 0.5)
		if num > 0 then return end
		update_top(pos, node)

	end
})
