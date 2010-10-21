--[[ Localization (l10n)

Beschreibung:
	Für lokalisierung von Texten.
	L10N ist eine weitverbreitete Abkürzung für 'Localization',
	wers nicht glaubt kann ja mal in Wikipedia gucken. ^.^
	
Functionen:
	load ( <Name> ) -  Läd eine Lokalisierungsdatei.

]]

l10n =
{
	t_meta = {},
	t = {},
	language = 'de'
	--languages = {}
}

l10n.t_meta.__index = function(t,key)
	return '<'..key..'>'
end

setmetatable(l10n.t, l10n.t_meta)


function t(Key)
	return l10n.t[Key]
end


function l10n.loadNode(Root, Path)
	local idx = 0
	local key = nil
	local ln = nil
	repeat
		key = xmlFindChild(Root, 'key', idx)
		if not key then break end
		idx = idx + 1

		ln = xmlFindChild(key, l10n.language, 0)
		if ln then
			l10n.t[Path..xmlNodeGetAttribute(key, 'id')] = xmlNodeGetValue(ln)
		end
		
		l10n.loadNode(key, Path..xmlNodeGetAttribute(key, 'id')..'.')
	until false

	return true
end

function l10n.load(Name)
	local root = xmlLoadFile(':test/locale/'..Name..'.xml')
	if not root then return false end
	local ret = l10n.loadNode(root, Name..'.')
	xmlUnloadFile(root)
	return ret
end