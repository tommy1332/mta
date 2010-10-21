gui =
{
	wins = {},
	open = 0
}

function gui.register(Win)
	gui.wins[Win] = { anim = false }
end


function gui.getAni(Win)
	return gui.wins[Win].ani
end


function gui.show(Win)
	local v = gui.wins[Win]

	if v.ani then return end
	
	v.ani = 'show'

	guiSetAlpha(Win, 0.0)
	guiSetVisible(Win, true)
	guiBringToFront(Win)
	
	gui.open = gui.open + 1
	showCursor(true)
	guiSetInputEnabled(true)

	v.w, v.h = guiGetSize(Win, false)
	Animation.createAndPlay(Win,
	{
		from = 0,
		to = 1,
		time = 300,
		fn = gui.showAnim,
		endFn = gui.showAnimEnd
	})
end

function gui.showAnim(e, t)
	guiSetAlpha(e, t)
	local v = gui.wins[e]
	guiSetSize(e, v.w, v.h*t, false)
end

function gui.showAnimEnd(e, a, p)
	gui.wins[e].ani = false
	local v = gui.wins[e]
	guiSetSize(e, v.w, v.h, false)
end


function gui.hide(Win)
	local v = gui.wins[Win]
	
	if v.ani then return end
	
	v.ani = 'hide'
	
	gui.open = gui.open - 1
	if gui.open <= 0 then
		showCursor(false)
		guiSetInputEnabled(false)
	end

	v.w, v.h = guiGetSize(Win, false)
	v.aniObj = Animation.createAndPlay(Win,
	{
		from = 1,
		to = 0,
		time = 300,
		fn = gui.hideAnim,
		endFn = gui.hideAnimEnd
	})
end

function gui.hideAnim(e, t)
	guiSetAlpha(e, t)
	local v = gui.wins[e]
	guiSetSize(e, v.w, v.h*t, false)
end

function gui.hideAnimEnd(e, a, p)
	gui.wins[e].ani = false
	guiSetVisible(e, false)
	local v = gui.wins[e]
	guiSetSize(e, v.w, v.h, false)
end