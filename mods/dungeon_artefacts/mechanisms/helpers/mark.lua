-- rnd: code borrowed from mechanisms, mark.lua

-- need for marking



mechanisms.markset = {}


function mechanisms.start_marking(name, positions, texture_func)
	minetest.log("action", "started marking " .. name .. " initial positions: " .. #positions)
	mechanisms.markset[name] = {
		markers = {},
		positions = positions or {},
	}
	for k,pos in pairs(positions) do
		mechanisms.mark_pos(name, pos, texture_func and texture_func(pos))
	end
end

function mechanisms.end_marking(name)
	minetest.log("action", "finished marking " .. name)
	local markset = mechanisms.markset[name] or {}

	for k,marker in pairs(markset.markers or {}) do
		marker:remove()
	end
	mechanisms.markset[name] = nil
	return markset.positions
end


mechanisms.mark_pos = function(name, pos, texture)
	local markset = mechanisms.markset[name]

	local id = minetest.pos_to_string(pos)
	markset.markers[id] = markset.markers[id] or minetest.add_entity(pos, "mechanisms:marker")
	if markset.markers[id] ~= nil then
		local ent = markset.markers[id]:get_luaentity()
		ent.markset = name
		ent.id = str
		if texture then
		   ent:set_texture(texture)
		end
	end
end

mechanisms.unmark_pos = function(name, pos)
	local markset = mechanisms.markset[name]

	local id = minetest.pos_to_string(pos)
	if markset.markers[id] ~= nil then
		markset.markers[id]:remove()
		markset.markers[id] = nil
	end
end


minetest.register_entity("mechanisms:marker", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"mechanisms_mark.png", "mechanisms_mark.png",
			"mechanisms_mark.png", "mechanisms_mark.png",
			"mechanisms_mark.png", "mechanisms_mark.png"},
		collisionbox = {0, 0, 0, 0, 0, 0},
		physical = false,
	},
	on_step = function(self, dtime)
		if self.markset and self.id and (not mechanisms.markset[self.markset] or not mechanisms.markset[self.markset].markers[self.id]) then
			self.object:remove()
		end
	end,
	on_activate = function(self, staticdata)
		if staticdata and staticdata ~= "" then
			local split = string.split(staticdata, " ")
			self.markset, self.id = split[1], split[2]
		else
			self.markset, self.id = "_", "_"
		end
	end,
	get_staticdata = function(self)
		return (self.markset or "_") .. " " .. (self.id or "_")
	end,
	on_punch = function(self, hitter) end,
	set_texture = function(self, texture)
	   self.object:set_properties({textures={
									  texture,texture,texture,
									  texture,texture,texture,}})
	end
})

minetest.register_entity(":mechanisms:pos11", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"mechanisms_mark.png", "mechanisms_mark.png",
			"mechanisms_mark.png", "mechanisms_mark.png",
			"mechanisms_mark.png", "mechanisms_mark.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
		physical = false,
	},
	on_step = function(self, dtime)
		if not mechanisms[self.name] then mechanisms[self.name]={}; mechanisms[self.name].timer = 10 end
		mechanisms[self.name].timer = mechanisms[self.name].timer - dtime
		if mechanisms[self.name].timer<=0 or mechanisms.marker11[self.name] == nil then
			self.object:remove()
		end
	end,
	on_punch = function(self, hitter)
		self.object:remove()
		mechanisms.marker11[self.name] = nil
		mechanisms[self.name].timer = 10
	end,
})

minetest.register_entity(":mechanisms:pos2", {
	initial_properties = {
		visual = "cube",
		visual_size = {x=1.1, y=1.1},
		textures = {"mechanisms_pos2.png", "mechanisms_pos2.png",
			"mechanisms_pos2.png", "mechanisms_pos2.png",
			"mechanisms_pos2.png", "mechanisms_pos2.png"},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
		physical = false,
	},
	on_step = function(self, dtime)
		if not mechanisms[self.name] then mechanisms[self.name]={}; mechanisms[self.name].timer = 10 end
		if mechanisms[self.name].timer<=0 or mechanisms.marker2[self.name] == nil then
			self.object:remove()
		end
	end,
})
