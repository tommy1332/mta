--[[ First Person Sicht (ego)

	Beschreibung:
		Setzt die Kamera Sicht, sodass man in der First Person Sicht ist.
	
	Funktionen:
		ego.onStart()
		ego.onStop()
		ego.calculateCamera()

	Beschreibung:
		restrictFn kann eine Funktion enthalten, welche den Sichtbereich begrenzt.
		Diese Funktion wird aufgerufen sobald die Maus bewegt wird
		und bekommt die neuen Rotationswerte übergeben.
		Jetzt kann diese mit den Werten arbeiten und am Ende neue Werte als Tuple zurückgeben.

]]

-- Keine Spezialbehandlung für "vorbeugen" etc., vllt. so ein allgemeiner Offset-Stack .. eh? <- Warum Stack? Liste währ auch möglich oder?
-- Statt dem "sicht-gerade-dreh-interpolations-zeug" vllt. allgemein so ein einen Wert den andere Module setzen können. S.o. -^
-- Die Maus gibt nur die Verschiebung der Sicht an, allerdings werden dazu keine Berechungen in der Spielewelt durchgeführt. => Keine Rückkopplungseffekte!
-- Spezielle Sicht-Offset-Werte für bestimmte Situationen. => Je nach Animation oder Fahrzeug. => So eine XML-Datei welche diese Werte beinhaltet.

ego =
{
	isEnabled = true,
	viewAngle = Vector(0,0,0),
	vehicleAngle = Vector(0,0,0),
	lookAt = Vector(1,1,1),
	head = Vector(0,0,0),
	roll = 0.0,
	fTimeOld = 0.0,
	fTime = 0.0,
	viewOffset = {},
	totalOffset = { pos = Vector(0,0,0), rot = Vector(0,0,0) },
	restrictFn = false
}

function ego.updateOffset()
	for v in ego.viewOffset do
		ego.totalOffset.pos = ego.totalOffset.pos + v.pos
		ego.totalOffset.rot = ego.totalOffset.rot + v.rot
	end
end


function ego.addOffset(Name, Pos, Rot)
	viewOffset[name] = 
	{
		pos = pos + Pos,
		rot = rot + Rot
	}
	ego.updateOffset()
end

function ego.removeOffset(name)
	viewOffset[name] = nil
end

function ego.onAim(key, keystate)
	if keystate == 'down' then
		if not isPedInVehicle(g_Me) and getPedWeapon(g_Me) ~= 0 and getPedTotalAmmo(g_Me) ~= 0 then
			log("ego.isEnabled = false")
			ego.isEnabled = false -- TODO: Proxyfunktionen währen toll. Damit könnte dann auch setCameraTarget impliziert werden. ^^
			setCameraTarget(g_Me, g_Me)
		end
	else
		ego.isEnabled = true
	end
end

function ego.calculateCamera()
	ego.head = Vector(getPedBonePosition(g_Me, 8))
	ego.head.z = ego.head.z + 0.2 -- allgemeines offset, wegen Bone und so

	if isPedInVehicle(g_Me) and getPedOccupiedVehicle(g_Me) then -- Im Vehikel, Anpassen der Rotation
		ego.vehicleAngle = Vector(getElementRotation(getPedOccupiedVehicle(g_Me)))
		ego.vehicleAngle.x = ego.vehicleAngle.x / 180 * math.pi
		ego.vehicleAngle.y = ego.vehicleAngle.y / 180 * math.pi
		ego.vehicleAngle.z = ego.vehicleAngle.z / 180 * math.pi
		local c = ego.vehicleAngle.y
		ego.vehicleAngle.y = ego.vehicleAngle.z
		ego.vehicleAngle.z = c
		--log(ego.vehicleAngle) -- debug
	else -- Ausserhalb des Fahrzeuges, roll Wert auf 0 interpolieren
		if ego.viewAngle.z > 0 then
			ego.viewAngle.z = Lerp(ego.viewAngle.z, 0, 0.07*ego.fTime)
		elseif ego.viewAngle.z < 0 then
			ego.viewAngle.z = Lerp(0, ego.viewAngle.z, 0.07*ego.fTime)
		end
	end
	
	--[[
	if(isPedInVehicle(g_Me) and getPedOccupiedVehicle(g_Me)) then -- wenn wir in einem Fahrzeug sind, beziehen wir dessen Rotation mit ein
		local newVehicleAngle = Vector(getElementRotation(getPedOccupiedVehicle(g_Me)))
		local diff = newVehicleAngle.z - ego.lastVehicleAngle.z
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
			ego.roll = Lerp(ego.roll, 0, 0.07*ego.fTime)
		else
			ego.roll = Lerp(0, ego.roll, 0.07*ego.fTime)
		end
	end
	
	if ego.viewAngleZ < 1.0 then
		ego.viewAngleZ = 1.0
	elseif ego.viewAngleZ > 2.0 then
		ego.viewAngleZ = 2.0
	end
	]]
	log("vehicleAngle:" .. tostring(ego.vehicleAngle))
	local angle = ego.viewAngle + ego.vehicleAngle + ego.totalOffset.rot
	log("angle: " .. tostring(angle))
	ego.lookAt = ego.head + Angle2Vector(angle.x, angle.y) + ego.totalOffset.pos
	-- ego.roll = angle.z
end

function ego.rotateHead( X , Y )
	X = Wrap( ego.viewAngle.x - (X-0.5)*4 , 0 , 2*math.pi )
	Y = BoundBy( ego.viewAngle.y + (Y-0.5)*4 , (0.5+0.01)*math.pi , (1.5-0.01)*math.pi )
	if not ego.restrictFn then
		ego.viewAngle.x = X
		ego.viewAngle.y = Y
	else
		ego.viewAngle.x, ego.viewAngle.y = ego.restrictFn(X,Y)
	end
end

function ego.onStart()
	--bindKey('c', 'both', ego.onLookUp) -- old stuff
	
	bindKey('mouse2', 'both', ego.onAim)
	
	log('ego.onStart')

	setCameraClip(false, false)
	setCursorPosition(g_ScreenSize.x/2, g_ScreenSize.y/2)
	
	addEventHandler('onClientPreRender', g_Root, 
	function()
		if ego.isEnabled then
			ego.calculateCamera()
			setCameraMatrix(ego.head.x,
							ego.head.y,
							ego.head.z,
							ego.lookAt.x,
							ego.lookAt.y,
							ego.lookAt.z,
							ego.roll, 90)
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
		if not ego.isEnabled or guiGetVisible(mmenu.win) or isMainMenuActive() --[[ und so weiter ... toolfunktion ? ]] then
			return
		end
		--log("absolute = "..(absoluteX-(g_ScreenSize.x/2)).." "..(absoluteY-(g_ScreenSize.y/2)))
		ego.rotateHead(cursorX, cursorY)
		setCursorPosition(g_ScreenSize.x/2, g_ScreenSize.y/2)
	end)
	
	addEvent('onHeadMove', true)
	addEventHandler('onHeadMove', getRootElement(), 
		function(lX, lY, lZ)
			setPedLookAt(source, lX, lY, lZ)
		end
	)
	addEventHandler("onClientPlayerSpawn", g_Me, 
	function()
		ego.viewAngle.x = getPedRotation(g_Me)
		ego.viewAngle.y = 0
		ego.isEnabled = true
	end)

end

function ego.onStop()
	log('ego.onStop')
end

base.addModule('ego', ego.onStart, ego.onStop, 'mmenu')

function Angle2Vector(u,v) -- Sollte irgendwann mal in tools/tools.lua oder in tools/vec.lua als Memberfunktion ;)
	return Vector( math.cos(u) * math.cos(v), math.sin(u) * math.cos(v), math.sin(v) )
end

--[[ Altes Zeug

	addEventHandler("onClientPlayerVehicleEnter", g_Root, 
		function (vehicle)
			ego.lastVehicleAngle = Vector(getElementRotation(vehicle))
			-- ego.lastVehicleAngleX, ego.lastVehicleAngleY, ego.lastVehicleAngleZ = ego.lastVehicleAngleX / 360, ego.lastVehicleAngleY / 360, ego.lastVehicleAngleZ / 360 -- dunnow was das hier tut
		end
	)

addEventHandler("onClientPlayerVehicleExit", g_Root,
		function(vehicle)
			ego.lookup = false
		end
	)

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
