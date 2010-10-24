--[[ Depency Sorted List (dsl)

Beschreibung:
	Klasse um tolle DSLs zu erstellen und zu 'kompilieren'.
	DSL heisst zu deutsch 'Abh�ngigkeit sortierte Liste', d.h. dass jedem Wert ein Schl�ssel und
	beliebig viele Abh�ngigkeiten zugeordnet werden.
	Die Werte werden so sortiert, dass sie erst dann auftauchen, wenn ihre Abh�ngigkeiten schon in der Liste sind,
	insofern muss es mindestens einen Wert ohne Abh�ngigkeiten geben.


Funktionen:
	dsl createDSL ( ) - Erstellt eine DSL-Instanz.
	dsl:add ( <Schl�ssel>, <Wert>, <Abh�ngigkeiten -> ...> ) - F�gt einer DSL neue Werte hinzu.
	dsl:compile ( <R�ckw�rts> ) - Kompiliert eine DSL, dabei wird die DSL sortiert und alles au�er den Werten gel�scht.


Kommentar:
	Ich hoffe mal, es sind genug Kommentare vorhanden, denn der Code an sich ist leider zwangsl�ufig ein Monster. :X
	Es gibt au�erdem die Einschr�nkung, das man keine Abh�ngigkeits-Loops erstellen sollte, d.h. das zwei Eintr�ge von sich gegenseitig abh�ngig sind.
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
	-- Schritt 1: Alle Abh�ngigkeiten l�schen, die es nicht gibt.

	for i = 1, #self, 1 do
		-- F�r jeden Eintrag...

		for k,v in pairs(self[i][3]) do -- TODO: Warum zur H�LLE ist es Index 3? H�? H�H? Das ist UN-LO-GISCH!13lf :C
			local found = false

			-- F�r jede Abh�ngigkeit...
			for j = 1, #self, 1 do
				-- In allen Eintr�gen nach dessen Vorkommen suchen.
				if self[j][1] == v then
					found = true
					break
				end
			end
			
			if found == false then
				-- Wenn es diese Abh�ngigkeit nicht gibt: diese l�schen!
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

			-- F�r jeden Eintrag...
			local found = 0
			
			for k,v in pairs(self[i][3]) do
				-- F�r jede Abh�ngigkeit...
				for j = 1, #out, 1 do
					-- In allen fertigen Eintr�gen nach dessen Vorkommen suchen.
					if out[j][1] == v then
						found = found + 1
					end
				end
			end

			if found >= #self[i][3] then
				-- Wenn alle Abh�ngigkeiten schon in der Liste sind: Verschieben! :D
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