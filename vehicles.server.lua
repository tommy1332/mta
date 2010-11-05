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
		vehicles.isValidModel(modelID)
		
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
	data =
	{

	}
}

function vehicles.onStart()
	log('vehicles.onStart')
	vehicles.initDB()
	vehicles.loadCars()
	setTimer(function()
			for k,v in pairs(vehicles.data) do
				if v.meta.blinker ~= 0 then
					local player = getVehicleController(v.vehid)
					if player then
						triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'blinker')
					end
					for i = 1, getVehicleMaxPassengers(v.vehid) + 1, 1 do
						local passenger = getVehicleOccupant(v.vehid, i)
						if passenger then
							triggerClientEvent(passenger, 'onServerRequestPlaySound', rootElement, 'blinker')
						end
					end
					if v.meta.blinkerstate == false then
						if v.meta.blinker == 2 then
							if v.meta.lights == 1 then
								setVehicleLightState(v.vehid, 0, 1)
								setVehicleLightState(v.vehid, 3, 1)
							end
							setVehicleLightState(v.vehid, 1, 1)
							setVehicleLightState(v.vehid, 2, 1)
						elseif v.meta.blinker == 1 then
							if v.meta.lights == 1 then
								setVehicleLightState(v.vehid, 1, 1)
								setVehicleLightState(v.vehid, 2, 1)
							end
							setVehicleLightState(v.vehid, 0, 1)
							setVehicleLightState(v.vehid, 3, 1)
						elseif v.meta.blinker == 3 then
							setVehicleLightState(v.vehid, 0, 1)
							setVehicleLightState(v.vehid, 1, 1)
							setVehicleLightState(v.vehid, 2, 1)
							setVehicleLightState(v.vehid, 3, 1)
						end
					else
						if v.meta.blinker == 2 then
							if v.meta.lights == 1 then
								setVehicleLightState(v.vehid, 0, 1)
								setVehicleLightState(v.vehid, 3, 1)
							end
							setVehicleLightState(v.vehid, 1, 0)
							setVehicleLightState(v.vehid, 2, 0)
						elseif v.meta.blinker == 1 then
							if v.meta.lights == 1 then
								setVehicleLightState(v.vehid, 1, 1)
								setVehicleLightState(v.vehid, 2, 1)
							end
							setVehicleLightState(v.vehid, 0, 0)
							setVehicleLightState(v.vehid, 3, 0)
						elseif v.meta.blinker == 3 then
							setVehicleLightState(v.vehid, 0, 0)
							setVehicleLightState(v.vehid, 1, 0)
							setVehicleLightState(v.vehid, 2, 0)
							setVehicleLightState(v.vehid, 3, 0)
						end
					end
					setVehicleOverrideLights(v.vehid, 2)
					if player then 
						triggerClientEvent(player, 'onServerRequestBlinkerChange', rootElement, v.meta.blinker, v.meta.blinkerstate) 
					end
					v.meta.blinkerstate = not v.meta.blinkerstate
				end
			end
		end, 800, 0)

	addCommandHandler("veh", vehicles.commandVeh)
	addCommandHandler("lock", vehicles.commandLock)
	addCommandHandler("taxi", vehicles.commandTaxi)
	addEventHandler("onVehicleEnter", rootElement, vehicles.configurePlayer)
	addEventHandler("onVehicleExit", rootElement, vehicles.unconfigurePlayer)
	addEventHandler("onVehicleDamage", rootElement, vehicles.damagePlayer)
	addEventHandler("onVehicleStartEnter", rootElement, vehicles.tryEnter)
	addEventHandler("onVehicleStartExit", rootElement, vehicles.tryExit)
end

function vehicles.onStop()
	log('vehicles.onStop')
	vehicles.unloadCars()
end

base.addModule('vehicles', vehicles.onStart, vehicles.onStop, 'db')

	
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
			v.meta = fromJSON(v.meta)
			setElementID(v.vehid, 'veh ' .. k)
	end
end

-- Funktion zum Entfernen aller Fahrzeuge aus dem Spiel
function vehicles.unloadCars()
	for k,v in pairs(vehicles.data) do
		destroyElement(v.vehid)
		vehicles.data[k] = nil
	end
end

-- Tool um zu pruefen, ob die Model ID existiert
function vehicles.isValidModel(modelID)
	if modelID > 399 and modelID < 612 then
		return true
	end
	return false
end

-- Kommando um ein beliebiges Fahrzeug zu erstellen
function vehicles.commandVeh(playerSource, commandName, col1)
	if vehicles.isValidModel(tonumber(col1)) then
		local x, y, z = getElementPosition ( playerSource )
		local vehid = #vehicles.data + 1
		vehicles.data[vehid] = { 
						id = vehid, 
						modelid = col1, 
						x = x, 
						y = y, 
						z = z, 
						rx = 0.0, 
						ry = 0.0, 
						rz = 0.0, 
						numberplate = {}, 
						meta = {
								lights = 1,
								engine = false,
								handbrake = true,
								blinker = 0,
								blinkerstate = false
							}
					}
		local vehelement = createVehicle(vehicles.data[vehid].modelid, x, y, z)
		setElementID(vehelement, 'veh ' .. vehid)
		if vehelement then
			setVehicleRespawnPosition(vehelement, vehicles.data[vehid].x, vehicles.data[vehid].y, vehicles.data[vehid].z, vehicles.data[vehid].rx, vehicles.data[vehid].ry, vehicles.data[vehid].rz)
			setVehicleFuelTankExplodable(vehelement, true)
			setVehiclePlateText(vehelement, "42");
			db.query('INSERT INTO vehicles (modelid,x,y,z,rx,ry,rz,numberplate,meta) VALUES ("'..db.escQS(vehicles.data[vehid].modelid)..'","'..db.escQS(vehicles.data[vehid].x)..'","'..db.escQS(vehicles.data[vehid].y)..'","'..db.escQS(vehicles.data[vehid].z)..'","'..db.escQS(vehicles.data[vehid].rx)..'","'..db.escQS(vehicles.data[vehid].ry)..'","'..db.escQS(vehicles.data[vehid].rz)..'","'..db.escQS(toJSON(vehicles.data[vehid].numberplate))..'","'..db.escQS(toJSON(vehicles.data[vehid].meta))..'")')
			local tbl = db.query('SELECT * FROM vehicles ORDER BY id DESC LIMIT 1')
			vehicles.data[vehid] = tbl[1]
			vehicles.data[vehid].meta = fromJSON(vehicles.data[vehid].meta)
			vehicles.data[vehid].vehid = vehelement
		end
	end
end

-- Kommando um ein Fahrzeug abzuschließen / aufzuschließen
function vehicles.commandLock(playerSource) -- TODO: Maybe add Sound
	local veh = getPedOccupiedVehicle(playerSource)
	if not veh then
		local x, y, z = getElementPosition(playerSource)
		for k,v in pairs(vehicles.data) do
			if getDistanceBetweenPoints3D(x, y, z, v.x, v.y, v.z) < 5.0 then
				veh = v.vehid
			end
		end
	else
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

function vehicles.keyHandling(player, key, keyState)
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
					if vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.lights == 1 then
						setVehicleOverrideLights(playerVehicle, 2)
						vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.lights = 2
					else
						setVehicleOverrideLights(playerVehicle, 1)
						vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.lights = 1
					end
				end
				triggerClientEvent(player, 'onServerRequestLightChange', rootElement, vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.lights)
			end
		elseif key == 'm' then
			if playerVehicle then
				if getVehicleController(playerVehicle) == player then
					vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.engine = not vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.engine
					setVehicleEngineState(playerVehicle, vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.engine)
				end
			end
		elseif key == 'space' then
			if playerVehicle then
				vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.handbrake = not vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.handbrake
				triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'handbrake')
				for i = 1, getVehicleMaxPassengers(playerVehicle) + 1, 1 do
					local passenger = getVehicleOccupant(playerVehicle, i)
					if passenger then
						triggerClientEvent(passenger, 'onServerRequestPlaySound', rootElement, 'handbrake')
					end
				end
				setControlState(player, 'handbrake', vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.handbrake)
				triggerClientEvent(player, 'onServerRequestHandbrakeChange', rootElement, vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.handbrake)
			end
		elseif key == 'num_6' then
			if playerVehicle then
				triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'switch')
				if vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinker == 2 then
					vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinker = 0
					vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinkerstate = true
					for i = 0, 3, 1 do
						setVehicleLightState(playerVehicle, i, 0)
					end
					triggerClientEvent(player, 'onServerRequestBlinkerChange', rootElement, 0, false)
					setVehicleOverrideLights(playerVehicle, vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.lights)
				else
					vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinker = 2
				end
			end
		elseif key == 'num_4' then
			if playerVehicle then
				triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'switch')
				if vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinker == 1 then
					vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinker = 0
					vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinkerstate = true
					for i = 0, 3, 1 do
						setVehicleLightState(playerVehicle, i, 0)
					end
					triggerClientEvent(player, 'onServerRequestBlinkerChange', rootElement, 0, false)
					setVehicleOverrideLights(playerVehicle, vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.lights)
				else
					vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinker = 1
				end
			end
		elseif key == 'num_5' then
			if playerVehicle then
				triggerClientEvent(player, 'onServerRequestPlaySound', rootElement, 'switch')
				if vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinker == 3 then
					vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinker = 0
					vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinkerstate = true
					for i = 0, 3, 1 do
						setVehicleLightState(playerVehicle, i, 0)
					end
					triggerClientEvent(player, 'onServerRequestBlinkerChange', rootElement, 0, false)
					setVehicleOverrideLights(playerVehicle, vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.lights)
				else
					vehicles.data[vehicles.getVehicleIDfromElement(playerVehicle)].meta.blinker = 3
				end
			end
		end
	end
end

function vehicles.configurePlayer(thePlayer, seat, jacked)
	if seat == 0 then
		setVehicleEngineState(source, vehicles.data[vehicles.getVehicleIDfromElement(source)].meta.engine)
		if vehicles.data[vehicles.getVehicleIDfromElement(source)].meta.lights == 2 then
			setVehicleOverrideLights(source, 2)
		else
			setVehicleOverrideLights(source, 1)
		end
		toggleControl(thePlayer, "handbrake", false)
		setControlState(thePlayer, 'handbrake', vehicles.data[vehicles.getVehicleIDfromElement(source)].meta.handbrake)
		triggerClientEvent(thePlayer, 'onServerRequestHandbrakeChange', rootElement, vehicles.data[vehicles.getVehicleIDfromElement(source)].meta.handbrake)
		triggerClientEvent(thePlayer, 'onServerRequestBlinkerChange', rootElement, vehicles.data[vehicles.getVehicleIDfromElement(source)].meta.blinker, vehicles.data[vehicles.getVehicleIDfromElement(source)].meta.blinkerstate)
		triggerClientEvent(thePlayer, 'onServerRequestLightChange', rootElement, vehicles.data[vehicles.getVehicleIDfromElement(source)].meta.lights)
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

