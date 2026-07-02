--Adjust this to the sand texdef!
texdefname="sand";

snd_sandroll=-1;
texture=-1;

function MayMove(side,actor,dir)
if (ACTOR_IsPlayer(actor)) then
 if (dir=="forward") then 
   return 0;
 else 
   return 1;
 end;
end;
end;

function SideConstructor(sideid)
 SIDE_SetVar(sideid,"SoundTimer",0);
end;

function SideThink(side)
 SIDE_SetVar(side,"SoundTimer",SIDE_GetVar(side,"SoundTimer")-LEVEL_GetElapsed());
end;

function PlayActorSound(actor,side)
  SOUND_Play(snd_sandroll,-1);
  SIDE_SetVar(side,"SoundTimer",1);
end;

function Event_OnSide(side,actor)
 if (ACTOR_IsPlayer(actor)) then
   local cm=ACTOR_CurrentMove(actor);
   if (cm=="forward" or cm=="down" or cm=="up") and   SIDE_GetVar(side,"SoundTimer")<=0 then 
     PlayActorSound(actor,side);
   end;
 end;
end;


function Precache()
  texture=TEXDEF_Load(texdefname);
  snd_sandroll=SOUND_Load("sandroll");
end

function RenderSide(side)
  TEXDEF_Render(texture,side); 
end

