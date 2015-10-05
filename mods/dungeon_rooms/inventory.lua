


unified_inventory.register_button("dungeon_edit", {
	type = "image",
	image = "dungeon_rooms_wall.png",
	tooltip = "Dungeon Editing",
})

local dungeonedit_context = {}

unified_inventory.register_page("dungeon_edit", {
	get_formspec = function(player)
		local name = player:get_player_name()
		local pos = player:getpos()

		local room = dungeon_rooms.room_at(pos)
		local roomtype, rotation, Xdoor = dungeon_rooms.get_room_details(room)
		
		local roomlist = ""
		for p,pool in pairs(dungeon_rooms.rooms) do
			for k,r in pairs(pool) do
				roomlist = roomlist=="" and r or roomlist..","..r
			end
		end

		-- "background[0.06,0.99;7.92,7.52;ui_bags_main_form.png]"
		local formspec = ""
			.."label[0,0;DungeonEdit]"
			.."label[0,1;" .. room.x ..","..room.z .. " rot:" .. rotation .. "]"
			.."button[1,2;2,0.5;dungeon_room_load;Load]"
			.."textlist[4,0.5;3,3.8;dungeon_room_schematic;"..roomlist..";1;true]"
			.."button[1,3;2,0.5;dungeon_room_save;Save]"
		
		return {formspec=formspec}
	end,
})



minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then
		return
	end

	if fields.dungeon_room_load then
		
		local name = player:get_player_name()
		local pos = player:getpos()

		dungeonedit_context = {}
		
		
		if load_room(pos, fields.schematic, 0) then
			minetest.chat_send_player(name, "room loaded: " .. fields.schematic)
		else
			minetest.chat_send_player(name, "room couldn't be loaded")
		end

	elseif fields.dungeon_room_schematic then

		local name = player:get_player_name()		
		print("recevied fields " .. dump(fields))
		for i, m in string.gmatch(fields.dungeon_room_schematic,"[^:]+") do

			if i == 2 then
				local pos = player:getpos()
				
				local schematic = m
				
				if load_room(pos, schematic, 0) then
					minetest.chat_send_player(name, "room loaded: " .. schematic)
				else
					minetest.chat_send_player(name, "room couldn't be loaded")
				end
			end
		end
	end
end)


