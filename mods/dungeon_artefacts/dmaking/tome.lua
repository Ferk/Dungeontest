
statuses.register_status("dmaking:maker",{
	description = "DungeonMaking",
	hidden = true,
	survive_player_death = true,
	groups = {dmaking=1}
})

local pool_selection_array = {"0","1","2","3","4","down","up"}

-- Teleport the given player to the X entrance of the room, which is always
-- open in unrotated schematics. This way he won't get inside a wall on load
function dmaking.teleport_player_safe(player)
	local room = dungeon_rooms.room_at(player:get_pos())
	local pos = {
			x = room.maxp.x - 1,
			y = room.maxp.y - dungeon_rooms.room_area.y/2,
			z = room.maxp.z - dungeon_rooms.room_area.z/2,
	}
	player:setpos(pos)
end

function dmaking.show_formspec(player, context)

	local name = player:get_player_name() or "singleplayer"
	local pos = player:get_pos()

	local room = dungeon_rooms.room_at(pos)
	local details = dungeon_rooms.get_room_details(room)

	context.room = context.room or room

	if pos.y > dungeon_rooms.origin.y then
		minetest.chat_send_player(name, "You open the tome but it's empty! it seems to have no power outside the Dungeon")
		return false
	end

	local formspec = "size[10,7]"
		.."background[-1,-1;12,9;dmaking_tome_bg.png]"
		.."label[0.5,0;Tome of DungeonMaking]"
		.."label[0,1;Level " .. room.level .." of the Dungeon.]"
		.."label[0,1.5;" .. details.leveldata.name .."]"
		.."button[0,1.5;4,3.5;show_map;Show Level map]"
		.."label[0,2;Current Room: (" .. room.x ..","..room.z .. ")]"
		.."button[0,3;4,3.5;reset;RESET room to default state]"
		.."label[0,5;Default state layout: " .. details.layout .. " (rotation:" .. details.rotation .. ")]"
		.."label[0,5.5;Title: " .. details.data.name .."]"
		.."label[0,6;Door direction: " .. details.door .."]"



	if context.roomdata and context.room.x == room.x and context.room.z == room.z and context.room.level == room.level then

		local roomdata = context.roomdata
		formspec = formspec
			.."field[5.75,0.5;4,1;roomdata_name;Room Name;" .. minetest.formspec_escape(roomdata.name) .."]"
			.."field[5.75,1.6;1,1;roomdata_rarity;Rarity;" .. roomdata.rarity .."]"
			.."field[6.75,1.6;1.5,1;roomdata_minlevel;Min Level;" .. (roomdata.minlevel or "") .."]"
			.."field[8.25,1.6;1.5,1;roomdata_maxlevel;Max Level;" .. (roomdata.maxlevel or "") .."]"
			.."field[5.75,3;4,1;roomdata_groups;Groups (comma separated);" .. table.concat(roomdata.groups,",") .."]"
			.."button[5.75,3.5;4,3.5;save;Save this room]"
			.."button[5.75,4.5;4,3.5;select;Load another room]"

	-- If there's at least a pool index, show the selection
	elseif context.pooli then

		local poolid = pool_selection_array[context.pooli] or error("Invalid pool index " .. context.pooli)
		local pool = dungeon_rooms.rooms[poolid] or error("No rooms loaded for pool " .. poolid)

		local roomlist = ""
		for i=1, #pool do
			local room = minetest.formspec_escape(pool[i].name)
			roomlist = roomlist=="" and room or roomlist..","..room
		end

		formspec = formspec
			.."label[5.75,0;Room Layout:]"
			.."dropdown[7.75,-0.1;2,1;select;".. table.concat(pool_selection_array,",") ..";" .. context.pooli .. "]"
			.."label[5.75,0.75;Double click the room to load it]"
			.."textlist[5.75,1.5;3,4;selected_roomdata;"..roomlist..";1;true]"
	else
		formspec = formspec
			.."label[5.75,0;No Room Data selected.]"
			.."label[5.75,1.0;If you had a room selected before]"
			.."label[5.75,1.5;the room might have been reset]"
			.."label[5.75,2.0;or you walked into a different room]"
			.."button[5.75,2.75;4,3.5;select;SELECT room data to load]"
			.."button[5.75,3.5;4,4.75;new;Create NEW room data]"
	end

	minetest.show_formspec(name, "dmaking:tome", formspec)
end

-- Turn a comma-separated string into a table of groups
-- or an empty table in any other case
local function togroups(str)
	return string.split(str,",") or {}
end

minetest.register_on_player_receive_fields(function(player, formname, fields)

	if formname == "dmaking:tome" then

		local name = player:get_player_name()
		local context = statuses.get_player_status(name)["dmaking:maker"]

		if fields.reset then
			minetest.show_formspec(name, "dmaking:tome", "size[4,2.5]"
				.."label[0,0;Are you sure you want to reset it?]"
				.."label[0,0.5;Current room changes will be lost]"
				.."button_exit[0,1.5;2,1;reset_for_sure;Reset!]"
				.."button_exit[2,1.5;2,1;cancel;Cancel]", context)

		elseif fields.reset_for_sure then

			local pos = player:get_pos()

			dungeon_rooms.clear_room_meta(pos)
			local room = dungeon_rooms.room_at(pos)
			local center = {
				x = room.maxp.x - math.floor(dungeon_rooms.room_area.x/2),
				y = room.maxp.y - math.floor(dungeon_rooms.room_area.y/2),
				z = room.maxp.z - math.floor(dungeon_rooms.room_area.z/2),
			}
			local details = dungeon_rooms.spawn_room(center)
			-- reset the context as well
			context.pooli = nil
			context.roomdata = nil
			--dmaking.teleport_player_safe(player)
			minetest.chat_send_player(name, "room regenerated: " .. details.data.name)


		-- Room data selection
		elseif fields.select then

			-- Room data was clicked!
			if fields.selected_roomdata then
				local event = minetest.explode_textlist_event(fields.selected_roomdata)

				if event.type == "DCL" then
					local pool = dungeon_rooms.rooms[fields.select]
					context.roomdata = pool and pool[event.index]
					if context.roomdata then
						context.room = nil
						dmaking.show_formspec(player, context)
						local pos = player:get_pos()
						dungeon_rooms.clear_room_meta(pos)
						if dungeon_rooms.place_roomdata(pos, context.roomdata) then
							minetest.chat_send_player(name, "room loaded: " .. context.roomdata.name)
							dmaking.teleport_player_safe(player)
						else
							minetest.chat_send_player(name, "room couldn't be loaded")
						end
					end
				end
			else
				-- Refresh formspec with appropiate value for the selection
				context.roomdata = nil
				context.pooli = context.pooli or 1
				for i=1, #pool_selection_array do
					if fields.select == pool_selection_array[i] then
						context.pooli = i
						break
					end
				end
				dmaking.show_formspec(player, context)
			end

		elseif fields.save then
			local filesplit = string.split(context.roomdata.path, "/",true,-1,true)
			context.filename = filesplit[#filesplit]
			context.save = {
				name = fields.roomdata_name,
				rarity = tonumber(fields.roomdata_rarity),
				minlevel = tonumber(fields.roomdata_minlevel),
				maxlevel = tonumber(fields.roomdata_maxlevel),
				groups = fields.roomdata_groups,
			}
			if context.save.rarity == 0 then
				context.save.rarity = nil
			end

			minetest.show_formspec(name, "dmaking:tome", "size[5,3]"
				.."label[0,0;A different filename will create a new room]"
				.."field[0.5,1.5;4,1;filename;Room filename;" .. context.filename .."]"
				.."button_exit[0.5,2.5;2,1;save_for_sure;Save!]"
				.."button_exit[2.5,2.5;2,1;cancel;Cancel]", context)

		elseif fields.save_for_sure then

			-- Sanitize filenames
			local filename = string.gsub(string.gsub(fields.filename, "/", "_"), "%.", "_")

			local dir = pool_selection_array[context.pooli]
			context.roomdata.path = dungeon_rooms.roomdata_directory .. "/" .. dir .. "/" .. filename
			context.roomdata.name = context.save.name
			context.roomdata.rarity = context.save.rarity
			context.roomdata.minlevel = context.save.minlevel
			context.roomdata.maxlevel = context.save.maxlevel
			context.roomdata.groups = togroups(context.save.groups)

			local roomconf = Settings(context.roomdata.path .. ".conf")

			roomconf:set("name", context.save.name)
			if context.save.rarity then
				roomconf:set("rarity", context.save.rarity)
			else
				roomconf:remove("rarity")
			end
			if context.save.minlevel then
				roomconf:set("minlevel", context.save.minlevel)
			else
				roomconf:remove("minlevel")
			end
			if context.save.maxlevel then
				roomconf:set("maxlevel", context.save.maxlevel)
			else
				roomconf:remove("maxlevel")
			end
			if context.save.groups then
				roomconf:set("groups", context.save.groups)
			else
				roomconf:remove("groups")
			end

			if roomconf:write() and dungeon_rooms.save_roomdata(player:get_pos(), context.roomdata) then
				minetest.chat_send_player(name, "room saved: " .. (context.save.name or filename))
			else
				minetest.chat_send_player(name, "room couldn't be saved")
			end

			if filename ~= context.filename then
				-- if the filename is new (different file) add it to the pool!
				table.insert(dungeon_rooms.rooms[dir], context.roomdata)
			end
			context.filename = nil
			context.save = nil

		elseif fields.new then
			minetest.show_formspec(name, "dmaking:tome", "size[4,3]"
				.."label[0,0.0;To create a new room, first load a]"
				.."label[0,0.5;room for the desired layout and]"
				.."label[0,1.0;then save it under a different name]"
				.."button[0,2;4,1;select;SELECT room data to load]", context)

		elseif fields.show_map then
			dmaking.show_map(player)

		end
		return true
	end
	return false
end)



minetest.register_tool("dmaking:tome", {
	description = "Tome of DungeonMaking",
	inventory_image = "dmaking_tome.png",
	groups = {dmaking=1},
	liquids_pointable = true,
	stack_max = 1,

	on_use = function(itemstack, player, pointed_thing)
		local name = player:get_player_name()
		local context = statuses.get_player_status(name)["dmaking:maker"]
		if not context then
			local i
			i, context = statuses.apply_player_status(player, {name="dmaking:maker"})
		end

		if context then dmaking.show_formspec(player, context) end
		return itemstack
	end,
})
