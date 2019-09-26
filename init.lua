-- ENERGY LIB WRITTEN BY Andrey01.


-- THE UNITS CONCERNING TO THE ENERGY.

-- The energy amount is throughout measured in *kilojoules* (kj).
-- The velocity of energy emitting/energizement measured in *kilojoules per a second* (kj/s).


--Initial heat emitting values of just put-in world nodes (first field) and velocities of their emitting & energizing (second field).

heat = {}
heat.default_nodes_heat_data = {
	["default:lava_source"] = {40, 0.003},
	["default:lava_flowing"] = {50, 0.010},
	["default:water_flowing"] = {1.5, 0.0002},
	["default:furnace_active"] = {25, 0.05},
	["default:meselamp"] = {5, 0.4},
	["default:mese_post_light"] = {2.5, 0.8},
	["default:torch"] = {13, 0.0008},
	["fire:basic_flame"] = {22, 2},
	["fire:permanent_flame"] = {22, 2},
	["default:mese"] = {3, 0.2},
	["default:stone"] = {0, 0.0005},
	["default:cobble"] = {0, 0.0013},
	["default:stonebrick"] = {0, 0.001},
	["default:stone_block"] = {0, 0.0002},
	["default:mossycobble"] = {0, 0.001},
	["default:desert_stone"] = {0, 0.0012},
	["default:desert_stonebrick"] = {0, 0.0007},
	["default:desert_stone_block"] = {0, 0.001},
	["default:dirt"] = {0, 0.0002},
	["default:dirt_with_grass"] = {0, 0.0005},
	["air"] = {0, 0.5}
}

-- Runs node defs of all nodes listed in default_nodes_heat_data and overrides them with new params 'init_heat_emit' and 'heat_vel'.
for name, def in pairs(minetest.registered_nodes) do
	if heat.default_nodes_heat_data[name] then
		def.init_heat_emit = heat.default_nodes_heat_data[name][1]
		def.heat_vel = heat.default_nodes_heat_data[name][2]
	end
		
	def.on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("cur_heat_amount", (heat.default_nodes_heat_data[name] or 0) or heat.default_nodes_heat_data[name][1])
	end
	minetest.register_node(":"..name, def)
	
end

--[[A node that wanted to be energized is finding out neighbour nodes with a heat value > 0 around itself in radius 1 node.
*e_node is energizing node.
*e_nodepos is position of energizing node.]]
heat.find_nodes_with_heat = function (e_node, e_nodepos)
	local surround_nodes = minetest.find_nodes_with_meta({x=e_nodepos.x-1, y=e_nodepos.y-1, z=e_nodepos.z-1}, {x=e_nodepos.x+1, y=e_nodepos.y+1, z=e_nodepos.z+1})
	local surround_nodes_with_energy = {}
	for i, pos in pairs(surround_nodes) do
		-- *t_node is transmitting an energy node.
		local t_node = minetest.get_node(pos)
		local meta = minetest.get_meta()
		local name = t_node.name
		if minetest.registered_node[name].heat_vel and meta:get_string("cur_heat_amount") > 0 then
			surround_nodes_with_energy[i] = pos
		end
	end
	return surround_nodes_with_energy
end

-- Increases a heat value of *e_node and takes away it from *t_node. Amount of transmitted energy depends on heat energizement velocity of *e_node.
heat.energize = function (e_node, e_nodepos)
	local name = e_node.name
	local heat_vel = minetest.registered_nodes[name].heat_vel
	if not heat_vel then
		return
	end
	
	local surround_nodes = heat.find_nodes_with_heat(e_node, e_nodepos)
	for i, pos in pairs(surround_nodes) do
		local node = minetest.get_node(pos)
		local t_node_meta, e_node_meta = minetest.get_meta(pos), minetest.get_meta(e_nodepos)
		local t_node_heat, e_node_heat = t_node_meta:get_string("cur_heat_amount"), e_node_meta:get_string("cur_heat_amount")
		local rand_energy_trans = math.random(t_node_heat/2, t_node_heat)
		t_node_meta:set_string("cur_heat_amount", t_node_heat-rand_energy_trans)
		e_node_meta:set_string("cur_heat_amount", e_node_heat+rand_energy_trans)
	end
end
	

