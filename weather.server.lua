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
		setWeather(weather.weatherid)
	end
)

function weather.updateWeather()
	local tbl = db.query('SELECT weatherid FROM weather')
	if not tbl or #tbl == 0 then return end

	for i = 1, #tbl, 1 do
		if (tonumber(tbl[i].weatherid) >= 5 and tonumber(tbl[i].weatherid) <= 16) or tonumber(tbl[i].weatherid) == 35 then
			weather.weatherid = 16
		elseif (tonumber(tbl[i].weatherid) >= 0 and tonumber(tbl[i].weatherid) <= 4) or (tonumber(tbl[i].weatherid) >= 37 and tonumber(tbl[i].weatherid) <= 43) or (tonumber(tbl[i].weatherid) >= 45 and tonumber(tbl[i].weatherid) <= 47) then
			weather.weatherid = 8
		elseif tonumber(tbl[i].weatherid) == 20 then
			weather.weatherid = 9
		elseif (tonumber(tbl[i].weatherid) >= 17 and tonumber(tbl[i].weatherid) <= 18) or tonumber(tbl[i].weatherid) == 44 then
			weather.weatherid = 41
		elseif (tonumber(tbl[i].weatherid) >= 19 and tonumber(tbl[i].weatherid) <= 20) then
			weather.weatherid = 6
		else
			weather.weatherid = 0
		end
	end
	setWeatherBlended(weather.weatherid)
end
