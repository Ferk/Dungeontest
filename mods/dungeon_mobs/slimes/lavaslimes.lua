-- sounds
local lava_sounds = {
	damage = "slimes_damage",
	death = "slimes_death",
	jump = "slimes_jump",
	attack = "slimes_attack",
}

-- lava slime textures
local lava_textures = {"lava_slime_sides.png", "lava_slime_sides.png", "lava_slime_sides.png", "lava_slime_sides.png", "lava_slime_front.png", "lava_slime_sides.png"}

-- register small lava slime
mobs:register_mob("slimes:lavasmall", {
	type = "monster",
	hp_min = 1,	hp_max = 2,
	collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	visual = "cube",
	visual_size = {x = 0.5, y = 0.5},
	textures = { lava_textures },
	blood_texture = "lava_slime_blood.png",
	makes_footstep_sound = false,
	sounds = lava_sounds,
	attack_type = "dogfight",
	attacks_monsters = true,
	damage = 1,
	passive = false,
	walk_velocity = 2,
	run_velocity = 2,
	walk_chance = 0,
	jump_chance = 30,
	jump_height = 6,
	armor = 100,
	view_range = 10,
	drops = {
		{name = "tnt:gunpowder", chance = 4, min = 1, max = 2},
	},
	drawtype = "front",
	water_damage = 10,
	lava_damage = 0,
	light_damage = 0,
	replace_rate = 20,
	replace_what = {"air"},
	replace_with = "fire:basic_flame",
})
mobs:register_egg("slimes:lavasmall", "Small Lava Slime", "lava_slime_front.png", 0)

-- register medium lava slime
mobs:register_mob("slimes:lavamedium", {
	type = "monster",
	hp_min = 3,	hp_max = 4,
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	visual = "cube",
	visual_size = {x = 1, y = 1},
	textures = { lava_textures },
	blood_texture = "lava_slime_blood.png",
	makes_footstep_sound = false,
	sounds = lava_sounds,
	attack_type = "dogfight",
	attacks_monsters = true,
	damage = 2,
	passive = false,
	walk_velocity = 2,
	run_velocity = 2,
	walk_chance = 0,
	jump_chance = 30,
	jump_height = 6,
	armor = 100,
	view_range = 10,
	on_die = function(self, pos)
		local num = math.random(2, 4)
		for i=1,num do
			minetest.add_entity({x=pos.x + math.random(-2, 2), y=pos.y + 1, z=pos.z + (math.random(-2, 2))}, "slimes:lavasmall")
		end
	end,
	drawtype = "front",
	water_damage = 10,
	lava_damage = 0,
	light_damage = 0,
	replace_rate = 20,
	replace_what = {"air"},
	replace_with = "fire:basic_flame",
})
mobs:register_egg("slimes:lavamedium", "Medium Lava Slime", "lava_slime_front.png", 0)

-- register big lava slime
mobs:register_mob("slimes:lavabig", {
	type = "monster",
	hp_min = 5,	hp_max = 6,
	collisionbox = {-1, -1, -1, 1, 1, 1},
	visual = "cube",
	visual_size = {x = 2, y = 2},
	textures = { lava_textures },
	blood_texture = "lava_slime_blood.png",
	makes_footstep_sound = false,
	sounds = lava_sounds,
	attack_type = "dogfight",
	attacks_monsters = true,
	damage = 3,
	passive = false,
	walk_velocity = 2,
	run_velocity = 2,
	walk_chance = 0,
	jump_chance = 30,
	jump_height = 6,
	armor = 100,
	view_range = 10,
	on_die = function(self, pos)
		local num = math.random(1, 2)
		for i=1,num do
			minetest.add_entity({x=pos.x + math.random(-2, 2), y=pos.y + 1, z=pos.z + (math.random(-2, 2))}, "slimes:lavamedium")
		end
	end,
	drawtype = "front",
	water_damage = 10,
	lava_damage = 0,
	light_damage = 0,
	replace_offset = -1,
	replace_rate = 20,
	replace_what = {"air"},
	replace_with = "fire:basic_flame",
})
mobs:register_egg("slimes:lavabig", "Big Lava Slime", "lava_slime_front.png", 0)

--mobs:spawn_specific(name, nodes, neighbors, min_light, max_light, interval, chance, active_object_count, min_height, max_height)

mobs:spawn_specific("slimes:lavabig", {"default:lava_source"},{"default:lava_flowing"}, 4, 20, 30, 5000, 8, -32000, -64)
mobs:spawn_specific("slimes:lavamedium", {"default:lava_source"},{"default:lava_flowing"}, 4, 20, 30, 10000, 8, -32000, -64)
mobs:spawn_specific("slimes:lavasmall", {"default:lava_source"},{"default:lava_flowing"}, 4, 20, 30, 15000, 8, -32000, -64)
