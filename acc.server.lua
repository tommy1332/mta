--[[ Accountsystem (acc)

Beschreibung:
	Das Accountsystem um beliebige Spielerdaten dauerhaft zu speichern.
	Siehe Datenbank.


Funktionen:
	initDB ( ) - Initiiert die Tabelle in der Datenbank.
	AcID findByPlayer ( <Spielerobjekt> ) - Account-ID nach Spielerobjekt finden. (Funktioniert natürlich nur bei Spielern, die online sind.)
	AcID findByName ( <Name> ) - Account-ID nach Namen finden.
	AcID create( <Name>, <Passworthash> ) - Account aus Name und Passworthash erstellen. (Sofern der Name noch nicht vergeben ist.)
	delete( <ID> ) - Account löschen.
	loadAll ( ) - Komplette Datenbank laden.
	saveAll ( ) - Alle Accounts in die Datenbank speichern.
	save ( <ID> ) - Einzelnen Account speichern. ( Im Prinzip werden hier nur die Metadaten gespeichert, da der Rest immer sofort gesynct wird. )
	bool exists ( <ID ) - Prüft ob ein bestimmter Account existiert.

	setName ( <ID>, <Name> ) - Setzt und synct den Namen.
	string getName ( <ID> ) - Gibt den Namen aus.

	setPwHash ( <ID>, <Passworthash> ) - Setzt und synct den Passworthash.
	string getPwHash ( <ID> ) - Gibt den Passworthash aus.

	setData ( <ID>, <Schlüssel>, <Wert> ) - Setzt Metadaten. (Wird erst bei save() gesynct.)
	any getData ( <ID>, <Schlüssel> ) - Gibt bestimmte Metadaten aus.
	
	setPlayer( <ID> , <Spielerobjekt> ) - Setzt das Spielerobjekt.
	player getPlayer( <ID> ) - Gibt das Spielerobjekt aus, nil wenn der Spieler offline ist.

]]

acc =
{
	data = {},
	plr2acc = {}
}

-- Account-Daten, die hier gespeichert werden:
-- [ID]
-- Name
-- Passwort-Hash
-- Meta-Info (JSON-String)
-- Modified-Flag
-- Spieler-Objekt (wenn ingame)



function acc.onStart()
	log('acc.onStart')
	l10n.load('acc')
	acc.initDB()
	acc.loadAll()
end

function acc.onStop()
	log('acc.onStop')
end

base.addModule('acc', acc.onStart, acc.onStop, 'db')


---- Allgemeine Tools ----

-- Table erstellen, wenn nicht vorhanden.
function acc.initDB()
	return db.createTable('accounts (id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32) NOT NULL, pwhash VARCHAR(32) NOT NULL, meta TEXT NOT NULL)')
end


-- Tool um einen bestimmten Eintrag eines Accounts zu updaten.
function acc.updateDB(AcID, Key, Value)
	return db.query('UPDATE accounts SET '..Key..'="'..db.escQS(Value)..'" WHERE id='..AcID)
end


-- Dem zum Spieler gehörenden Account finden.
function acc.findByPlayer(Plr)
	return acc.plr2acc[Plr]
end


-- Account mittels Namen finden.
function acc.findByName(Name)
	for k,v in pairs(acc.data) do
		if v.name == Name then
			return k
		end
	end
	return nil
end


-- Account erstellen.
function acc.create(Name, PwHash)
	if acc.findByName(Name) then return nil end
	local acid = #acc.data
	acc.data[acid] = { name=Name, pwhash=PwHash, meta={}, syncmeta=false, plr=nil }
	db.query('INSERT INTO accounts (name,pwhash,meta) VALUES ("'..db.escQS(Name)..'","'..db.escQS(PwHash)..'","'..db.escQS(toJSON(tbl))..'")')
	return acid
end


-- Account löschen.
function acc.delete(AcID)
	if acc.data[AcID] == nil then return nil end
	acc.data[AcID] = nil
	db.query('DELETE FROM accounts WHERE ID='..AcID)
end


---- Das Laden und Speichern ----

-- Alle Accounts laden.
function acc.loadAll()
	local tbl = db.query('SELECT id,name,pwhash,meta FROM accounts')
	if not tbl or #tbl == 0 then return end

	for i = 1, #tbl, 1 do
		acc.data[tonumber(tbl[i].id)] = { name=tbl[i].name, pwhash=tbl[i].pwhash, meta=fromJSON(tbl[i].meta), syncmeta=false, plr=nil }
	end
end


-- Alle Metadaten speichern.
function acc.saveAll()
	for k,v in pairs(acc.data) do
		acc.save(k)
	end
end


-- Metadaten eines bestimmten Accounts speichern.
function acc.save(AcID)
	if acc.data[AcID] == nil then return end
	if acc.data[AcID].syncmeta == false then return end
	acc.updateDB(AcID, 'meta', toJSON(acc.data[AcID].meta))
end


-- Existiert ein Account mit dieser ID?
function acc.exists(AcID)
	if acc.data[AcID] == nil then return false end
	return true
end


---- Account Daten lesen und setzen ----

-- Namen abfragen.
function acc.getName(AcID)
	if acc.data[AcID] == nil then return nil end
	return acc.data[AcID].name
end


-- Namen setzen.
function acc.setName(AcID, Name)
	if acc.data[AcID] == nil then return end
	acc.data[AcID].name = Name
	acc.updateDB(AcID, 'name', Name)
end


-- Passwort-Hash abfragen. (Oder checkAccPw?)
function acc.getPwHash(AcID)
	if acc.data[AcID] == nil then return nil end
	return acc.data[AcID].pwhash
end
-- ^- Passwort sollte nur auf dem Client ungehasht vorliegen.
-- TODO: Entsprechende Hash-Funktion im Clientscript bauen. -> Mit Salz! :D


-- Passwort-Hash setzen.
function acc.setPwHash(AcID, PwHash)
	if acc.data[AcID] == nil then return end
	acc.data[AcID].pwhash = PwHash
	acc.updateDB(AcID, 'pwhash', PwHash)
end


-- Spieler-Objekt abfragen.
function acc.getPlayer(AcID)
	if acc.data[AcID] == nil then return nil end
	return acc.data[AcID].plr
end


-- Metadaten setzen.
function acc.setData(AcID, Key, Value)
	if acc.data[AcID] == nil then return end
	acc.data[AcID].meta[Key] = Value
	acc.data[AcID].syncmeta = true
end


-- Metadaten abfragen.
function acc.getData(AcID, Key)
	if acc.data[AcID] == nil then return nil end
	return acc.data[AcID].meta[Key]
end


-- Spielerobjekt setzen.
function acc.setPlayer(AcID, Plr)
	if acc.data[AcID] == nil then return nil end
	acc.data[AcID].plr = Plr
end


-- Spielerobjekt abfragen.
function acc.getPlayer(AcID)
	if acc.data[AcID] == nil then return nil end
	return acc.data[AcID].plr
end



---- Speilerhandling ----


function acc.logIn(AcID, Name, PwHash, Plr)
	if (not acc.exists(AcID)) or (not Plr) then return false end
	if acc.data[AcID].name ~= Name then return false end
	if acc.data[AcID].pwhash ~= PwHash then return false end
	if acc.data[AcID].plr then return false end

	acc.data[AcID].plr = Plr
	acc.plr2acc[Plr] = AcID
	setPlayerName(Plr, Name)
	-- Jetzt noch wichtiges Zeug tun!
	-- Z.B. Spieler spawnen.
	log(Name..' logged in.')
	
	return true
end


function acc.logOut(AcID)
	log('LogOut: '..(AcID or 'nil'))
	if not acc.exists(AcID) then return end
	if not acc.data[AcID].plr then return end

	acc.save(acid)
	acc.data[AcID].plr = nil
	-- Jetzt noch wichtiges Zeug tun!
	-- Z.B. Spieler in Zuschauermodus versetzen.
	log(acc.data[AcID].name..' logged out.')
end


function acc.onPlayerJoin(Plr)
	if not Plr then Plr = source end
	
	-- ...

	local acid = acc.findByName(getPlayerName(Plr))
	
	if acc.exists(acid) then
		log('Account '..acid..' exists.')
	else
		log('Account not found. :C')
		return
	end
	
	log('Skill: '..tostring(acc.getData(acid, 'skill')))

end
addEventHandler('onPlayerJoin', g_Root, acc.onPlayerJoin)


function acc.onPlayerQuit(plr)
	if type(plr) ~= 'userdata' then
		plr = source
	end
	
	local acid = acc.findByPlayer(plr)
	acc.logOut(acid)
end
addEventHandler('onPlayerQuit', g_Root, acc.onPlayerQuit)


function acc.onLoginSubmit(Plr, Name, PwHash)
	if not Plr then Plr = source end
	
	acid = acc.findByName(Name)
	if not acid then
		log('Login failed!')
		triggerClientEvent(Plr, 'acc.onLoginResponse', Plr, true, t('acc.InvalidAccName'))
		return
	end
	
	if acc.data[acid].plr then
		log('Login failed!')
		triggerClientEvent(Plr, 'acc.onLoginResponse', Plr, true, t('acc.AccInUsage'))
		return
	end
	
	if not acc.logIn(acid, Name, PwHash, Plr) then
		log('Login failed!')
		triggerClientEvent(Plr, 'acc.onLoginResponse', Plr, true, t('acc.PwIncorrect'))
		return
	end
	triggerClientEvent(Plr, 'acc.onLoginResponse', Plr, false)
	plr.respawn(acid)
end
addEvent('acc.onLoginSubmit', true)
addEventHandler('acc.onLoginSubmit', g_Root, acc.onLoginSubmit)