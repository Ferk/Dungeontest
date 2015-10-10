
rods = {}


local cost_mana = tonumber(minetest.setting_get("rods_cost_mana"))
if cost_mana ~= nil then
	rods.settings.cost_mana = cost_mana
end




minetest.register_tool("rods:rod_of_blinking", {
	description = "Rod of blinking",
	range = 20.0,
	tool_capabilities = {},
	wield_image = "rod_3.png",
	inventory_image = "rod_3.png",
	on_use = function(itemstack, user, pointed_thing)
		if scrolls.cast("scrolls:teleportation", user, pointed_thing) then
			failure = not mana.subtract(user:get_player_name(), rods.settings.cost_mana)
		end
		return itemstack
	end,
})
