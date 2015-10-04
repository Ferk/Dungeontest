
dungeon_mobs = {}

dungeon_mobs.registered_spawns = {}

local modpath = minetest.get_modpath(minetest.get_current_modname())

--dofile(modpath.."/api/registration.lua")

dofile(modpath.."/spawner.lua")

function dungeon_mobs.register_spawn(name, def)
    dungeon_mobs.registered_spawns[name] = def;
end


dungeon_mobs.register_spawn("slimes:greensmall", {
    maxlevel=3
});

dungeon_mobs.register_spawn("slimes:greenmedium", {
    minlevel=3,
    maxlevel=10
});

dungeon_mobs.register_spawn("slimes:greenbig", {
    minlevel=5,
});

dungeon_mobs.register_spawn("mobs:rat", {
    maxlevel=2
});

dungeon_mobs.register_spawn("mobs:spider", {
    minlevel=1,
	maxlevel=8
});

dungeon_mobs.register_spawn("mobs:stone_monster", {
    minlevel=3,
	maxlevel=10
});


dungeon_mobs.register_spawn("mobs:mese_monster", {
    minlevel=3,
	maxlevel=10
});

dungeon_mobs.register_spawn("mobs:oerkki", {
    minlevel=4
});

dungeon_mobs.register_spawn("ghost:ghost", {
    minlevel=5
});

dungeon_mobs.register_spawn("mobs:dungeon_master", {
    minlevel=7
});

----
