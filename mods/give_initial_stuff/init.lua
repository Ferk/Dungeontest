minetest.register_on_newplayer(function(player)
	if minetest.setting_getbool("give_initial_stuff") then
		minetest.log("action", "Giving initial stuff to player "..player:get_player_name())
		player:get_inventory():add_item('main', 'default:sword_steel')
		player:get_inventory():add_item('main', 'farming:bread 5')
	end
end)

