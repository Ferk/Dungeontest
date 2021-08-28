-- minetest/fire/init.lua

-- Global namespace for functions

fire = {}


-- Register flame node

minetest.register_node("fire:basic_flame", {
	description = "Fire",
	drawtype = "firelike",
	tiles = {{
		name = "fire_basic_flame_animated.png",
		animation = {type = "vertical_frames",
			aspect_w = 16, aspect_h = 16, length = 1},
	}},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = 14,
	groups = {igniter = 2, dig_immediate = 3},
	drop = '',
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 4,

	on_construct = function(pos)
		minetest.after(0, fire.on_flame_add_at, pos)
	end,

	on_destruct = function(pos)
		minetest.after(0, fire.on_flame_remove_at, pos)
	end,

	on_blast = function() end, -- unaffected by explosions
})

minetest.register_node("fire:permanent_flame", {
	description = "Permanent Flame",
	drawtype = "firelike",
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	inventory_image = "fire_basic_flame.png",
	paramtype = "light",
	light_source = 14,
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	damage_per_second = 4,
	groups = {igniter = 2, dig_immediate = 3},
	drop = "",

	on_blast = function()
	end,
})

-- Get sound area of position

fire.D = 6 -- size of sound areas

function fire.get_area_p0p1(pos)
	local p0 = {
		x = math.floor(pos.x / fire.D) * fire.D,
		y = math.floor(pos.y / fire.D) * fire.D,
		z = math.floor(pos.z / fire.D) * fire.D,
	}
	local p1 = {
		x = p0.x + fire.D - 1,
		y = p0.y + fire.D - 1,
		z = p0.z + fire.D - 1
	}
	return p0, p1
end


-- Fire burning areas table (area size is fire.D)
-- key: position hash of low corner of area
-- value: {sound=sound handle, name=sound name, density=flame node counter}
fire.burn_areas = {}


-- Update fire density and sounds in burn area of position
-- diff: integer to add to the density of the area

function fire.update_burn_area(pos, diff)
	local p0, p1 = fire.get_area_p0p1(pos)
	local p0_hash = minetest.hash_node_position(p0)

	local burnarea = fire.burn_areas[p0_hash]
	if not burnarea then
		-- If we don't have a previous saved state, calculate it
		burnarea = { density = 0 }
		fire.burn_areas[p0_hash] = burnarea
	end
	local density = burnarea.density + diff

	-- Negative density can happen if the flames were already there on world load
	-- In this case, check for the flames in the area properly
	if density < 0 then
		local flames_p = minetest.find_nodes_in_area(p0, p1, {"fire:basic_flame"})
		density = #flames_p
	end

	local sound = false
	if density >= 9 then
		sound = {name = "fire_large", gain = 1.5}
	elseif density > 0 then
		sound = {name = "fire_small", gain = 1.5}
	else
		-- remove sound and saved state if the density is 0
		if burnarea.sound then
			minetest.sound_stop(burnarea.sound)
		end
		fire.burn_areas[p0_hash] = nil
		return
	end
	burnarea.density = density

	if sound and sound.name ~= burnarea.name then
		if burnarea.sound then
			minetest.sound_stop(burnarea.sound)
		end
		local cp = {x = (p0.x + p1.x) / 2, y = (p0.y + p1.y) / 2, z = (p0.z + p1.z) / 2}
		burnarea.name = sound.name
		burnarea.sound = minetest.sound_play(sound, {
			pos = cp,
			max_hear_distance = fire.D,
			loop = true
		})
	end
end


-- Update fire sounds on flame node construct or destruct

function fire.on_flame_add_at(pos)
	fire.update_burn_area(pos, 1)
end


function fire.on_flame_remove_at(pos)
	fire.update_burn_area(pos, -1)
end


-- Return positions for flames around a burning node

function fire.find_pos_for_flame_around(pos)
	return minetest.find_node_near(pos, 1, {"air"})
end


-- Detect nearby extinguishing nodes

function fire.flame_should_extinguish(pos)
	return minetest.find_node_near(pos, 1, {"group:puts_out_fire"})
end


-- Enable ABMs according to 'disable fire' setting

if minetest.settings:get_bool("disable_fire") then

	-- Extinguish flames quickly with dedicated ABM

	minetest.register_abm({
		nodenames = {"fire:basic_flame"},
		interval = 3,
		chance = 2,
		action = function(p0, node, _, _)
			minetest.remove_node(p0)
		end,
	})

else

	-- Extinguish flames quickly with water, snow, ice

	minetest.register_abm({
		nodenames = {"fire:basic_flame"},
		neighbors = {"group:puts_out_fire"},
		interval = 3,
		chance = 2,
		action = function(p0, node, _, _)
			minetest.remove_node(p0)
			minetest.sound_play("fire_extinguish_flame",
				{pos = p0, max_hear_distance = 16, gain = 0.25})
		end,
	})

	-- Ignite neighboring nodes

	minetest.register_abm({
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		interval = 7,
		chance = 16,
		action = function(p0, node, _, _)
			-- If there is water or stuff like that around node, don't ignite
			if fire.flame_should_extinguish(p0) then
				return
			end
			local p = fire.find_pos_for_flame_around(p0)
			if p then
				minetest.set_node(p, {name = "fire:basic_flame"})
			end
		end,
	})

	-- Remove flames and flammable nodes (customizable interval)

	local fire_update_interval = tonumber(minetest.settings:get("fire_update_interval"))
	if fire_update_interval == 0 then
		fire_update_interval = 2
	end

	minetest.register_abm({
		nodenames = {"fire:basic_flame"},
		interval = fire_update_interval,
		chance = 4,
		action = function(p0, node, _, _)
			-- If there is water or stuff like that around flame, remove flame
			if fire.flame_should_extinguish(p0) then
				minetest.remove_node(p0)
				return
			end
			-- Make the following things rarer
			if math.random(1, 3) == 1 then
				return
			end

			-- If there are no flammable nodes around flame, remove flame
			local p = minetest.find_node_near(p0, 1, {"group:flammable"})
			if not p then
				minetest.remove_node(p0)
			elseif math.random(1, 2) == 1 then
				-- remove the flammable node found around flame
				minetest.remove_node(p)
				nodeupdate(p)
			elseif math.random(1, 2) == 1 then
				-- We might still randomly remove the flame
				minetest.remove_node(p0)
			end
		end,
	})

end


-- Rarely ignite things from far

--[[ Currently disabled to reduce the chance of uncontrollable spreading
	fires that disrupt servers. Also for less lua processing load.

minetest.register_abm({
	nodenames = {"group:igniter"},
	neighbors = {"air"},
	interval = 5,
	chance = 10,
	action = function(p0, node, _, _)
		local reg = minetest.registered_nodes[node.name]
		if not reg or not reg.groups.igniter or reg.groups.igniter < 2 then
			return
		end
		local d = reg.groups.igniter
		local p = minetest.find_node_near(p0, d, {"group:flammable"})
		if p then
			-- If there is water or stuff like that around flame, don't ignite
			if fire.flame_should_extinguish(p) then
				return
			end
			local p2 = fire.find_pos_for_flame_around(p)
			if p2 then
				minetest.set_node(p2, {name = "fire:basic_flame"})
			end
		end
	end,
})
--]]
