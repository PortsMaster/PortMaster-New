--Brigde-Mode

--BridgeMode=0;
--You can set it to 1.. Try it... Build a brigde between two solid blocks by a phaser. If BrigdeMode=1 holds, and the Phaser vanished, you will slide down from the solid block when trying to move over it. Otherwise you'll roll around it by "normal" means :-) 

texture=-1;

tillbreak=0.15;
tilldisappear=0.2;

snd_break=-1;

--function MayMove(side,actor,dir)
-- if dir=="rolldown" then
--   return 0;
 --end;
 --return 1;
--end;

--function MaySlideDown(side,actor)
 -- return 1;
--end;

function GetEditorInfo(name,default)
 if name=="BlockOnly" then
  return "yes";
 elseif name=="BlockItemsAllowed" then
  return "no";
elseif name=="SideItemsAllowed" then
  return "no";
elseif name=="NumVars" then
  return 4;
 elseif name=="Var1" then
  return "ActiveTime";
 elseif name=="VarType1" then
  return "float";
 elseif name=="Var2" then
  return "DeactiveTime";
 elseif name=="VarType2" then
  return "float";
 elseif name=="Var3" then
  return "BlendTime";
 elseif name=="VarType3" then
  return "float";
 elseif name=="Var4" then
  return "Phase";
 elseif name=="VarType4" then
  return "float";
-- elseif name=="Var5" then
--  return "BridgeMode";
-- elseif name=="VarType5" then
--  return "bool";
 end;
 return default;
end;

function Precache()
  texture=TEXDEF_Load("phaser");
  --snd_break=SOUND_Load("breakblock");
end


local avis=0.5;

function GetVis(block)
  local atime=BLOCK_GetVar(block,"ActiveTime");
  local dtime=BLOCK_GetVar(block,"DeactiveTime");
  local btime=BLOCK_GetVar(block,"BlendTime");
  local ph=BLOCK_GetVar(block,"Phase");
  local time=BLOCK_GetVar(block,"timer");
  local fulltime=atime+dtime+2*btime;
  --Reduce the time
  local time=time+ph*fulltime;
  --And now subtract the whole part
  local itime=math.floor(time/fulltime)*fulltime;
  local time=time-itime;
  if time<=atime then
    BLOCK_SetVar(block,"State","active");
    return avis;
  elseif time<=atime+btime then
    BLOCK_SetVar(block,"State","blendingdown");
    return (1-(time-atime)/btime)*avis;
  elseif time<=atime+btime+dtime then
    BLOCK_SetVar(block,"State","deactive");
    return 0;
  else
    BLOCK_SetVar(block,"State","blendingup");
    return ((time-atime-dtime-btime)/btime)*avis;
  end;
end;

function RenderSide(side)
  SIDE_DistanceRender(side,CAM_ZDistance(SIDE_GetMidpoint(side)));
end

function DistRenderSide(side)

  local vis=0.5;
local block=SIDE_GetBlock(side);
 

plr=GLOBAL_GetVar("ActivePlayer");
local act=-1;
if GLOBAL_GetVar("ActivePlayer")>=0 then
 act=PLAYER_GetActiveActor(plr);
end;
if (GLOBAL_GetVar("EditorMode")~=1) and (act>=0) and (ACTOR_GetVar(act,"GogglesActive")==0) then
  vis=GetVis(block);
else 
  vis=GetVis(block)+0.1;

end;

   

 local diffuse={r=0.05*3, g=0.05*3 , b=0.75*3, a=vis};
 MATERIAL_SetDiffuse(diffuse);
-- BLEND_Activate();
 
 --CULL_Mode(0);

 TEXDEF_Render(texture,side); 
 TEXDEF_ResetLastRenderedType();
 --CULL_Mode(1);
-- BLEND_Deactivate();
 
end






function BlockThink(block)
  local time=BLOCK_GetVar(block,"timer")+LEVEL_GetElapsed();
  BLOCK_SetVar(block,"timer",time);

  local oldphase=BLOCK_GetVar(block,"State");
  local dummy=GetVis(block);
  local phase=BLOCK_GetVar(block,"State");
 -- print(phase.."  "..oldphase);
  if (phase~=oldphase) and (BLOCK_GetVar(block,"BridgeMode")==0) then
   --  print("Phasechange");
    if oldphase=="deactive" then
      BLOCK_AttachToNeighbors(block);
    elseif phase=="deactive" then 
      BLOCK_RemoveFromNeighbors(block);
    end;

  end;

end;


function BlockConstructor(block)
  --print("BLOCK CONSTRUCTOR "..block);
  BLOCK_SetVar(block,"timer",0);
  BLOCK_SetVar(block,"ActiveTime",1);
  BLOCK_SetVar(block,"DeactiveTime",1);
  BLOCK_SetVar(block,"BlendTime",0.1);
  BLOCK_SetVar(block,"Phase",0);
  BLOCK_SetVar(block,"BridgeMode",1);
  local dummy=GetVis(block);  
end

function Event_OnSide(sideid,actorid)
  --local block=SIDE_GetBlock(sideid);
 -- local time=BLOCK_GetVar(block,"timer");
  -- THIS WILL START THE TIMER
  --if time==0 then
    --time=time+LEVEL_GetElapsed();
    --BLOCK_SetVar(block,"timer",time);
  --end;
end

function IsPassable(block)

 -- local time=BLOCK_GetVar(block,"timer");
 --- if time<tillbreak then
 ---   return 0;
 -- else 
 --   return 1;
 -- end;

 if GLOBAL_GetVar("EditorMode")==1 then
  return 0;
 end;

 local state=BLOCK_GetVar(block,"State");
 if state=="deactive" then
  return 1;
 else


   return 0;
 end;
end

function HasTransparency(block)
    return 1;
end;
