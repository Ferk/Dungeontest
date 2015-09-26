



mobs:register_mob("dungeon_chests:mimic", {
	type = "monster",
	hp_min = 5,	hp_max = 10,
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	visual = "cube",
	visual_size = {x = 1, y = 1},
	textures = {{
		"dungeon_chest_top.png", "dungeon_chest_top.png", "dungeon_chest_side.png",
		"dungeon_chest_side.png", "dungeon_mimic_front.png", "dungeon_chest_back.png" }},
	makes_footstep_sound = false,
	blood_texture = "tnt_smoke.png",
	sounds = {
		damage = "default_dig_choppy",
		death = "default_dig_choppy",
		jump = "default_wood_footstep",
		attack = "default_place_node",
	},
	attack_type = "dogfight",
	attacks_monsters = true,
	damage = 1,
	passive = false,
	walk_velocity = 2,
	run_velocity = 2,
	walk_chance = 0,
	jump_chance = 30,
	jump_height = 3,
	armor = 100,
	view_range = 10,
	on_die = function(self, pos)

	end,
	drawtype = "front",
	water_damage = 0,
	lava_damage =  0,
	light_damage = 0,
})
