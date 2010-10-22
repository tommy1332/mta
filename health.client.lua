--[[ Health System (health)

	Beschreibung:
		Zeigt den aktuellen HP Status anhand einer Koerper Grafik an.
		
	Funktionen:
		
]]

health = 
{

}

function health.onStart()
	log('health.onStart')
	addEventHandler('onClientRender', g_Root, 
		function()
			local color = tocolor(255, 0, 0)
			if getElementHealth(g_Me) > 66 then
				color = tocolor(0, 255, 0)
			elseif getElementHealth(g_Me) > 33 then
				color = tocolor(255, 255, 0)
			end
			dxDrawImage(getAbsoluteCoordinateX(0.88), getAbsoluteCoordinateY(0.1), getAbsoluteCoordinateX(0.1), getAbsoluteCoordinateY(0.1), 'data/images/body_main.png', 0, 0, 0, color)
			dxDrawImage(getAbsoluteCoordinateX(0.905), getAbsoluteCoordinateY(0.06), getAbsoluteCoordinateX(0.05), getAbsoluteCoordinateY(0.05), 'data/images/body_head.png', 0, 0, 0, color)
			dxDrawImage(getAbsoluteCoordinateX(0.88), getAbsoluteCoordinateY(0.17), getAbsoluteCoordinateX(0.1), getAbsoluteCoordinateY(0.1), 'data/images/body_legs.png', 0, 0, 0, color)
			dxDrawImage(getAbsoluteCoordinateX(0.88), getAbsoluteCoordinateY(0.097), getAbsoluteCoordinateX(0.1), getAbsoluteCoordinateY(0.1), 'data/images/body_arms.png', 0, 0, 0, color)
		end
	)
end

function health.onStop()
	log('health.onStop')
end

base.addModule('health', health.onStart, health.onStop)