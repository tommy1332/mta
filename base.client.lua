--[[ Basisscript (base)

Beschreibung:
	Allgemeine Sachen, die von jedem Modul ben�tigt werden.


Variablen:
	g_Root - Basiselement des Objektbaumes.
	g_ResRoot - Basiselement des Ressourcenbaumes.
	g_Player - Der eigene Spieler.


Funktionen:
	log ( <Nachricht> ) - Loggt ein Ereignis. ( Warscheinlich kommt sp�ter noch eine Option f�r den Ereignistyp hinzu -> Info,Warning,Error oder sowas)
	addModule ( <Name>, <Startfunktion>, <Stopfunktion>, <Abh�ngigkeiten> ) - Registriert ein neues Modul.

]]


g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
g_Res = getThisResource()
g_Player = getLocalPlayer()


base =
{
	modules = {},
	startlist = createDSL(),
	stoplist = {},
	serverstopped = false
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
	--if res ~= g_Res then return end

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
end
addEventHandler('onClientResourceStart', g_Root, base.onResourceStart)


function base.onResourceStop(res)
	--if res ~= g_Res then return end
	for i = 1, #base.stoplist, 1 do
		base.stoplist[i]()
	end
end
addEventHandler('onClientResourceStop', g_Root, base.onResourceStop)

function log(Msg)
	if not base.serverstopped then
		triggerServerEvent("onClientLog", g_Player, Msg)
	else
		outputDebugString('['..getPlayerName(source)..'] '..Msg)
	end
end