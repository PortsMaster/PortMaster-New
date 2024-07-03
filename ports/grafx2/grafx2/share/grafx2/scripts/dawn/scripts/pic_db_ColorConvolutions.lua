--PICTURE: Color Convolutions V1.5 
--by Richard 'DawnBringer' Fhager

--(V1.5 db-func optimized)


dofile("../libs/dawnbringer_lib.lua")
--> db.applyConvolution2Pic

--
function main()

 local conv

conv = {}

  conv[1] = {{1,2,1,},
             {2,4,2,}, 
             {1,2,1 }}
  conv[1].name = "Gaussian Blur [3x3]"
  conv[1].div = 16


 conv[2] =  {
             {1,2,3,2,1},
             {2,4,6,4,2},
             {3,6,8,6,3}, 
             {2,4,6,4,2},
             {1,2,3,2,1}
            }
  conv[2].name = "Gaussian Blur [5x5]"
  conv[2].div = 80


  --conv[3] = {{-1,-1,-1,},
  --           {-1, 9,-1,}, 
  --           {-1,-1,-1 }}
  --conv[3].name = "Edge/Sharpen 3x3"
  --conv[3].div = 1

  conv[3] = {{-1,-3,-1,},
             {-3, 19,-3,}, 
             {-1,-3,-1 }}
  conv[3].name = "Edge/Sharpen  [3x3]"
  conv[3].div = 3
 

 conv[4] = {{ 1,  1,  1,},
            { 1, -8,  1,}, 
            { 1,  1,  1 }}
 conv[4].name = "NegEdge       [3x3]"
 conv[4].div = 1



 conv[5] = {{-1, 0, 0,},
            {0, 1, 0}, 
            {0, 0, 1}}
 conv[5].name = "Emboss        [3x3]"
 conv[5].div = 1


 conv[6] = {{2, 1,0,},
            {1, 1,-1,}, 
            {0,-1,-2 }}
 conv[6].name = "EmbossDeep    [3x3]"
 conv[6].div = 1


 conv[7] = {{-1, -2, 0,},
            {-2, 2, 2,}, 
            {0,  2, 1 }}
 conv[7].name = "Extrude       [3x3]"
 conv[7].div = 2


 --conv[5] = {{1}}
 --conv[5].name = "None (for Negative)"
 --conv[5].div = 1
 


 conv[99] = {{-1, -2, -3, -1, 0},
            {-2, -3, -5,  0, 1},
            {-3, -5,  2,  5, 3},
            {-1,  0,  5,  3, 2},
            { 0,  1,  3,  2, 1}}

--divisor = 1
-- conv = {{0,0,0,},{0,2,0,}, {0,0,-1 }}

neg = 0
bias = 0
weaken = 0

OK,q1,q2,q3,q4,q5,q6,q7,neg,amount = inputbox("Color Convolutions",
                       
                           "1. ".. conv[1].name,       1,  0,1,-1,
                           "2. ".. conv[2].name,       0,  0,1,-1,
                           "3. ".. conv[3].name,       0,  0,1,-1, 
                           "4. ".. conv[4].name,       0,  0,1,-1,
                           "5. ".. conv[5].name,       0,  0,1,-1,
                           "6. ".. conv[6].name,       0,  0,1,-1,
                           "7. ".. conv[7].name,       0,  0,1,-1,
                           --conv[6].name,       0,  0,1,-1,
                           "NEGATIVE",        0,  0,1,0, 
                           --"Brightness -255..255",             0,  -255,255,0,
                           "AMOUNT %",       100,  0,100,0    
);

if OK == true then

b = q1 + q2*2 + q3*4 + q4*8 + q5*16 + q6*32 + q7*64
n = 1 + math.log(b) / math.log(2)

--y = math.ceil(#conv[1] / 2)
--x =  math.ceil(#conv[1][1] / 2)
--conv[n][y][x] = conv[n][y][x] 
--conv[n].div = conv[n].div

t1 = os.clock()

db.applyConvolution2Pic(conv[n],conv[n].div,bias,neg,amount/100)

--messagebox("Seconds: "..(os.clock() - t1))

end

end
-- main

main()