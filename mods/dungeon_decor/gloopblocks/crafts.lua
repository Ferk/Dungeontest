-- Various crafts

minetest.register_craft( {
	type = "shapeless",
	output = "gloopblocks:rainbow_block",
	recipe = {
		"group:basecolor_red",
		"group:excolor_orange",
		"group:basecolor_yellow",
		"group:basecolor_green",
		"group:basecolor_blue",
		"group:excolor_violet",
		"default:stone",
		"default:mese_crystal",
	},
})


minetest.register_craft({
	type = "shapeless",
	output = "default:nyancat_rainbow",
	recipe = {
		"gloopblocks:rainbow_block", 
		"default:diamondblock",
		"default:steelblock",
		"default:copperblock",
		"default:bronzeblock",
		"default:goldblock",
		"default:mese",
		"moreores:silver_block",
		"moreores:mithril_block"
	}
})

minetest.register_craft({
	output = "default:nyancat",
	recipe = {
		{"gloopblocks:rainbow_block", "gloopblocks:rainbow_block", "gloopblocks:rainbow_block"},
		{"gloopblocks:rainbow_block", "gloopblocks:rainbow_block", "gloopblocks:rainbow_block"},
		{"gloopblocks:rainbow_block", "gloopblocks:rainbow_block", "gloopblocks:rainbow_block"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "gloopblocks:wet_cement",
	recipe = {
		"bucket:bucket_water",
		"default:gravel",
	},
	replacements = {{'bucket:bucket_water', 'bucket:bucket_empty'},},
})

minetest.register_craft({
	type = "cooking",
	output = "gloopblocks:cement",
	recipe = "gloopblocks:wet_cement",
	cooktime = 8
})

minetest.register_craft({
	output = "default:gravel",
	recipe = {
		{"gloopblocks:cement"},
	},
})


if minetest.get_modpath("glooptest") then

	minetest.register_craft({
		type = "shapeless",
		output = "gloopblocks:evil_stick",
		recipe = {
			"glooptest:kalite_lump",
			"default:gold_ingot",
			"default:coal_lump",
			"group:stick"
		}
	})

elseif minetest.get_modpath("gloopores") then

	minetest.register_craft({
		type = "shapeless",
		output = "gloopblocks:evil_stick",
		recipe = {
			"gloopores:kalite_lump",
			"default:gold_ingot",
			"default:coal_lump",
			"group:stick"
		}
	})
else
	minetest.register_craft({
		type = "shapeless",
		output = "gloopblocks:evil_stick",
		recipe = {
			"default:gold_ingot",
			"default:gold_ingot",
			"default:coal_lump",
			"group:stick"
		}
	})
end

minetest.register_craft({
	output = "gloopblocks:evil_block",
	recipe = {
		{"gloopblocks:evil_stick", "gloopblocks:evil_stick"},
		{"gloopblocks:evil_stick", "gloopblocks:evil_stick"},
	}
})

minetest.register_craft({
	output = "gloopblocks:scaffolding 12",
		recipe = {
		{"group:stick", "group:wood", "group:stick"},
		{"", "group:stick", ""},
		{"group:stick", "group:wood", "group:stick"},
	}
})

minetest.register_craft({
	output = "gloopblocks:evil_stick 4",
	recipe = {
		{"gloopblocks:evil_block"}
	}
})

minetest.register_craft({
	output = "gloopblocks:pick_cement",
	recipe = {
		{"gloopblocks:cement", "gloopblocks:cement", "gloopblocks:cement"},
		{"", "group:stick", ""},
		{"", "group:stick", ""},
	}
})

minetest.register_craft({
	output = "gloopblocks:axe_cement",
	recipe = {
		{"gloopblocks:cement", "gloopblocks:cement"},
		{"gloopblocks:cement", "group:stick"},
		{"", "group:stick"},
	}
})

minetest.register_craft({
	output = "gloopblocks:axe_cement",
	recipe = {
		{"gloopblocks:cement", "gloopblocks:cement"},
		{"group:stick", "gloopblocks:cement"},
		{"group:stick", ""},
	}
})

minetest.register_craft({
	output = "gloopblocks:shovel_cement",
	recipe = {
		{"gloopblocks:cement"},
		{"group:stick"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "gloopblocks:sword_cement",
	recipe = {
		{"gloopblocks:cement"},
		{"gloopblocks:cement"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "gloopblocks:pick_evil",
	recipe = {
		{"gloopblocks:evil_block", "gloopblocks:evil_block", "gloopblocks:evil_block"},
		{"", "gloopblocks:evil_stick", ""},
		{"", "gloopblocks:evil_stick", ""},
	}
})

minetest.register_craft({
	output = "gloopblocks:axe_evil",
	recipe = {
		{"gloopblocks:evil_block", "gloopblocks:evil_block"},
		{"gloopblocks:evil_block", "gloopblocks:evil_stick"},
		{"", "gloopblocks:evil_stick"},
	}
})

minetest.register_craft({
	output = "gloopblocks:axe_evil",
	recipe = {
		{"gloopblocks:evil_block", "gloopblocks:evil_block"},
		{"gloopblocks:evil_stick", "gloopblocks:evil_block"},
		{"gloopblocks:evil_stick", ""},
	}
})

minetest.register_craft({
	output = "gloopblocks:shovel_evil",
	recipe = {
		{"gloopblocks:evil_block"},
		{"gloopblocks:evil_stick"},
		{"gloopblocks:evil_stick"},
	}
})

minetest.register_craft({
	output = "gloopblocks:sword_evil",
	recipe = {
		{"gloopblocks:evil_block"},
		{"gloopblocks:evil_block"},
		{"gloopblocks:evil_stick"},
	}
})

if minetest.get_modpath("building_blocks") then
	minetest.register_craft({
		output = "default:wood 4",
		recipe = {
			 {"building_blocks:faggot", "building_blocks:faggot"},
			 {"building_blocks:faggot", "building_blocks:faggot"},
		}
	})
else
	minetest.register_craft({
		output = "default:wood",
		recipe = {
			 {"default:stick", "default:stick"},
			 {"default:stick", "default:stick"},
		}
	})
end

minetest.register_craft({
	output = "gloopblocks:pavement 5",
	recipe = {
		{"gloopblocks:basalt",    "gloopblocks:wet_cement","gloopblocks:basalt"},
		{"gloopblocks:wet_cement","gloopblocks:basalt",    "gloopblocks:wet_cement"},
		{"gloopblocks:basalt",    "gloopblocks:wet_cement","gloopblocks:basalt"},
	}
})

minetest.register_craft({
	output = "gloopblocks:pavement 5",
	recipe = {
		{"gloopblocks:wet_cement","gloopblocks:basalt",    "gloopblocks:wet_cement"},
		{"gloopblocks:basalt",    "gloopblocks:wet_cement","gloopblocks:basalt"},
		{"gloopblocks:wet_cement","gloopblocks:basalt",    "gloopblocks:wet_cement"},
	}
})

minetest.register_craft({
	output = "gloopblocks:oerkki_block 2",
	recipe = {
		{"default:iron_lump", "default:coal_lump", "default:iron_lump"},
		{"default:coal_lump", "default:bookshelf", "default:coal_lump"},
		{"default:iron_lump", "default:coal_lump", "default:iron_lump"},
	},
	replacements = { { "default:bookshelf", "default:book 3" } }
})

minetest.register_craft({
	output = "gloopblocks:oerkki_block 2",
	recipe = {
		{"default:coal_lump", "default:iron_lump", "default:coal_lump"},
		{"default:iron_lump", "default:bookshelf", "default:iron_lump"},
		{"default:coal_lump", "default:iron_lump", "default:coal_lump"},
	},
	replacements = { { "default:bookshelf", "default:book 3" } }
})

minetest.register_craft({
	type = "shapeless",
	output = "gloopblocks:stone_brick_mossy 2",
	recipe = {
		"default:stonebrick",
		"default:stonebrick",
		"default:junglegrass",
		"default:junglegrass"
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "gloopblocks:stone_brick_mossy 2",
	recipe = {
		"default:stonebrick",
		"default:stonebrick",
		"default:grass_1",
		"default:grass_1",
		"default:grass_1",
		"default:grass_1"
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "gloopblocks:cobble_road 5",
	recipe = {
		"default:cobble",
		"default:cobble",
		"default:cobble",
		"default:cobble",
		"gloopblocks:pavement"
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "gloopblocks:cobble_road_mossy 2",
	recipe = {
		"gloopblocks:cobble_road",
		"gloopblocks:cobble_road",
		"default:junglegrass",
		"default:junglegrass"
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "gloopblocks:cobble_road_mossy 2",
	recipe = {
		"gloopblocks:cobble_road",
		"gloopblocks:cobble_road",
		"default:grass_1",
		"default:grass_1",
		"default:grass_1",
		"default:grass_1"
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "gloopblocks:stone_mossy 2",
	recipe = {
		"default:stone",
		"default:stone",
		"default:junglegrass",
		"default:junglegrass"
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "gloopblocks:stone_mossy 2",
	recipe = {
		"default:stone",
		"default:stone",
		"default:grass_1",
		"default:grass_1",
		"default:grass_1",
		"default:grass_1"
	}
})

