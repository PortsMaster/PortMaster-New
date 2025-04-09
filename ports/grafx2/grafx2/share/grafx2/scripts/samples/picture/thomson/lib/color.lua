-- color.lua : a color class capable of representing
-- and manipulating colors in PC-space (gamma=2.2) or
-- in linear space (gamma=1).
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


if not Color then
	Color = {ONE=255,NORMALIZE=.005}
	function Color:new(r,g,b)
		local o = {};
		o.r = type(r)=='number' and r or r and r.r or 0;
		o.g = type(g)=='number' and g or r and r.g or 0;
		o.b = type(b)=='number' and b or r and r.b or 0;
		setmetatable(o, self)
		self.__index = self
		return o
	end
	Color.black = Color:new(0,0,0)

	function Color.clamp(v,...)
		if v then
			return v<0         and 0 or
				   v>Color.ONE and Color.ONE or
				   v,Color.clamp(...)
		end
	end

	function Color:clone()
		return Color:new(self.r, self.g, self.b)
	end

	function Color:tostring()
		return "(r=" .. self.r .. " g=" .. self.g .. " b=" .. self.b .. ")"
	end

	function Color:HSV()
		local max=math.floor(.5+math.max(self.r,self.g,self.b))
		local min=math.floor(.5+math.min(self.r,self.g,self.b))

		local H=(max<=min and 0 or
			     max<=self.r and (self.g-self.b)/(max-min)+6 or
			     max<=self.g and (self.b-self.r)/(max-min)+2 or
			 	 max<=self.b and (self.r-self.g)/(max-min)+4)/6 % 1.0
		local S=(max==0 or max<=min) and 0 or 1-min/max
		local V=max/Color.ONE

		return H,S,V
	end

	function Color:intensity()
		return .3*self.r + .59*self.g + .11*self.b
	end

	function Color:mul(val)
		self.r = self.r * val;
		self.g = self.g * val;
		self.b = self.b * val;
		return self;
	end

	function Color:div(val)
		return self:mul(1/val);
	end

	function Color:add(other)
		self.r = self.r + other.r;
		self.g = self.g + other.g;
		self.b = self.b + other.b;
		return self;
	end

	function Color:sub(other)
		self.r = self.r - other.r;
		self.g = self.g - other.g;
		self.b = self.b - other.b;
		return self;
	end

	function Color:dist2(other)
		return self:euclid_dist2(other)
		-- return Color.dE2000(self,other)^2
		-- return Color.dE2fast(self,other)
	end

	function Color:euclid_dist2(other)
		return (self.r - other.r)^2 +
		       (self.g - other.g)^2 +
			   (self.b - other.b)^2
	end

	function Color:floor()
		self.r = math.min(math.floor(self.r),Color.ONE);
		self.g = math.min(math.floor(self.g),Color.ONE);
		self.b = math.min(math.floor(self.b),Color.ONE);
		return self;
	end

	function Color:toPC()
		local function f(val)
			val = val/Color.ONE
			-- if val<=0.018 then val = 4.5*val; else val = 1.099*(val ^ (1/2.2))-0.099; end

			-- works much metter: https://fr.wikipedia.org/wiki/SRGB
			if val<=0.0031308 then val=12.92*val else val = 1.055*(val ^ (1/2.4))-0.055 end
			return val*Color.ONE
		end;
		self.r = f(self.r);
		self.g = f(self.g);
		self.b = f(self.b);
		return self;
	end

	function Color:toLinear()
		local function f(val)
			val = val/Color.ONE
			-- if val<=0.081 then val = val/4.5; else val = ((val+0.099)/1.099)^2.2; end

			-- works much metter: https://fr.wikipedia.org/wiki/SRGB#Transformation_inverse
			if val<=0.04045 then val = val/12.92 else val = ((val+0.055)/1.055)^2.4 end
			return val*Color.ONE
		end;
		self.r = f(self.r);
		self.g = f(self.g);
		self.b = f(self.b);
		return self;
	end

	function Color:toRGB()
		return self.r, self.g, self.b
	end

	-- return the Color @(x,y) on the original screen in linear space
	local screen_w, screen_h, _getLinearPictureColor = getpicturesize()
	function getLinearPictureColor(x,y)
		if _getLinearPictureColor==nil then
			_getLinearPictureColor = {}
			for i=0,255 do _getLinearPictureColor[i] = Color:new(getbackupcolor(i)):toLinear(); end
			if Color.NORMALIZE>0 then
				local histo = {}
				for i=0,255 do histo[i] = 0 end
				for y=0,screen_h-1 do
					for x=0,screen_w-1 do
						local r,g,b = getbackupcolor(getbackuppixel(x,y))
						histo[r] = histo[r]+1
						histo[g] = histo[g]+1
						histo[b] = histo[b]+1
					end
				end
				local acc,thr=0,Color.NORMALIZE*screen_h*screen_w*3
				local max
				for i=255,0,-1 do
					acc = acc + histo[i]
					if not max and acc>=thr then
						max = Color:new(i,i,i):toLinear().r
					end
				end
				for _,c in ipairs(_getLinearPictureColor) do
					c:mul(Color.ONE/max)
					c.r,c.g,c.b = Color.clamp(c.r,c.g,c.b)
				end
			end
		end
		return (x<0 or y<0 or x>=screen_w or y>=screen_h) and Color.black or _getLinearPictureColor[getbackuppixel(x,y)]
	end

	-- http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
	function Color.RGBtoXYZ(R,G,B)
		return 0.4887180*R +0.3106803*G +0.2006017*B,
			   0.1762044*R +0.8129847*G +0.0108109*B,
                            0.0102048*G +0.9897952*B
	end

	function Color.XYZtoRGB(X,Y,Z)
		return   2.3706743*X -0.9000405*Y -0.4706338*Z,
                -0.5138850*X +1.4253036*Y +0.0885814*Z,
                 0.0052982*X -0.0146949*Y +1.0093968*Z
	end

	-- https://fr.wikipedia.org/wiki/CIE_L*a*b*
	function Color.XYZtoCIELab(X,Y,Z)
		local function f(t)
			return t>0.00885645167 and t^(1/3)
			                        or  7.78703703704*t+0.13793103448
		end
		X,Y,Z=X/Color.ONE,Y/Color.ONE,Z/Color.ONE
		return 116*f(Y)-16,
			   500*(f(X)-f(Y)),
			   200*(f(Y)-f(Z))
	end
	function Color.CIEALabtoXYZ(L,a,b)
		local function f(t)
			return t>0.20689655172 and t^3
			                        or  0.12841854934*(t-0.13793103448)
		end
		local l=(L+16)/116
		return Color.ONE*f(l),
		       Color.ONE*f(l+a/500),
			   Color.ONE*f(l-b/200)
	end
	function Color:toLab()
		return Color.XYZtoCIELab(Color.RGBtoXYZ(self:toRGB()))
	end

	-- http://www.brucelindbloom.com/Eqn_DeltaE_CIE2000.html
	function Color.dE1976(col1,col2)
		local L1,a1,b1 = col1:toLab()
		local L2,a2,b2 = col2:toLab()
		return ((L1-L2)^2+(a1-a2)^2+(b1-b2)^2)^.5
	end
	function Color.dE1994(col1,col2)
		local L1,a1,b1 = col1:toLab()
		local L2,a2,b2 = col2:toLab()

		local k1,k2 = 0.045,0.015
		local kL,kC,kH = 1,1,1

		local c1 = (a1^2 + b1^2)^.5
		local c2 = (a2^2 + b2^2)^.5

		local dA = a1 - a2
		local dB = b1 - b2
		local dC = c1 - c2

		local dH2 = dA^2 + dB^2 - dC^2
		local dH = dH2>0 and dH2^.5 or 0
		local dL = L1 - L2

		local sL = 1
		local sC = 1 + k1*c1
		local sH = 1 + k2*c1

		local vL = dL/(kL*sL)
		local vC = dC/(kC*sC)
		local vH = dH/(kH*sH)

		return (vL^2 + vC^2 + vH^2)^.5
	end
	-- http://www.color.org/events/colorimetry/Melgosa_CIEDE2000_Workshop-July4.pdf
	-- https://en.wikipedia.org/wiki/Color_difference#CIEDE2000
	function Color.dE2000(col1,col2)
		local L1,a1,b1 = col1:toLab()
		local L2,a2,b2 = col2:toLab()

		local kL,kC,kH = 1,1,1

		local l_p = (L1 + L2)/2

		function sqrt(x)
			return x^.5
		end
		function norm(x,y)
			return sqrt(x^2+y^2)
		end
		function mean(x,y)
			return (x+y)/2
		end
		local function atan2(a,b)
			local t=math.atan2(a,b)*180/math.pi
			return t<0 and t+360 or t
		end
		local function sin(x)
			return math.sin(x*math.pi/180)
		end
		local function cos(x)
			return math.cos(x*math.pi/180)
		end

		local c1  = norm(a1,b1)
		local c2  = norm(a2,b2)
		local c_  = mean(c1,c2)

		local G   = 0.5*(1-sqrt(c_^7/(c_^7+25^7)))
		local a1p = a1*(1+G)
		local a2p = a2*(1+G)

		local c1p = norm(a1p,b1)
		local c2p = norm(a2p,b2)
		local c_p = mean(c1p,c2p)

		local h1p = atan2(b1,a1p)
		local h2p = atan2(b2,a2p)

		local h_p = mean(h1p,h2p) +
		            (math.abs(h1p - h2p)<=180 and 0 or
					  h1p+h2p<360 and 180 or -180)

		local T   = 1 -
				    0.17 * cos(    h_p - 30) +
			        0.24 * cos(2 * h_p     ) +
			        0.32 * cos(3 * h_p +  6) -
			        0.20 * cos(4 * h_p - 63)

		local dhp = h2p - h1p + (math.abs(h1p - h2p)<=180 and 0 or
		                                         h2p<=h1p and 360 or
												             -360)
		local dLp = L2 - L1
		local dCp = c2p - c1p
		local dHp = 2*sqrt(c1p*c2p)*sin(dhp/2)


		local sL = 1 + 0.015*(l_p - 50)^2/sqrt(20+(l_p-50)^2)
		local sC = 1 + 0.045*c_p
		local sH = 1 + 0.015*c_p*T

		local d0 = 30*math.exp(-((h_p-275)/25)^2)

		local rC = 2*sqrt(c_p^7/(c_p^7+25^7))
		local rT = -rC * sin(2*d0)

		return sqrt( (dLp / (kL*sL))^2 +
		             (dCp / (kC*sC))^2 +
			         (dHp / (kH*sH))^2 +
			         (dCp / (kC*sC))*(dHp / (kH*sH))*rT )
	end

	function Color.dE2fast(col1,col2)
		-- http://www.compuphase.com/cmetric.htm#GAMMA
		local r1,g1,b1 = Color.clamp(col1:toRGB())
		local r2,g2,b2 = Color.clamp(col2:toRGB())

		local rM = (r1+r2)/(Color.ONE*2)

		return ((r1-r2)^2)*(2+rM) +
		       ((g1-g2)^2)*(4+1) +
			   ((b1-b2)^2)*(3-rM)
	end

	function Color:hash(M)
		M=M or 256
		local m=(M-1)/Color.ONE
		local function f(x)
			return math.floor(.5+(x<0 and 0 or x>Color.ONE and Color.ONE or x)*m)
		end
		return f(self.r)+M*(f(self.g)+M*f(self.b))
	end
end -- Color defined
