texture=-1;

heat_speed=1.55;


function Precache()
 -- print("Precache BDEF");
  texture=TEXDEF_Load("fire");
end

function RenderSide(side)
  TEXDEF_Render(texture,side); 
end

function Event_OnSide(side,actor)
  if (ACTOR_IsPlayer(actor)) then
    ACTOR_SetVar(actor,"Temperature",ACTOR_GetVar(actor,"Temperature")+LEVEL_GetElapsed()*heat_speed); 
  end;
end;

