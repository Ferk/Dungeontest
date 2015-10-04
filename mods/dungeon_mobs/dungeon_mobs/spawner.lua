






-- Spawns a mob based on the given definitions.
-- If a "name" is given, the mob by this entity name will be used
-- Otherwise
function dungeon_mobs.spawn_mob(pos, def)

    if def.name == nil then
        -- Figure out the mobs available for the defined parameters
        local available_mobs = {}
        for name,mob in pairs(dungeon_mobs.registered_spawns) do
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


-- in creative, spawners metadata can be edited
if minetest.setting_getbool("creative_mode") then

    spawner_context = {}
    function spawner_on_rightclick(pos, node, player, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)

        local name = player:get_player_name()
        spawner_context[name] = {
            pos = pos,
            meta = meta,
        }

        minetest.show_formspec(name, "dungeon_mobs:edit_spawner",
            "size[8,4]" ..
            "field[0.5,0.5;1.5,1;amount;Amount;2]" ..
            "field[0.5,1.5;1.5,2;chance;Chance;1]" ..
            "field[3,0.5;5,1;names;Mob ids;]" ..
            "field[3,1.5;5,2;groups;Mob groups;]" ..
            "button_exit[3,2;4,3;exit;Save]")

    end


    minetest.register_on_player_receive_fields(function(player, formname, fields)
    	if formname == "dungeon_mobs:edit_spawner" then

    		local name = player:get_player_name()
    		local context = spawner_context[name]

    		local meta = context.meta or minetest.get_meta(context.pos)
            meta:set_int("amount", fields.amount)
            meta:set_string("names", fields.names)
            meta:set_string("groups", fields.groups)
            meta:set_int("chance", fields.chance)

            minetest.chat_send_player(name, "Changes saved to mob spawner")

    		-- release context
    		spawner_context[name] = nil
    		return true
    	end

    	-- Not my formname
    	return false
    end)

end



-- Mob Spawner nodes

minetest.register_node("dungeon_mobs:spawner_active", {
	description = "Dungeon Pentacle (active!)",
	drawtype = "signlike",
    paramtype = "light",
	paramtype2 = "wallmounted",
    node_box = {
        type="wallmounted",
        wall_top = {-0.5, 0.49, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.49, 0.5},
        wall_side = {-0.5, -0.5, -0.5, -0.49, 0.5, 0.5},
    },
	tiles = {"dungeon_pentacle_active.png"},
    inventory_image = "dungeon_pentacle_active.png",
    wield_image = "dungeon_pentacle_active.png",
    sunlight_propagates = true,
    walkable = false,
	selection_box = {
        type="wallmounted",
        wall_top = {-0.5, 0.49, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.49, 0.5},
        wall_side = {-0.5, -0.5, -0.5, -0.49, 0.5, 0.5},
    },
	groups = {creative_breakable = 1},
    on_rightclick = spawner_on_rightclick,
})

minetest.register_node("dungeon_mobs:spawner_inactive", {
	description = "Dungeon Pentacle",
	drawtype = "signlike",
    paramtype = "light",
	paramtype2 = "wallmounted",
    node_box = {
        type="wallmounted",
        wall_top = {-0.5, 0.49, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.49, 0.5},
        wall_side = {-0.5, -0.5, -0.5, -0.49, 0.5, 0.5},
    },
	tiles = {"dungeon_pentacle_inactive.png"},
    inventory_image = "dungeon_pentacle_inactive.png",
    wield_image = "dungeon_pentacle_inactive.png",
    sunlight_propagates = true,
    walkable = false,
	selection_box = {
        type="wallmounted",
        wall_top = {-0.5, 0.49, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.49, 0.5},
        wall_side = {-0.5, -0.5, -0.5, -0.49, 0.5, 0.5},
    },
	groups = {creative_breakable = 1},
    on_rightclick = spawner_on_rightclick,
})

-- this is just for decoration... maybe also to confuse/scare the player
minetest.register_node("dungeon_mobs:decorative_pentacle", {
	description = "Decorative Dungeon Pentacle",
	drawtype = "signlike",
    paramtype = "light",
	paramtype2 = "wallmounted",
    node_box = {
        type="wallmounted",
        wall_top = {-0.5, 0.49, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.49, 0.5},
        wall_side = {-0.5, -0.5, -0.5, -0.49, 0.5, 0.5},
    },
	tiles = {"dungeon_pentacle_inactive.png"},
    inventory_image = "dungeon_pentacle_inactive.png",
    wield_image = "dungeon_pentacle_inactive.png",
    sunlight_propagates = true,
    walkable = false,
	selection_box = {
        type="wallmounted",
        wall_top = {-0.5, 0.49, -0.5, 0.5, 0.5, 0.5},
        wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.49, 0.5},
        wall_side = {-0.5, -0.5, -0.5, -0.49, 0.5, 0.5},
    },
	groups = {creative_breakable = 1},
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

        	-- set it inactive as soon as it triggers to avoid triggering twice!
            node.name = "dungeon_mobs:spawner_inactive"
            minetest.set_node(pos, node)

            -- if a chance is defined, apply it before continuing
            local meta = minetest.get_meta(pos)
            local chance = meta:get_int("chance")
            if chance > 1 and math.random(1,chance) ~= 1 then
                return
            end

            -- Get the rest of the metadata
            local amount = meta:get_int("amount")
            local names_str = meta:get_string("names")
            local groups_str = meta:get_string("groups")

            if not amount or amount == 0 then
                amount = 2
            end
            local names
            if names_str then
                names = {}
                for i in string.gmatch(names_str, "%S+") do
                    table.insert(names, i)
                end
            end
            local groups
            if groups_str then
                groups = {}
                for i in string.gmatch(names_str, "%S+") do
                    table.insert(groups, i)
                end
            end

            -- spawn mobs in direction opposed to the wall
            local dir = minetest.wallmounted_to_dir(node.param2)
            pos.x, pos.y, pos.z = pos.x - dir.x , pos.y - dir.y, pos.z -dir.z
            local level = dungeon_rooms.get_level(pos)
            for i=1,amount do
                dungeon_mobs.spawn_mob(pos, {
                    minlevel = level,
                    maxlevel = level,
                    names = names,
                    groups = names,
                })
            end
        end
    })

end
