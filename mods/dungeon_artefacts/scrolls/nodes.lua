

-- temporary water source, use param2 when playing it to determine duration
minetest.register_node("scrolls:temporary_water", {
	description = "Temporary Water Source",
	inventory_image = minetest.inventorycube("default_river_water.png"),
	drawtype = "liquid",
	tiles = {
		{
			name = "default_river_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	special_tiles = {
		{
			name = "default_river_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
			backface_culling = false,
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "scrolls:flowing_temporary_water",
    liquid_alternative_source = "scrolls:temporary_water",
	liquid_viscosity = 1,
	liquid_renewable = false,
	liquid_range = 5,
	post_effect_color = {a=120, r=30, g=76, b=90},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},

    on_construct = function(pos)
        local node = minetest.get_node(pos)
        if node.param2 < 1 then
            node.param2 = 5
            minetest.swap_node(pos, node)
        end
        minetest.get_node_timer(pos):start(node.param2)
    end,

    on_timer = function(pos, elapsed)
        local node = minetest.get_node(pos)
        node.param2 = node.param2 - elapsed
        if node.param2 <= 0 then
            minetest.set_node(pos, {name = "air"})
            return false
        else
            minetest.swap_node(pos, node)
            return true
        end

    end,
})

minetest.register_node("scrolls:flowing_temporary_water", {
	description = "Flowing Temporary Water",
	inventory_image = minetest.inventorycube("default_river_water.png"),
	drawtype = "flowingliquid",
	tiles = {"default_river_water.png"},
	special_tiles = {
		{
			name = "default_river_water_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
		{
			name = "default_river_water_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.8,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "scrolls:flowing_temporary_water",
    liquid_alternative_source = "scrolls:temporary_water",
	liquid_viscosity = 1,
	liquid_renewable = false,
	liquid_range = 5,
	post_effect_color = {a=120, r=30, g=76, b=90},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})


-- A flame with a specific timer, will last shorter than standard flames
minetest.register_node("scrolls:temporary_flame", {
	description = "Temporary Flame",
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
	groups = {igniter = 2, dig_immediate = 3, not_in_creative_inventory=1},
	drop = "",

	on_blast = function() end,

	on_construct = function(pos)
		local node = minetest.get_node(pos)
		if node.param2 < 1 then
			node.param2 = math.random(4,6)
			minetest.swap_node(pos, node)
		end
		minetest.get_node_timer(pos):start(node.param2)
	end,

	on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		node.param2 = node.param2 - elapsed
		if node.param2 <= 0 then
			minetest.set_node(pos, {name = "air"})
			return false
		else
			minetest.swap_node(pos, node)
			return true
		end

	end,
})


minetest.register_node("scrolls:temporary_ice", {
	description = "Temporary Ice",
	drawtype = "nodebox",
	tiles = {"default_ice.png"},
	is_ground_content = false,
	drops = "",
	paramtype = "light",
	groups = {cracky=3, puts_out_fire=1, not_in_creative_inventory=1 },
	sounds = default.node_sound_glass_defaults(),
	use_texture_alpha = "blend",
	post_effect_color = {a=75, r=200, g=200, b=255},
	sunlight_propagates = true,
	liquidtype = "source",
	liquid_viscosity = 31,
	liquid_alternative_flowing = "scrolls:temporary_ice",
	liquid_alternative_source = "scrolls:temporary_ice",
	liquid_renewable = false,
	liquid_range = 0,

	on_construct = function(pos)
		local node = minetest.get_node(pos)
		if node.param2 < 1 then
			node.param2 = math.random(5,10)
		end
		minetest.get_node_timer(pos):start(node.param2)
	end,

	on_timer = function(pos, elapsed)
		minetest.remove_node(pos)
	end
})

minetest.register_node("scrolls:biotoxin", {
    description = "Biotoxin",
    inventory_image = minetest.inventorycube("scrolls_biotoxin.png"),
    tiles = {
        {name="scrolls_biotoxin_source_animated.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=2.0}}
    },
    special_tiles = {
        {
            name="scrolls_biotoxin_source_animated.png",
            animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=2.0},
            backface_culling = false,
        }
    },
    drawtype = "nodebox",
    paramtype = "light",
    use_texture_alpha = "blend",
    sunlight_propagates = true,
    walkable = false,
    diggable = false,
    pointable = false,
    drop = "",
    liquidtype = "source",
    liquid_alternative_flowing = "scrolls:biotoxin_flowing",
    liquid_alternative_source = "scrolls:biotoxin",
    post_effect_color = {a=10, r=50, g=240, b=76},
    groups = {liquid=5, flammable=15},
	on_construct = function(pos)
		local node = minetest.get_node(pos)
		if node.param2 > 0 then
			minetest.get_node_timer(pos):start(node.param2)
		end
	end,
	on_timer = function(pos, elapsed)
		minetest.remove_node(pos)
	end
})

minetest.register_node("scrolls:biotoxin_flowing", {
    description = "Flowing Biotoxin",
    inventory_image = minetest.inventorycube("scrolls_biotoxin.png"),
    tiles =  {
        {
            image="scrolls_biotoxin_flowing_animated.png",
            backface_culling=false,
            animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=0.8}
        }
    },
	drawtype = "nodebox",
	sunlight_propagates = true,
	paramtype = "light",
	use_texture_alpha = "blend",
	walkable = false,
	diggable = false,
	pointable = false,
	drop = "",
	liquidtype = "flowing",
	liquid_alternative_flowing = "scrolls:biotoxin_flowing",
	liquid_alternative_source = "scrolls:biotoxin",
	climbable = false,
	post_effect_color = {a=10, r=50, g=240, b=76},
	damage_per_second = 0.2,
	groups = {liquid=5, flammable=15, not_in_creative_inventory=1},
})

minetest.register_abm({
	nodenames = {"scrolls:biotoxin_source", "scrolls:biotoxin_flowing"},
	interval = 2,
	chance = 16,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local objs = minetest.get_objects_inside_radius(pos, 2)
		for k, obj in pairs(objs) do
			if obj:is_player() then
				statuses.apply_status(obj, {
					name = "scrolls:poisoning",
					duration = active_object_count_wider + math.random(8,18),
				})
			end
		end
	end
})
