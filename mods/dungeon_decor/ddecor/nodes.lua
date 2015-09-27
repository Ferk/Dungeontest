xpanes.register_pane("bamboo_frame", {
	description = "Bamboo Frame",
	tiles = {"ddecor_bamboo_frame.png"},
	drawtype = "airlike",
	paramtype = "light",
	textures = {"ddecor_bamboo_frame.png", "ddecor_bamboo_frame.png", "xpanes_space.png"},
	inventory_image = "ddecor_bamboo_frame.png",
	wield_image = "ddecor_bamboo_frame.png",
	groups = {snappy=3, pane=1, flammable=2},
	recipe = {
		{"default:papyrus", "default:papyrus", "default:papyrus"},
		{"default:papyrus", "farming:cotton", "default:papyrus"},
		{"default:papyrus", "default:papyrus", "default:papyrus"}
	}
})

ddecor.register("baricade", {
	description = "Baricade",
	drawtype = "plantlike",
	walkable = false,
	inventory_image = "ddecor_baricade.png",
	tiles = {"ddecor_baricade.png"},
	groups = {snappy=3, flammable=3},
	damage_per_second = 4,
	selection_box = ddecor.nodebox.slab_y(0.3)
})

ddecor.register("barrel", {
	description = "Barrel",
	inventory = {size=24},
	infotext = "Barrel",
	tiles = {"ddecor_barrel_top.png", "ddecor_barrel_sides.png"},
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults()
})

ddecor.register("cabinet", {
	description = "Wood Cabinet",
	inventory = {size=24},
	infotext = "Wood Cabinet",
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	tiles = {
		"ddecor_cabinet_sides.png", "ddecor_cabinet_sides.png",
		"ddecor_cabinet_sides.png", "ddecor_cabinet_sides.png",
		"ddecor_cabinet_sides.png", "ddecor_cabinet_front.png"
	}
})

ddecor.register("cabinet_half", {
	description = "Half Wood Cabinet",
	inventory = {size=8},
	infotext = "Half Wood Cabinet",
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = ddecor.nodebox.slab_y(0.5, 0.5),
	tiles = {
		"ddecor_cabinet_sides.png", "ddecor_cabinet_sides.png",
		"ddecor_half_cabinet_sides.png", "ddecor_half_cabinet_sides.png",
		"ddecor_half_cabinet_sides.png", "ddecor_half_cabinet_front.png"
	}
})

ddecor.register("candle", {
	description = "Candle",
	light_source = 12,
	drawtype = "torchlike",
	inventory_image = "ddecor_candle_inv.png",
	wield_image = "ddecor_candle_wield.png",
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	walkable = false,
	groups = {dig_immediate=3, attached_node=1},
	tiles = {
		{ name = "ddecor_candle_floor.png",
			animation = {type="vertical_frames", length=1.5} },
		{ name = "ddecor_candle_ceiling.png",
			animation = {type="vertical_frames", length=1.5} },
		{ name = "ddecor_candle_wall.png",
			animation = {type="vertical_frames", length=1.5} }
	},
	selection_box = {
		type = "wallmounted",
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.1, 0.25},
		wall_side = {-0.5, -0.35, -0.15, -0.15, 0.4, 0.15}
	}
})

ddecor.register("cardboard_box", {
	description = "Cardboard Box",
	inventory = {size=8},
	infotext = "Cardboard Box",
	groups = {flammable=3},
	tiles = {"ddecor_cardbox_top.png", "ddecor_cardbox_top.png",
		"ddecor_cardbox_sides.png"},
	node_box = {
		type = "fixed", fixed = {{-0.3125, -0.5, -0.3125, 0.3125, 0, 0.3125}}
	}
})

ddecor.register("cauldron", {
	description = "Cauldron",
	tiles = {
		{ name = "ddecor_cauldron_top_anim.png",
			animation = {type="vertical_frames", length=3.0} },
		"ddecor_cauldron_sides.png"
	}
})

if minetest.get_modpath("bucket") then
	local original_bucket_on_use = minetest.registered_items["bucket:bucket_empty"].on_use
	minetest.override_item("bucket:bucket_empty", {
		on_use = function(itemstack, user, pointed_thing)
			local inv = user:get_inventory()
			if pointed_thing.type == "node" and minetest.get_node(pointed_thing.under).name == "ddecor:cauldron" then
				if inv:room_for_item("main", "bucket:bucket_water 1") then
					itemstack:take_item()
					inv:add_item("main", "bucket:bucket_water 1")
				else
					minetest.chat_send_player(user:get_player_name(), "No room in your inventory to add a filled bucket!")
				end
				return itemstack
			else if original_bucket_on_use then
				return original_bucket_on_use(itemstack, user, pointed_thing)
			else return end
		end
	end
	})
end

xpanes.register_pane("chainlink", {
	description = "Chain Link",
	tiles = {"ddecor_chainlink.png"},
	drawtype = "airlike",
	paramtype = "light",
	textures = {"ddecor_chainlink.png", "ddecor_chainlink.png", "xpanes_space.png"},
	inventory_image = "ddecor_chainlink.png",
	wield_image = "ddecor_chainlink.png",
	groups = {pane=1},
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "", "default:steel_ingot"}
	}
})

ddecor.register("chair", {
	description = "Chair",
	tiles = {"ddecor_wood.png"},
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3, flammable=3},
	node_box = {
		type = "fixed",
		fixed = {{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125},
			{0.1875, -0.5, 0.1875, 0.3125, 0.5, 0.3125},
			{-0.1875, 0.025, 0.22, 0.1875, 0.45, 0.28},
			{-0.3125, -0.5, -0.3125, -0.1875, -0.125, -0.1875},
			{0.1875, -0.5, -0.3125, 0.3125, -0.125, -0.1875},
			{-0.3125, -0.125, -0.3125, 0.3125, 0, 0.1875}}
	}
})

ddecor.register("stone_chair", {
	description = "Stone Chair",
	tiles = {"default_stone.png"},
	sounds = default.node_sound_stone_defaults(),
	groups = {cracky=3},
	node_box = {
		type = "fixed",
		fixed = {{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125},
			{0.1875, -0.5, 0.1875, 0.3125, 0.5, 0.3125},
			{-0.1875,  -0.125, 0.22, 0.1875, 0.45, 0.28},
			{-0.3125, -0.5, -0.3125, -0.1875, -0.125, -0.1875},
			{0.1875, -0.5, -0.3125, 0.3125, -0.125, -0.1875},
			{-0.3125, -0.125, -0.3125, 0.3125, 0, 0.1875}}
	}
})


ddecor.register("table", {
	description = "Table",
	tiles = {"ddecor_wood.png"},
	groups = {flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
			{-0.15, -0.5, -0.15, 0.15, 0.4, 0.15}}
	}
})

ddecor.register("stone_table", {
	description = "Stone Table",
	tiles = {"default_stone.png"},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
			{-0.15, -0.5, -0.15, 0.15, 0.4, 0.15}}
	}
})

ddecor.register("chandelier", {
	description = "Chandelier",
	drawtype = "plantlike",
	walkable = false,
	inventory_image = "ddecor_chandelier.png",
	tiles = {"ddecor_chandelier.png"},
	groups = {dig_immediate=3},
	light_source = 14,
	selection_box = ddecor.nodebox.slab_y(0.5, 0.5)
})

ddecor.register("cobweb", {
	description = "Cobweb",
	drawtype = "plantlike",
	tiles = {"ddecor_cobweb.png"},
	inventory_image = "ddecor_cobweb.png",
	liquid_viscosity = 8,
	liquidtype = "source",
	liquid_alternative_flowing = "ddecor:cobweb",
	liquid_alternative_source = "ddecor:cobweb",
	liquid_renewable = false,
	liquid_range = 0,
	walkable = false,
	selection_box = {type = "regular"},
	groups = {dig_immediate=3, liquid=3, flammable=3},
	sounds = default.node_sound_leaves_defaults()
})

local colors = {"red"} -- Add more curtains colors simply here.

for _, c in pairs(colors) do
	ddecor.register("curtain_"..c, {
		description = c:gsub("^%l", string.upper).." Curtain",
		walkable = false,
		tiles = {"wool_white.png^[colorize:"..c..":170"},
		inventory_image = "wool_white.png^[colorize:"..c..":170^ddecor_curtain_open_overlay.png^[makealpha:255,126,126",
		wield_image = "wool_white.png^[colorize:"..c..":170",
		drawtype = "signlike",
		paramtype2 = "wallmounted",
		groups = {flammable=3},
		selection_box = {type="wallmounted"},
		on_rightclick = function(pos, node, _, _)
			minetest.set_node(pos, {name="ddecor:curtain_open_"..c, param2=node.param2})
		end
	})

	ddecor.register("curtain_open_"..c, {
		tiles = {"wool_white.png^[colorize:"..c..":170^ddecor_curtain_open_overlay.png^[makealpha:255,126,126"},
		drawtype = "signlike",
		paramtype2 = "wallmounted",
		walkable = false,
		groups = {flammable=3, not_in_creative_inventory=1},
		selection_box = {type="wallmounted"},
		drop = "ddecor:curtain_"..c,
		on_rightclick = function(pos, node, _, _)
			minetest.set_node(pos, {name="ddecor:curtain_"..c, param2=node.param2})
		end
	})

	minetest.register_craft({
		output = "ddecor:curtain_"..c.." 4",
		recipe = {
			{"", "wool:"..c, ""},
			{"", "wool:"..c, ""}
		}
	})
end

ddecor.register("cushion", {
	description = "Cushion",
	tiles = {"ddecor_cushion.png"},
	groups = {snappy=3, flammable=3, fall_damage_add_percent=-50},
	on_place = minetest.rotate_node,
	node_box = ddecor.nodebox.slab_y(-0.5, 0.5)
})

local function door_access(door)
	if door:find("prison") then return true end
	return false
end

local door_types = {
	{"japanese", "brown"}, {"prison", "grey"}, {"prison_rust", "rust"},
	{"screen", "brownb"}, {"slide", "brownc"}, {"woodglass", "brown"}
}

for _, d in pairs(door_types) do
	doors.register_door("ddecor:"..d[1].."_door", {
		description = string.gsub(d[1]:gsub("^%l", string.upper), "_r", " R").." Door",
		inventory_image = "ddecor_"..d[1].."_door_inv.png",
		groups = {choppy=3, flammable=2, door=1},
		tiles_bottom = {"ddecor_"..d[1].."_door_b.png", "ddecor_"..d[2]..".png"},
		tiles_top = {"ddecor_"..d[1].."_door_a.png", "ddecor_"..d[2]..".png"},
		only_placer_can_open = door_access(d[1]),
		sounds = default.node_sound_wood_defaults(),
		sunlight = false
	})
end

ddecor.register("empty_shelf", {
	description = "Empty Shelf",
	inventory = {size=24},
	infotext = "Empty Shelf",
	tiles = {"default_wood.png", "default_wood.png^ddecor_empty_shelf.png"},
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults()
})


ddecor.register("ivy", {
	description = "Ivy",
	drawtype = "signlike",
	walkable = false,
	climbable = true,
	groups = {flammable=3, plant=1},
	paramtype2 = "wallmounted",
	selection_box = {type="wallmounted"},
	legacy_wallmounted = true,
	tiles = {"ddecor_ivy.png"},
	inventory_image = "ddecor_ivy.png",
	wield_image = "ddecor_ivy.png",
	sounds = default.node_sound_leaves_defaults()
})

ddecor.register("lantern", {
	description = "Lantern",
	light_source = 12,
	drawtype = "torchlike",
	inventory_image = "ddecor_lantern_floor.png",
	wield_image = "ddecor_lantern_floor.png",
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	walkable = false,
	groups = {attached_node=1},
	tiles = {"ddecor_lantern_floor.png", "ddecor_lantern_ceiling.png",
			"ddecor_lantern.png"},
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.25, -0.4, -0.25, 0.25, 0.5, 0.25},
		wall_bottom = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25},
		wall_side = {-0.5, -0.5, -0.15, 0.5, 0.5, 0.15}
	}
})

ddecor.register("lightbox", {
	description = "Light Box",
	tiles = {"ddecor_lightbox.png"},
	groups = {cracky=3},
	light_source = 13,
	sounds = default.node_sound_glass_defaults()
})

ddecor.register("packed_ice", {
	drawtype = "normal",
	description = "Packed Ice",
	tiles = {"ddecor_packed_ice.png"},
	groups = {cracky=2},
	sounds = default.node_sound_glass_defaults()
})


ddecor.register("painting", {
	description = "Painting",
	drawtype = "signlike",
	tiles = {"ddecor_painting.png"},
	extra_tiles = {
		{"ddecor_painting2.png"}, {"ddecor_painting3.png"},
		{"ddecor_painting4.png"}
	},
	inventory_image = "ddecor_painting.png",
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	walkable = false,
	wield_image = "ddecor_painting.png",
	selection_box = {type="wallmounted"},
	groups = {dig_immediate=3, flammable=3, attached_node=1}
})

ddecor.register("blood_splat", {
	description = "Blood Splat",
	drawtype = "signlike",
	tiles = {"ddecor_blood_splat.png"},
	extra_tiles = {
		{"ddecor_blood_splat1.png"}, {"ddecor_blood_splat2.png"},
		{"ddecor_blood_splat3.png"}, {"ddecor_blood_splat4.png"},
		{"ddecor_blood_splat5.png"}
	},
	wield_image = "ddecor_blood_splat.png",
	inventory_image = "ddecor_blood_splat.png",
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	walkable = false,
	selection_box = {type="wallmounted"},
	groups = {attached_node=1}
})

ddecor.register("skull", {
	description = "Skull",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = { -- Skull
			{-0.1875, -0.4125, 0,      0.125, -0.04,   -0.25},
			{-0.2375, -0.2875, 0.205,  0.185, -0.04,   -0.125},
			{ 0.0625, -0.475, -0.125,  0.125, -0.4125, -0.25},
			{-0.0625, -0.475, -0.125,  0,     -0.4125, -0.25},
			{-0.1875, -0.475, -0.125, -0.125, -0.4125, -0.25},
		},
	},
	tiles = {
		"ddecor_bone.png","ddecor_bone.png","ddecor_bone.png",
		"ddecor_bone.png","ddecor_bone.png","ddecor_skull_front.png"
	},
	inventory_image = "ddecor_skull_front.png",
	paramtype2 = "facedir",
	walkable = false,
	wield_image = "ddecor_skull_front.png",
	selection_box = {type="fixed", fixed = {-0.2375, -0.475, -0.25, 0.185, 0, 0.205}},
	groups = {dig_immediate=3}
})


for _, b in pairs({{"cactus", "cactus"}, {"moon", "stone"}}) do
	ddecor.register(b[1].."brick", {
		drawtype = "normal",
		description = b[1]:gsub("^%l", string.upper).." Brick",
		tiles = {"ddecor_"..b[1].."brick.png"},
		sounds = default.node_sound_stone_defaults(),
	})

	minetest.register_craft({
	output = "ddecor:"..b[1].."brick",
	recipe = {
		{"default:brick", "default:"..b[2]}
	}
})
end

ddecor.register("multishelf", {
	description = "Multi Shelf",
	inventory = {size=24},
	infotext = "Multi Shelf",
	tiles = {"default_wood.png", "default_wood.png^ddecor_multishelf.png"},
	groups = {choppy=3, flammable=3},
	sounds = default.node_sound_wood_defaults()
})

xpanes.register_pane("rust_bar", {
	description = "Rust Bars",
	tiles = {"ddecor_rust_bars.png"},
	drawtype = "airlike",
	paramtype = "light",
	textures = {"ddecor_rust_bars.png", "ddecor_rust_bars.png", "xpanes_space.png"},
	inventory_image = "ddecor_rust_bars.png",
	wield_image = "ddecor_rust_bars.png",
	groups = {creative_breakable=1, pane=1},
	recipe = {
		{"", "default:dirt", ""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	}
})

ddecor.register("stonepath", {
	description = "Garden Stone Path",
	tiles = {"default_stone.png"},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {{0, -0.5, 0, 0.375, -0.47, 0.375},
			{-0.4375, -0.5, -0.4375, -0.0625, -0.47, -0.0625},
			{-0.4375, -0.5, 0.125, -0.125, -0.47, 0.4375},
			{0.125, -0.5, -0.375, 0.375, -0.47, -0.125}}
	},
	selection_box = ddecor.nodebox.slab_y(0.05)
})

local stonish = {"desertstone_tile", "stone_tile", "stone_rune",
		"coalstone_tile", "hard_clay"}

for _, t in pairs(stonish) do
	ddecor.register(t, {
		drawtype = "normal",
		description = string.sub(t:gsub("^%l", string.upper), 1, -6)
				.." "..t:sub(-4):gsub("^%l", string.upper),
		tiles = {"ddecor_"..t..".png"},
		sounds = default.node_sound_stone_defaults()
	})
end


ddecor.register("tatami", {
	description = "Tatami",
	tiles = {"ddecor_tatami.png"},
	wield_image = "ddecor_tatami.png",
	groups = {flammable=3},
	node_box = {
		type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}}
	}
})


ddecor.register("woodframed_glass", {
	description = "Wood Framed Glass",
	drawtype = "glasslike_framed",
	tiles = {"ddecor_woodframed_glass.png", "ddecor_woodframed_glass_detail.png"},
	sounds = default.node_sound_glass_defaults()
})

ddecor.register("wood_tile", {
	description = "Wood Tile",
	tiles = {"ddecor_wood_tile.png"},
	drawtype = "normal",
	groups = {wood=1, flammable=2},
	sounds = default.node_sound_wood_defaults()
})
