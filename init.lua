minetest.register_node("killer:killer", {
		tiles = {"killer_killer.png"},
		groups = {crumbly=1},
		description = "[!] Killer [!]",
		light_source = 14,
		drop = { max_items = 0, items = {} }
})

minetest.register_node("killer:antikiller", {
	tiles = {"killer_antikiller.png"},
	groups = {crumbly=1},
	description = "Antikiller",
})

minetest.register_node("killer:killall", {
	tiles = {"killer_killall.png"},
	groups = {crumbly=1},
	description = "Killall (Kill all virus blocks)",
	on_punch = function(pos, node, player, itemstack, pointed_thing)
		if not killall then
			killall = true
			minetest.chat_send_player(player:get_player_name(), "Killall on")
		else
			killall = false
			minetest.chat_send_player(player:get_player_name(), "Killall off")
		end
	end,
	after_destruct = function(pos, oldnode)
		killall = false
	end,
})

minetest.register_node("killer:protector", {
	tiles = {"killer_protector.png"},
	groups = {crumbly=1},
	description = "Protector (Range:5)",
})

minetest.register_node("killer:novirusblock", {
	tiles = {"killer_novirusblock.png"},
	groups = {cracky=1},
	description = "Virus Protection Block",
})

killall = false

local contain = function(t, s)
	for k, v in ipairs(t) do
		if v == s then
			return true
		else
			return false
		end
	end
end

minetest.register_abm({
	nodenames = {"killer:protector"},
	chance = 1,
	interval = 5,
	action = function(pos)
		for i=0, 5, 1 do
			local node_pos
			node_pos = minetest.find_node_near(pos, 5, {"killer:killer"})
			if node_pos then
				minetest.remove_node(node_pos)
			else
				break
			end
		end
	end,
})

minetest.register_abm({
	nodenames = {"killer:antikiller"},
	chance = 1,
	interval = 1,
	action = function(pos)
		check_for_killer = function(pos)
			local is
			is = false
			for _, obj in pairs(minetest.get_objects_inside_radius(pos,2)) do
				if obj:is_player() then
					obj:set_hp(math.min(math.max(obj:get_hp()-5,0),math.ceil(obj:get_hp()/2)))
				end
			end
			for i=0, 5, 1 do
				local node_pos
				node_pos = minetest.find_node_near(pos, 2, {"killer:killer"})
				if node_pos then
					minetest.set_node(node_pos, {name="killer:antikiller"})
					is = true
				end
			end
			return is
		end
		if not check_for_killer(pos) then
			minetest.remove_node(pos)
		end
	end,
})

minetest.register_abm({
	nodenames = {"killer:killer"},
	chance = 1,
	interval = 5,
	action = function(pos)
		if killall then
			minetest.remove_node(pos)
		end
		if math.random(1, 5) == 1 then
			local p = {
				x=pos.x+math.random(-1, 1),
				y=pos.y+math.random(-1, 1),
				z=pos.z+math.random(-1, 1),
			}
		for _, obj in pairs(minetest.get_objects_inside_radius(pos,2)) do
			if obj:is_player() then
				obj:set_hp(obj:get_hp()-3)
			end
		end
		if minetest.get_node(p).name ~= "killer:killer" and minetest.get_node(p).name ~= "killer:novirusblock" then
				minetest.set_node(p, {name="killer:killer"})
			end
		end
	end,
})

minetest.register_craft({
	output="killer:killer 1",
	recipe={
		{"default:gold_ingot", "default:steel_ingot", "default:gold_ingot"},
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:gold_ingot", "default:steel_ingot", "default:gold_ingot"},
	},
})

minetest.register_craft({
	output="killer:antikiller 1",
	recipe = {
		{"", "default:dirt", ""},
		{"default:dirt", "", "default:dirt"},
		{"", "default:dirt", ""},
		},
})

minetest.register_craft({
	output="killer:protector 2",
	recipe = {
		{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
		{"default:cobble", "", "default:cobble"},
		{"default:steel_ingot", "default:cobble", "default:steel_ingot"},
		},
})

minetest.register_craft({
	output="killer:novirusblock 2",
	recipe = {
		{"default:stone", "default:obsidian", "default:stone"},
		{"", "", ""},
		{"", "", ""},
	},
})
