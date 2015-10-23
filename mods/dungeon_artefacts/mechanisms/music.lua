

mechanisms.musicboxes = {}

local default_music = "music_default"
local hear_distance = 6


local function musicbox_update(pos)
	local hash = minetest.hash_node_position(pos)

	if not mechanisms.musicboxes[hash] then
		local meta = minetest.get_meta(pos)
		local name = meta:get_string("name")
		if not name or name == "" then
			name = default_music
		end
		print("playing music! " .. name)

		mechanisms.musicboxes[hash] = minetest.sound_play(name, {
			--gain = 0.5,
			pos = pos,
			max_hear_distance = 3,
			loop = true
		})
	end
end


local function musicbox_stop(pos)
	local hash = minetest.hash_node_position(pos)
	local sound = mechanisms.musicboxes[hash]
	if sound then
		print("stopping music! ")
		minetest.sound_stop(sound)
	end
end

minetest.register_node("mechanisms:musicbox",	{
	description = "Music box",
	tiles = {"default_stone.png", "default_wood.png", "default_wood.png"},
	--inventory_image = "music_inventory.png",
	--wield_image = "music_inventory.png",
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-4/16, -0.5, -4/16, 4/16, -0.5 + (4/16), 4/16}
	},
	on_construct = function(pos)
		musicbox_update(pos)
	end,
	on_destruct = function(pos)
		musicbox_stop(pos)
	end,
	groups = {creative_breakable = 1}
})

minetest.register_abm({
	nodenames = {"mechanisms:musicbox"},
	interval = 2,
	chance = 1,
	action = musicbox_update
})
