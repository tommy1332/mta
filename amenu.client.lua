--[[ Adminmenü (amenu)


Beschreibung:
	Stellt das Hauptmenü (F7) zur Verfügung,
	welches allgemeine Funktionen dem Spieler zur Verfügung stellt.


Funktionen:
	show ( ) - Öffnet das Fenster, falls dies noch nicht geschehen ist.
	hide ( ) - Schließt das Fenster, sofern es noch nicht geschehen ist.
	toggle ( ) - Öffnet das Fenster bzw. schließt es.
	select ( <Name> ) - Wählt einen bestimmten Tab aus.

	element add ( <Name> ) - Erstellt ein neues Tab mit dem angegebenen Namen und gibt ein entsprechendes Containerobjekt zurück.
	remove ( <Name> ) - Löscht den Tab mit dem angegebenen Namen.

]]


amenu =
{
	win = nil,
	tabPanel = nil,
	tabs = {},
	curTab = nil,
	BUTTON_HEIGHT = 30
}

function amenu.update(Tab)
	amenu.curTab = Tab
	guiSetSize(amenu.win, Tab.w, Tab.h + amenu.BUTTON_HEIGHT, false)
	guiWindowSetSizable(amenu.win, Tab.r)
end

function amenu.onSwitch(tab)
	local name = amenu.findTabByElement(tab)
	if not name then return end
	local v = amenu.tabs[name]
	amenu.curTab = v
	
	local x1, y1 = guiGetPosition(amenu.win, false)
	local w1, h1 = guiGetSize(amenu.win, false)

	local x2 = x1
	local y2 = y1
	local w2 = v.w
	local h2 = v.h + amenu.BUTTON_HEIGHT
	Animation.createAndPlay(amenu.win, Animation.presets.guiMoveResize(x2, y2, w2, h2, 300, false, x1, y1, w1, h1, true))

	guiWindowSetSizable(amenu.win, v.r)
end


function amenu.onResize()
	local w,h = guiGetSize(amenu.win, false)
	h = h - amenu.BUTTON_HEIGHT
	if amenu.curTab.r and gui.getAni(amenu.win) ~= false then
		amenu.curTab.w = w
		amenu.curTab.h = h
	end
	guiSetSize(amenu.tabPanel, w, h, false)
	guiSetProperty(amenu.tabPanel, 'TabHeight', tostring(amenu.BUTTON_HEIGHT/h))
end


function amenu.onStart()
	log('amenu.onStart')
	bindKey('F7', 'down', amenu.toggle)

	amenu.win = guiCreateWindow(10, 0, 100, 100, 'Admin Menu', false)
	gui.register(amenu.win)
	--guiWindowSetMovable(amenu.win, false)
	guiWindowSetSizable(amenu.win, false)

	amenu.tabPanel = guiCreateTabPanel(0, 30, 100, 70, false, amenu.win)
	guiSetVisible(amenu.win, false)
	
	addEventHandler('onClientGUISize', amenu.win, amenu.onResize, false)
	addEventHandler('onClientGUITabSwitched', amenu.tabPanel, amenu.onSwitch)

	local atab = amenu.add('Allgemein', 400, 600, false)
	local rtab = amenu.add('Rechte Verwaltung', 400, 600, false)	
	
	guiCreateScrollBar(390,600,10,600,true,false,rtab)	

end

function amenu.onStop()
	log('amenu.onStop')
end

base.addModule('amenu', amenu.onStart, amenu.onStop)


function amenu.show()
	gui.show(amenu.win)
end


function amenu.hide()
	gui.hide(amenu.win)
end


function amenu.toggle()
	if guiGetVisible(amenu.win) then
		amenu.hide()
	else
		amenu.show()
	end
end


function amenu.select(Name)
	if not amenu.tabs[Name] then return end
	guiSetSelectedTab(amenu.tabPanel, amenu.tabs[Name].e)
end


function amenu.findTabByElement(Element)
	for k,v in pairs(amenu.tabs) do
		if v.e == Element then
			return k
		end
	end
	return nil
end


function amenu.add(Name, Width, Height, Resizeable)
	amenu.remove(Name)
	local tab = guiCreateTab(Name, amenu.tabPanel)
	amenu.tabs[Name] = { e=tab, w=Width, h=Height, r=Resizeable }
	amenu.update(amenu.tabs[Name])
	return tab
end


function amenu.remove(Name)
	if not amenu.tabs[Name] then return end
	guiDeleteTab(amenu.tabs[Name].e)
	amenu.tabs[Name] = nil
end