--[[ Hauptmenü (mmenu)


Beschreibung:
	Stellt das Hauptmenü (F1) zur Verfügung,
	welches allgemeine Funktionen dem Spieler zur Verfügung stellt.


Funktionen:
	show ( ) - Öffnet das Fenster, falls dies noch nicht geschehen ist.
	hide ( ) - Schließt das Fenster, sofern es noch nicht geschehen ist.
	toggle ( ) - Öffnet das Fenster bzw. schließt es.
	select ( <Name> ) - Wählt einen bestimmten Tab aus.

	element add ( <Name> ) - Erstellt ein neues Tab mit dem angegebenen Namen und gibt ein entsprechendes Containerobjekt zurück.
	remove ( <Name> ) - Löscht den Tab mit dem angegebenen Namen.

]]


mmenu =
{
	win = nil,
	tabPanel = nil,
	tabs = {},
	curTab = nil,
	BUTTON_HEIGHT = 30
}

function mmenu.update(Tab)
	mmenu.curTab = Tab
	guiSetSize(mmenu.win, Tab.w, Tab.h + mmenu.BUTTON_HEIGHT, false)
	guiWindowSetSizable(mmenu.win, Tab.r)
end

function mmenu.onSwitch(tab)
	local name = mmenu.findTabByElement(tab)
	if not name then return end
	if name == 'Schliessen' then
		guiSetSelectedTab(mmenu.tabPanel, mmenu.tabs['Login'].e)
		mmenu.toggle()
	end
	local v = mmenu.tabs[name]
	mmenu.curTab = v
	
	local x1, y1 = guiGetPosition(mmenu.win, false)
	local w1, h1 = guiGetSize(mmenu.win, false)

	local x2 = x1
	local y2 = y1
	local w2 = v.w
	local h2 = v.h + mmenu.BUTTON_HEIGHT
	Animation.createAndPlay(mmenu.win, Animation.presets.guiMoveResize(x2, y2, w2, h2, 300, false, x1, y1, w1, h1, true))

	guiWindowSetSizable(mmenu.win, v.r)
end


function mmenu.onResize()
	local w,h = guiGetSize(mmenu.win, false)
	h = h - mmenu.BUTTON_HEIGHT
	if mmenu.curTab.r and gui.getAni(mmenu.win) ~= false then
		mmenu.curTab.w = w
		mmenu.curTab.h = h
	end
	guiSetSize(mmenu.tabPanel, w, h, false)
	guiSetProperty(mmenu.tabPanel, 'TabHeight', tostring(mmenu.BUTTON_HEIGHT/h))
end

function mmenu.onStart()
	log('mmenu.onStart')
	bindKey('f1', 'down', mmenu.toggle)

	mmenu.win = guiCreateWindow(20, 20, 100, 100, 'Main Menu', false)
	gui.register(mmenu.win)
	--guiWindowSetMovable(mmenu.win, false)
	--guiWindowSetSizable(mmenu.win, false)

	mmenu.tabPanel = guiCreateTabPanel(0, 30, 100, 70, false, mmenu.win)
	guiSetVisible(mmenu.win, false)
	
	addEventHandler('onClientGUISize', mmenu.win, mmenu.onResize, false)
	addEventHandler('onClientGUITabSwitched', mmenu.tabPanel, mmenu.onSwitch)
end

function mmenu.onStop()
	log('mmenu.onStop')
end

base.addModule('mmenu', mmenu.onStart, mmenu.onStop)


function mmenu.show()
	gui.show(mmenu.win)
end


function mmenu.hide()
	gui.hide(mmenu.win)
end


function mmenu.toggle()
	if guiGetVisible(mmenu.win) then
		mmenu.hide()
	else
		mmenu.show()
	end
end


function mmenu.select(Name)
	if not mmenu.tabs[Name] then return end
	guiSetSelectedTab(mmenu.tabPanel, mmenu.tabs[Name].e)
end


function mmenu.findTabByElement(Element)
	for k,v in pairs(mmenu.tabs) do
		if v.e == Element then
			return k
		end
	end
	return nil
end


function mmenu.add(Name, Width, Height, Resizeable)
	mmenu.remove(Name)
	local tab = guiCreateTab(Name, mmenu.tabPanel)
	mmenu.tabs[Name] = { e=tab, w=Width, h=Height, r=Resizeable }
	mmenu.update(mmenu.tabs[Name])
	return tab
end


function mmenu.remove(Name)
	if not mmenu.tabs[Name] then return end
	guiDeleteTab(mmenu.tabs[Name].e)
	mmenu.tabs[Name] = nil
end