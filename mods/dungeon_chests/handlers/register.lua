dungeon_chests.registered_chests = {}
dungeon_chests.registered_chests_count = 0

function dungeon_chests.register_chest(type, def)
	dungeon_chests.registered_chests[type] = def
    dungeon_chests.registered_chests_count = dungeon_chests.registered_chests_count + 1
end



------ Chest node

local chest_context = {}

local function request_chest_type(pos, player)
    local name = player:get_player_name()
    chest_context[name] = {pos = pos}

    local typelist
    for k,v in pairs(dungeon_chests.registered_chests) do
        typelist = (typelist and (typelist .. ",") or "") .. (v.description or k)
    end

    minetest.show_formspec(name, "dungeon_chests:settype",
        "size[4.5,5]" ..
        "label[0,0;Dungeon Chest Type]" ..
        "textlist[0,1;4,3;type;" .. typelist .. "]" ..
        "button_exit[0,3;4,4;set_chest_type;Set Chest Type]")
end

minetest.register_node("dungeon_chests:chest", {
	description = "Dungeon Chest",
	tiles = {"dungeon_chest_top.png", "dungeon_chest_top.png", "dungeon_chest_side.png",
		"dungeon_chest_side.png", "dungeon_chest_back.png", "dungeon_chest_front.png"},
	paramtype2 = "facedir",
	groups = { creative_breakable = 1 },
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_blast = function() end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Chest")
	end,
	can_dig = function(pos,player) return minetest.setting_getbool("creative_mode")	end,
	after_place_node = function(pos, player, itemstack, pointed_thing)
        request_chest_type(pos, player)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local type = meta:get_string("chesttype")

        if type == "" then
            if minetest.setting_getbool("creative_mode") then
                return request_chest_type(pos, player)
            else
                type = "random"
            end
        end

		local def = dungeon_chests.registered_chests[type]

		local shallopen = true
		if def and def.on_open then
			shallopen = def.on_open(pos, node, player, itemstack, pointed_thing, meta)
		end

		if shallopen then
			local name = player:get_player_name()
			minetest.show_formspec(name, "dungeon_chest:chest", "size[8,8]"..
				default.gui_bg..
				default.gui_bg_img..
				default.gui_slots..
				"list[nodemeta:".. pos.x .. "," .. pos.y .. "," .. pos.z ..";main;0,0.3;8,3;]"..
				"list[current_player;main;0,3.85;8,1;]"..
				"list[current_player;main;0,5.08;8,3;8]"..
				"listring[nodemeta:".. pos.x .. "," .. pos.y .. "," .. pos.z ..";main]"..
				"listring[current_player;main]"..
				default.get_hotbar_bg(0,4.85))
		end
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
			" rearranged stuff in a chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local inam = stack:get_name()
		minetest.log("action", player:get_player_name().. " put " .. inam .. " in a chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local inam = stack:get_name()
		minetest.log("action", player:get_player_name().. " took " .. inam .. " from a chest at "..minetest.pos_to_string(pos))
	end,
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "dungeon_chests:settype" then

        if fields.set_chest_type then

            local name = player:get_player_name()
            local context = chest_context[name]

            local meta = context.meta or minetest.get_meta(context.pos)
            meta:set_string("chesttype", context.type)
            minetest.chat_send_player(name, "Chest type set to: " .. context.type)

            local def = dungeon_chests.registered_chests[context.type]
            if def and def.on_setup then
                def.on_setup(context.pos, meta, player)
            end

            chest_context[name] = nil -- release context

        elseif fields.type then

            local event = minetest.explode_textlist_event(fields.type)
            if event.type == "CHG" then
                local i = 0
                for type, def in pairs(dungeon_chests.registered_chests) do
                    i = i + 1
                    if event.index == i then
                        -- This is the chest type we want!
                        local name = player:get_player_name()
                		local context = chest_context[name]

                        if not context then
                            minetest.log("error", "couldn't find context for dungeon chest formspec")
                            return false
                        end

                        context.type = type
                    end
                end
            end

        end
        return true
	end

	-- Not my formname
	return false
end)
