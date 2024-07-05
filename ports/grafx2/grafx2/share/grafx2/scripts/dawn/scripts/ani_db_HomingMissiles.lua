--ANIM: Homing Missiles (pfunction version)
--by Richard 'DawnBringer' Fhager


data = { -- Default values
            missiles = 80,
                seed = -1, -- Random seed, -1 = Random
              frames = 5000,

             drawmis = true,  -- Draw missiles
             misscol = -1,  -- Missile color, -1 = Ink / 2 (Black 0 = 0, White 255 = 128)

              update = 50, -- Update screen every nth frame, 1 = real time, 50 = good fast mode
                wait = 0,  -- Update speed/wait in slow mode, nominal = 0

              ispeed = 18,
             inertia = 0.05, -- i.e. Scale
                macc = 0.03,
                drag = 0.965,

                 ink = 255,
               stamp = 0.03, -- Transparancy 0..1, 1 = solid. Default 0.03 for white ink, 0.1 for black ink
                mult = 1.1, -- Default 1.0 for black ink, 1.1 for white ink
               gamma = 2.2, -- Default 1.5 for black ink, 2.2 for white ink
          
                fade = 0.75, --  Fade over the this last faction of frames

           slideshow = 99,   -- Scenes to play in slideshow mode
           viewpause = 1.5,   -- Seconds of pausing image before next scene. (screen clearing also adds to the length of this pause)

              dotext = 1, -- Display text, 0 = no, 1 = yes (just simple compatability with inputbox())

               setbg = 1 -- CUSTOM DATA ONLY FOR THIS SCRIPT, Set up palette and cloudfractal for background
     }


--
function menu2()
  local stamp,mult,gamma,status,fade,slideshow,OK2 
  fade = data.fade * 100
  status = false
  stamp = 0.15 - (0.15-0.03)/255*data.ink 
  mult  = 1.0 + (1.1-1.0)/255*data.ink
  gamma = 1.5 + (2.2-1.5)/255*data.ink
  slideshow = 0; if data.slideshow > 1 then slideshow = 1; end

  OK2, data.frames, data.stamp, data.mult, data.gamma, fade, data.update, slideshow, data.dotext, data.setbg = inputbox("Homing Missiles - 2. Graphics",      
    "Frames: 50-100.000",       data.frames, 50,100000,0,
    "Stamp/Strength: 0..1",           stamp, 0,1,3,
    "Overdraw Mult: 0.5-2.0",          mult, 0,2.0,3,
    "Gamma: 0.5-3.0",                 gamma, 0.5,3,3,
    "Fade over Last % Frames",         fade, 0,100,1,
    "Update every... (1 = rt)", data.update, 1,500,1,
    "Slideshow Mode",                    1, 0,1,0,
    "Display Text",            data.dotext, 0,1,0,
    "SETUP PAL & BACKGROUND",   data.setbg, 0,1,0                                        
  );

  if OK2 then
   data.fade = fade / 100 
   if slideshow == 0 then data.slideshow = 1; end -- play just the one scene
   return true 
    else status = menu1(); 
   end
  return status
end
--

--
function menu1()
  local status,OK1
  status = false
  OK1, data.ink, data.missiles, data.seed, data.macc, data.drag, data.inertia, data.ispeed = inputbox("Homing Missiles - 1. Data",
                        
    "Plot Col/Index: 0-255",     data.ink, 0,255,0,
    "Missiles: 2-500",           data.missiles, 2,500,0,
    "RND Seed (-1 = random)",    data.seed, -1,999999,0, 
    "Acceleration: 0.001-1.0",   data.macc, 0.001,1,3,
    "Drag: 0.01-0.999",          data.drag, 0.01,0.999,3,
    "Inertia/Scale: -10..0.9",   data.inertia, -10,0.9,3,
    "Inital Speed: 1-100",       data.ispeed, 1,100,0
                                                              
  );
  if OK1 then status = menu2(); end
  return status
end
--


if menu1() then

 if data.setbg == 1 then
  pals = {"pal_db_SetDawn_256.lua","pal_db_SetDusk_256.lua","pal_db_SetBlueSepia_256.lua","pal_db_SetWatermelon_256.lua"}
  seeds = {467,546,625,689}
  dofile("../gradients/"..pals[math.random(1,#pals)])
  dofile("../pfunctions/pfunc_CloudFractal.lua")(10, 1, 0.5,  2.2,  64, "linear", 0,   true, seeds[math.random(1,#seeds)])
  ---math.randomseed(os.clock()) -- make sure the seed of cloudfractal don't determine the gradients
  finalizepicture()
 end

 dofile("../pfunctions/pfunc_HomingMissiles.lua")(data)
end

--breaktext(data,true)

  


