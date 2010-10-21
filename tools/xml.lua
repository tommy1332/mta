--[[ XML-Tools

Beschreibung:
	Ein paar Hilfsfunktionen, die den Umgang mit XML-Dateien erleichtern.


Funktionen:
	xmlnode xmlNodeByPath ( <Startknoten>, <Pfad>, <Nicht existierende Knoten erstellen?> ) - Sucht/Erstellt einen Knoten mit Pfadangabe.

]]


function xmlNodeByPath(Root, Path, Create)
	local last = Root
	local find = nil
	local a = split(Path, string.byte('/'))
	for k,v in ipairs(a) do
		find = xmlFindChild(last, v, 0)
		if not find then
			if not Create then return nil end
			last = xmlCreateChild(last, v)
		else
			last = find
		end
	end
	return last
end


function xmlLoadOrCreate(Path, Root)
	local rootNode = xmlLoadFile(Path)
	if not rootNode then
		rootNode = xmlCreateFile(Path, Root)
	end
	return rootNode
end