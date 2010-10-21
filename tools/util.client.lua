function createServerCallInterface()
	return setmetatable(
		{},
		{
			__index = function(t, k)
				t[k] = function(...) triggerServerEvent('onServerCall', g_Me, k, ...) end
				return t[k]
			end
		}
	)
end

addEvent('onClientCall', true)
addEventHandler('onClientCall', getResourceRootElement(getThisResource()),
	function(fnName, ...)
		local fn = _G
		local path = fnName:split('.')
		for i,pathpart in ipairs(path) do
			fn = fn[pathpart]
		end
		fn(...)
	end,
	false
)

function setCameraPlayerMode()
	local r
	local vehicle = getPedOccupiedVehicle(g_Me)
	if vehicle then
		local rx, ry, rz = getElementRotation(vehicle)
		r = rz
	else
		r = getPedRotation(g_Me)
	end
	local x, y, z = getElementPosition(g_Me)
	setCameraMatrix(x - 4*math.cos(math.rad(r + 90)), y - 4*math.sin(math.rad(r + 90)), z + 1, x, y, z + 1)
	setTimer(setCameraTarget, 100, 1, g_Me)
end

function getPlayerOccupiedSeat(player)
	local vehicle = getPedOccupiedVehicle(player)
	if not vehicle then
		return false
	end
	for i=0,getVehicleMaxPassengers(vehicle) do
		if getVehicleOccupant(vehicle, i) == player then
			return i
		end
	end
	return false
end

function destroyBlipsAttachedTo(elem)
	local wasDestroyed = false
	for i,attached in ipairs(getAttachedElements(elem)) do
		if getElementType(attached) == 'blip' then
			destroyElement(attached)
			wasDestroyed = true
		end
	end
	return wasDestroyed
end