local world_path = minetest.get_worldpath()


--[[

-- Makes the player screen black for 5 seconds (very experimental!)
statuses.register_effect_type("blind", "Blind", nil, {},
	function(player)
		local hudid = player:hud_add({
			hud_elem_type = "image",
			position = { x=0.5, y=0.5 },
			scale = { x=-100, y=-100 },
			text = "statuses_example_black.png",
		})
		if(hudid ~= nil) then
			return { hudid = hudid }
		else
			minetest.log("error", "[statuses] [examples] The effect \"Blind\" could not be applied. The call to hud_add(...) failed.")
			return false
		end
	end,
	function(effect, player)
		player:hud_remove(effect.metadata.hudid)
	end
)

-- Makes the user faster
statuses.register_effect_type("high_speed", "High speed", nil, {"speed"},
	function(player)
		player:set_physics_override(4,nil,nil)
	end,

	function(effect, player)
		player:set_physics_override(1,nil,nil)
	end
)

-- Makes the user faster (hidden effect)
statuses.register_effect_type("high_speed_hidden", "High speed", nil, {"speed"},
	function(player)
		player:set_physics_override(4,nil,nil)
	end,

	function(effect, player)
		player:set_physics_override(1,nil,nil)
	end,
	true
)



-- Slows the user down
statuses.register_effect_type("low_speed", "Low speed", nil, {"speed"},
	function(player)
		player:set_physics_override(0.25,nil,nil)
	end,

	function(effect, player)
		player:set_physics_override(1,nil,nil)
	end
)

-- Increases the jump height
statuses.register_effect_type("highjump", "Greater jump height", "statuses_example_highjump.png", {"jump"},
	function(player)
		player:set_physics_override(nil,2,nil)
	end,
	function(effect, player)
		player:set_physics_override(nil,1,nil)
	end
)

-- Adds the “fly” privilege. Keep the privilege even if the player dies
statuses.register_effect_type("fly", "Fly mode available", "statuses_example_fly.png", {"fly"},
	function(player)
		local playername = player:get_player_name()
		local privs = minetest.get_player_privs(playername)
		privs.fly = true
		minetest.set_player_privs(playername, privs)
	end,
	function(effect, player)
		local privs = minetest.get_player_privs(effect.playername)
		privs.fly = nil
		minetest.set_player_privs(effect.playername, privs)
	end,
	false, -- not hidden
	false  -- do NOT cancel the effect on death
)
--]]



-- Makes the player screen black for 5 seconds (very experimental!)
statuses.register_status("blind", {

	description = "Blind",
	on_start = function(player)
		local hudid = player:hud_add({
			hud_elem_type = "image",
			position = { x=0.5, y=0.5 },
			scale = { x=-100, y=-100 },
			text = "statuses_example_black.png",
		})
		if(hudid ~= nil) then
			return { hudid = hudid }
		else
			minetest.log("error", "[altars] The effect \"Blind\" could not be applied. The call to hud_add(...) failed.")
			return false
		end
	end,
	on_cancel = function(effect, player)
		player:hud_remove(effect.metadata.hudid)
	end
})

-- Makes the user faster
statuses.register_status("high_speed",{
	description = "High Speed",
	icon =  "heart.png",
	groups = "speed",
	on_start = function(status, target)
		local name = target:get_player_name()
		minetest.chat_send_player(name, "You suddently feel very hyperactive!")
		target:set_physics_override(4,nil,nil)
	end,
	on_cancel = function(status, target)
		local name = target:get_player_name()
		minetest.chat_send_player(name, "You regain normal speed")
		target:set_physics_override(1,nil,nil)
	end
})

-- Increases the jump height
statuses.register_status("high_jump", {
	description = "Low Gravity",
	icon =  "heart.png",
	groups = "speed",
	on_start = function(status, target)
		local name = target:get_player_name()
		minetest.chat_send_player(name, "You suddently feel very light!")
		target:set_physics_override(nil,2,nil)
	end,
	on_cancel = function(status, target)
		local name = target:get_player_name()
		minetest.chat_send_player(name, "You regain your normal weight, no longer feeling light")
		target:set_physics_override(nil,1,nil)
	end
})


local xom_effects = {
	[0]={
		status = { name = "blind", duration = 4 },
		message = "You gaze upon Xom's eyes and get blinded by its insanity"
	},
	{
		spell = "scrolls:speed",
		message = "Xom finds you amusing",
	},
	{
		spell = "scrolls:levitation",
		message = "Xom finds you amusing",
	},
	{
		spell = "scrolls:regeneration",
		message = "Xom finds you amusing",
	},
	{
		spell = "scrolls:poisoning",
		message = "Xom is bored",
	},
	{
		spell = "scrolls:random",
		message = "Xom is bored",
	},
}


function random_effect(player)
	local name = player:get_player_name()

	local mana_cost = math.random(50,100)

	if mana.subtract(player:get_player_name(), mana_cost) then

		local effect = xom_effects[math.random(#xom_effects)]
		minetest.chat_send_player(name, effect.message)

		if effect.status then
			statuses.apply_player_status(player, effect.status)

		elseif effect.spell then
			scrolls.self_cast(effect.spell, player, {})
		end

		minetest.sound_play("altars_xom_laughter", {
			to_player = name,
			gain = 2.0,
		})

	end
end


altars.register_god("xom", {
	title = "Xom, god of chaos",
	texture = "altars_xom.png",
	particle = "altars_xom_particle.png",
	on_pray = function(pos, node, player, itemstack)

		random_effect(player)

	end
})
