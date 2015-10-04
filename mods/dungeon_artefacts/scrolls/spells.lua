



scrolls.register_spell("scrolls:speed", {
	description = "Speed",
	scroll_image = "scroll_of_speed.png",
	particle_image = "scroll_status_speed.png",
    groups = {speed=1},

    status_duration = 10,
    status = {
    	description = "High Speed",
    	on_start = function(status, target)
    		scrolls.chat_if_player(target, "You suddently feel very hyperactive!")
    		target:set_physics_override(3,nil,nil)
    	end,
    	on_cancel = function(status, target)
    		scrolls.chat_if_player(target, "You regain normal speed")
    		target:set_physics_override(1,nil,nil)
    	end
    }
})


scrolls.register_spell("scrolls:levitation", {
	description = "Levitation",
	scroll_image = "scroll_of_levitation.png",
	particle_image =  "scroll_status_levitation.png",
	groups = {gravity=1},

	status_duration = 15,
    status = {
        description = "Levitating",
        on_start = function(status, target)
			local name = target:get_player_name()
            minetest.chat_send_player(name, "You feel very light, as if you were floating!")

            local privs = minetest.get_player_privs(name)
            privs.fly = true
            minetest.set_player_privs(name, privs)

            -- set gravity to 10% of its original value
            target:set_physics_override({ gravity = 0.1 })
        end,
        on_cancel = function(status, target)
            local name = target:get_player_name()
            minetest.chat_send_player(name, "You no longer feel light")
            local privs = minetest.get_player_privs(name)
            privs.fly = nil
            minetest.set_player_privs(name, privs)

            -- set gravity to its original value
            target:set_physics_override({ gravity = 1 })
        end
    }
})


scrolls.register_spell("scrolls:poisoning", {
	description = "Poisoning",
	scroll_image = "scroll_of_poisoning.png",
	particle_image =  "scroll_status_poisoning.png",
	groups = {health=1},

	status_duration = 15,
    status = {
        description = "Poisoned",
        on_start = function(status, target)
            scrolls.chat_if_player(target, "You have been poisoned!")
        end,
        on_cancel = function(status, target)
            scrolls.chat_if_player(target, "The poison has washed away")
        end,
		repeaters = {{
			interval = 2,
			on_activate = function(target)
				target:set_hp(target:get_hp()-1)
			end
		}}
    }
})

scrolls.register_spell("scrolls:regeneration", {
	description = "Regeneration",
	scroll_image = "scroll_of_healing.png",
	particle_image =  "heart.png",
	groups = {health=1},

	status_duration = 15,
    status = {
        description = "Regeneration",
        on_start = function(status, target)
            scrolls.chat_if_player(target, "You feel a healing aura")
        end,
        on_cancel = function(status, target)
            scrolls.chat_if_player(target, "You no longer feel a healing aura")
        end,
		repeaters = {{
			interval = 2,
			on_activate = function(target)
				target:set_hp(target:get_hp()+1)
			end
		}}
    }
})

scrolls.register_spell("scrolls:breathing", {
	description = "Breathing",
	scroll_image = "scroll_of_breathing.png",
	particle_image =  "bubble.png",
	groups = {health=1},

	status_duration = 30,
    status = {
        description = "Water breathing",
		repeaters = {{
			interval = 2,
			on_activate = function(target)
				target:set_breath(target:get_breath()+2)
			end
		}}
    }
})



scrolls.register_spell("scrolls:confusion", {
	description = "Confusion",
	scroll_image = "scroll_of_confusion.png",
	particle_image =  "scroll_status_confusion.png",

	status_duration = 1,
    status = {
        description = "Confusion",
        on_start = function(status, target)
            scrolls.chat_if_player(target, "You feel disoriented!")
        end,
        on_cancel = function(status, target)
            scrolls.chat_if_player(target, "You no longer feel disoriented")
        end,
		repeaters = {{
			interval = 1,
			on_activate = function(target)
				local rnd_yaw = math.random() * math.pi * 2
				target:set_look_yaw(rnd_yaw)
			end
		}}
    }
})

scrolls.register_spell("scrolls:immolation", {
	description = "immolation",
	scroll_image = "scroll_of_immolation.png",
	particle_image =  "default_furnace_fire_fg.png",
	groups = { fire = 1 },

	on_self_cast = function(caster, pointed_thing)
		local s = caster:getpos()
		local p = caster:get_look_dir()
		local vec = {x=s.x-p.x, y=s.y-p.y, z=s.z-p.z}
		caster:punch(caster, 1.0,  {
			full_punch_interval=1.0,
			damage_groups = {fleshy=4},
		}, vec)
		local pos = caster:getpos()
		for dx=0,1 do
			for dy=0,1 do
				for dz=0,1 do
					local p = {x=pos.x+dx, y=pos.y+dy, z=pos.z+dz}
					local n = minetest.env:get_node(p).name
					if (n == "air") then
							minetest.env:set_node(p, {name="fire:basic_flame"})
					end
				end
			end
		end
		return true
	end,

	on_cast = function(caster, pointed_thing)
		local pos
		if pointed_thing.type == "node" then
			pos = pointed_thing.under

		elseif pointed_thing.type == "object" and pointed_thing.ref.getpos then
			local target = pointed_thing.ref
			pos = target:getpos()

			if target.punch and caster.get_look_dir then
				local dir = caster:get_look_dir()
				local vec = {x=pos.x-dir.x, y=pos.y-dir.y, z=pos.z-dir.z}
				target:punch(caster, 1.0,  {
					full_punch_interval=1.0,
					damage_groups = {fleshy=4},
				}, vec)
			end
		else
			return false
		end

		for dx=-1,1 do
			for dy=-2,1 do
				for dz=-1,1 do
					local p = {x=pos.x+dx, y=pos.y+dy, z=pos.z+dz}
					local n = minetest.env:get_node(p).name
					if (n == "air") then
							minetest.env:set_node(p, {name="fire:basic_flame"})
					end
				end
			end
		end
		return true
	end
})

scrolls.register_spell("scrolls:irrigation", {
	description = "Irrigation",
	scroll_image = "scroll_of_irrigation.png",
	particle_image =  minetest.inventorycube("default_river_water.png"),
	liquids_pointable = true,

	on_self_cast = function(caster, pointed_thing)
		local pos = caster:getpos()
		pos.y = pos.y + 1
		for dx=-1,1 do
			for dy=-2,1 do
				for dz=-1,1 do
					local p = {x=pos.x+dx, y=pos.y+dy, z=pos.z+dz}
					local n = minetest.env:get_node(p).name
					if (n == "air") then
							minetest.env:set_node(p, {name="scrolls:temporary_water", param2 = 10})
					end
				end
			end
		end
		return true
	end,

	on_cast = function(caster, pointed_thing)
		local pos = (pointed_thing.type == "node" and pointed_thing.under)
			or (pointed_thing.type == "object" and pointed_thing.ref.getpos and pointed_thing.ref:getpos())
		if pos then
			for dx=-1,1 do
				for dy=-2,1 do
					for dz=-1,1 do
						local p = {x=pos.x+dx, y=pos.y+dy, z=pos.z+dz}
						local n = minetest.env:get_node(p).name
						if (n == "air") then
								minetest.env:set_node(p, {name="scrolls:temporary_water", param2 = 10})
						end
					end
				end
			end
			return true
		else
			return false
		end
	end
})


scrolls.register_spell("scrolls:random", {
	description = "Chaos",
	scroll_image = "scroll_of_chaos.png",

    on_self_cast = function(caster, pointed_thing)
        local random_spell
        -- pick a random spell with self_cast
        while not random_spell do
            local spell_position = math.random(1, scrolls.registered_spells_count)
            local index = 1
            for name, spell in pairs(scrolls.registered_spells) do
                if index == spell_position then
                    if spell.on_self_cast then
                        random_spell = spell
                    end
                    break
                end
				index = index + 1
            end
        end
        return random_spell.on_self_cast(caster, pointed_thing)
    end,

    on_cast = function(caster, pointed_thing)
        local random_spell
        -- pick a random spell with cast
        while not random_spell do
            local spell_position = math.random(1, scrolls.registered_spells_count)
            local index = 1
            for name, spell in pairs(scrolls.registered_spells) do
                if index == spell_position then
                    if spell.on_cast then
                        random_spell = spell
                    end
                    break
                end
				index = index + 1
            end
        end
        return random_spell.on_cast(caster, pointed_thing)
    end,
})
