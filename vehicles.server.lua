--[[ Vehikel System (vehicles)

	Beschreibung:
		Das Vehikel System
		
	Funktionen:
		vehicles.initDB()
		vehicles.updateDB(vehid, Key, Value)
		vehicles.loadCars()
		vehicles.unloadCars()
		vehicles.commandVeh(playerSource, commandName, col1)
		vehicles.commandLock(playerSource)
		vehicles.commandTaxi(playerSource)
		vehicles.configurePlayer(thePlayer, seat, jacked)
		vehicles.unconfigurePlayer(thePlayer, seat, jacked)
		vehicles.keyHandling(player, key, keyState)
		vehicles.damagePlayer(loss)
		vehicles.tryEnter(player, seat, jacked)
		vehicles.tryExit(player, seat, jacked)
		
	Kommandos:
		/veh [modelid]  < Kommando um ein beliebiges Fahrzeug zu erstellen
		/lock           < Kommando um ein Fahrzeug auf- und abzuschließen
		/taxi           < Kommando um die Taxi Lichter ein- und abzustellen
		
	Tasten Bindings:
		'l' 'down'      < Taste zum ein- und ausschalten des Lichtes
		'm' 'down'      < Taste zum ein- und ausschalten des Motors
		'space' 'down'  < Taste zum Anziehen der Handbremse
]]

rootElement = getRootElement()

vehicles = 
{
	data = {},
	settings = {}
}

function vehicles.onStart()
	log('vehicles.onStart')
	vehicles.initDB()
	vehicles.loadCars()
end

function vehicles.onStop()
	log('vehicles.onStop')
	vehicles.unloadCars()
end

base.addModule('vehicles', vehicles.onStart, vehicles.onStop, 'db')

setTimer(
	function()
		for k,v in pairs(vehicles.settings) do
			if v.blinker ~= 0 then
				local player = getVehicleController(vehicles.data[k].vehid)
				if player then
					triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'blinker')
				end
				for i = 1, getVehicleMaxPassengers(vehicles.data[k].vehid) + 1, 1 do
					local passenger = getVehicleOccupant(vehicles.data[k].vehid, i)
					if passenger then
						triggerClientEvent(passenger, 'onServerRequestPlaySound', rootElement, 'blinker')
					end
				end
				if v.blinkerstate == false then
					if v.blinker == 2 then
						if v.lights == 1 then
							setVehicleLightState(vehicles.data[k].vehid, 0, 1)
							setVehicleLightState(vehicles.data[k].vehid, 3, 1)
						end
						setVehicleLightState(vehicles.data[k].vehid, 1, 1)
						setVehicleLightState(vehicles.data[k].vehid, 2, 1)
					elseif v.blinker == 1 then
						if v.lights == 1 then
							setVehicleLightState(vehicles.data[k].vehid, 1, 1)
							setVehicleLightState(vehicles.data[k].vehid, 2, 1)
						end
						setVehicleLightState(vehicles.data[k].vehid, 0, 1)
						setVehicleLightState(vehicles.data[k].vehid, 3, 1)
					elseif v.blinker == 3 then
						setVehicleLightState(vehicles.data[k].vehid, 0, 1)
						setVehicleLightState(vehicles.data[k].vehid, 1, 1)
						setVehicleLightState(vehicles.data[k].vehid, 2, 1)
						setVehicleLightState(vehicles.data[k].vehid, 3, 1)
					end
				else
					if v.blinker == 2 then
						if v.lights == 1 then
							setVehicleLightState(vehicles.data[k].vehid, 0, 1)
							setVehicleLightState(vehicles.data[k].vehid, 3, 1)
						end
						setVehicleLightState(vehicles.data[k].vehid, 1, 0)
						setVehicleLightState(vehicles.data[k].vehid, 2, 0)
					elseif v.blinker == 1 then
						if v.lights == 1 then
							setVehicleLightState(vehicles.data[k].vehid, 1, 1)
							setVehicleLightState(vehicles.data[k].vehid, 2, 1)
						end
						setVehicleLightState(vehicles.data[k].vehid, 0, 0)
						setVehicleLightState(vehicles.data[k].vehid, 3, 0)
					elseif v.blinker == 3 then
						setVehicleLightState(vehicles.data[k].vehid, 0, 0)
						setVehicleLightState(vehicles.data[k].vehid, 1, 0)
						setVehicleLightState(vehicles.data[k].vehid, 2, 0)
						setVehicleLightState(vehicles.data[k].vehid, 3, 0)
					end
				end
				setVehicleOverrideLights(vehicles.data[k].vehid, 2)
				if player then triggerClientEvent(player, 'onServerRequestBlinkerChange', rootElement, v.blinker, v.blinkerstate) end
				v.blinkerstate = not v.blinkerstate
			end
		end
	end, 800, 0)
	
-- Initalisiere Datenbank
function vehicles.initDB()
	if(db.createTable('vehicles (id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, modelid INT(10), x FLOAT(10), y FLOAT(10), z FLOAT(10), rx FLOAT(10), ry FLOAT(10), rz FLOAT(10), numberplate TEXT NOT NULL, meta TEXT NOT NULL)')) then
		return true
	else
		return false
	end
end

-- Funktion um einen bestimmten Eintrag eines Vehikels zu updaten.
function vehicles.updateDB(vehid, Key, Value)
	return db.query('UPDATE vehicles SET '..Key..'="'..db.escQS(Value)..'" WHERE id='..vehid)
end

function vehicles.getVehicleIDfromElement(element)
	return tonumber(string.sub(getElementID(element), 5))
end

-- Funktion zum Laden der Fahrzeuge aus der Datenbank mit gleichzeitigem Erstellen

function vehicles.loadCars()
	local tbl = db.query('SELECT * FROM vehicles')
	if not tbl or #tbl == 0 then return end
	
	vehicles.data = tbl
	
	for k, v in pairs(vehicles.data) do
			v.vehid = createVehicle(v.modelid, v.x, v.y, v.z, v.rx, v.ry, v.rz, v.numberplate)
			vehicles.settings[k] = { lights = 1, engine = false, handbrake = true, blinker = 0, blinkerstate = false }
			setElementID(v.vehid, 'veh ' .. k)
	end
end

-- Funktion zum Entfernen aller Fahrzeuge aus dem Spiel
function vehicles.unloadCars()
	for k,v in pairs(vehicles.data) do
		destroyElement(v.vehid)
		v = nil
		vehicles.settings[k] = nil
	end
end

-- Kommando um ein beliebiges Fahrzeug zu erstellen
function vehicles.commandVeh(playerSource, commandName, col1)
	local x, y, z = getElementPosition ( playerSource )
	local vehid = #vehicles.data + 1
	vehicles.data[vehid] = { id = vehid, modelid = col1, x = x, y = y, z = z, rx = 0.0, ry = 0.0, rz = 0.0, numberplate = {}, meta = {} }
	vehicles.settings[vehid] = { lights = 1, engine = false, handbrake = true, blinker = 0, blinkerstate = false }
	local vehelement = createVehicle(vehicles.data[vehid].modelid, x, y, z)
	setElementID(vehelement, 'veh ' .. vehid)
	if vehelement then
		setVehicleRespawnPosition(vehelement, vehicles.data[vehid].x, vehicles.data[vehid].y, vehicles.data[vehid].z, vehicles.data[vehid].rx, vehicles.data[vehid].ry, vehicles.data[vehid].rz)
		setVehicleFuelTankExplodable(vehelement, true)
		db.query('INSERT INTO vehicles (modelid,x,y,z,rx,ry,rz,numberplate,meta) VALUES ("'..db.escQS(vehicles.data[vehid].modelid)..'","'..db.escQS(vehicles.data[vehid].x)..'","'..db.escQS(vehicles.data[vehid].y)..'","'..db.escQS(vehicles.data[vehid].z)..'","'..db.escQS(vehicles.data[vehid].rx)..'","'..db.escQS(vehicles.data[vehid].ry)..'","'..db.escQS(vehicles.data[vehid].rz)..'","'..db.escQS(toJSON(vehicles.data[vehid].numberplate))..'","'..db.escQS(toJSON(vehicles.data[vehid].meta))..'")')
		local tbl = db.query('SELECT * FROM vehicles ORDER BY id DESC LIMIT 1')
		vehicles.data[vehid] = tbl[1]
		vehicles.data[vehid].vehid = vehelement
	end
end

-- Kommando um ein Fahrzeug abzuschließen / aufzuschließen
function vehicles.commandLock(playerSource) -- TODO: Maybe add Sound
	local veh = getPedOccupiedVehicle(playerSource)
	if veh == false then
		local x, y, z = getElementPosition(playerSource)
		for k,v in pairs(vehicles.data) do
			if getDistanceBetweenPoints3D(x, y, z, v.x, v.y, v.z) < 5.0 then
				veh = v.vehid
			end
		end
	end
	if veh then
		if isVehicleLocked(veh) then
			setVehicleLocked(veh, false)
		else
			setVehicleLocked(veh, true)
		end
	end
end

function vehicles.commandTaxi(playerSource)
	local veh = getPedOccupiedVehicle(playerSource)
	if veh then
		if ( getVehicleController ( veh ) == playerSource ) then
			local id = getElementModel ( veh )
			if ( ( id == 420 ) or ( id == 438 ) ) then
				setVehicleTaxiLightOn ( veh, not isVehicleTaxiLightOn ( veh ) )
			end
		end
	end
end

function vehicles.keyHandling(player, key, keyState) -- TODO: Maybe add Sound
	local playerVehicle = getPedOccupiedVehicle(player)
	if keyState == 'down' then
		if key == 'l' then
			if playerVehicle then
				for i = 1, getVehicleMaxPassengers(playerVehicle) + 1, 1 do
					local passenger = getVehicleOccupant(playerVehicle, i)
					if passenger then
						triggerClientEvent(passenger, 'onServerRequestPlaySound', rootElement, 'switch')
					end
				end
				triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'switch')
				if getVehicleController(playerVehicle) == player then
					if vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].lights == 1 then
						setVehicleOverrideLights(playerVehicle, 2)
						vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].lights = 2
					else
						setVehicleOverrideLights(playerVehicle, 1)
						vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].lights = 1
					end
				end
				triggerClientEvent(player, 'onServerRequestLightChange', rootElement, vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].lights)
			end
		elseif key == 'm' then
			if playerVehicle then
				if getVehicleController(playerVehicle) == player then
					vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].engine = not vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].engine
					setVehicleEngineState(playerVehicle, vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].engine)
				end
			end
		elseif key == 'space' then
			if playerVehicle then
				vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].handbrake = not vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].handbrake
				triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'handbrake')
				for i = 1, getVehicleMaxPassengers(playerVehicle) + 1, 1 do
					local passenger = getVehicleOccupant(playerVehicle, i)
					if passenger then
						triggerClientEvent(passenger, 'onServerRequestPlaySound', rootElement, 'handbrake')
					end
				end
				setControlState(player, 'handbrake', vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].handbrake)
				triggerClientEvent(player, 'onServerRequestHandbrakeChange', rootElement, vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].handbrake)
			end
		elseif key == 'num_6' then
			if playerVehicle then
				triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'switch')
				if vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinker == 2 then
					vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinker = 0
					vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinkerstate = false
					for i = 0, 3, 1 do
						setVehicleLightState(playerVehicle, i, 0)
					end
					triggerClientEvent(player, 'onServerRequestBlinkerChange', rootElement, 0, false)
					setVehicleOverrideLights(playerVehicle, vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].lights)
				else
					vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinker = 2
				end
			end
		elseif key == 'num_4' then
			if playerVehicle then
				triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'switch')
				if vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinker == 1 then
					vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinker = 0
					vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinkerstate = false
					for i = 0, 3, 1 do
						setVehicleLightState(playerVehicle, i, 0)
					end
					triggerClientEvent(player, 'onServerRequestBlinkerChange', rootElement, 0, false)
					setVehicleOverrideLights(playerVehicle, vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].lights)
				else
					vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinker = 1
				end
			end
		elseif key == 'num_5' then
			if playerVehicle then
				triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'switch')
				if vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinker == 3 then
					vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinker = 0
					vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinkerstate = false
					for i = 0, 3, 1 do
						setVehicleLightState(playerVehicle, i, 0)
					end
					triggerClientEvent(player, 'onServerRequestBlinkerChange', rootElement, 0, false)
					setVehicleOverrideLights(playerVehicle, vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].lights)
				else
					vehicles.settings[vehicles.getVehicleIDfromElement(playerVehicle)].blinker = 3
				end
			end
		end
	end
end

function vehicles.configurePlayer(thePlayer, seat, jacked)
	if seat == 0 then
		setVehicleEngineState(source, vehicles.settings[vehicles.getVehicleIDfromElement(source)].engine)
		if vehicles.settings[vehicles.getVehicleIDfromElement(source)].lights == 2 then
			setVehicleOverrideLights(source, 2)
		else
			setVehicleOverrideLights(source, 1)
		end
		toggleControl(thePlayer, "handbrake", false)
		setControlState(thePlayer, 'handbrake', vehicles.settings[vehicles.getVehicleIDfromElement(source)].handbrake)
		triggerClientEvent(thePlayer, 'onServerRequestHandbrakeChange', rootElement, vehicles.settings[vehicles.getVehicleIDfromElement(source)].handbrake)
		triggerClientEvent(thePlayer, 'onServerRequestBlinkerChange', rootElement, vehicles.settings[vehicles.getVehicleIDfromElement(source)].blinker, vehicles.settings[vehicles.getVehicleIDfromElement(source)].blinkerstate)
		triggerClientEvent(thePlayer, 'onServerRequestLightChange', rootElement, vehicles.settings[vehicles.getVehicleIDfromElement(source)].lights)
		bindKey(thePlayer, "l", "down", vehicles.keyHandling)
		bindKey(thePlayer, "m", "down", vehicles.keyHandling)
		bindKey(thePlayer, "space", "down", vehicles.keyHandling)
		bindKey(thePlayer, 'num_6', 'down', vehicles.keyHandling)
		bindKey(thePlayer, 'num_4', 'down', vehicles.keyHandling)
		bindKey(thePlayer, 'num_5', 'down', vehicles.keyHandling)
	end
end

function vehicles.unconfigurePlayer(thePlayer, seat, jacked)
	if seat == 0 then
		toggleControl(thePlayer, "handbrake", false)
	end
end

function vehicles.damagePlayer(loss)
	for i = 0, getVehicleMaxPassengers(source), 1 do
		local thePlayer = getVehicleOccupant(source, i)
		if thePlayer then
			setElementHealth(thePlayer, getElementHealth(thePlayer)-(loss/12))
		end
	end
end

function vehicles.tryEnter(player, seat, jacked)
	if isVehicleLocked(source) then
		cancelEvent()
	end
end

function vehicles.tryExit(player, seat, jacked)
	unbindKey(player, 'space', 'down', vehicles.keyHandling)
	unbindKey(player, "l", "down", vehicles.keyHandling)
	unbindKey(player, "m", "down", vehicles.keyHandling)
	unbindKey(player, 'num_6', 'down', vehicles.keyHandling)
	unbindKey(player, 'num_4', 'down', vehicles.keyHandling)
	unbindKey(player, 'num_5', 'down', vehicles.keyHandling)
end

addCommandHandler("veh", vehicles.commandVeh)
addCommandHandler("lock", vehicles.commandLock)
addCommandHandler("taxi", vehicles.commandTaxi)
addEventHandler("onVehicleEnter", rootElement, vehicles.configurePlayer)
addEventHandler("onVehicleExit", rootElement, vehicles.unconfigurePlayer)
addEventHandler("onVehicleDamage", rootElement, vehicles.damagePlayer)
addEventHandler("onVehicleStartEnter", rootElement, vehicles.tryEnter)
addEventHandler("onVehicleStartExit", rootElement, vehicles.tryExit)
