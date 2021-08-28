
-- Slimes by ?

dofile(minetest.get_modpath("slimes").."/greenslimes.lua")
dofile(minetest.get_modpath("slimes").."/lavaslimes.lua")

-- cannot find mesecons?, craft glue instead
if not minetest.get_modpath("mesecons_materials") then
	minetest.register_craftitem(":mesecons_materials:glue", {
		image = "jeija_glue.png",
		description="Glue",
	})
end

if minetest.settings:get("log_mods") then minetest.log("action", "Slimes loaded") end
damage_enabled = minetest.settings:get_bool("enable_damage")

