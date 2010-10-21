--[[ Admin System (asys)

	Beschreibung:
		Das Adminsystem
		
	Funktionen:
		asys.onStart()
		asys.onStop()
		
	Kommandos:
		/porttoplayer
		/portplayer
		/kick
]]

asys = 
{

}

function asys.onStart()
	log('asys.onStart()')
	addCommandHandler('porttoplayer',
		function(playerSource, commandName, arg1)
			if grp.containsUser(acc.findByPlayer(playerSource, 'mtx.supporter')) then
				local alivePlayers = getAlivePlayers()
				for k,v in pairs(alivePlayers) do
					if acc.getName(acc.findByPlayer(v)) == arg1 then
						local vDim = getElementDimension(v)
						local x, y, z = getElementPosition(v)
						setElementPosition(playerSource, x, y, z)
						setElementDimension(playerSource, vDim)
						outputChatBox('[asys.porttoplayer]: Teleportation abgeschlossen', playerSource)
						return
					end
				end
			end
		end
	)
	addCommandHandler('portplayer',
		function(playerSource, commandName, arg1)
			if grp.containsUser(acc.findByPlayer(playerSource, 'mtx.supporter')) then
				local alivePlayers = getAlivePlayers()
				for k,v in pairs(alivePlayers) do
					if acc.getName(acc.findByPlayer(v)) == arg1 then
						local pSourceDim = getElementDimension(playerSource)
						local x, y, z = getElementPosition(playerSource)
						setElementPosition(v, x, y, z)
						setElementDimension(v, pSourceDim)
						outputChatBox('[asys.portplayer]: Teleportation abgeschlossen', playerSource)
						return
					end
				end
			end
		end
	)
	addCommandHandler('kick',
		function(playerSource, commandName, arg1)
			if grp.containsUser(acc.findByPlayer(playerSource, 'mtx.supporter')) then
				local alivePlayers = getAlivePlayers()
				for k, v in pairs(alivePlayers) do
					if acc.getName(acc.findByPlayer(v)) == arg1 then
						kickPlayer(v, playerSource)
						outputChatBox('[asys.kick]: Spieler erflogreich vom Server gekickt', playerSource)
						return
					end
				end
			end
		end
	)
end

function asys.onStop()
	log('asys.onStop()')
end

base.addModule('asys', asys.onStart, asys.onStop, 'grp', 'acc')

