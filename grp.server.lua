--[[ Gruppensystem (grp)

Beschreibung:
	Ein universelles Gruppensystem mit Baumstruktur und 1337.


Funktionen:
	initDB ( ) - Initiiert die Tabelle in der Datenbank.

]]

grp =
{
	data = {}
}

-- Gruppen-Table:
---- ID
---- Name
---- Childs
---- ...

function omgtest(name, group)
	if grp.containsUser(name, group) then
		log(name..' is in group '..group)
	else
		log(name..' is not in group '..group)
	end
end

function grp.onStart()
	log('grp.onStart')
	grp.initDB()
	grp.loadAll()

	omgtest(2, 'test')
	omgtest(2, 'test.wtf')
	omgtest(3, 'test')
	omgtest(3, 'test.wtf')
	omgtest(4, 'test')
	omgtest(4, 'test.wtf')
end

function grp.onStop()
	log('grp.onStop')
end

base.addModule('grp', grp.onStart, grp.onStop, 'db')


---- Allgemeine Tools ----

-- Table erstellen, wenn nicht vorhanden.
function grp.initDB()
	return db.createTable('groups (id VARCHAR(32) NOT NULL PRIMARY KEY, parent VARCHAR(32) NOT NULL, members TEXT NOT NULL)')
end


-- Tool um einen bestimmten Eintrag einer Gruppe zu updaten.
function grp.updateDB(Id, Key, Value)
	return db.query('UPDATE groups SET '..Key..'="'..db.escQS(Value)..'" WHERE id="'..db.escQS(Id)..'"')
end


-- Gruppe lÃ¶schen.
function grp.delete(GrID)
	-- Auch alle Childs lÃ¶schen!

	--if acc.data[AcID] == nil then return nil end
	--acc.data[AcID] = nil
	--db.query('DELETE FROM accounts WHERE ID='..AcID)
end


-- Alle Gruppen laden.
function grp.loadAll()
	local tbl = db.query('SELECT id,parent,members FROM groups')
	if not tbl or #tbl == 0 then return end
	grp.load(tbl, grp.data, '')
end

function grp.load(tbl, target, last)
	for i,v in ipairs(tbl) do
		if v.parent == last then
			target[v.id] = { _data = { members = v.members } }
			grp.load(tbl, target[v.id], v.id)
		end
	end
end

function grp.get(Name)
	local tbl = grp.data
	local a = Name:split('.')
	for i,v in ipairs(a) do
		tbl = tbl[v]
		if not tbl then return nil end
	end
	return tbl
end

function grp.containsUser(AcID, Group)
	-- Schauen, ob Group und AcID ein echter Wert ist
	if not Group or not AcID then
		return false
	end

	-- Wenn Group als String Ã¼bergeben wird ...
	if type(Group) == 'string' then
		Group = grp.get(Group) -- Group-Table holen!
		if not Group then return false end
	end

	-- Erstmal in der Wurzelgruppe suchen.
	local a = Group._data.members:split(',')
	for i,v in ipairs(a) do
		-- Eine Account-ID?
		if v:byte(1) == string.byte('#',1) then
			if v == '#'..tostring(AcID) then
				return true
			end
		end
		
		-- Okok, dann ists eine Gruppe!
		if grp.containsUser(AcID, v) then -- >:D
			return true
		end
	end
	
	-- Wenn da nichts gefunden wird, suchen wir in den Untergruppen. *rekursiv*
	for k,v in pairs(Group) do
		if k ~= '_data' then
			if grp.containsUser(AcID, v) then
				return true
			end
		end
	end

	return false
end
