--[[ Depency Sorted List (dsl)

Beschreibung:
	Klasse um tolle DSLs zu erstellen und zu 'kompilieren'.
	DSL heisst zu deutsch 'Abhängigkeit sortierte Liste', d.h. dass jedem Wert ein Schlüssel und
	beliebig viele Abhängigkeiten zugeordnet werden.
	Die Werte werden so sortiert, dass sie erst dann auftauchen, wenn ihre Abhängigkeiten schon in der Liste sind,
	insofern muss es mindestens einen Wert ohne Abhängigkeiten geben.


Funktionen:
	dsl createDSL ( ) - Erstellt eine DSL-Instanz.
	dsl:add ( <Schlüssel>, <Wert>, <Abhängigkeiten -> ...> ) - Fügt einer DSL neue Werte hinzu.
	dsl:compile ( <Rückwärts> ) - Kompiliert eine DSL, dabei wird die DSL sortiert und alles außer den Werten gelöscht.


Kommentar:
	Ich hoffe mal, es sind genug Kommentare vorhanden, denn der Code an sich ist leider zwangsläufig ein Monster. :X
	Es gibt außerdem die Einschränkung, das man keine Abhängigkeits-Loops erstellen sollte, d.h. das zwei Einträge von sich gegenseitig abhängig sind.
	Zwar gibt es eine Notsicherung gegen eine Unendlich-Schleife, aber toll explizit wird sowas nicht behoben!
		Henry Kielmann - 2010

]]


dsl = {}

function createDSL()
	return table.copy(dsl)
end

function dsl:add(Key, Value, ...)
	self[#self+1] = { Key, Value, { ... } }
end

function dsl:compile(Reverse)
	-- Schritt 1: Alle Abhängigkeiten löschen, die es nicht gibt.

	for i = 1, #self, 1 do
		-- Für jeden Eintrag...

		for k,v in pairs(self[i][3]) do -- TODO: Warum zur HÖLLE ist es Index 3? Hä? HÄH? Das ist UN-LO-GISCH!13lf :C
			local found = false

			-- Für jede Abhängigkeit...
			for j = 1, #self, 1 do
				-- In allen Einträgen nach dessen Vorkommen suchen.
				if self[j][1] == v then
					found = true
					break
				end
			end
			
			if found == false then
				-- Wenn es diese Abhängigkeit nicht gibt: diese löschen!
				table.remove(self[i][3], k)
			end
			
		end
	end
	
	
	-- Schritt 2: Nach Bubblesort-Prinzip Key-Value-Paare in den output-Table verfrachten.
	
	local out = {}
	
	local finished = false
	for run = 1, 99, 1 do
	
		local i = 0
		local imax = #self
		repeat
			i = i + 1
			if i > imax then break end

			-- Für jeden Eintrag...
			local found = 0
			
			for k,v in pairs(self[i][3]) do
				-- Für jede Abhängigkeit...
				for j = 1, #out, 1 do
					-- In allen fertigen Einträgen nach dessen Vorkommen suchen.
					if out[j][1] == v then
						found = found + 1
					end
				end
			end

			if found >= #self[i][3] then
				-- Wenn alle Abhängigkeiten schon in der Liste sind: Verschieben! :D
				out[#out+1] = { self[i][1], self[i][2] }
				table.remove(self, i)
				
				if #self == 0 then
					finished = true
					break
				else
					i = i - 1 -- Index fixen
					imax = imax - 1
				end
			end

		until false
		
		if finished == true then
			break
		end
	
	end
	
	
	-- Schritt 3: Value-Liste erstellen.

	self = {}
	for i = 1, #out, 1 do
		self[i] = out[i][2]
	end
	return self
end