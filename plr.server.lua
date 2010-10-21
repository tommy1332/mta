--[[ Spielerfunktionen (plr)

Beschreibung:
	Alles was man für Spieler so braucht. <.<


Funktionen:
	setSpawn( <Account>, <X>, <Y>, <Z>, <Dimension> ) - Setzt die Spawnposition eines Spielers. (Wird in der DB gespeichert.)
	bool respawn( <Account> ) - Spawnt einen Spieler.
	
	table finalizeSpawn ( <string/table> ) - Wenn eine Spawnvariable über einen Namen definiert ist, wird diese zu einem Spawnpunkt expandiert. Sollte erst aufgerufen werden, wenn die Koordinaten auch tatsächlich gebraucht werden!
	loadSpawns ( ) - spawns.xml einlesen. -> Für eine Liste von vordefinierten, über Namen erreichbaren Spawns.
	saveSpawns ( ) - Alle Spawns speichern.

]]

plr =
{
	teamActive = createTeam('Active', 255, 255, 255),
	teamInactive = createTeam('Inactive', 128, 128, 128),
	spawns = {},
	savespawns = false,
	defaultspawn = { x = 0.0, y = 0.0, z = 5.0, rot = nil, world = 0 }
}


function plr.onStart()
	log('plr.onStart')
	plr.loadSpawns()
	--plr.createSpawn('fleischberg', { x=-50, y=-271, z=7, rot=nil, world=0 })
end

function plr.onStop()
	log('plr.onStop')
	if plr.savespawns then
		plr.saveSpawns()
	end
end

base.addModule('plr', plr.onStart, plr.onStop, 'acc')


function plr.setSkin(AcID, Skin)
	-- TODO: SkinID prüfen. Aber bitte eine eigene Funktion dafür.
	acc.setData(AcID, 'skin', Skin)
	local plr = acc.getPlayer(AcID)
	if plr then
		-- TODO: Spieler können auch einen temporären Skin für Jobs oder so haben. :o
		setPedSkin(plr, Skin)
	end
end


function plr.getSkin(AcID)
	--return getPedSkin(plr, Skin) -- TODO: So nicht. <.<
	local skin = acc.getData(AcID, 'skin')
	if not skin then
		skin = 42
	end
	return skin
end


function plr.setSpawn(AciD, Pos)
	acc.setData(AcID, 'spawn', Pos)
end


function plr.getSpawn(AcID)
	local data = acc.getData(AcID, 'spawn')
	if not data then
		data = plr.defaultspawn
	end
	return data
end


addEvent('plr.onRespawn', false)
function plr.respawn(AcID)
	local p = acc.getPlayer(AcID)
	killPed(p)
	local pos = plr.finalizeSpawn(plr.getSpawn(AcID))
	setPlayerTeam(p, plr.teamActive)
	spawnPlayer(p, pos.x, pos.y, pos.z, math.random(1, 360), plr.getSkin(AcID), 0, pos.dim)
	setCameraTarget(p, p)
	setCameraInterior(p, getElementInterior(p))
	fadeCamera(p, true)
	showPlayerHudComponent(p, "radar", false)
	showPlayerHudComponent(p, "vehicle_name", false)
	showPlayerHudComponent(p, "area_name", false)
	showPlayerHudComponent(p, "clock", false)
	showPlayerHudComponent(p, "money", false)
	showPlayerHudComponent(p, "ammo", false)
	showPlayerHudComponent(p, "armour", false)
	showPlayerHudComponent(p, "health", false)
	showPlayerHudComponent(p, "weapon", false)
	showPlayerHudComponent(p, "breath", false)
	triggerEvent('plr.onRespawn', p)
	return true
end


function plr.onJoin(Plr)
	if type(Plr) ~= 'userdata' then
		Plr = source
	end
	setPlayerTeam(Plr, plr.teamInactive)
	fadeCamera(Plr, false) -- TODO: Set Inactive oder so sollte das regeln. :o
end
addEventHandler('onPlayerJoin', g_Root, plr.onJoin)


function plr.onWasted(Plr)
	if type(Plr) ~= 'userdata' then
		Plr = source
	end
	local acid = acc.findByPlayer(Plr)
	if not acid then return end
	setTimer(plr.respawn, 5000, 1, acid)
end
addEventHandler('onPlayerWasted', g_Root, plr.onWasted)


---- Spawns laden und speichern ----


function plr.finalizeSpawn(Spawn)
	if type(Spawn) ~= 'table' then
		Spawn = plr.spawns[tostring(Spawn)]
		if not Spawn then
			Spawn = plr.defaultspawn
		end
	end
	
	if Spawn.rot == nil then
		Spawn.rot = math.random(1,360)
	end
	
	return Spawn
end


function plr.loadSpawns()
	local node = xmlLoadFile('spawns.xml')
	if not node then return end

	local idx = 0
	local subnode = nil
	repeat
		subnode = xmlFindChild(node, 'spawn', idx)
		if not subnode then break end
		idx = idx + 1

		local r = xmlNodeGetAttribute(subnode, 'rot')
		if not r then
			r = nil
		else
			r = tonumber(r)
		end
		
		local w = xmlNodeGetAttribute(subnode, 'world')
		if not w then
			w = 0
		else
			w = tonumber(w)
		end
		
		plr.spawns[tostring(xmlNodeGetAttribute(subnode, 'id'))] =
		{
			x = tonumber(xmlNodeGetAttribute(subnode, 'x')),
			y = tonumber(xmlNodeGetAttribute(subnode, 'y')),
			z = tonumber(xmlNodeGetAttribute(subnode, 'z')),
			rot = r,
			world = w,
		}
		
	until false
	xmlUnloadFile(node)
end


function plr.saveSpawns()
	local node = xmlCreateFile(':test/spawns.xml', 'spawns')
	if not node then return end
	
	local subnode = nil
	for k,v in pairs(plr.spawns) do
		subnode = xmlCreateChild(node, 'spawn')
		if not subnode then break end
		
		xmlNodeSetAttribute(subnode, 'id', k)
		xmlNodeSetAttribute(subnode, 'x', v.x)
		xmlNodeSetAttribute(subnode, 'y', v.y)
		xmlNodeSetAttribute(subnode, 'z', v.z)
		
		if v.rot then
			xmlNodeSetAttribute(subnode, 'rot', v.rot)
		end
		
		if v.world ~= 0 then
			xmlNodeSetAttribute(subnode, 'world', v.world)
		end
	end

	xmlSaveFile(node)
	xmlUnloadFile(node)
end


function plr.createSpawn(Name, Pos)
	plr.spawns[Name] = Pos
	plr.savespawns = true
end

function plr.deleteSpawn(Name)
	if not plr.spawns[Name] then return end
	plr.spawns[Name] = nil
	plr.savespawns = true
end