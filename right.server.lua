--[[ Rechte (rights)

Beschreibung:
	Stellt Funktionen für die überprüfung der Rechte zur Verfügung.


Funktionen:
	initDB() - Initialisiert die Datenbank
	addRight(groupID,rightID) - Gibt einer Gruppe das Recht für ein Recht
	deleteRight(groupID,rightID) - Nimmt einer Gruppe das Recht für ein Recht
	hasUserRight(userID,rightID) - Überprüft ob der User das Recht hat für ein Recht
	hasGroupRight(groupID,rightID) - Überprüft ob die Gruppe das Recht hat für ein Recht
]]

right = {}

function right.onStart()
	log('right.onStart')
	right.initDB()
end

function right.onStop()
	log('right.onStop')
end

base.addModule('right', right.onStart, right.onStop, 'db', 'grp', 'acc')

function right.initDB()
	if(db.createTable('RightToGroup (rightID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, groupID INT(10), status INT(1))')) then
		if(db.createTable('Rights (ID INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, name VARCHAR(32))')) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function right.deleteRight(groupID,rightID)
	local result = db.query(db.escQS('SELECT * FROM RightToGroup WHERE groupID=' + groupID + ' AND rightID=' + rightID + ' LIMIT 2;'))
	if(mysql_rows(result) == 0) then
		return 1
	elseif(mysql_rows(result) == 1) then
		db.query(db.escQS('UPDATE RightToGroup SET status=0 WHERE groupID=' + groupID + ' AND rightID=' + rightID + ' LIMIT 1;'))
		return 1	
	else
		db.query(db.escQS('DELETE FROM RightToGroup WHERE groupID=' + groupID + ' AND rightID=' + rightID + ';'))
		log('right.server.lua: All Entrys with GroupID(' + groupID + ') AND RightID(' + rightID + ') deleted!')
		log('right.server.lua: Something doesnt work here!')
		db.query(db.escQS('INSERT INTO RightToGroup (groupID,rightID,status)VALUES(' + groupID + ',' + rightID + ',0);'))
		return 1	
	end
end

function right.addRight(groupID,rightID)
	local result = db.query(db.escQS('SELECT * FROM RightToGroup WHERE groupID=' + groupID + ' AND rightID=' + rightID + ' LIMIT 2;'))
	if(mysql_rows(result) == 0) then
		db.query(db.escQS('INSERT INTO RightToGroup (groupID,rightID,status)VALUES(' + groupID + ',' + rightID + ',1);'))
		return 1
	elseif(mysql_rows(result) == 1) then
		db.query(db.escQS('UPDATE RightToGroup SET status=1 WHERE groupID=' + groupID + ' AND rightID=' + rightID + ' LIMIT 1;'))
		return 1		
	else
		db.query(db.escQS('DELETE FROM RightToGroup WHERE groupID=' + groupID + ' AND rightID=' + rightID + ';'))
		log('right.server.lua: All Entrys with GroupID(' + groupID + ') AND RightID(' + rightID + ') deleted!')
		log('right.server.lua: Something doesnt work here!')
		db.query(db.escQS('INSERT INTO RightToGroup (groupID,rightID,status)VALUES(' + groupID + ',' + rightID + ',1);'))
		return 1	
	end
end

function hasGroupRight(groupID,rightID)
	local result = db.query(db.escQS('SELECT * FROM RightToGroup WHERE groupID=' + groupID + ' AND rightID=' + rightID + ' AND status=1 LIMIT 1;'))
	if(mysql_rows(result) > 0) then
		return true
	else
		return false
	end
end