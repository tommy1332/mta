--[[ First Person Sicht (firstperson)

	Beschreibung:
		Setzt die Kamera Sicht, sodass man in der First Person Sicht ist.
	
	Funktionen:
		firstperson.onStart()
		firstperson.onStop()
		firstperson.calculateCamera()

]]

firstperson = 
{
	isEnabled = false,
	viewAngleXY, viewAngleZ = 0.0, 0.0,
	lastVehicleAngleX, lastVehicleAngleY, lastVehicleAngleZ = 0.0, 0.0, 0.0,
	lookAtX, lookAtY, lookAtZ = 0.0, 0.0, 0.0,
	headX, headY, headZ = 0.0, 0.0, 0.0,
	cursorX, cursorY = 1.0, 1.0,
	lookup = false,
	roll = 0.0,
	fTimeOld = 0.0,
	fTime = 0.0
}

screenSizeX, screenSizeY = guiGetScreenSize()

function firstperson.onLookUp(key, keystate)
	if isPedInVehicle(g_Me) then
		if key == 'c' then
			if keystate == 'down' then
				firstperson.lookup = true
			else
				firstperson.lookup = false
			end
		end
	end
end

function firstperson.onAim(key, keystate)
	if keystate == 'down' then
		if not isPedInVehicle(g_Me) and getPedWeapon(g_Me) ~= 0 and getPedTotalAmmo(g_Me) ~= 0 then
			firstperson.isEnabled = false
			setCameraTarget(g_Me, g_Me)
		end
	else
		firstperson.isEnabled = true
	end
end

function firstperson.calculateCamera()
	firstperson.headX, firstperson.headY, firstperson.headZ = getPedBonePosition(g_Me, 8)
	if firstperson.lookup == true then
		firstperson.headZ = firstperson.headZ - 0.11
	end
	firstperson.headZ = firstperson.headZ + 0.2
	local tmpcursorX, tmpcursorY = (0.5 - firstperson.cursorX) * 2.5, (0.5 - firstperson.cursorY) * 2.5
	firstperson.viewAngleXY = firstperson.viewAngleXY + tmpcursorX
	firstperson.viewAngleZ  = firstperson.viewAngleZ  + tmpcursorY
	setCursorPosition(screenSizeX/2, screenSizeY/2)
	if(isPedInVehicle(g_Me) and getPedOccupiedVehicle(g_Me)) then
		local newVehicleAngleX, newVehicleAngleY, newVehicleAngleZ = getElementRotation(getPedOccupiedVehicle(g_Me))
		newVehicleAngleZ = newVehicleAngleZ / 360.0
		local diff = newVehicleAngleZ - firstperson.lastVehicleAngleZ
		firstperson.viewAngleXY = firstperson.viewAngleXY + diff
		firstperson.lastVehicleAngleX, firstperson.lastVehicleAngleY, firstperson.lastVehicleAngleZ = newVehicleAngleX, newVehicleAngleY, newVehicleAngleZ
		firstperson.headZ = firstperson.headZ - 0.1
		if newVehicleAngleX > 90 and newVehicleAngleX < 270 then
			firstperson.roll = newVehicleAngleY - 180
		else
			firstperson.roll = -newVehicleAngleY
		end
	else -- interpoliere roll ausserhalb des fahrzeuges wieder auf 0
		if firstperson.roll > 0 then
			firstperson.roll = firstperson.roll - (firstperson.roll*(firstperson.fTime*0.01))
		end
	end
	if firstperson.viewAngleZ < 1.0 then
		firstperson.viewAngleZ = 1.0
	elseif firstperson.viewAngleZ > 2.0 then
		firstperson.viewAngleZ = 2.0
	end
	if firstperson.lookup == false then 
		firstperson.lookAtX, firstperson.lookAtY, firstperson.lookAtZ = getPointOnSphere(0.0, 0.0, 0.0, 0.01, firstperson.viewAngleXY, firstperson.viewAngleZ)
	else
		firstperson.lookAtX, firstperson.lookAtY, firstperson.lookAtZ = getPointOnSphere(0.0, 0.0, 0.0, 0.35, firstperson.lastVehicleAngleZ-0.25, firstperson.viewAngleZ)
	end
end

function firstperson.onStart()
	bindKey('c', 'both', firstperson.onLookUp)
	bindKey('mouse2', 'both', firstperson.onAim)
	log('firstperson.onStart')
	addEventHandler('onClientPreRender', g_Root, 
	function()
		if not isMainMenuActive() and firstperson.isEnabled and not guiGetVisible(mmenu.win) then
			firstperson.calculateCamera()
			setCameraMatrix(firstperson.headX + firstperson.lookAtX, firstperson.headY + firstperson.lookAtY, firstperson.headZ, firstperson.headX + firstperson.lookAtX*2, firstperson.headY + firstperson.lookAtY*2, firstperson.headZ + firstperson.lookAtZ*2, firstperson.roll, 90)
		end
	end)
	addEventHandler('onClientRender', g_Root,
	function()
		local tickcount = getTickCount()
		firstperson.fTime = tickcount - firstperson.fTimeOld
		firstperson.fTimeOld = tickcount	
	end)
	addEventHandler('onClientCursorMove', g_Root,
	function(cursorX, cursorY, absoluteX, absoluteY, worldX, worldY, worldZ)
		if firstperson.lookup == false then
			firstperson.cursorX, firstperson.cursorY = cursorX, cursorY
		else
			firstperson.cursorY = cursorY
		end
		--firstperson.calculateCamera()
	end)
	addEvent('onHeadMove', true)
	addEventHandler('onHeadMove', getRootElement(), 
		function(lX, lY, lZ)
			setPedLookAt(source, lX, lY, lZ)
		end
	)
end

function firstperson.onStop()
	log('firstperson.onStop')
end

base.addModule('firstperson', firstperson.onStart, firstperson.onStop, 'mmenu')

addEventHandler("onClientPlayerSpawn", g_Me, 
function()
	firstperson.viewAngleXY = getPedRotation(g_Me)
	firstperson.viewAngleZ = 0.0
	firstperson.isEnabled = true
end)

addEventHandler("onClientPlayerVehicleEnter", g_Root, 
	function (vehicle)
		firstperson.lastVehicleAngleX, firstperson.lastVehicleAngleY, firstperson.lastVehicleAngleZ = getElementRotation(vehicle)
		firstperson.lastVehicleAngleX, firstperson.lastVehicleAngleY, firstperson.lastVehicleAngleZ = firstperson.lastVehicleAngleX / 360, firstperson.lastVehicleAngleY / 360, firstperson.lastVehicleAngleZ / 360
	end
)

addEventHandler("onClientPlayerVehicleExit", g_Root,
	function(vehicle)
		firstperson.lookup = false
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
