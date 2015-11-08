



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
    },

	treasure = {
		rarity = 0.07,
		preciousness = 5,
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
    },

	treasure = {
		rarity = 0.02,
		preciousness = 7,
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
    },

	treasure = {
		rarity = 0.1,
		preciousness = 2,
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
    },

	treasure = {
		rarity = 0.1,
		preciousness = 4,
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
    },

	treasure = {
		rarity = 0.09,
		preciousness = 4,
	}
})



scrolls.register_spell("scrolls:confusion", {
	description = "Confusion",
	scroll_image = "scroll_of_confusion.png",
	particle_image =  "scroll_status_confusion.png",

	status_duration = 15,
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
    },

	treasure = {
		rarity = 0.07,
		preciousness = 2.5,
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
		scrolls.replace_air_in_radius(pos, 1, {name="fire:basic_flame"})
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
		scrolls.replace_air_in_radius(pos, 1, {name="fire:basic_flame"})
		return true
	end,

	treasure = {
		rarity = 0.03,
		preciousness = 8,
	}
})

scrolls.register_spell("scrolls:frostbite", {
	description = "immolation",
	--scroll_image = "scroll_of_frostbite.png",
	particle_image =  minetest.inventorycube("default_ice.png"),
	groups = { ice = 1 },

	on_self_cast = function(caster, pointed_thing)
		local s = caster:getpos()
		local p = caster:get_look_dir()
		local vec = {x=s.x-p.x, y=s.y-p.y, z=s.z-p.z}
		caster:punch(caster, 1.0,  {
			full_punch_interval=1.0,
			damage_groups = {fleshy=4},
		}, vec)
		local pos = caster:getpos()
		scrolls.replace_air_in_radius(pos, 1, {name="scrolls:temporary_ice", param2=10})
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
		scrolls.replace_air_in_radius(pos, 1, {name="scrolls:temporary_ice", param2=10})
		return true
	end,

	treasure = {
		rarity = 0.04,
		preciousness = 8,
	}
})

scrolls.register_spell("scrolls:irrigation", {
	description = "Irrigation",
	scroll_image = "scroll_of_irrigation.png",
	particle_image =  minetest.inventorycube("default_river_water.png"),
	liquids_pointable = true,

	on_self_cast = function(caster, pointed_thing)
		local pos = caster:getpos()
		pos.y = pos.y + 1
		scrolls.replace_air_in_radius(pos, 1, {name="scrolls:temporary_water", param2 = 10})
		return true
	end,

	on_cast = function(caster, pointed_thing)
		local pos = (pointed_thing.type == "node" and pointed_thing.under)
			or (pointed_thing.type == "object" and pointed_thing.ref.getpos and pointed_thing.ref:getpos())
		if pos then
			scrolls.replace_air_in_radius(pos, 1, {name="scrolls:temporary_water", param2 = 10})
			return true
		else
			return false
		end
	end,

	treasure = {
		rarity = 0.03,
		preciousness = 7,
	}
})


scrolls.register_spell("scrolls:teleportation", {
	description = "Teleportation",
	scroll_image = "scroll_of_teleportation.png",
	groups = {speed=1},

	-- Teleport to a random location on self cast
	on_self_cast = function(caster, pointed_thing)
		local pos = caster:getpos()

		-- Use the center of the room, as it's more likely there'll be space there
		if dungeon_rooms then
			local room = dungeon_rooms.room_at(pos)
			pos.y = room.maxp.y - dungeon_rooms.room_area.y/2
		end

		local range = 40
		-- see if you can find a random position in 15 tries
		for tries=1, 15 do
			local dst = {
				x = pos.x + math.random(-range, range),
				y=pos.y,
				z = pos.z + math.random(-range, range)
			}

			local node = minetest.get_node(dst)
			if node.name == "air" then
				if minetest.get_node({x=dst.x, y=dst.y+1, z=dst.z}).name == "air" then
					minetest.sound_play( {name="scrolls_teleport1", gain=1}, {pos=src, max_hear_distance=12})
					caster:setpos(dst)
					minetest.after(0.5, function(dest) minetest.sound_play( {name="scrolls_teleport2", gain=1}, {pos=dest, max_hear_distance=12}) end, dest)
					return true
				end
			end
		end
		return false
	end,

	-- teleport to the pointed thing, or swap positions with it if it's an entity
	on_cast = function(caster, pointed_thing)
		local pos
		if pointed_thing.type == "object" and pointed_thing.ref.getpos then
			pos = pointed_thing.ref:getpos()
		else
			pos = pointed_thing.above
		end
		if not pos then
			return false
		end
		local src = caster:getpos()
		local dest = {x=pos.x, y=math.ceil(pos.y)-0.5, z=pos.z}
		local over = {x=dest.x, y=dest.y+1, z=dest.z}
		local destnode = minetest.get_node({x=dest.x, y=math.ceil(dest.y), z=dest.z})
		local overnode = minetest.get_node({x=over.x, y=math.ceil(over.y), z=over.z})

		-- prevent the player's head to spawn in a walkable node if the player clicked on the lower side of a node
		-- NOTE: This piece of code must be updated as soon the collision boxes of players become configurable
		local def = minetest.registered_nodes[overnode.name]
		if def and def.walkable then
			dest.y = dest.y - 1
		end

		-- The destination must be collision free
		destnode = minetest.get_node({x=dest.x, y=math.ceil(dest.y), z=dest.z})
		def = minetest.registered_nodes[destnode.name]
		if def and def.walkable then
			return false
		end

		minetest.sound_play( {name="scrolls_teleport1", gain=1}, {pos=src, max_hear_distance=12})
		caster:setpos(dest)
		minetest.after(0.5, function(dest) minetest.sound_play( {name="scrolls_teleport2", gain=1}, {pos=dest, max_hear_distance=12}) end, dest)

		-- switch positions with pointed thing if object
		if pointed_thing.type == "object" and pointed_thing.ref.setpos then
			pointed_thing.ref:setpos(src)
		end

		return true
	end,

	treasure = {
		rarity = 0.07,
		preciousness = 6,
	}
})

scrolls.register_spell("scrolls:invisibility", {
	description = "Invisibility",
	--scroll_image = "scroll_of_invisibility.png",

	status_duration = 15,
    status = {
        on_start = function(status, target)
            scrolls.chat_if_player(target, "You became transparent ")
			-- TODO: this doesn't work, how to get current visual property?
			status.visual = target.visual
			target:set_properties({visual="air"})
			local nametag = target:get_nametag_attributes()
			nametag.color.a = 0
			target:set_nametag_attributes(nametag)
        end,
        on_cancel = function(status, target)
            scrolls.chat_if_player(target, "You regain visibility")
			target:set_properties({visual = status.visual or "mesh"})
			local nametag = target:get_nametag_attributes()
			nametag.color.a = 255
			target:set_nametag_attributes(nametag)
        end,
    },

	treasure = {
		rarity = 0.02,
		preciousness = 8,
	}
})

scrolls.register_spell("scrolls:fireball", {
	description = "Fireball",
	scroll_image = "scroll_of_fireball.png",

	on_cast = function(caster, pointed_thing)
		local pointed_pos
		if not pointed_thing then
			if caster.get_look_pitch and caster.get_look_yaw then
				local pitch = caster:get_look_pitch()
				local yaw = caster:get_look_yaw()
				pointed_pos = {x = cos(yaw), y = sin(pitch), z = sin(-yaw)}
			else
				return false
			end
		elseif pointed_thing.type == "object" and pointed_thing.ref.getpos then
			pointed_pos = pointed_thing.ref:getpos()
		else
			pointed_pos = pointed_thing.above
		end
		if not pointed_pos then
			return false
		end
		local pos = caster:getpos()
		pos.y  = pos.y + 1
		local direction = vector.direction(pos, pointed_pos)

		scrolls.shoot_projectile(pos, {
			direction = direction,
			speed = 6,

			hit_entity = function(self, player)
				player:punch(self.object, 1.0,  {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 8},
				}, 0)
				local pos = player:getpos()
				scrolls.replace_air_in_radius(pos, 1, {name="scrolls:temporary_flame", param2=1}, 2)
			end,

			hit_node = function(self, pos, node)
				scrolls.replace_air_in_radius(pos, 1, {name="scrolls:temporary_flame", param2=2}, 2)
			end
		})
		return true
	end,

	treasure = {
		rarity = 0.02,
		preciousness = 0.5,
	}
})


scrolls.register_spell("scrolls:icebolt", {
	description = "Icebold",
	scroll_image = "scroll_of_icebolt.png",

	on_cast = function(caster, pointed_thing)
		local pointed_pos
		if not pointed_thing then
			if caster.get_look_pitch and caster.get_look_yaw then
				local pitch = caster:get_look_pitch()
				local yaw = caster:get_look_yaw()
				pointed_pos = {x = cos(yaw), y = sin(pitch), z = sin(-yaw)}
			else
				return false
			end
		elseif pointed_thing.type == "object" and pointed_thing.ref.getpos then
			pointed_pos = pointed_thing.ref:getpos()
		else
			pointed_pos = pointed_thing.above
		end
		if not pointed_pos then
			return false
		end
		local pos = caster:getpos()
		pos.y  = pos.y + 1
		local direction = vector.direction(pos, pointed_pos)

		scrolls.shoot_projectile(pos, {
			direction = direction,
			speed = 6,
			properties = {
				textures = {"scrolls_icebolt.png"},
			},

			hit_entity = function(self, player)
				print("OUCH!!!!")
				player:punch(self.object, 1.0,  {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 8},
				}, 0)
				local pos = player:getpos()
				scrolls.replace_air_in_radius(pos, 1, {name="scrolls:temporary_ice", param2=5}, 2)
			end,

			hit_node = function(self, pos, node)
				scrolls.replace_air_in_radius(pos, 1, {name="scrolls:temporary_ice", param2=5}, 2)
			end
		})
		return true
	end,

	treasure = {
		rarity = 0.02,
		preciousness = 0.5,
	}
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

	treasure = {
		rarity = 0.08,
		preciousness = 2,
	}
})
