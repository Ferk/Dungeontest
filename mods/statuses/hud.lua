
--[[ table containing all the HUD info tables, indexed by player names.
A single HUD info table is formatted like this: { text_id = 1, icon_id=2, pos = 0 }
Where:	text_id: HUD ID of the textual effect description
	icon_id: HUD ID of the effect icon (optional)
	pos: Y offset factor (starts with 0)
Example of full table:
{ ["player1"] = {{ text_id = 1, icon_id=4, pos = 0 }}, ["player2] = { { text_id = 5, icon_id=6, pos = 0 }, { text_id = 7, icon_id=8, pos = 1 } } }
]]
statuses.hudinfos = {}


--[=[ HUD ]=]

function statuses.hud_update(player)
	local playername = player:get_player_name()
	local hudinfos = statuses.hudinfos[playername]
	if(hudinfos ~= nil) then
		local now = os.time()
		for sindex, hudinfo in pairs(hudinfos) do
			local status = statuses.active[sindex]
			if(status ~= nil and hudinfo.text_id ~= nil) then
				local def = statuses.registered_statuses[status.name]
				local text = def.description
				if status.duration then
					local time_left = status.duration - os.difftime(now, status.start_time)
					text = text .. " (" .. tostring(time_left) .. " s)"
				end

				player:hud_change(hudinfo.text_id, "text", text)
			end
		end
	end
end

function statuses.hud_clear(player)
	local playername = player:get_player_name()
	local hudinfos = statuses.hudinfos[playername]
	if(hudinfos ~= nil) then
		for sindex, hudinfo in pairs(hudinfos) do
			local status = statuses.active[sindex]
			if(hudinfo.text_id ~= nil) then
				player:hud_remove(hudinfo.text_id)
			end
			if(hudinfo.icon_id ~= nil) then
				player:hud_remove(hudinfo.icon_id)
			end
			statuses.hudinfos[playername][sindex] = nil
		end
	end
end

function statuses.hud_effect(status_name, player, pos, time_left)
	local text_id, icon_id
	local def = statuses.registered_statuses[status_name]
	if not def then
		minetest.log("action", "[statuses] status definition not registered '" .. status.name .. "', won't display it")

	elseif(def.hidden ~= true) then
		local color
		if(def.cancel_on_death == true) then
			color = 0xFFFFFF
		else
			color = 0xF0BAFF
		end
		local description = def.description
		local text = description .. " ("..tostring(time_left).." s)"

		text_id = player:hud_add({
			hud_elem_type = "text",
			position = { x = 1, y = 0.3 },
			name = "status_"..status_name,
			text = text,
			scale = { x = 170, y = 20},
			alignment = { x = -1, y = 0 },
			direction = 1,
			number = color,
			offset = { x = -5, y = pos*20 }
		})
		if(def.icon ~= nil) then
			icon_id = player:hud_add({
				hud_elem_type = "image",
				scale = { x = 1, y = 1 },
				position = { x = 1, y = 0.3 },
				name = "status_icon_"..status_name,
				text = def.icon,
				alignment = { x = -1, y=0 },
				direction = 0,
				offset = { x = -186, y = pos*20 },
			})
		end
	else
		text_id = nil
		icon_id = nil
	end
	return text_id, icon_id
end
