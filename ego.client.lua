--[[ First Person Sicht (ego)

	Beschreibung:
		Setzt die Kamera Sicht, sodass man in der First Person Sicht ist.
	
	Funktionen:
		ego.onStart()
		ego.onStop()
		ego.calculateCamera()

]]

-- X Statt "ego" könnte man das Modul doch auch "ego" nennen? Währ kürzer und so. ^^
-- Keine Spezialbehandlung für "vorbeugen" etc., vllt. so ein allgemeiner Offset-Stack .. eh?
-- Statt dem "sicht-gerade-dreh-interpolations-zeug" vllt. allgemein so ein einen Wert den andere Module setzen können. S.o. -^
-- Die Maus gibt nur die Verschiebung der Sicht an, allerdings werden dazu keine Berechungen in der Spielewelt durchgeführt. => Keine Rückkopplungseffekte!
-- Spezielle Sicht-Offset-Werte für bestimmte Situationen. => Je nach Animation oder Fahrzeug. => So eine XML-Datei welche diese Werte beinhaltet.

ego =
{
	isEnabled = false,
	viewAngleXY, viewAngleZ = 0.0, 0.0,
	cursorX, cursorY = 1.0, 1.0,
	lastVehicleAngle = createV3D(),
	lookAt = createV3D(),
	head = createV3D(),
	roll = 0.0,
	fTimeOld = 0.0,
	fTime = 0.0
}

screenSizeX, screenSizeY = guiGetScreenSize()

function ego.onAim(key, keystate)
	if keystate == 'down' then
		if not isPedInVehicle(g_Me) and getPedWeapon(g_Me) ~= 0 and getPedTotalAmmo(g_Me) ~= 0 then
			ego.isEnabled = false
			setCameraTarget(g_Me, g_Me)
		end
	else
		ego.isEnabled = true
	end
end

function ego.calculateCamera()
	ego.headX

	ego.headX, ego.headY, ego.headZ = getPedBonePosition(g_Me, 8)

	if ego.lookup == true then
		ego.headZ = ego.headZ - 0.11
	end

	ego.headZ = ego.headZ + 0.2

	local tmpcursorX = (0.5 - ego.cursorX) * 2.5
	local tmpcursorY = (0.5 - ego.cursorY) * 2.5

	ego.viewAngleXY = ego.viewAngleXY + tmpcursorX
	ego.viewAngleZ  = ego.viewAngleZ  + tmpcursorY

	if not isMainMenuActive() then	
		setCursorPosition(screenSizeX/2, screenSizeY/2)
	end
	if(isPedInVehicle(g_Me) and getPedOccupiedVehicle(g_Me)) then
		local newVehicleAngleX, newVehicleAngleY, newVehicleAngleZ = getElementRotation(getPedOccupiedVehicle(g_Me))
		local diff = newVehicleAngleZ - ego.lastVehicleAngleZ
		ego.viewAngleXY = ego.viewAngleXY + diff
		ego.lastVehicleAngleX, ego.lastVehicleAngleY, ego.lastVehicleAngleZ = newVehicleAngleX, newVehicleAngleY, newVehicleAngleZ
		ego.headZ = ego.headZ - 0.1
		if newVehicleAngleX > 90 and newVehicleAngleX < 270 then
			ego.roll = newVehicleAngleY - 180
		else
			ego.roll = -newVehicleAngleY
		end
	else -- interpoliere roll ausserhalb des fahrzeuges wieder auf 0
		if ego.roll > 0 then
			ego.roll = Lerp(ego.roll, 0, 0.07)
		else
			ego.roll = Lerp(0, ego.roll, 0.07)
		end
	end
	if ego.viewAngleZ < 1.0 then
		ego.viewAngleZ = 1.0
	elseif ego.viewAngleZ > 2.0 then
		ego.viewAngleZ = 2.0
	end
	if ego.lookup == false then 
		ego.lookAtX, ego.lookAtY, ego.lookAtZ = getPointOnSphere(0.0, 0.0, 0.0, 0.01, ego.viewAngleXY, ego.viewAngleZ)
	else
		ego.lookAtX, ego.lookAtY, ego.lookAtZ = getPointOnSphere(0.0, 0.0, 0.0, 0.35, ego.lastVehicleAngleZ-0.25, ego.viewAngleZ)
	end
end

function ego.onStart()
	bindKey('c', 'both', ego.onLookUp)
	bindKey('mouse2', 'both', ego.onAim)
	log('ego.onStart')
	addEventHandler('onClientPreRender', g_Root, 
	function()
		if ego.isEnabled and not guiGetVisible(mmenu.win) then
			ego.calculateCamera()
			setCameraMatrix(ego.headX + ego.lookAtX, ego.headY + ego.lookAtY, ego.headZ, ego.headX + ego.lookAtX*2, ego.headY + ego.lookAtY*2, ego.headZ + ego.lookAtZ*2, ego.roll, 90)
		end
	end)
	addEventHandler('onClientRender', g_Root,
	function()
		local tickcount = getTickCount()
		ego.fTime = tickcount - ego.fTimeOld
		ego.fTimeOld = tickcount	
	end)
	addEventHandler('onClientCursorMove', g_Root,
	function(cursorX, cursorY, absoluteX, absoluteY, worldX, worldY, worldZ)
		if ego.lookup == false then
			ego.cursorX, ego.cursorY = cursorX, cursorY
		else
			ego.cursorY = cursorY
		end
		--ego.calculateCamera()
	end)
	addEvent('onHeadMove', true)
	addEventHandler('onHeadMove', getRootElement(), 
		function(lX, lY, lZ)
			setPedLookAt(source, lX, lY, lZ)
		end
	)
end

function ego.onStop()
	log('ego.onStop')
end

base.addModule('ego', ego.onStart, ego.onStop, 'mmenu')

addEventHandler("onClientPlayerSpawn", g_Me, 
function()
	ego.viewAngleXY = getPedRotation(g_Me)
	ego.viewAngleZ = 0.0
	ego.isEnabled = true
end)

addEventHandler("onClientPlayerVehicleEnter", g_Root, 
	function (vehicle)
		ego.lastVehicleAngleX, ego.lastVehicleAngleY, ego.lastVehicleAngleZ = getElementRotation(vehicle)
		ego.lastVehicleAngleX, ego.lastVehicleAngleY, ego.lastVehicleAngleZ = ego.lastVehicleAngleX / 360, ego.lastVehicleAngleY / 360, ego.lastVehicleAngleZ / 360
	end
)

addEventHandler("onClientPlayerVehicleExit", g_Root,
	function(vehicle)
		ego.lookup = false
	end
)

function getPointOnSphere(destx,desty,destz,radius,u,v)
	u = u * 2 * math.pi
	v = -1 * (v - 0.5) * math.pi
	destx = radius * math.cos(u) * math.cos(v)
	desty = radius * math.sin(u) * math.cos(v)
	destz = radius * math.sin(v)
	return destx,desty,destz
end

--[[ Altes Zeug

function ego.onLookUp(key, keystate) -- whut?
	if isPedInVehicle(g_Me) then
		if key == 'c' then
			if keystate == 'down' then
				ego.lookup = true
			else
				ego.lookup = false
			end
		end
	end
end

]]