--PICTURE: Emboss V1.3 
--by Richard 'DawnBringer' Fhager


-- (V1.3 Speed-up (db-func) +5%, Grayscale mode, 0.5 rotfix)

dofile("../libs/dawnbringer_lib.lua")
--> db.applyConvolution2PicRot

conv = {}
 conv[1] = {{-1, 0, 0,},
            { 0, 0, 0 }, 
            { 0, 0, 1 }}
 conv[1].name = "Emboss      [3x3]"
 conv[1].div = 1

 conv[2] = {{-1, -2, 0,},
            {-2,  0, 2,}, 
            { 0,  2, 1 }}
 conv[2].name = "Extrude     [3x3]"
 conv[2].div = 2

conv[3] =  {{-1, -2, -3, -1, 0},
            {-2, -3, -5,  0, 1},
            {-3, -5,  0,  5, 3},
            {-1,  0,  5,  3, 2},
            { 0,  1,  3,  2, 1}}
 conv[3].name = "Deep Groove [5x5]"
 conv[3].div = 8


bias = 0
weaken = 0
neg = 0

OK,q1,q2,q3,rot,ht,str,bias,amount = inputbox("Emboss Convolution",
                       
                           "1. "..conv[1].name,           1,  0,1,-1,
                           "2. "..conv[2].name,           0,  0,1,-1,
                           "3. "..conv[3].name,           0,  0,1,-1,

                           "Angle: -359°..359°",      -45,  -359,359,0,  
                           "Height: 0.5-10.0",  1,  0.5,10,2,  -- Could less than 0.5 have an effect on larger than 3x3 matrices? Don't look like it 
                           "Strength %: 1-500",      50,1,500,2,  
                           "Brightness: -255..255",             128,  -255,255,0,
                           --"NEGATIVE?",        0,  0,1,0, 
                           "AMOUNT % (-1 = gryscale)",       100,  -1,100,0    
);

    -- ht      --> PS:Height i.e. radius
    -- divisor --> PS:Amount i.e. strength, Nominal PS is 50% of our (100%)

if OK == true then

b = q1 + q2*2 + q3*4 --+ q4*8 + q5*16 + q6*32
n = 1 + math.log(b) / math.log(2)

 div = (100 / str) * conv[n].div
 rot = (rot + 45) % 360 -- +45 degrees to make 0 top down

--y = math.ceil(#conv[1] / 2)
--x =  math.ceil(#conv[1][1] / 2)
--conv[n][y][x] = conv[n][y][x] 
--conv[n].div = conv[n].div

--db.applyConvolution2Pic(conv[n],conv[n].div,bias,neg,amount/100)

-- Set grayscale
if amount == -1 then
 for n = 0, 255, 1 do
  setcolor(n,n,n,n)
 end
 amount = 100
end

t1 = os.clock()

db.applyConvolution2PicRot(conv[n],div,bias,neg,amount/100,rot,ht)

t2 = os.clock()
ts = (t2 - t1) 
--messagebox("Seconds: "..ts)


end