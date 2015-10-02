
local modpath = minetest.get_modpath("altars")

local altars_context = {}

altars = {}

altars.gods = {}

function altars.register_god(name, def)
	altars.gods[name] = def
end

dofile(modpath.."/eresh.lua")

altars.register_god("xom", {
	title = "Xom, god of chaos",
	texture = "altars_xom.png",
	particle = "altars_xom_particle.png",
})

altars.register_god("trog", {
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
		if staticdata and staticdata ~= "" then
			self.texture = staticdata
		end
		if self.texture ~= nil then
			self.object:set_properties({textures={self.texture}})
		end
	end,
	get_staticdata = function(self)
		if self.texture ~= nil then
			return self.texture
		end
		return ""
	end
})


local particle_effect = function(pos, godname, duration)
   if not godname or not altars.gods[godname] then return end
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
		 texture = altars.gods[godname].particle or "altars_particle.png",
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
	remove_top(pos)
	local meta = minetest.get_meta(pos)

	local godname = meta:get_string("god")

	if not godname or not altars.gods[godname] then
		minetest.log("action","unknown god " .. godname)
		-- Just take the first god registered
		godname = next(altars.gods)
		meta:set_string("god", godname)
		meta:set_string("infotext", "Altar of " .. altars.gods[godname].title)
	end

	pos.y = pos.y + 1
	local texture = altars.gods[godname].texture

	local e = minetest.add_entity(pos, "altars:altar_top")
	e:get_luaentity():on_activate(texture)

	particle_effect(pos,godname)
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
	after_place_node = function(pos, player, itemstack)
		local name = player:get_player_name()
		altars_context[name] = {pos = pos}
		minetest.show_formspec(name,
							   "altars:godname", "size[4,3]" ..
								   "field[1,0.5;3,1;godname;God for the altar;]" ..
								   "button_exit[1,1;2,1;exit;Save]")

	end,
	on_rightclick = function(pos, node, player, itemstack)
        local meta = minetest.get_meta(pos)
		local god = altars.gods[meta:get_string("god")]
		if god then
			if god.on_pray then
				god.on_pray(pos, node, player, itemstack)
			end
		end
	end,
	on_destruct = function(pos)
	   remove_top(pos)
	end,
	on_blast = function() end

})


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "altars:godname" and fields.godname then
		local name = player:get_player_name()
		local god = altars.gods[fields.godname]
		if god then
			local context = altars_context[name]
			local meta = context.meta or minetest.get_meta(context.pos)
			meta:set_string("god", fields.godname)
			local title = god.title
			meta:set_string("infotext", "Altar of " .. title)
			local name = player:get_player_name()
			minetest.chat_send_player(name, "You raised an altar to " .. title)
		else
			minetest.chat_send_player(name, "Unknown god")
		end
		altars_context[name] = nil
	end
end)


minetest.register_abm({
	nodenames = {"altars:altar_base"},
	interval = 15, chance = 1,
	action = function(pos, node, _, _)
		local meta = minetest.get_meta(pos)
		local godname = meta:get_string("god")
		particle_effect(pos,godname)

		local num = #minetest.get_objects_inside_radius(pos, 0.5)
		if num > 0 then return end
		update_top(pos, node)
	end
})
