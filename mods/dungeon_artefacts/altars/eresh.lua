local world_path = minetest.get_worldpath()
local org_file = world_path .. "/eresh_spawns"
local file = world_path .. "/eresh_spawns"
local bkwd = false

local spawns = {}

function read_spawns()
	local spawns = beds.spawn
	local input = io.open(file, "r")
	if input and not bkwd then
		repeat
			local x = input:read("*n")
			if x == nil then
            			break
            		end
			local y = input:read("*n")
			local z = input:read("*n")
			local name = input:read("*l")
			spawns[name:sub(2)] = {x = x, y = y, z = z}
		until input:read(0) == nil
		io.close(input)
	elseif input and bkwd then
		beds.spawn = minetest.deserialize(input:read("*all"))
		input:close()
		beds.save_spawns()
		os.rename(file, file .. ".backup")
		file = org_file
	else
		spawns = {}
	end
end

function save_spawns()
	local output = io.open(org_file, "w")
	for i, v in pairs(spawns) do
		output:write(v.x.." "..v.y.." "..v.z.." "..i.."\n")
	end
	io.close(output)
end

minetest.register_on_respawnplayer(function(player)
	if not spawns then return false end
	local name = player:get_player_name()
	local spawn = spawns[name]
	if spawn then
	   player:setpos(spawn)
	   minetest.chat_send_player(name, "Eresh favors you!")
	   return true
	end
end)

minetest.register_on_mapgen_init(function(mapgen_params)
    read_spawns()
end)

minetest.register_on_shutdown(function()
    save_spawns()
end)

altars.register_god("eresh", {
       title = "Eresh, goddess of Life and Death",
       texture = "altars_eresh.png",
       particle = "altars_eresh_particle.png",
       on_pray = function(pos, node, player, itemstack)
          local name = player:get_player_name()
          spawns[name] = player:getpos()
          minetest.chat_send_player(name, "Eresh listened to your prayers")
       	  save_spawns() -- not sure if it's a good idea to save every time
       end
})
