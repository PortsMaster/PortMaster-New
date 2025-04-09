-- bayer.lua : bayer matrix suppport.
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

if not bayer then
	bayer = {}

	-- doubles a matrix rows and columns
	function bayer.double(matrix)
		local m,n=#matrix,#matrix[1]
		local r = {}
		for j=1,m*2 do
			local t = {}
			for i=1,n*2 do t[i]=0; end
			r[j] = t;
		end

		-- 0 3
		-- 2 1
		for j=1,m do
			for i=1,n do
				local v = 4*matrix[j][i]
				r[m*0+j][n*0+i] = v-3
				r[m*1+j][n*1+i] = v-2
				r[m*1+j][n*0+i] = v-1
				r[m*0+j][n*1+i] = v-0
			end
		end

		return r;
	end

	-- returns a version of the matrix normalized into
	-- the 0-1 range
	function bayer.norm(matrix)
		local m,n=#matrix,#matrix[1]
		local max,ret = 0,{}
		for j=1,m do
			for i=1,n do
				max = math.max(max,matrix[j][i])
			end
		end
		-- max=max+1
		for j=1,m do
			ret[j] = {}
			for i=1,n do
				ret[j][i]=matrix[j][i]/max
			end
		end
		return ret
	end

	-- returns a normalized order-n bayer matrix
	function bayer.make(n)
		local m = {{1}}
		while n>1 do n,m = n/2,bayer.double(m) end
		return bayer.norm(m)
	end

end -- Bayer
