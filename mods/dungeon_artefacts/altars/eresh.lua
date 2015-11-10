

statuses.register_status("altars:eresh_respawn",{
	description = "Eresh Resurrection",
	icon = "altars_eresh_particle.png",
	hidden = true,
	survive_player_death = true,
	groups = {spawn=1},
	on_cancel = function(status, target)
		local name = target:get_player_name()
		minetest.chat_send_player(name, "Eresh has forgotten about you")
	end
})



minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	local status_list = statuses.get_player_status(name)
	local respawn = status_list["altars:eresh_respawn"]
	minetest.log("action","list: " .. dump(status_list))
	minetest.log("action","Eresh value: " .. dump(respawn))
	if respawn then
		player:setpos(respawn.value)
		minetest.chat_send_player(name, "Eresh favors you!")
		return true
	else
		return false
	end
end)


altars.register_god("eresh", {
       title = "Eresh, goddess of Life and Death",
       texture = "altars_eresh.png",
       particle = "altars_eresh_particle.png",
       on_pray = function(pos, node, player, itemstack)
		  local name = player:get_player_name()
			statuses.update_player_status(player, { name="altars:eresh_respawn", value = player:getpos() })
			minetest.log("action","player '" .. name .. "' saved Eresh spawn at " .. minetest.serialize(pos))
			minetest.chat_send_player(name, "Eresh listened to your prayers")
       end
})
