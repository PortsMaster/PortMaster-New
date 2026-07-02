
INCLUDE("/include/std.inc");
radius=GLOBAL_GetScale()/3;
groundoffset = .2000000000*GLOBAL_GetScale();
extrascale=1.4;
rotspeedmultiply=-1000;

function SetupBase(actor,basis)
  
  local speed=ACTOR_GetVar(actor,"Speed");
  BASIS_SetPos(basis,ACTOR_GetPos(actor));
  BASIS_AxisRotate(basis,VECTOR_New(0,1,0),speed*LEVEL_GetElapsed()*1.5*math.sin(0.51*LEVEL_GetTime()));
  BASIS_AxisRotate(basis,VECTOR_New(0,0,1),speed*LEVEL_GetElapsed()*0.63*math.sin(0.33*LEVEL_GetTime()));
  BASIS_AxisRotate(basis,VECTOR_New(1,0,0),speed*LEVEL_GetElapsed()*1.37);
 
end;



function Precache()
  LoadMdl("spikyenemy");
end;  

