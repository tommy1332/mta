--[[ Tor System (gates)

	Beschreibung:
		Das Tor System zum laden von Toren aus einer XML Datei.
		
	Funktionen:
		gates.loadGates()
		gates.unloadGates()
		
	Kommandos:
		/move
		
]]

gates = 
{
	data = {}
}

function gates.onStart()
	log('gates.onStart')
	gates.loadGates()
end

function gates.onStop()
	log('gates.onStop')
	gates.unloadGates()
end

base.addModule('gates', gates.onStart, gates.onStop, 'db')

function gates.loadGates()
	log('loading gates')
	local node = xmlLoadFile('gates.xml')
	if not node then return end

	local idx = 0
	local subnode = nil
	repeat
		subnode = xmlFindChild(node, 'gate', idx)
		if not subnode then break end
		idx = idx + 1
		
		local model = tonumber(xmlNodeGetAttribute(subnode, 'model'))
		local x = tonumber(xmlNodeGetAttribute(subnode, 'x'))
		local y = tonumber(xmlNodeGetAttribute(subnode, 'y'))
		local z = tonumber(xmlNodeGetAttribute(subnode, 'z'))
		local rx = tonumber(xmlNodeGetAttribute(subnode, 'rx'))
		local ry = tonumber(xmlNodeGetAttribute(subnode, 'ry'))
		local rz = tonumber(xmlNodeGetAttribute(subnode, 'rz'))
		local world = tonumber(xmlNodeGetAttribute(subnode, 'world'))
		local range = tonumber(xmlNodeGetAttribute(subnode, 'range'))
		-- Optionale Angaben
		local zx = tonumber(xmlNodeGetAttribute(subnode, 'zx'))
		local zy = tonumber(xmlNodeGetAttribute(subnode, 'zy'))
		local zz = tonumber(xmlNodeGetAttribute(subnode, 'zz'))
		local zrx = tonumber(xmlNodeGetAttribute(subnode, 'zrx'))
		local zry = tonumber(xmlNodeGetAttribute(subnode, 'zry'))
		local zrz = tonumber(xmlNodeGetAttribute(subnode, 'zrz'))
		local movetime = tonumber(xmlNodeGetAttribute(subnode, 'movetime'))
		
		-- Setze auf Default Werte
		if(zx == nil) then
			zx = x
			zy = y
			zz = z-10
			zrx = rx
			zry = ry
			zrz = rz
		end
		
		if(movetime == nil) then
			movetime = 5000
		end
		
		local obj = createObject(model, x, y, z, rx, ry, rz)
		
		gates.data[idx] = 
		{
			model = model,
			x = x,
			y = y,
			z = z,
			rx = rx,
			ry = ry,
			rz = rz,
			zx = zx,
			zy = zy,
			zz = zz,
			zrx = zrx,
			zry = zry,
			zrz = zrz,
			movetime = movetime,
			world = world,
			obj = obj,
			range = range,
			open = false
		}
	
	until false
	xmlUnloadFile(node)
	log('gates loaded')
end

function gates.unloadGates()
	for i = 1, #gates.data, 1 do
		destroyElement(gates.data[i].obj)
		gates.data[i] = nil
	end
	log('gates unloaded')
end

function gates.commandMove(playerSource)
	local x, y, z = getElementPosition ( playerSource )
	for i = 1, #gates.data, 1 do
		if(gates.data[i].range>getDistanceBetweenPoints3D(x, y, z, gates.data[i].x, gates.data[i].y, gates.data[i].z)) then
			if(gates.data[i].open == false) then
				moveObject(gates.data[i].obj, gates.data[i].movetime, gates.data[i].zx, gates.data[i].zy, gates.data[i].zz, gates.data[i].zrx, gates.data[i].zry, gates.data[i].zrz)
				gates.data[i].open = true
			else
				moveObject(gates.data[i].obj, gates.data[i].movetime, gates.data[i].x, gates.data[i].y, gates.data[i].z, gates.data[i].rx, gates.data[i].ry, gates.data[i].rz)
				gates.data[i].open = false
			end
		end
	end
end

addCommandHandler ( "move", gates.commandMove )
