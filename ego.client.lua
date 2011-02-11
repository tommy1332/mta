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
	
	camDir = Vector(1,1,1),
	camPos = Vector(0,0,0),
	camRoll = 0.0,
	
	fTimeOld = 0.0,
	fTime = 0.0,
	
	viewOffset = {},
	viewOffsetTotal = { pos = Vector(0,0,0), rot = Vector(0,0,0) }, -- Fertig berechnetes Offset von der Offset-Liste :O (viewOffset)
	
	restrictFn = false
}

function ego.updateOffset()
	ego.viewOffsetTotal = {} -- erstmal zurücksetzen
	for v in ego.viewOffset do
		ego.viewOffsetTotal.pos = ego.viewOffsetTotal.pos + v.pos
		ego.viewOffsetTotal.rot = ego.viewOffsetTotal.rot + v.rot
	end
end


function ego.addOffset(Name, Pos, Rot)
	ego.viewOffset[name] = 
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
			ego.isEnabled = false -- TODO: Proxyfunktionen währen toll. Damit könnte dann auch setCameraTarget impliziert werden. ^^
			setCameraTarget(g_Me, g_Me)
		end
	else
		ego.isEnabled = true
	end
end

function ego.calculateCamera()
	ego.camPos = Vector(0,0,0)
	
	if getPedOccupiedVehicle(g_Me) then -- Im Vehikel
		-- Rotation anpassen
		ego.vehicleAngle = Vector(getElementRotation(getPedOccupiedVehicle(g_Me)))
		local c = ego.vehicleAngle.x
		local e = ego.vehicleAngle.y
		ego.vehicleAngle.x = ego.vehicleAngle.z / 180 * math.pi
		ego.vehicleAngle.y = -c / 180 * math.pi
		ego.vehicleAngle.z = -e
		ego.camRoll = ego.vehicleAngle.z
		
		-- Position anpassen
		local vd = vehicles.getViewData( getElementModel(getPedOccupiedVehicle(g_Me) , getPlayerOccupiedSeat(g_Me) ) );
		if vd.offset ~= 0 then
			ego.camPos = ego.camPos + Vector(getPedBonePosition(g_Me, 8)) -- Position vom Kopf
			ego.camPos.z = ego.camPos.z + 0.2 -- allgemeines offset, wegen Bone
		end
		ego.camPos = ego.camPos + vd.pos;
		
	else -- Ausserhalb des Fahrzeuges
		-- camRoll Wert auf 0 interpolieren
		if ego.viewAngle.z > 0 then
			ego.viewAngle.z = Lerp(ego.viewAngle.z, 0, 0.07*ego.fTime)
		elseif ego.viewAngle.z < 0 then
			ego.viewAngle.z = Lerp(0, ego.viewAngle.z, 0.07*ego.fTime)
		end
		
		-- camPos Offset hinzurechnen
		ego.camPos = ego.camPos + Vector(getPedBonePosition(g_Me, 8)) -- Position vom Kopf
		ego.camPos.z = ego.camPos.z + 0.2 -- allgemeines offset, wegen Bone
	end
	
	-- camDir zusammenbasteln :3
	local angle = ego.viewAngle + ego.vehicleAngle + ego.viewOffsetTotal.rot
	ego.camDir = ego.camDir + Angle2Vector(angle.x, angle.y) + ego.viewOffsetTotal.pos
	-- ego.camRoll = angle.z
end

function ego.rotatecamPos( X , Y )
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
			setCameraMatrix(ego.camPos.x,
							ego.camPos.y,
							ego.camPos.z,
							ego.camDir.x,
							ego.camDir.y,
							ego.camDir.z,
							ego.camRoll, 90)
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
		ego.rotatecamPos(cursorX, cursorY)
		setCursorPosition(g_ScreenSize.x/2, g_ScreenSize.y/2)
	end)
	
	addEvent('oncamPosMove', true)
	addEventHandler('oncamPosMove', getRootElement(), 
		function(lX, lY, lZ)
			setPedcamDir(source, lX, lY, lZ)
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