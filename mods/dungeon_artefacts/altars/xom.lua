local world_path = minetest.get_worldpath()


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
