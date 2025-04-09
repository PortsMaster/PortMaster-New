-- convxhull.lua : support for computing the convex
-- hull of a set of points.
--
-- inspired from: https://gist.github.com/anonymous/5184ba0bcab21d3dd19781efd3aae543
--
-- Version: 02-jan-2017
--
-- Copyright 2016-2017 by Samuel Devulder
--
-- This program is free software; you can redistribute
-- it and/or modify it under the terms of the GNU
-- General Public License as published by the Free
-- Software Foundation; version 2 of the License.
-- See <http://www.gnu.org/licenses/>

if not ConvexHull then

local function sub(u,v)
	return {u[1]-v[1],u[2]-v[2],u[3]-v[3]}
end

local function mul(k,u)
	return {k*u[1],k*u[2],k*u[3]}
end

local function cross(u,v)
	return {u[2]*v[3] - u[3]*v[2],
	        u[3]*v[1] - u[1]*v[3],
			u[1]*v[2] - u[2]*v[1]}
end

local function dot(u,v)
	return u[1]*v[1] + u[2]*v[2] + u[3]*v[3]
end

local function unit(u)
	local d=dot(u,u)
	return d==0 and u or mul(1/d^.5, u)
end

ConvexHull = {}

function ConvexHull:new(coordFct)
	local o = {
		points={},
		coord=coordFct
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function ConvexHull.coord(elt)
	return {elt[1],elt[2],elt[3]}
end

function ConvexHull:vect(a,b)
	return sub(self.coord(b),self.coord(a))
end

function ConvexHull:normal(face)
	local u=self:vect(face[1],face[2])
	local v=self:vect(face[1],face[3])
	return cross(u,v)
end

function ConvexHull:printPoint(p)
	return '('..table.concat(self.coord(p),',')..')'
end

function ConvexHull:printFace(F)
	return '['..self:printPoint(F[1])..' '..
	            self:printPoint(F[2])..' '..
				self:printPoint(F[3])..']'
end

function ConvexHull:seen(face,p)
	local N=self:normal(face)
	local P=self:vect(face[1],p)
	return dot(N,P)>=0
end

function ConvexHull:bdry(faces)
	local code={n=0}
	function code.encode(pt,...)
		if pt then
			local k = code[pt]
			if not k then
				k = code.n+1
				code[k]  = pt
				code[pt] = k
				code.n   = k
			end
			local rest = code.encode(...)
			return rest and (k..','..rest) or ""..k
		end
	end
	function code.decode(str)
		local i = str:find(',')
		if i then
			local k = str:sub(1,i-1)
			return code[tonumber(k)],code.decode(str:sub(i+1))
		else
			return code[tonumber(str)]
		end
	end
	local set = {}
	local  function add(...)
		set[code.encode(...)] = true
	end
	local function rem(...)
		set[code.encode(...)] = nil
	end
	local function keys()
		local r = {}
		for k in pairs(set) do
			r[{code.decode(k)}] = true
		end
		return r
	end
	for F in pairs(faces) do
		add(F[1],F[2])
		add(F[2],F[3])
		add(F[3],F[1])
	end
	for F in pairs(faces) do
		rem(F[1],F[3])
		rem(F[3],F[2])
		rem(F[2],F[1])
	end
	return keys()
end

function ConvexHull:addPoint(p)
	-- first 3 points
	if self.points then
		if p==self.points[1] or p==self.points[2] then return end
		table.insert(self.points,p)

		if #self.points==3 then
			self.hull={
				{self.points[1],self.points[2],self.points[3]},
				{self.points[1],self.points[3],self.points[2]}
			}
			self.points=nil
		end
	else
		local seenF,n = {},0
		for _,F in ipairs(self.hull) do
			if F[1]==p or F[2]==p or F[3]==p then return end
			if self:seen(F,p) then seenF[F]=true;n=n+1 end
		end

		if n==#self.hull then
			-- if can see all faces, unsee ones looking "down"
			local N
			for F in pairs(seenF) do N=self:normal(F); break; end
			for F in pairs(seenF) do
				if dot(self:normal(F),N)<=0 then
					seenF[F] = nil
					n=n-1
				end
			end
		end

		-- remove (old) seen faces
		local z=#self.hull
		for i=#self.hull,1,-1 do
			if seenF[self.hull[i]] then
				table.remove(self.hull,i)
			end
		end

		-- insert new boundaries with seen faces
		for E in pairs(self:bdry(seenF)) do
			table.insert(self.hull,{E[1],E[2],p})
		end
	end
	return self
end

function ConvexHull:verticesSet()
	local v = {}
	if self.hull then
		for _,F in ipairs(self.hull) do
			v[F[1]] = true
			v[F[2]] = true
			v[F[3]] = true
		end
	end
	return v
end

function ConvexHull:verticesSize()
	local n = 0
	for _ in pairs(self:verticesSet()) do n=n+1 end
	return n
end

function ConvexHull:distToFace(F,pt)
	local N=unit(self:normal(F))
	local P=self:vect(F[1],pt)
	return dot(N,P)
end

function ConvexHull:distToHull(pt)
	local d
	for _,F in ipairs(self.hull) do
		local t = self:distToFace(F,pt)
		d = d==nil and t or
			(0<=t and t<d or
			 0>=t and t>d) and t or
			d
		if d==0 then break end
	end
	return d
end

end -- ConvexHull
