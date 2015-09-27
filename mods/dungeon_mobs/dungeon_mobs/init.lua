
dungeon_mobs = {}

local spawn_table = {}

function dungeon_mobs.register_spawn(name, def)
    spawn_table[name] = def;
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

-- Spawns a mob based on the given definitions.
-- If a "name" is given, the mob by this entity name will be used
-- Otherwise
function dungeon_mobs.spawn_mob(pos, def)

    if def.name == nil then
        -- Figure out the mobs available for the defined parameters
        local available_mobs = {}
        for name,mob in pairs(spawn_table) do
            local isAvailable = true
            if def.minlevel and mob.maxlevel and mob.maxlevel < def.minlevel then
                isAvailable=false
                --minetest.log("action","Too high minlevel ("..def.minlevel..") for "..name)
            elseif def.maxlevel and mob.minlevel and mob.minlevel > def.maxlevel then
                isAvailable=false
                --minetest.log("action","Not enough maxlevel ("..def.maxlevel..") for "..name)
            end
            if isAvailable then
                table.insert(available_mobs, name)
            end
        end
        if #available_mobs == 0 then
            minetest.log("action","No mobs available to spawn at "..pos.x..","..pos.y..","..pos.z)
        else
            def.name = available_mobs[math.random(1,#available_mobs)]
            --minetest.log("action","spawning "..def.name.." out of "..#available_mobs.." available")
        end
    end
    if def.name then minetest.add_entity(pos, def.name) end
end

function onlyCreative(var)
    if minetest.setting_getbool("creative_mode") then
        return var
    else
        return nil
    end
end

-- Mob Spawner nodes

minetest.register_node("dungeon_mobs:spawner_active", {
	description = "Dungeon Pentacle (active!)",
	tiles = {"dungeon_pentacle_active.png"},
	is_ground_content = true,
	groups = onlyCreative({oddly_breakable_by_hand = 3}),
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("dungeon_mobs:spawner_inactive", {
	description = "Dungeon Pentacle",
	tiles = {"dungeon_pentacle_inactive.png"},
	is_ground_content = true,
	groups = onlyCreative({oddly_breakable_by_hand = 3}),
	sounds = default.node_sound_stone_defaults(),
})



-- spawners won'T change state on creative mode, to permit editting
if not minetest.setting_getbool("creative_mode") then

    minetest.register_abm( {
    	nodenames = {"dungeon_mobs:spawner_inactive"},
    	interval = 10,
    	chance = 50,
    	action = function(pos, node, active_object_count, active_object_count_wider)
    		-- set it active
            node.name = "dungeon_mobs:spawner_active"
            minetest.set_node(pos, node)
    	end }
    )

    minetest.register_abm( {
        nodenames = {"dungeon_mobs:spawner_active"},
        interval = 2,
        chance = 2,
        action = function(pos, node, active_object_count, active_object_count_wider)
        	-- set it inactive
            node.name = "dungeon_mobs:spawner_inactive"
            minetest.set_node(pos, node)
        	-- spawn mobs
            pos.y = pos.y + 1

            local nod = minetest.get_node_or_nil(pos)
            if not nod
            or not nod.name
            or not minetest.registered_nodes[nod.name]
            or minetest.registered_nodes[nod.name].walkable == true then
                return
            end

            local level = dungeon_rooms.get_level(pos)
            minetest.log("action","Spawning level: "..level.." ("..pos.y)
            dungeon_mobs.spawn_mob(pos, {
                minlevel = level,
                maxlevel = level
            })
        end
    })

end
