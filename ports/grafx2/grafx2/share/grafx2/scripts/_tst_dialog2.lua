--
-- test of GUI library
--
run("libs/gui.lua")

local counter = gui.label{x=10, y=54, value=0, format="% .3d"}
local form = gui.dialog{
    title="Dialogtest",
    w=100,
    h=150,
    counter,
    gui.button{ label="+",
      x=6, y=38, w=14, h=14, repeatable=true, click=function()
      counter.value=counter.value+1;
    end},
    gui.button{ label="-",
      x=26, y=38, w=14, h=14, repeatable=true, click=function()
      counter.value=counter.value-1;
    end},
    gui.button{ label="Help",
      x=6, y=70, w=54, h=14, click=function()
      messagebox("Help screen");
    end},
    gui.button{ label="Close",
      x=6, y=18, w=54, h=14, key=27, click=function()
      return true; -- causes closing
    end},
    gui.textbox{
      x=6, y=90, nbchar=8, decimal=1,
      min=450, max=1450, maxchar=8, value = 1234,
      change=function()
      -- do nothing
      end
    },
    gui.textbox{
      x=6, y=104, nbchar=10, maxchar=20, value = "test"
    },
    gui.textbox{
      x=6, y=118, nbchar=8, decimal=0, min=0,
      maxchar=8, value = 456,
      change=function()
      -- do nothing
      end
    },
}

form:run()
