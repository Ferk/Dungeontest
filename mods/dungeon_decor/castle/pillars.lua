
function castle.register_pillar(name, def)
	-- Node Definitions for bottom, top and middle pillar nodes
	minetest.register_node(name.."_bottom", {
	    drawtype = "nodebox",
		description = def.description.." Base",
		tiles = {def.tile},
		groups = def.groups or {cracky=3,attached_node=1},
		sounds = def.sounds or default.node_sound_defaults(),
	    paramtype = "light",
	    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.500000,-0.500000,0.500000,-0.375000,0.500000},
			{-0.375000,-0.375000,-0.375000,0.375000,-0.125000,0.375000},
			{-0.250000,-0.125000,-0.250000,0.250000,0.500000,0.250000},
		},
	},
	})
	minetest.register_node(name.."_top", {
	    drawtype = "nodebox",
		description = def.description.." Top",
		tiles = {def.tile},
		groups = def.groups or {cracky=3,attached_node=1},
		sounds = def.sounds or default.node_sound_defaults(),
	    paramtype = "light",
	    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.500000,0.312500,-0.500000,0.500000,0.500000,0.500000},
			{-0.375000,0.062500,-0.375000,0.375000,0.312500,0.375000},
			{-0.250000,-0.500000,-0.250000,0.250000,0.062500,0.250000},
		},
	},
	})
	minetest.register_node(name.."_middle", {
	    drawtype = "nodebox",
		description = def.description.." Middle",
		tiles = {def.tile},
		groups = def.groups or {cracky=3,attached_node=1},
		sounds = def.sounds or default.node_sound_defaults(),
	    paramtype = "light",
	    paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.250000,-0.500000,-0.250000,0.250000,0.500000,0.250000},
		},
	},
	})
	-- Only register crafts if craft_material is defined
	if def.craft_material then
		minetest.register_craft({
			output = name.."_bottom 4",
			recipe = {
			{"",def.craft_material,""},
			{"",def.craft_material,""},
			{def.craft_material,def.craft_material,def.craft_material} },
		})
		minetest.register_craft({
			output = name.."_top 4",
			recipe = {
			{def.craft_material,def.craft_material,def.craft_material},
			{"",def.craft_material,""},
			{"",def.craft_material,""} },
		})
		minetest.register_craft({
			output = name.."_middle 4",
			recipe = {
			{def.craft_material,def.craft_material},
			{def.craft_material,def.craft_material},
			{def.craft_material,def.craft_material} },
		})
	end
end

-- register all castle pillars
castle.register_pillar("castle:pillars_stonewall", {
	description = "Stonewall Pillar",
	tile = "castle_stonewall.png",
	craft_material = "castle:stonewall"
})
castle.register_pillar("castle:pillars_cobble", {
	description = "Cobble Pillar",
	tile = "default_cobble.png",
	craft_material = "default:cobble"
})
castle.register_pillar("castle:pillars_stonebrick", {
	description = "Stonebrick Pillar",
	tile = "default_stone_brick.png",
	craft_material = "default:stonebrick"
})
castle.register_pillar("castle:pillars_sandstonebrick", {
	description = "Sandstone Brick Pillar",
	tile = "default_sandstone_brick.png",
	craft_material = "default:sandstonebrick"
})
castle.register_pillar("castle:pillars_desertstonebrick", {
	description = "Desert Stone Brick Pillar",
	tile = "default_desert_stone_brick.png",
	craft_material = "default:desert_stonebrick"
})
castle.register_pillar("castle:pillars_stone", {
	description = "Stone Pillar",
	tile = "default_stone.png",
	craft_material = "default:stone"
})
castle.register_pillar("castle:pillars_sandstone", {
	description = "Sandstone Pillar",
	tile = "default_sandstone.png",
	craft_material = "default:sandstone"
})
castle.register_pillar("castle:pillars_desertstone", {
	description = "Desert Stone Pillar",
	tile = "default_desert_stone.png",
	craft_material = "default:desert_stone"
})

-- for compatibility
minetest.register_alias("castle:pillars_bottom", "castle:pillars_stonewall_bottom")
minetest.register_alias("castle:pillars_top", "castle:pillars_stonewall_top")
minetest.register_alias("castle:pillars_middle", "castle:pillars_stonewall_middle")
