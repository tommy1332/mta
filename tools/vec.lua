--[[ Vector (vec)

Beschreibung:
	Tolle generische Vektor Klasse :o


Funktionen:
	Vector( < Initiale Werte (geben auch die Dimension an) > ) - gibt einen N-dimensionalen Vektor zurück
]]

vec = {}
_vec = {}

function Vector( ... )
	local v = { ... }
	setmetatable(v,_vec)
	return v
end

function vec:copy()
	local r = table.copy(self)
	setmetatable(r,_vec)
	return r
end

function _vec.operate( A , B , F )
	local r = Vector()
	for i = 1, Min(#A,#B) do
		rawset( r , i , F(A[i],B[i]) )
	end
	
	if #A ~= #B then
		if #B > #A then
			Swap(A,B)
		end
		for i = #B, #A do
			rawset( r , i , A[i] )
		end
	end
	return r
end

function _vec.__add( A , B )
	return _vec.operate(A,B,function(A,B) return A+B end)
end

function _vec.__sub( A , B )
	return _vec.operate(A,B,function(A,B) return A-B end)
end

function _vec.__mul( A , B )
	return _vec.operate(A,B,function(A,B) return A*B end)
end

function _vec.__div( A , B )
	return _vec.operate(A,B,function(A,B) return A/B end)
end

function _vec.__unm( A )
	local r = A.copy()
	setmetatable(v,_vec)
	for i = 1, #r do
		r[i] = -r[i]
	end
	return r
end

function _vec.__eq( A , B )
	if #A ~= #B then
		return false
	end
	for i = 1, #A do
		if A[i] ~= B[i] then
			return false
		end
	end
	return true
end

function _vec.__index( V , K )
	if K == 'x' then return rawget(V,1)
	elseif K == 'y' then return rawget(V,2)
	elseif K == 'z' then return rawget(V,3)
	elseif K == 'r' then return rawget(V,1)
	elseif K == 'g' then return rawget(V,2)
	else --[[ K == 'b' ]] return rawget(V,3)
	end
end

function _vec.__newindex( V , K , X )
	if K == 'x' then rawset(V,1,X)
	elseif K == 'y' then rawset(V,2,X)
	elseif K == 'z' then rawset(V,3,X)
	elseif K == 'r' then rawset(V,1,X)
	elseif K == 'g' then rawset(V,2,X)
	elseif K == 'b' then rawset(V,3,X)
	else rawset(V,K,X)
	end
	return X
end

function _vec.__tostring( V )
	local s = "[ "
	for i = 1, #V do
		if i == 1 then
			s = s..tostring(V[i])
		else
			s = s.." | "..tostring(V[i])
		end
	end
	return s.." ]"
end
