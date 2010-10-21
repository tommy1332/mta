--[[ Accountsystem (acc)


Funktionen:
	createLoginWindow ( ) - Fenster initial erstellen.
	openLoginWindow ( ) - Fenster leeren anzeigen.
	closeLoginWindow ( ) - Fenster schließen.
	
	onLoginCancel ( ) - Wenn auf den Cancel-Knopf gedrückt wurde.
	onLoginSubmit ( ) - Wenn auf den Submit-Knopf gedrückt wurde.
	onLoginResponse ( ) - Wenn der Server auf ein Submit antwortet.
	
	loadSettings ( ) - Einstellungen aus der Config laden.
	saveSettings ( ) - Einstellungen in Config speichern.
	deleteLoginSettings ( ) - Login-Daten aus der Config löschen.

]]

acc =
{
	login =
	{
		name = nil,
		pw = nil,
		remember = nil,
		msg = nil
	}
}


function acc.onStart()
	log('acc.onStart')
	
	acc.createLoginTab()
	--acc.createRegisterTab()

	mmenu.add('News', 400, 300, true)
	mmenu.add('Optionen', 500, 400, false)
	mmenu.add('Schliessen', 500, 400, false)

	mmenu.select('Login')
	mmenu.show()
end

function acc.onStop()
	log('acc.onStop')
end

base.addModule('acc', acc.onStart, acc.onStop, 'mmenu')


---- Fensterfunktionen ----

function acc.createLoginTab()
	local tab = mmenu.add('Login', 400, 300, false)

	-- Benutzername
	local nameLabel = guiCreateLabel(11, 30, 60, 18, 'Name:', false, tab)
	guiSetFont(nameLabel, 'default-bold-small')

	acc.login.name = guiCreateEdit(110, 24, 175, 27, '', false, tab)
	
	-- Passwort
	local pwLabel = guiCreateLabel(10, 69, 60, 12, 'Password:', false, tab)
	guiSetFont(pwLabel, 'default-bold-small')

	acc.login.pw = guiCreateEdit(110, 64, 175, 27, '', false, tab)
	guiEditSetMasked(acc.login.pw, true)
	
	-- Erinnermich
	acc.login.remember = guiCreateCheckBox(223, 107, 62, 22, 'Save', false, false, tab)
	guiCheckBoxSetSelected(acc.login.remember, false)
	
	-- Cancel
	--local cancelButton = guiCreateButton(141, 134, 69, 28, 'Cancel', false, tab)
	--addEventHandler('onClientGUIClick', cancelButton, acc.onLoginCancel, false)

	-- Ok
	local okButton = guiCreateButton(216, 133, 69, 29, 'OK', false, tab)
	addEventHandler('onClientGUIClick', okButton, acc.onLoginSubmit, false)

	-- Response-Nachricht
	acc.login.msg = guiCreateLabel(9, 108, 179, 20, '', false, tab)
	guiLabelSetColor(acc.login.msg, 255, 0, 0)
	
	
	-- Setup!
	guiSetText(acc.login.name, getPlayerName(g_Player))
	guiSetText(acc.login.pw, '')
	guiSetText(acc.login.msg, '')
	acc.loadSettings()

	return true
end


function acc.createRegisterTab()
	local tab = mmenu.add('Registrieren', 400, 300, false)

	-- Benutzername
	local nameLabel = guiCreateLabel(11, 30, 60, 18, 'Name:', false, tab)
	guiSetFont(nameLabel, 'default-bold-small')

	acc.register.name = guiCreateEdit(110, 24, 175, 27, '', false, tab)
	
	-- Passwort
	local pwLabel = guiCreateLabel(10, 69, 60, 12, 'Password:', false, tab)
	guiSetFont(pwLabel, 'default-bold-small')

	acc.register.pw = guiCreateEdit(110, 64, 175, 27, '', false, tab)
	guiEditSetMasked(acc.login.pw, true)

	-- Ok
	local okButton = guiCreateButton(216, 133, 69, 29, 'OK', false, tab)
	addEventHandler('onClientGUIClick', okButton, acc.onRegisterSubmit, false)

	return true
end


---- Events ----

function acc.onLoginCancel()
	acc.closeLoginWindow()
end


function acc.onLoginSubmit()
	log('acc.onLoginSubmit')

	-- TODO: Hier erstmal vorprüfen!

	triggerServerEvent('acc.onLoginSubmit', g_Player, g_Player, guiGetText(acc.login.name), guiGetText(acc.login.pw))

	if guiCheckBoxGetSelected(acc.login.remember) then
		acc.saveSettings()
	else
		acc.deleteLoginSettings()
	end
	
end


addEvent('acc.onLoginResponse', true)
function acc.onLoginResponse(Rejected, Reason)
	if Rejected then
		log('Login rejected: '..Reason)
		guiSetText(acc.login.msg, Reason)
		Animation.createAndPlay(acc.login.msg, { from = 255, to = 180, time = 300, fn = acc.msgAni })
	else
		log('Login successfull!')
		mmenu.hide()
	end
end
addEventHandler('acc.onLoginResponse', g_Root, acc.onLoginResponse)


function acc.msgAni(e, t)
	guiLabelSetColor(e, t, 0, 0)
end

---- XML-Settings ----

function acc.loadSettings()
	local rootNode = xmlLoadFile(':test/config.xml')
	if not rootNode then return end
	
	local accNode = xmlFindChild(rootNode, 'acc', 0)
	if accNode then
		local nameNode = xmlFindChild(accNode, 'name', 0)
		if nameNode then
			guiSetText(acc.login.name, xmlNodeGetValue(nameNode))
		end

		local pwNode = xmlFindChild(accNode, 'pw', 0)
		if pwNode then
			guiSetText(acc.login.pw, xmlNodeGetValue(pwNode))
		end
		
		guiCheckBoxSetSelected(acc.login.remember, true)
	end

	xmlUnloadFile(rootNode)
end


function acc.saveSettings()
	local rootNode = xmlLoadOrCreate(':test/config.xml', 'config')

	local node = xmlNodeByPath(rootNode, 'acc/name', true)
	xmlNodeSetValue(node, guiGetText(acc.login.name))
	
	node = xmlNodeByPath(rootNode, 'acc/pw', true)
	xmlNodeSetValue(node, guiGetText(acc.login.pw))
	
	xmlSaveFile(rootNode)
	xmlUnloadFile(rootNode)
end


function acc.deleteLoginSettings()
	local rootNode = xmlLoadFile(':test/config.xml')
	if not rootNode then return end
	
	local accNode = xmlFindChild(rootNode, 'acc', 0)
	if not accNode then return end
	
	xmlDestroyNode(accNode)

	xmlSaveFile(rootNode)
	xmlUnloadFile(rootNode)
end


---- TEST ----

-- callAnimated(lerp, 1.0, 10, guiSetAlpha, 0.0, 1.0)

--[[

function callAnimated(LerpFn, Duration, Calls, Fn, ...)
	local parIn = {...}
	local parOut = {}
	local i = 1
	repeat
		if i > #parIn then break end
		
		if parIn[i+1] == nil then
			parOut[#parOut+1] = parIn[i]
		end
		
		i = i + 2
	until false

	local data = { nil, LerpFn, Fn, parIn, parOut }
	data[1] = setTimer(_callAnimated, Duration/Calls, Calls, data)
	return timer
end

function _callAnimated(data)
	local t = 0.5
	
	local i = 1
	repeat
		if i > #data[4] then break end
		
		if data[4][i+1] == nil then
			data[5][#data[5]+1] = data[4][i]
		else
			data[5][#data[5]+1] = data[2](data[4][i], data[4][i+1], t)
		end
		
		i = i + 2
	until false

	data[3](unpack(parOut))
end

]]

