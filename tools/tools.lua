function Min(A,B)
	if A < B then
		return A
	else
		return B
	end
end

function Max(A,B)
	if A > B then
		return A
	else
		return B
	end
end

function BoundBy(V,A,B)
	if V < A then
		return A
	elseif V > B then
		return B
	end
	return V
end

function Inside(V,A,B)
	return V > A and V < B
end

function Swap(A,B)
	local c = A
	A = B
	B = c
end

function Wrap(V,A,B)
	-- if not B - A then return A end
	
	while V < A do
		V = V + ( B - A )
	end

	while V >= B do
		V = V - ( B - A )
	end

	return V
end





function Lerp(P0, P1, Factor)
	return P0*(1.0-Factor) + P1*Factor
end

-- table table.copy( table tab )
-- http://wiki.mtasa.com/wiki/Table.copy

function table.copy(tab)
    local ret = {}
    for key, value in pairs(tab) do
        if (type(value) == "table") then ret[key] = table.copy(value)
        else ret[key] = value end
    end
    return ret
end


-- table setTableProtected( table tbl )
-- http://wiki.mtasa.com/wiki/SetTableProtected

function setTableProtected (tbl)
  return setmetatable ({}, 
    {
    __index = tbl,  -- read access gets original table item
    __newindex = function (t, n, v)
       error ("attempting to change constant " .. 
             tostring (n) .. " to " .. tostring (v), 2)
      end -- __newindex, error protects from editing
    })
end


-- void Check( string funcname, var types1, var arg1, string argname1, [ ... ] )
-- http://wiki.mtasa.com/wiki/Check

function Check(funcname, ...)
    local arg = {...}
 
    if (type(funcname) ~= "string") then
        error("Argument type mismatch at 'Check' ('funcname'). Expected 'string', got '"..type(funcname).."'.", 2)
    end
    if (#arg % 3 > 0) then
        error("Argument number mismatch at 'Check'. Expected #arg % 3 to be 0, but it is "..(#arg % 3)..".", 2)
    end
 
    for i=1, #arg-2, 3 do
        if (type(arg[i]) ~= "string" and type(arg[i]) ~= "table") then
            error("Argument type mismatch at 'Check' (arg #"..i.."). Expected 'string' or 'table', got '"..type(arg[i]).."'.", 2)
        elseif (type(arg[i+2]) ~= "string") then
            error("Argument type mismatch at 'Check' (arg #"..(i+2).."). Expected 'string', got '"..type(arg[i+2]).."'.", 2)
        end
 
        if (type(arg[i]) == "table") then
            local aType = type(arg[i+1])
            for _, pType in next, arg[i] do
                if (aType == pType) then
                    aType = nil
                    break
                end
            end
            if (aType) then
                error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..table.concat(arg[i], "' or '").."', got '"..aType.."'.", 3)
            end
        elseif (type(arg[i+1]) ~= arg[i]) then
            error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..arg[i].."', got '"..type(arg[i+1]).."'.", 3)
        end
    end
end


-- string FormatDate( string format, [ string escaper = "'", int timestamp = GetTimestamp() ] )
-- http://wiki.mtasa.com/wiki/FormatDate

local gWeekDays = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
function FormatDate(format, escaper, timestamp)
	Check("FormatDate", "string", format, "format", {"nil","string"}, escaper, "escaper", {"nil","string"}, timestamp, "timestamp")
 
	escaper = (escaper or "'"):sub(1, 1)
	local time = getRealTime(timestamp)
	local formattedDate = ""
	local escaped = false
 
	time.year = time.year + 1900
	time.month = time.month + 1
 
	local datetime = { d = ("%02d"):format(time.monthday), h = ("%02d"):format(time.hour), i = ("%02d"):format(time.minute), m = ("%02d"):format(time.month), s = ("%02d"):format(time.second), w = gWeekDays[time.weekday+1]:sub(1, 2), W = gWeekDays[time.weekday+1], y = tostring(time.year):sub(-2), Y = time.year }
 
	for char in format:gmatch(".") do
		if (char == escaper) then escaped = not escaped
		else formattedDate = formattedDate..(not escaped and datetime[char] or char) end
	end
 
	return formattedDate
end



---- OTHER STUFF ----

function table.find(t, ...)
	local args = { ... }
	if #args == 0 then
		for k,v in pairs(t) do
			if v then
				return k
			end
		end
		return false
	end
	
	local value = table.remove(args)
	if value == '[nil]' then
		value = nil
	end
	for k,v in pairs(t) do
		for i,index in ipairs(args) do
			if type(index) == 'function' then
				v = index(v)
			else
				if index == '[last]' then
					index = #v
				end
				v = v[index]
			end
		end
		if v == value then
			return k
		end
	end
	return false
end

function table.findall(t, ...)
	local args = { ... }
	local result = {}
	if #args == 0 then
		for k,v in pairs(t) do
			if v then
				result[#result+1] = k
			end
		end
		return result
	end
	
	local value = table.remove(args)
	if value == '[nil]' then
		value = nil
	end
	for k,v in pairs(t) do
		for i,index in ipairs(args) do
			if type(index) == 'function' then
				v = index(v)
			else
				if index == '[last]' then
					index = #v
				end
				v = v[index]
			end
		end
		if v == value then
			result[#result+1] = k
		end
	end
	return result
end

function table.removevalue(t, val)
	for i,v in ipairs(t) do
		if v == val then
			table.remove(t, i)
			return i
		end
	end
	return false
end

function table.merge(appendTo, ...)
	-- table.merge(targetTable, table1, table2, ...)
	-- Append the values of one or more tables to a target table.
	--
	-- In the arguments list, a table pointer can be followed by a
	-- numeric or textual key. In that case the values in the table
	-- will be assumed to be tables, and of each of these the value
	-- corresponding to the given key will be appended instead of the
	-- subtable itself.
	local appendval
	local args = { ... }
	for i,a in ipairs(args) do
		if type(a) == 'table' then
			for k,v in pairs(a) do
				if args[i+1] and type(args[i+1]) ~= 'table' then
					appendval = v[args[i+1]]
				else
					appendval = v
				end
				if appendval then
					if type(k) == 'number' then
						table.insert(appendTo, appendval)
					else
						appendTo[k] = appendval
					end
				end
			end
		end
	end
	return appendTo
end

function table.map(t, callback)
	for k,v in ipairs(t) do
		t[k] = callback(v)
	end
	return t
end

function table.dump(t, caption, depth)
	if not depth then
		depth = 1
	end
	if depth == 1 and caption then
		outputConsole(caption .. ':')
	end
	if not t then
		outputConsole('Table is nil')
	elseif type(t) ~= 'table' then
		outputConsole('Argument passed is of type ' .. type(t))
		local str = tostring(t)
		if str then
			outputConsole(str)
		end
	else
		local braceIndent = string.rep('  ', depth-1)
		local fieldIndent = braceIndent .. '  '
		outputConsole(braceIndent .. '{')
		for k,v in pairs(t) do
			if type(v) == 'table' and k ~= 'siblings' and k ~= 'parent' then
				outputConsole(fieldIndent .. tostring(k) .. ' = ')
				table.dump(v, nil, depth+1)
			else
				outputConsole(fieldIndent .. tostring(k) .. ' = ' .. tostring(v))
			end
		end
		outputConsole(braceIndent .. '}')
	end
end

function table.flatten(t, result)
	if not result then
		result = {}
	end
	for k,v in ipairs(t) do
		if type(v) == 'table' then
			table.flatten(v, result)
		else
			table.insert(result, v)
		end
	end
	return result
end

function table.rep(value, times)
	local result = {}
	for i=1,times do
		table.insert(result, value)
	end
	return result
end

function table.each(t, index, callback, ...)
	local args = { ... }
	if type(index) == 'function' then
		table.insert(args, 1, callback)
		callback = index
		index = false
	end
	for k,v in pairs(t) do
		callback(index and v[index] or v, unpack(args))
	end
	return t
end

function string.split(str, delim)
	local startPos = 1
	local endPos = string.find(str, delim, 1, true)
	local result = {}
	while endPos do
		table.insert(result, string.sub(str, startPos, endPos-1))
		startPos = endPos + 1
		endPos = string.find(str, delim, startPos, true)
	end
	table.insert(result, string.sub(str, startPos))
	return result
end

function xmlToTable(xmlFile, leafAttrs)
	-- takes an xml file with <group>s of leaf nodes (groups may be nested),
	-- and returns it as a table of the form { 'group', name='groupname', children={ {'leafName', leafattr1='attr1', ...}, ... } }
	local xml = getResourceConfig(xmlFile)
	if not xml then
		outputChatBox(xmlFile .. ' could not be opened')
		return false
	end
	local result = {}
	_addXMLChildrenToTable(xml, xmlNodeGetAttribute(xml, 'type'), leafAttrs, result)
	xmlUnloadFile(xml)
	addTreeMetaInfo(result)
	return result
end

function _addXMLChildrenToTable(parentNode, leafName, leafAttrs, targetTable)
	local i = 0
	local groupNode = xmlFindChild(parentNode, 'group', 0)
	while groupNode do
		local group = {'group', name=xmlNodeGetAttribute(groupNode, 'name'), children={}}
		table.insert(targetTable, group)
		_addXMLChildrenToTable(groupNode, leafName, leafAttrs, group.children)
		i = i + 1
		groupNode = xmlFindChild(parentNode, 'group', i)
	end
	
	i = 0
	local leafNode = xmlFindChild(parentNode, leafName, 0)
	while leafNode do
		local leaf = {leafName}
		table.insert(targetTable, leaf)
		for k,attr in ipairs(leafAttrs) do
			leaf[attr] = ( attr == 'id' and tonumber(xmlNodeGetAttribute(leafNode, attr)) or xmlNodeGetAttribute(leafNode, attr) )
		end
		i = i + 1
		leafNode = xmlFindChild(parentNode, leafName, i)
	end
end

function followTreePath(root, ...)
	local item = root
	local path = table.flatten({...})
	for i,pathPart in ipairs(path) do
		if pathPart == '..' then
			item = item.parent
		else
			item = (item.children and item.children[pathPart]) or item[pathPart]
		end
		if not item then
			return false
		end
	end
	return item
end

function treePathToString(root, ...)
	local item = root
	local result = ''
	local path = table.flatten({...})
	if #path == 0 then
		return '/'
	end
	for i,pathPart in ipairs(path) do
		item = (item.children and item.children[pathPart]) or item[pathPart]
		if not item then
			return false
		end
		result = result .. '/' .. item.name
	end
	return result
end

function addTreeMetaInfo(targetTable, parentTable, depth)
	if not depth then
		depth = 1
	end
	local maxSubDepth = depth
	for k,v in pairs(targetTable) do
		if type(v) == 'table' then
			v.depth = depth
			v.parent = parentTable or targetTable
			v.siblings = targetTable
			if v.children then
				addTreeMetaInfo(v.children, v, depth+1)
				if v.maxSubDepth > maxSubDepth then
					maxSubDepth = v.maxSubDepth
				end
			end
		end
	end
	(parentTable or targetTable).maxSubDepth = maxSubDepth
end

function treeHasMetaInfo(tree)
	for k,v in pairs(tree) do
		if type(v) == 'table' then
			return v.depth and true or false
		end
	end
	return false
end

function applyToLeaves(t, callback)
	-- apply a callback function to leaves of a table created by xmlToTable()
	for i,item in ipairs(t) do
		if type(item) == 'table' then
			if item.children then
				applyToLeaves(item.children, callback)
			else
				callback(item)
			end
		end
	end
end
