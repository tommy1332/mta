--[[ Vehikel System (vehicles)
	
	Beschreibung:
		Stellt die Client seitigen Funktionen zur Verfuegung wie z.B. Tacho
	
	Funktionen:
		getVehicleSpeeed(vehicle)
		
]]

g_Me = getLocalPlayer()
g_Root = getRootElement()

g_tScreenSize = { guiGetScreenSize( ) }

g_tGaugePosition = { g_tScreenSize[1] * 0.02, g_tScreenSize[2] * 0.6 }

BlinkerID = 0
BlinkerState = false
Handbrake = false
LightState = 1
DrehZahl = 0
DrehZahlW = false

function getAbsoluteCoordinateX(x)
	return (x*g_tScreenSize[1])
end

function getAbsoluteCoordinateY(y)
	return (y*g_tScreenSize[2])
end

addEvent('onServerRequestPlaySound', true)
addEventHandler('onServerRequestPlaySound', g_Root, 
	function(message)
		if message == 'switch' then
			playSound('data/sounds/switch.mp3')
		elseif message == 'handbrake' then
			playSound('data/sounds/handbrake.mp3')
		elseif message == 'blinker' then
			playSound('data/sounds/blinker.mp3')
		end
	end
)

addEvent('onServerRequestBlinkerChange', true)
addEventHandler('onServerRequestBlinkerChange', g_Root,
	function(blinkerid, blinkerstate)
		BlinkerID = blinkerid
		BlinkerState = blinkerstate
	end
)

addEvent('onServerRequestHandbrakeChange', true)
addEventHandler('onServerRequestHandbrakeChange', g_Root,
	function(handbrakestatus)
		Handbrake = handbrakestatus
	end
)

addEvent('onServerRequestLightChange', true)
addEventHandler('onServerRequestLightChange', g_Root,
	function(lightstate)
		LightState = lightstate
	end
)

function onVehicleControlPressed(key, keystate)
	if isPedInVehicle(g_Me) then
		if key == 'w' then 
			if keystate == 'down' then
				DrehZahlW = true
			else
				DrehZahlW = false
			end
		end
	end
end

bindKey('w', 'both', onVehicleControlPressed)

setTimer(
	function()
		if isPedInVehicle(g_Me) then
			if DrehZahl < 20 then
				DrehZahl = DrehZahl + 1
			end
			if DrehZahlW == true then
				if DrehZahl + 1 < 210 then 
					DrehZahl = DrehZahl + 0.6
				end
			end
			if DrehZahlW == false then
				if DrehZahl - 4.5 > 20 then 
					DrehZahl = DrehZahl - 4.5
				end
			end
		else
			DrehZahl = 0
		end
	end, 50, 0
)

addEventHandler("onClientRender", g_Root,
	function()
		if isPedInVehicle(g_Me) then
			local veh = getPedOccupiedVehicle(g_Me)
			if veh then
				if getVehicleOccupant(veh, 0) == g_Me then
					if getVehicleType(veh) == 'BMX' then
						-- TODO: Add Bicycle Tacho
					elseif getVehicleType(veh) == 'Automobile' or getVehicleType(veh) == 'Monster Truck' or getVehicleType(veh) == 'Quad' then
						dxDrawImage(getAbsoluteCoordinateX(0.2), getAbsoluteCoordinateY(0.7), getAbsoluteCoordinateX(0.6), getAbsoluteCoordinateY(0.3), 'data/images/Tacho.png')
						dxDrawImage(getAbsoluteCoordinateX(0.39), getAbsoluteCoordinateY(0.745), getAbsoluteCoordinateX(0.22), getAbsoluteCoordinateY(0.23), 'data/images/geschwzeiger.png', getVehicleSpeed(veh) * 0.86 - 5)
						if (BlinkerID == 1 or BlinkerID == 3) and BlinkerState == true then dxDrawImage(getAbsoluteCoordinateX(0.36), getAbsoluteCoordinateY(0.7545), getAbsoluteCoordinateX(0.03), getAbsoluteCoordinateY(0.03), 'data/images/blinker.png') end
						if (BlinkerID == 2 or BlinkerID == 3) and BlinkerState == true then dxDrawImage(getAbsoluteCoordinateX(0.6105), getAbsoluteCoordinateY(0.7528), getAbsoluteCoordinateX(0.03), getAbsoluteCoordinateY(0.03), 'data/images/blinker.png', 180) end
						if Handbrake == true then dxDrawImage(getAbsoluteCoordinateX(0.203), getAbsoluteCoordinateY(0.93), getAbsoluteCoordinateX(0.049), getAbsoluteCoordinateY(0.035), 'data/images/handbremse.png') end
						if LightState == 2 then dxDrawImage(getAbsoluteCoordinateX(0.207), getAbsoluteCoordinateY(0.875), getAbsoluteCoordinateX(0.025), getAbsoluteCoordinateY(0.025), 'data/images/lampe1.png') end
						dxDrawImage(getAbsoluteCoordinateX(0.635), getAbsoluteCoordinateY(0.835), getAbsoluteCoordinateX(0.1), getAbsoluteCoordinateY(0.08), 'data/images/drehzahlzeiger.png', DrehZahl)
						dxDrawImage(getAbsoluteCoordinateX(0.296), getAbsoluteCoordinateY(0.85), getAbsoluteCoordinateX(0.08), getAbsoluteCoordinateY(0.08), 'data/images/zeigertanktemp.png', 255)
						dxDrawImage(getAbsoluteCoordinateX(0.25), getAbsoluteCoordinateY(0.85), getAbsoluteCoordinateX(0.08), getAbsoluteCoordinateY(0.08), 'data/images/zeigertanktemp.png', 0)
					elseif getVehicleType(veh) == 'Plane' or getVehicleType(veh) == 'Helicopter' then
						-- TODO: Add Plane/Helicopter Tacho
					elseif getVehicleType(veh) == 'Bike' then
						-- TODO: Add Motorbike Tacho
					elseif getVehicleType(veh) == 'Train' then
						-- TODO: Add Train Tacho
					elseif getVehicleType(veh) == 'Boat' then
						-- TODO: Add Boat Tacho
					end
				end
			end
		end
	end
)

-- Funktion zum Berechnen der Geschwindigkeit eines Fahrzeugs
function getVehicleSpeed(vehicle)
	if getElementType(vehicle) == 'vehicle' then
		speedx, speedy, speedz = getElementVelocity(vehicle)
		actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5)
		return actualspeed * 161
	end
	return false
end