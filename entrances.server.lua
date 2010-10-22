--[[ Eingaenge System (entrances)

	Beschreibung:
		Regelt die Eingaenge fuer z.B. die BSNs
		
	Funktionen:
		entrances.loadEntrances()

]]

entrances = 
{
	data = {},
	lastEntered = nil
}

function entrances.onStart()
	log('entrances.onStart')
	entrances.loadEntrances()
end

function entrances.onStop()
	log('entrances.onStop')
end

base.addModule('entrances', entrances.onStart, entrances.onStop)

function entrances.onPlayerEnterMarker(hitElement, matchingDimension)
	if getElementType(hitElement) == 'player' then
		if matchingDimension == true then
			for k,v in pairs(entrances.data) do
				if v.theMarker1 == source then
					if v.lastEntered == hitElement then 
						v.lastEntered = nil
						return 
					end
					v.lastEntered = hitElement
					setElementDimension(hitElement, v.world2)
					setElementInterior(hitElement, v.interior2)
					setElementPosition(hitElement, v.x2, v.y2, v.z2)
					setPedRotation(hitElement, v.angle2)
					return
				elseif v.theMarker2 == source then
					if v.lastEntered == hitElement then 
						v.lastEntered = nil
						return 
					end
					v.lastEntered = hitElement
					setElementDimension(hitElement, v.world1)
					setElementInterior(hitElement, v.interior1)
					setElementPosition(hitElement, v.x1, v.y1, v.z1)
					setPedRotation(hitElement, v.angle1)
					return
				end
			end
		end
	end
end

function entrances.loadEntrances()
	local node = xmlLoadFile('entrances.xml')
	if not node then return end

	local idx = 0
	local subnode = nil
	repeat
		subnode = xmlFindChild(node, 'entrance', idx)
		if not subnode then break end
		idx = idx + 1
		
		local x1 = tonumber(xmlNodeGetAttribute(subnode, 'x1'))
		local y1 = tonumber(xmlNodeGetAttribute(subnode, 'y1'))
		local z1 = tonumber(xmlNodeGetAttribute(subnode, 'z1'))
		local angle1 = tonumber(xmlNodeGetAttribute(subnode, 'angle1'))
		local world1 = tonumber(xmlNodeGetAttribute(subnode, 'world1'))
		local interior1 = tonumber(xmlNodeGetAttribute(subnode, 'interior1'))
		local x2 = tonumber(xmlNodeGetAttribute(subnode, 'x2'))
		local y2 = tonumber(xmlNodeGetAttribute(subnode, 'y2'))
		local z2 = tonumber(xmlNodeGetAttribute(subnode, 'z2'))
		local angle2 = tonumber(xmlNodeGetAttribute(subnode, 'angle2'))
		local world2 = tonumber(xmlNodeGetAttribute(subnode, 'world2'))
		local interior2 = tonumber(xmlNodeGetAttribute(subnode, 'interior2'))
		
		local theMarker1 = createMarker(x1, y1, z1, 'arrow', 1.5, 255, 255, 0, 170, g_Root)
		local theMarker2 = createMarker(x2, y2, z2, 'arrow', 1.5, 255, 255, 0, 170, g_Root)
		
		setElementDimension(theMarker1, world1)
		setElementDimension(theMarker2, world2)
	
		addEventHandler('onMarkerHit', theMarker1, entrances.onPlayerEnterMarker)
		addEventHandler('onMarkerHit', theMarker2, entrances.onPlayerEnterMarker)
				
		entrances.data[idx] = 
		{
			x1 = x1,
			y1 = y1,
			z1 = z1,
			angle1 = angle1,
			world1 = world1,
			interior1 = interior1,
			x2 = x2,
			y2 = y2,
			z2 = z2,
			angle2 = angle2,
			world2 = world2,
			interior2 = interior2,
			theMarker1 = theMarker1,
			theMarker2 = theMarker2
		}
	
	until false
	xmlUnloadFile(node)
end
