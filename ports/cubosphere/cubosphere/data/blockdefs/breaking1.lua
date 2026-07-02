texture=-1;

tillbreak=0.15;
tilldisappear=0.2;

snd_break=-1;

function ActsOnActor(actor)
  if ACTOR_IsPlayer(actor)==1 then
   return 1;
  end;
  local inter=ACTOR_GetVar(actor,"Interaction");
  if string.find(inter, "b") then
    return 1;
  else
    return 0;
  end;
end;

function MayMove(side,actor,dir)
 if dir=="rolldown" then
   return 0;
 end;
 return 1;
end;

function MaySlideDown(side,actor)
  return 1;
end;

function GetEditorInfo(name,default)
 if name=="BlockOnly" then
  return "yes";
 elseif name=="BlockItemsAllowed" then
  return "no";
elseif name=="SideItemsAllowed" then
  return "no";
 end;
 return default;
end;

function Precache()
  texture=TEXDEF_Load("breaking1");
  snd_break=SOUND_Load("breakblock");
end

function RenderSide(side)
  block=SIDE_GetBlock(side);
  time=BLOCK_GetVar(block,"timer");
  if time<tillbreak+tilldisappear then
    TEXDEF_Render(texture,side); 
  end;
end


function BlockThink(block)
  time=BLOCK_GetVar(block,"timer");
  if time>tillbreak then
    if time>tillbreak+tilldisappear then
       return;
    end;
    time=time+GLOBAL_GetElapsed()*GLOBAL_GetVar("MoveSpeedMultiply");
    size=1-(time-tillbreak)/tilldisappear;
    BLOCK_SetScale(block,size);
    BLOCK_SetVar(block,"timer",time);
    return;
  end;
  if time>0 then
    time=time+LEVEL_GetElapsed()*GLOBAL_GetVar("MoveSpeedMultiply");
    
    BLOCK_SetVar(block,"timer",time);
   -- print(block.." -> "..time);
    if time>tillbreak then
    --  print("break: "..time);
      BLOCK_RemoveFromNeighbors(block);
    
      local plr= GLOBAL_GetVar("ActivePlayer");
       PLAYER_SetVar(plr,"Score",PLAYER_GetVar(plr,"Score")+25);    
      SOUND_Play(snd_break,-1);

    end;
  end;
end;


function BlockConstructor(block)
  --print("BLOCK CONSTRUCTOR "..block);
  BLOCK_SetVar(block,"timer",0);
end

function Event_OnSide(sideid,actorid)
  block=SIDE_GetBlock(sideid);
  time=BLOCK_GetVar(block,"timer");
  -- THIS WILL START THE TIMER

  

  if time==0 then
    
     if ActsOnActor(actorid)==0 then
      return;
     end;

    time=time+LEVEL_GetElapsed();
    BLOCK_SetVar(block,"timer",time);
  --  print("timer go: "..time);
  end;
end

function IsPassable(block)
  time=BLOCK_GetVar(block,"timer");
  if time<tillbreak then
    return 0;
  else 
    return 1;
  end;
end

function HasTransparency(block)
  time=BLOCK_GetVar(block,"timer");
  if time<tillbreak then
    return 0;
  else 
    return 1;
  end;
end;
