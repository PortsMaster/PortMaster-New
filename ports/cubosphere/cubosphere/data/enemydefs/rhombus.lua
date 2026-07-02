
INCLUDE("/include/std.inc");
--radius=GLOBAL_GetScale()/2;
--extrascale=0.8;

radius = .225*GLOBAL_GetScale()
groundoffset = .275*GLOBAL_GetScale()
extrascale = 1.777777778


rotspeedmultiply=-1000;

function SetupBase(actor,basis)
  
  local speed=ACTOR_GetVar(actor,"Speed");
  BASIS_SetPos(basis,ACTOR_GetPos(actor));
  BASIS_AxisRotate(basis,VECTOR_New(0,1,0),speed*LEVEL_GetElapsed()*2);
 
end;



function Precache()
  LoadMdl("rhombus");
end;  

