
-- Ghost by BlockMen

mobs:register_mob("ghost:ghost", {
	type = "monster",
	passive = false,
	damage = 2,
	attack_type = "dogfight",
	hp_min = 7,
	hp_max = 12,
	armor = 130,
	collisionbox = {-0.3, -0.5, -0.3, 0.3, 0.75, 0.3},
	visual = "mesh",
	mesh = "creatures_mob.x",
	textures = {
		{"creatures_ghost.png"},
	},
	blood_texture = "tnt_smoke.png",
	visual_size = {x=1, y=1},
	makes_footstep_sound = false,
	sounds = {
		random = "creatures_ghost",
		damage = "creatures_ghost_hit",
		death = "creatures_ghost_death"
	},
	walk_velocity = 2,
	run_velocity = 2,
	fall_speed = 0,
	jump = true,
	fly = true,
	fly_in = "air",
	water_damage = 0,
	lava_damage = 0,
	light_damage = 2,
	view_range = 14,
	animation = {
		speed_normal = 30,		speed_run = 30,
		walk_start = 168,		walk_end = 187,

	},
})

mobs:register_spawn("ghost:ghost", {"bones:bones"}, 5, 0, 500, 1, 31000)

mobs:register_egg("ghost:ghost", "Ghost", "default_cloud.png", 1)
