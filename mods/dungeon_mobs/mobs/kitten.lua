
-- Kitten by Jordach / BFD

mobs:register_mob("mobs:kitten", {
	type = "animal",
	passive = true,
	hp_min = 5,
	hp_max = 10,
	armor = 200,
	collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.1, 0.3},
	visual = "mesh",
	visual_size = {x = 0.5, y = 0.5},
	mesh = "mobs_kitten.b3d",
	textures = {
		{"mobs_kitten_striped.png"},
		{"mobs_kitten_splotchy.png"},
		{"mobs_kitten_ginger.png"},
		{"mobs_kitten_sandy.png"},
	},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_kitten",
	},
	walk_velocity = 0.6,
	jump = false,
	drops = {
		{name = "farming:string",
		chance = 1, min = 1, max = 1},
	},
	water_damage = 1,
	lava_damage = 5,
	animation = {
		speed_normal = 42,
		stand_start = 97,
		stand_end = 192,
		walk_start = 0,
		walk_end = 96,
	},
	follow = {"mobs:rat", "ethereal:fish_raw"},
	view_range = 10,
	on_rightclick = function(self, clicker)
		mobs:feed_tame(self, clicker, 4, true)
		mobs:capture_mob(self, clicker, 50, 50, 90, false, nil)
	end
})

mobs:register_spawn("mobs:kitten", {"default:dirt_with_grass", "ethereal:grove_dirt"}, 20, 12, 22000, 1, 31000)

mobs:register_egg("mobs:kitten", "Kitten", "mobs_kitten_inv.png", 0)