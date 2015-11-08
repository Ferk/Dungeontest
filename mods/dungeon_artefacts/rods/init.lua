


minetest.register_tool("rods:rod_of_blinking", {
	description = "Rod of blinking",
	range = 20.0,
	tool_capabilities = {},
	wield_image = "rod_of_blinking.png",
	inventory_image = "rod_of_blinking.png",
	on_use = function(itemstack, user, pointed_thing)

	   local name = user:get_player_name()
	   if mana.get(name) > 60 and scrolls.cast("scrolls:teleportation", user, pointed_thing) then
		  mana.subtract(user:get_player_name(), 60)
	   end
	   return itemstack
	end,
})



minetest.register_tool("rods:rod_of_fireball", {
	description = "Rod of Fireballs",
	range = 20.0,
	tool_capabilities = {},
	wield_image = "rod_of_fireball.png",
	inventory_image = "rod_of_fireball.png",
	on_use = function(itemstack, user, pointed_thing)

	   local name = user:get_player_name()
	   if mana.get(name) > 20 and scrolls.cast("scrolls:fireball", user, pointed_thing) then
		  mana.subtract(user:get_player_name(), 20)
	   end
	   return itemstack
	end,
})



minetest.register_tool("rods:rod_of_icebolt", {
	description = "Rod of Icebolts",
	range = 20.0,
	tool_capabilities = {},
	wield_image = "rod_of_icebolt.png",
	inventory_image = "rod_of_icebolt.png",
	on_use = function(itemstack, user, pointed_thing)

	   local name = user:get_player_name()
	   if mana.get(name) > 20 and scrolls.cast("scrolls:icebolt", user, pointed_thing) then
		  mana.subtract(user:get_player_name(), 20)
	   end
	   return itemstack
	end,
})
