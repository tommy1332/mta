--[[ Vehikel System (vehicles)
	
	Beschreibung:
		Stellt die Client seitigen Funktionen zur Verfuegung wie z.B. Tacho
	
	Funktionen:
		getVehicleSpeeed(vehicle)
		
]]

--[[ TODO: Vielleicht mal generischer schreiben, sodass man Tachos und Sounds für jedes Auto setzen kann. ]]

vehicles = 
{
	gaugePosition = { g_ScreenSize[1] * 0.02, g_ScreenSize[2] * 0.6 },
	blinkerID = 0,
	blinkerState = false,
	handbrake = false,
	lightState = 1,
	drehZahl = 0,
	drehZahlW = false,

	currentSeat = 0,

	soundSwitch = 'data/sounds/switch.mp3',
	soundHandbrake = 'data/sounds/handbrake.mp3',
	soundBlinker = 'data/sounds/blinker.mp3',

	imageTacho = 'data/images/Tacho.png',
	imageSpeedZeiger = 'data/images/geschwzeiger.png',
	imageBlinker = 'data/images/blinker.png',
	imageHandbrake = 'data/images/handbremse.png',
	imageLamp = 'data/images/lampe1.png',
	imageDrehzahlZeiger = 'data/images/drehzahlzeiger.png',
	imageTankTempZeiger = 'data/images/zeigertanktemp.png',
	
	viewData = { default = { pos = Vector(0,0,0), offset = 1 } } -- für jede fahrzeug-id ein table, in dem für jeden sitz die position der kamera gespeichert ist
}

function vehicles.onStart()
	addEvent('onServerRequestPlaySound', true)
	addEventHandler('onServerRequestPlaySound', g_Root, 
		function(message)
			if message == 'switch' then
				playSound(vehicles.soundSwitch)
			elseif message == 'handbrake' then
				playSound(vehicles.soundHandbrake)
			elseif message == 'blinker' then
				playSound(vehicles.soundBlinker)
			end
		end
	)

	addEvent('onServerRequestBlinkerChange', true)
	addEventHandler('onServerRequestBlinkerChange', g_Root,
		function(blinkerid, blinkerstate)
			vehicles.blinkerID = blinkerid
			vehicles.blinkerState = blinkerstate
		end
	)

	addEvent('onServerRequestHandbrakeChange', true)
	addEventHandler('onServerRequestHandbrakeChange', g_Root,
		function(handbrakestatus)
			vehicles.handbrake = handbrakestatus
		end
	)

	addEvent('onServerRequestLightChange', true)
	addEventHandler('onServerRequestLightChange', g_Root,
		function(lightstate)
			vehicles.lightState = lightstate
		end
	)

	addEventHandler('onClientVehicleEnter', g_Root, 
		function(thePlayer, seat)
			if g_Me == thePlayer then
				vehicles.currentSeat = seat
			end
		end	
	)

	bindKey('w', 'both', vehicles.onVehicleControlPressed)

	setTimer( -- Timer zum Simulieren der Drehzahl Anzeige
		function()
			if isPedInVehicle(g_Me) then
				if vehicles.drehZahl < 20 then
					vehicles.drehZahl = vehicles.drehZahl + 1
				end
				if vehicles.drehZahlW == true then
					if vehicles.drehZahl + 1 < 210 then 
						vehicles.drehZahl = vehicles.drehZahl + 0.6
					end
				end
				if vehicles.drehZahlW == false then
					if vehicles.drehZahl - 4.5 > 20 then 
						vehicles.drehZahl = vehicles.drehZahl - 4.5
					end
				end
			else
				vehicles.drehZahl = 0
			end
		end, 50, 0
	)

	addEventHandler("onClientRender", g_Root, vehicles.onRender)
end

function vehicles.onStop()

end

base.addModule('vehicles', vehicles.onStart, vehicles.onStop)

function vehicles.getCurrentSeat()
	return vehicles.currentSeat
end

function vehicles.onRender()
	if isPedInVehicle(g_Me) then
		vehicles.drawTacho()	
	end
end

function vehicles.drawTacho()
	local veh = getPedOccupiedVehicle(g_Me)
	if veh then
		if getVehicleOccupant(veh, 0) == g_Me then
			-- Henry: Da atm keine Zeichenfunktionen für andere Fahrzeuge existieren, wird bis dahin der Code vom Auto-Zeugs genutzt.
		
			--[[ if getVehicleType(veh) == 'BMX' then
				-- TODO: Add Bicycle Tacho
			elseif getVehicleType(veh) == 'Automobile' or getVehicleType(veh) == 'Monster Truck' or getVehicleType(veh) == 'Quad' then
			]]
				dxDrawImage(getAbsoluteCoordinateX(0.2), getAbsoluteCoordinateY(0.7), getAbsoluteCoordinateX(0.6), getAbsoluteCoordinateY(0.3), vehicles.imageTacho)
				dxDrawImage(getAbsoluteCoordinateX(0.39), getAbsoluteCoordinateY(0.745), getAbsoluteCoordinateX(0.22), getAbsoluteCoordinateY(0.23), vehicles.imageSpeedZeiger, getVehicleSpeed(veh) * 0.86 - 5)
				if (vehicles.blinkerID == 1 or vehicles.blinkerID == 3) and vehicles.blinkerState == true then dxDrawImage(getAbsoluteCoordinateX(0.36), getAbsoluteCoordinateY(0.7545), getAbsoluteCoordinateX(0.03), getAbsoluteCoordinateY(0.03), vehicles.imageBlinker) end
				if (vehicles.blinkerID == 2 or vehicles.blinkerID == 3) and vehicles.blinkerState == true then dxDrawImage(getAbsoluteCoordinateX(0.6105), getAbsoluteCoordinateY(0.7528), getAbsoluteCoordinateX(0.03), getAbsoluteCoordinateY(0.03), vehicles.imageBlinker, 180) end
				if vehicles.handbrake == true then dxDrawImage(getAbsoluteCoordinateX(0.203), getAbsoluteCoordinateY(0.93), getAbsoluteCoordinateX(0.049), getAbsoluteCoordinateY(0.035), vehicles.imageHandbrake) end
				if vehicles.lightState == 2 then dxDrawImage(getAbsoluteCoordinateX(0.207), getAbsoluteCoordinateY(0.875), getAbsoluteCoordinateX(0.025), getAbsoluteCoordinateY(0.025), vehicles.imageLamp) end
				dxDrawImage(getAbsoluteCoordinateX(0.635), getAbsoluteCoordinateY(0.835), getAbsoluteCoordinateX(0.1), getAbsoluteCoordinateY(0.08), vehicles.imageDrehzahlZeiger, vehicles.drehZahl)
				dxDrawImage(getAbsoluteCoordinateX(0.296), getAbsoluteCoordinateY(0.85), getAbsoluteCoordinateX(0.08), getAbsoluteCoordinateY(0.08), vehicles.imageTankTempZeiger, 255)
				dxDrawImage(getAbsoluteCoordinateX(0.25), getAbsoluteCoordinateY(0.85), getAbsoluteCoordinateX(0.08), getAbsoluteCoordinateY(0.08), vehicles.imageTankTempZeiger, 0)
			--[[
			elseif getVehicleType(veh) == 'Plane' or getVehicleType(veh) == 'Helicopter' then
				-- TODO: Add Plane/Helicopter Tacho
			elseif getVehicleType(veh) == 'Bike' then
				-- TODO: Add Motorbike Tacho
			elseif getVehicleType(veh) == 'Train' then
				-- TODO: Add Train Tacho
			elseif getVehicleType(veh) == 'Boat' then
				-- TODO: Add Boat Tacho
			end
			]]
		end
	end
end

function vehicles.onVehicleControlPressed(key, keystate)
	if isPedInVehicle(g_Me) then
		if key == 'w' then 
			if keystate == 'down' then
				vehicles.drehZahlW = true
			else
				vehicles.drehZahlW = false
			end
		end
	end
end

function vehicles.loadViewData()
	local root_node = xmlLoadFile(':test/vehicle_view.xml')
	if not root_node then
		log("Can't load vehicle_view.xml!");
		return
	end


	local root_idx = 0

	local veh_node = nil
	local veh_idx = 0
	local veh_id = 0
	local veh_table = nil

	local seat_node = nil
	local seat_id = nil
	local seat_table = nil

	repeat
		veh_node = xmlFindChild(root_node, 'vehicle', root_idx)
		if not veh_node then break end
		root_idx = root_idx + 1
		
		veh_id = tonumber(xmlNodeGetAttribute(veh_node, 'id'))
		veh_table = {}
		vehicles.viewData[veh_id] = veh_table;

		veh_idx = 0
		repeat
			seat_node = xmlFindChild(veh_node, 'seat', veh_idx)
			if not seat_node then break end
			veh_idx = veh_idx + 1
			
			seat_id = tonumber(xmlNodeGetAttribute(seat_node, 'id'))
			seat_table = {}
			veh_table[seat_id] = seat_table;
			
			seat_table['pos'] = Vector( tonumber(xmlNodeGetAttribute(seat_node, 'x')),
										tonumber(xmlNodeGetAttribute(seat_node, 'y')),
										tonumber(xmlNodeGetAttribute(seat_node, 'z')));
			
			seat_table['offset'] = tonumber(xmlNodeGetAttribute(seat_node, 'offset'));
		until false
	until false

	xmlUnloadFile(rootNode)
end

function vehicles.getViewData( VehID , SeatID )
	if vehicles.viewData[VehID] == nil or vehicles.viewData[VehID][SeatID] == nil then return vehicles.viewData.default end
	return vehicles.viewData[VehID][SeatID]
end

-- Funktion zum Berechnen der Geschwindigkeit eines Fahrzeugs
function getVehicleSpeed(vehicle)
	if getElementType(vehicle) == 'vehicle' then
		speedx, speedy, speedz = getElementVelocity(vehicle)
		actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5)
		return actualspeed * 161
	end
	return false
end
