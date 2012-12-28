--[[ Scoreboard (board)

Beschreibung:
	Das Scoreboard.


Funktionen:
	addColumn ( <Name>, <Breite> ) - Neue Spalte erstellen.
	removeColumn ( <Name> ) - Spalte lÃ¶schen.

]]

board =
{
	res = getResourceFromName('scoreboard'),
	columns = {},
	index = 1
}


function board.onStart()
	log('board.onStart')
end

function board.onStop()
	log('board.onStop')
	for i,v in ipairs(board.columns) do
		call(board.res, 'removeScoreboardColumn', v)
	end
end

base.addModule('board', board.onStart, board.onStop)


function board.addColumn(Name, Width)
	call(board.res, 'addScoreboardColumn', Name, g_Root, board.index, Width)
	board.columns[#board.columns+1] = Name
end

function board.removeColumn(Name)
	call(board.res, 'removeScoreboardColumn', Name)
	for i,v in ipairs(board.columns) do
		if v == Name then
			table.remove(board.columns, i)
			return
		end
	end
end