if (minetest.get_modpath("intllib")) then
	dofile(minetest.get_modpath("intllib").."/intllib.lua")
	S = intllib.Getter(minetest.get_current_modname())
else
	S = function ( s ) return s end
end

rods = {}

--[[ Load settings, apply default settings ]]
rods.settings = {}
rods.settings.avoid_collisions = true
rods.settings.adjust_head = true
rods.settings.cost_mana = 20
local avoid_collisions = minetest.setting_getbool("rods_avoid_collisions")
if avoid_collisions ~= nil then
	rods.settings.avoid_collision = avoid_collisions
end
local adjust_head = minetest.setting_getbool("rods_adjust_head")
if adjust_head ~= nil then
	rods.settings.adjust_head = adjust_head
end
local cost_mana = tonumber(minetest.setting_get("rods_cost_mana"))
if cost_mana ~= nil then
	rods.settings.cost_mana = cost_mana
end


function rods.teleport(player, pointed_thing)
	local pos = pointed_thing.above
	local src = player:getpos()
	local dest = {x=pos.x, y=math.ceil(pos.y)-0.5, z=pos.z}
	local over = {x=dest.x, y=dest.y+1, z=dest.z}
	local destnode = minetest.get_node({x=dest.x, y=math.ceil(dest.y), z=dest.z})
	local overnode = minetest.get_node({x=over.x, y=math.ceil(over.y), z=over.z})

	if rods.settings.adjust_head then
		-- This trick prevents the player's head to spawn in a walkable node if the player clicked on the lower side of a node
		-- NOTE: This piece of code must be updated as soon the collision boxes of players become configurable
		if minetest.registered_nodes[overnode.name].walkable then
			dest.y = dest.y - 1
		end
	end

	if rods.settings.avoid_collisions then
		-- The destination must be collision free
		destnode = minetest.get_node({x=dest.x, y=math.ceil(dest.y), z=dest.z})
		if minetest.registered_nodes[destnode.name].walkable then
			return false
		end
	end

	minetest.add_particlespawner({
		amount = 25,
		time = 0.1,
		minpos = {x=src.x-0.4, y=src.y+0.25, z=src.z-0.4},
		maxpos = {x=src.x+0.4, y=src.y+0.75, z=src.z+0.4},
		minvel = {x=-0.1, y=-0.1, z=-0.1},
		maxvel = {x=0, y=0.1, z=0},
		minexptime=1,
		maxexptime=1.5,
		minsize=1,
		maxsize=1.25,
		texture = "teleport_particle_departure.png",
	})
	minetest.sound_play( {name="spells_teleport1", gain=1}, {pos=src, max_hear_distance=12})

	player:setpos(dest)
	minetest.add_particlespawner({
		amount = 25,
		time = 0.1,
		minpos = {x=dest.x-0.4, y=dest.y+0.25, z=dest.z-0.4},
		maxpos = {x=dest.x+0.4, y=dest.y+0.75, z=dest.z+0.4},
		minvel = {x=0, y=-0.1, z=0},
		maxvel = {x=0.1, y=0.1, z=0.1},
		minexptime=1,
		maxexptime=1.5,
		minsize=1,
		maxsize=1.25,
		texture = "teleport_particle_arrival.png",
	})
	minetest.after(0.5, function(dest) minetest.sound_play( {name="spells_teleport2", gain=1}, {pos=dest, max_hear_distance=12}) end, dest)

	return true
end


minetest.register_tool("rods:rod_of_blinking", {
	description = S("Rod of blinking"),
	range = 20.0,
	tool_capabilities = {},
	wield_image = "rod_3.png",
	inventory_image = "rod_3.png",
	on_use = function(itemstack, user, pointed_thing)
		local failure = false
		if(pointed_thing.type == "node") then
			if(mana.get(user:get_player_name()) >= rods.settings.cost_mana) then
				failure = not rods.teleport(user, pointed_thing)
				if not failure then
					failure = not mana.subtract(user:get_player_name(), rods.settings.cost_mana)
				end
			else
				failure = true
			end
		else
			failure = true
		end
		if failure then
			minetest.sound_play( {name="spells_fail", gain=0.5}, {pos=user:getpos(), max_hear_distance=4})
		end
		return itemstack
	end,
})




