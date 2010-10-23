--[[ Wetter System (weather)

	Beschreibung:
		Das Wetter System
	
	Funktionen:
		weather.updateWeather()
		
]]

weather = 
{

}

function weather.onStart()
	log('weather.onStart')
	setWeather(0)
	weather.initDB()
	weather.updateWeather()
	weather.timer = setTimer(weather.updateWeather, 120000, 0)
end

function weather.onStop()
	log('weather.onStop')
	killTimer(weather.timer)
end

-- Initalisiere Datenbank
function weather.initDB()
	if(db.createTable('weather (id INT(10) PRIMARY KEY)')) then
		return true
	else
		return false
	end
end

base.addModule('weather', weather.onStart, weather.onStop, 'db')

addEventHandler('onPlayerJoin', getRootElement(), 
	function()
		setWeather(weather.id)
	end
)

function weather.updateWeather()
	local tbl = db.query('SELECT id FROM weather')
	if not tbl or #tbl == 0 then return end

	for i = 1, #tbl, 1 do
		if (tonumber(tbl[i].id) >= 5 and tonumber(tbl[i].id) <= 16) or tonumber(tbl[i].id) == 35 then
			weather.id = 16
		elseif (tonumber(tbl[i].id) >= 0 and tonumber(tbl[i].id) <= 4) or (tonumber(tbl[i].id) >= 37 and tonumber(tbl[i].id) <= 43) or (tonumber(tbl[i].id) >= 45 and tonumber(tbl[i].id) <= 47) then
			weather.id = 8
		elseif tonumber(tbl[i].id) == 20 then
			weather.id = 9
		elseif (tonumber(tbl[i].id) >= 17 and tonumber(tbl[i].id) <= 18) or tonumber(tbl[i].id) == 44 then
			weather.id = 41
		elseif (tonumber(tbl[i].id) >= 19 and tonumber(tbl[i].id) <= 20) then
			weather.id = 6
		else
			weather.id = 0
		end
	end
	setWeatherBlended(weather.id)
end
