

local player_status_file_path = minetest.get_worldpath().."/status_players.mt"

--[=[ Load inactive_effects and last_effect_id from statuses.mt, if this file exists  ]=]
do
	local file = io.open(player_status_file_path, "r")
	if file then
		local string = file:read()
		io.close(file)
		if(string ~= nil) then
			local savetable = minetest.deserialize(string)
			statuses.inactive = savetable.inactive
			minetest.log("action", "[statuses] status_players.mt successfully read.")
			--minetest.debug("[statuses] inactive = "..dump(statuses.inactive))
			statuses.id_count = savetable.id_count
			--minetest.debug("[statuses] id_count = "..dump(statuses.id_count))

		end
	end
end


--[=[ Saving all data to file ]=]
function statuses.save_to_file()
	local save_time = os.time()
	local savetable = {}
	local inactive = {}
	for id,effecttable in pairs(statuses.inactive) do
		local playername = id
		if(inactive[playername] == nil) then
			inactive[playername] = {}
		end
		for i=1,#effecttable do
			table.insert(inactive[playername], effecttable[i])
		end
	end
	for sindex,status in pairs(statuses.active) do
        local def = statuses.registered_statuses[status.name]

		local snew = {}
		-- shallow copy
		for k,v in pairs(status) do
			snew[k] = v
		end

        if status.duration and status.duration > 0 then
	        snew.duration = status.duration - os.difftime(save_time, status.start_time)
        end
        if snew.duration and snew.duration < 0 then
            minetest.log("action", "[statuses] status already expired")

        else
    		if status.playername and inactive[status.playername] == nil then
    			inactive[status.playername] = {}
    		end
    		table.insert(inactive[status.playername], snew)
        end
	end

	savetable.inactive = inactive
	savetable.id_count = statuses.id_count

	local savestring = minetest.serialize(savetable)

	local file = io.open(player_status_file_path, "w")
	if file then
		file:write(savestring)
		io.close(file)
		minetest.log("action", "[statuses] Wrote statuses data into "..player_status_file_path..".")
	else
		minetest.log("error", "[statuses] Failed to write statuses data into "..player_status_file_path..".")
	end
end



function statuses.get_player_status(playername)
	if(minetest.get_player_by_name(playername) ~= nil) then
		local status_list = {}
		for k,v in pairs(statuses.active) do
			if(v.playername == playername) then
				status_list[v.name] = v
			end
		end
		return status_list
	else
		return {}
	end
end


function statuses.apply_player_status(player, status)

	local is_player = false
	if(type(player)=="userdata") then
		if(player.is_player ~= nil) then
			if(player:is_player() == true) then
				is_player = true
			end
		end
	end
	if(is_player == false) then
		minetest.log("error", "[statuses] Attempted to apply status "..status.name.." to a non-player!")
		return false
	end

	local playername = player:get_player_name()
    local def = statuses.registered_statuses[status.name]

    if not def then
        minetest.log("action", "[statuses] status definition not registered '" .. status.name .. "', won't apply it")
        return false
    end

	-- cancel any previous instance of this status for this player
	local current_statuses = statuses.get_player_status(playername)
	if current_statuses[status.name] then
		statuses.remove_status(current_statuses[status.name].id)
	end

    status.playername = playername
    local sindex, status = statuses.add_status(player, status)

	local smallest_hudpos
	local biggest_hudpos = -1
	local free_hudpos
	if(statuses.hudinfos[playername] == nil) then
		statuses.hudinfos[playername] = {}
	end
	local hudinfos = statuses.hudinfos[playername]
	for sindex, hudinfo in pairs(hudinfos) do
		local hudpos = hudinfo.pos
		if(hudpos > biggest_hudpos) then
			biggest_hudpos = hudpos
		end
		if(smallest_hudpos == nil) then
			smallest_hudpos = hudpos
		elseif(hudpos < smallest_hudpos) then
			smallest_hudpos = hudpos
		end
	end
	if(smallest_hudpos == nil) then
		free_hudpos = 0
	elseif(smallest_hudpos >= 0) then
		free_hudpos = smallest_hudpos - 1
	else
		free_hudpos = biggest_hudpos + 1
	end

	--[[ show no more than 20 effects on the screen, so that hud_update does not need to be called so often ]]
	local text_id, icon_id
	if(free_hudpos <= 20) then
		text_id, icon_id = statuses.hud_effect(status.name, player, free_hudpos, status.duration)
		local hudinfo = {
				text_id = text_id,
				icon_id = icon_id,
				pos = free_hudpos,
		}
		statuses.hudinfos[playername][sindex] = hudinfo
	else
		text_id, icon_id = nil, nil
	end

	return sindex, status
end



--[=[ Callbacks ]=]
--[[ Cancel all effects on player death ]]
minetest.register_on_dieplayer(function(player)
	local status_list = statuses.get_player_status(player:get_player_name())
	for name, status in pairs(status_list) do
		if not statuses.registered_statuses[name].survive_player_death then
			statuses.remove_status(status.id)
		end
	end
end)


minetest.register_on_leaveplayer(function(player)
	local leave_time = os.time()
	local playername = player:get_player_name()
	local status_list = statuses.get_player_status(playername)

	statuses.hud_clear(player)

	if(statuses.inactive[playername] == nil) then
		statuses.inactive[playername] = {}
	end
	for name, status in pairs(status_list) do
		if status.duration then
			status.duration = status.duration - os.difftime(leave_time, status.start_time)
		end
		table.insert(statuses.inactive[playername], status)
		statuses.remove_status(status.id)
	end
end)

minetest.register_on_shutdown(function()
	minetest.log("action", "[statuses] Server shuts down. Rescuing data into statuses.mt")
	statuses.save_to_file()
end)

minetest.register_on_joinplayer(function(player)
	local playername = player:get_player_name()

	-- load all the effects again (if any)
	if(statuses.inactive[playername] ~= nil) then
		for i=1,#statuses.inactive[playername] do
			local status = statuses.inactive[playername][i]
			statuses.apply_player_status(player, status)
		end
		statuses.inactive[playername] = nil
	end
end)
