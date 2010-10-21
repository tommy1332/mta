--[[ Datenbank (db)

Beschreibung:
	Stellt Funktionen für die Kommunikation mit der Datenbank zur Verfügung.
	Aktuell wird intern MySQL verwendet. (Das Modul 'mta_mysql' wird benötigt!)


Variablen:
	connection - Internes DB-Handle. Sollte nach möglichkeit nicht verwendet werden.
							 Lieber ein Featurerequest machen.


Funktionen:
	connect ( ) - Stellt eine Verbindung zur Datenbank her. (Siehe Einstellungswerte.)
	disconnect ( ) - Trennt eine bestehende Verbindung.
	bool handleError ( ) - Prüft auf SQL-Fehler und loggt diese ggF.
	table/nil query ( <Kommando> ) - Führt eine SQL-Query aus.
	string escQS ( <String> ) - Sichert einen String gegen SQL-Injections ab. (D.h. alle SQL-Befehle werden escapt.)
	createTable ( <Definition> ) - Sofern nicht vorhanden, wird eine neue Tabelle mit der angegebenen Definition erstellt.

	
Einstellungswerte:
	hostname - Die URL, auf der der DB-Server läuft.
	username - Der Benutzer.
	password - Das Passwort (wenn benötigt).
	database - Der Name der Datenbank.

]]


db =
{
	connection = nil -- MySQL-Handle
}


-- Verindung zur DB aufbauen.
function db.connect()
	log('db.onStart')

	if db.connection == nil then
		log("mysql_connect("..get('db/hostname')..", "..get('db/username')..", "..get('db/password')..", "..get('db/database')..")")
		db.connection = mysql_connect(get('db/hostname'), get('db/username'), get('db/password'), get('db/database'))
		if not db.connection then
			log('mysql_connect failed: [ hostname: '..get('db/hostname')..', username: '..get('db/username')..', database: '..get('db/database')..' ]')
		else
			db.handleError('mysql_connect')
		end
	end
end


-- Verbindung beenden.
function db.disconnect()
	log('db.onStop')

	if db.connection == nil then
		return
	end
	
	mysql_close(db.connection)
	db.connection = nil
end

base.addModule('db', db.connect, db.disconnect)


-- Errorhandling für Dummies. :3
function db.handleError(what)
	if mysql_errno(db.connection) == 0 then
		return false
	end
	log(what..' failed: ('..mysql_errno(db.connection)..') '..mysql_error(db.connection))
	return true
end


-- Einen Query-String ausführen
function db.query(query)
	local result = mysql_query(db.connection, query)
	
	if db.handleError('mysql_query') then
		return nil
	end
	
	if not result then
		return nil
	end

	local tbl = {}
	for result,row in mysql_rows_assoc(result) do
		tbl[#tbl+1] = row
	end

	mysql_free_result(result)
	
	if #tbl == 0 then return nil end
	return tbl
end


-- String escapen um Code-Intrusion zu verhindern.
function db.escQS(str)
	return mysql_escape_string(db.connection, str)
end


---- Tools ----

function db.createTable(def)
	return db.query('CREATE TABLE IF NOT EXISTS '..def)
end