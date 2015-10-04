--[=[ Main tables ]=]

statuses = {}

--[[ table containing all the effect types ]]
statuses.registered_statuses = {}

--[[ table containing all the active effects ]]
statuses.active = {}

--[[ table containing all the inactive effects.
Effects become inactive if a player leaves an become active again if they join again. ]]
statuses.inactive = {}

-- Variable for counting the effect_id
statuses.id_count = 0


local modpath = minetest.get_modpath(minetest.get_current_modname())

--[=[ Include settings ]=]
dofile(modpath.."/settings.lua")

-- defaults
if(statuses.use_hud == nil) then
	statuses.use_hud = true
end
if(statuses.use_autosave == nil) then
	statuses.use_autosave = true
end
if(statuses.autosave_time == nil) then
	statuses.autosave_time = 10
end
if(statuses.use_examples == nil) then
	statuses.use_examples = false
end




--[[ table containing the groups (experimental) ]]
statuses.groups = {}

dofile(modpath.."/hud.lua")
dofile(modpath.."/player_status.lua")

function statuses.is_player(object)
	return object.is_player and object:is_player()
end

function statuses.next_status_id()
	statuses.id_count = statuses.id_count + 1
	return statuses.id_count
end

--[=[ API functions ]=]
function statuses.register_status(name, def)
	def = def or {}
	def.description = def.description or ""
	def.icon = def.icon or ""
	def.groups = def.groups or {}
	def.default_value = def.default_value or 0

	def.default_value = def.default_value or 0
	-- optional: def.repeater = { interval, on_activate }
	-- optional: def.on_death
	-- optional: def.on_start
	-- optional: def.on_cancel
	-- optional: def.duration
	-- optional: def.hidden
	-- optional: survive_player_death

	statuses.registered_statuses[name] = def
	minetest.log("action", "[statuses] status registered: " .. name)
end


function statuses.apply_status(target, status)

	if statuses.is_player(target) then
		return statuses.apply_player_status(target, status)
	elseif target.object then
		target = target.object
	end
	if target.get_luaentity then
		statuses.add_status(target, status)
	else
		minetest.log("action", "[statuses] non-entity and non-player cannot be affected by status")
	end
end


function statuses.add_status(target, status)

	local def = statuses.registered_statuses[status.name]

	if not def then
		minetest.log("action", "[statuses] status definition not registered: " .. name)
		return false
	else
		local sindex = statuses.next_status_id()
		status.id = sindex
		statuses.active[sindex] = status

		-- If a "duration" is defined, the status will be cancelled after it
		-- Also store the start time, to be able to get static data
		local duration = status.duration
		if duration and duration > 0 then
			status.start_time = os.time()
			minetest.after(duration, statuses.remove_status, sindex)
		end

		-- kickstart any repeating effects
		if def.repeaters then
			for i, repeater in pairs(def.repeaters) do
				local interval = repeater.interval
				if not interval or not (interval > 0) then
					minetest.log("action", "[statuses] status " .. status.name .. " repeater " .. i .. " has invalid interval '" .. (interval or "nil") .. "', it will be skipped")
				elseif duration and duration < interval then
					minetest.log("action", "[statuses] status " .. status.name .. " has a repeater with interval shorter than the status duration, it will be skipped")
				else
					minetest.after(interval, statuses.repeater_tick, repeater, sindex, target)
				end
			end
		end

		-- Trigger on_start callback if provided
		if def.on_start then
			def.on_start(status, target)
		end

		return sindex, status
	end
end

function statuses.repeater_tick(repeater, status_index, target)
	local status = statuses.active[status_index]
	if not status then
		minetest.log("action", "[statuses] status index no longer present '" .. status_index .. "', aborting repeater")
		return false
	else
		repeater.on_activate(target)
		if status.duration and (status.duration - os.difftime(os.time(), status.start_time)) < repeater.interval then
			minetest.log("action", "[statuses] skipping last repeater interval since the status is ending")
		else
			minetest.after(repeater.interval, statuses.repeater_tick, repeater, status_index, target)
		end
	end
end

function statuses.remove_status(sindex)
	local status = statuses.active[sindex]
	if status then

		local target
		if status.playername then
			target = minetest.get_player_by_name(status.playername)
			local hudinfo = statuses.hudinfos[status.playername][sindex]
			if(hudinfo ~= nil) then
				if(hudinfo.text_id~=nil) then
					target:hud_remove(hudinfo.text_id)
				end
				if(hudinfo.icon_id~=nil) then
					target:hud_remove(hudinfo.icon_id)
				end
				statuses.hudinfos[status.playername][sindex] = nil
			end
		elseif status.objectid then
			target = minetest.luaentities[status.objectid]
		end

		if target then
			local def = statuses.registered_statuses[status.name]
			if def and def.on_cancel then
				def.on_cancel(status, target)
			end
		end

		statuses.active[sindex] = nil
	else
		minetest.log("action", "[statuses] no status found with id " .. (sindex or nil))
	end
end




-- Global Loop!
statuses.globalstep_timer = 0
statuses.autosave_timer = 0

minetest.register_globalstep(function(dtime)
	statuses.globalstep_timer = statuses.globalstep_timer + dtime
	statuses.autosave_timer = statuses.autosave_timer + dtime

	-- Update HUDs of all players
	if(statuses.globalstep_timer >= 1) then
		statuses.globalstep_timer = 0

		local players = minetest.get_connected_players()
		for p=1,#players do
			statuses.hud_update(players[p])
		end
	end

	-- Autosave into file
	if(statuses.use_autosave == true and statuses.autosave_timer >= statuses.autosave_time) then
		statuses.autosave_timer = 0
		minetest.log("action", "[statuses] Autosaving mod data to statuses.mt ...")
		statuses.save_to_file()
	end

end)
