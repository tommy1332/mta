--[[ Basisscript (base)

Beschreibung:
	Allgemeine Sachen, die von jedem Modul benötigt werden.


Variablen:
	g_Root - Basiselement des Objektbaumes.
	g_ResRoot - Basiselement des Ressourcenbaumes.
	g_Res - Diese Resource.


Funktionen:
	log ( <Nachricht> ) - Loggt ein Ereignis. ( Warscheinlich kommt später noch eine Option für den Ereignistyp hinzu -> Info,Warning,Error oder sowas)
	addModule ( <Name>, <Startfunktion>, <Stopfunktion>, <Abhängigkeiten> ) - Registriert ein neues Modul.

]]


g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
g_Res = getThisResource()


base =
{
	-- logfile = nil,
	modules = {},
	startlist = createDSL(),
	stoplist = {}
}


function base.hasModule(Name)
	for i = 1, #base.modules, 1 do
		if base.modules[i] == Name then
			return true
		end
	end
	return false
end


function base.addModule(Name, FnStart, FnStop, ...)
	base.modules[#base.modules+1] = Name
	if FnStart or FnStop then
		base.startlist:add(Name, { FnStart, FnStop }, ...)
	end
end


function base.onResourceStart()
	-- base.logfile = fileCreate(getRealTime().days .. '.txt')

	base.startlist = base.startlist:compile(false)

	for i = 1, #base.startlist, 1 do
		if base.startlist[i][1] then
			base.startlist[i][1]()
		end
		if base.startlist[i][2] then
			base.stoplist[#base.startlist-i+1] = base.startlist[i][2]
		end
	end
	
	base.startlist = nil
	
	for k,v in ipairs(getElementsByType('player')) do
		triggerEvent('onPlayerJoin', g_Root, v)
	end
end
addEventHandler('onResourceStart', g_Root, base.onResourceStart)


function base.onResourceStop()
	for k,v in ipairs(getElementsByType('player')) do
		triggerEvent('onPlayerQuit', g_Root, v)
	end

	for i = 1, #base.stoplist, 1 do
		base.stoplist[i]()
	end
end
addEventHandler('onResourceStop', g_Root, base.onResourceStop)


function log(Msg)
	--outputServerLog(Msg)
	outputDebugString(Msg)
	--fileWrite(base.logfile, '['..getRealTime()..']: '..Msg..'\n')
	--db.query('INSERT INTO log (time,msg) VALUES (NOW(),"'..db.escQS(Msg)..'")')
end


function base.onClientLog(Msg)
	log('['..getPlayerName(source)..'] '..Msg)
end

addEvent('onClientLog', true)
addEventHandler('onClientLog', g_Root, base.onClientLog)


function base.onStart()
	-- db.createTable('log (time DATETIME NOT NULL PRIMARY KEY, msg TEXT NOT NULL)')
	log('base.onStart')
end

function base.onStop()
	--fileClose(base.logfile)
	log('base.onStop')
end

base.addModule('base_db', base.onStart, base.onStop, 'db')