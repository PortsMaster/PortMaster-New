
INCLUDE("/include/std.inc");
radius = .3000000000*GLOBAL_GetScale();
 groundoffset = .2000000000*GLOBAL_GetScale();
 extrascale = .6666666667;
rotspeedmultiply=-1000;

function SetupBase(actor,basis)
  
  local speed=ACTOR_GetVar(actor,"Speed");
  BASIS_SetPos(basis,ACTOR_GetPos(actor));
  BASIS_AxisRotate(basis,VECTOR_New(0,1,0),120);
  BASIS_AxisRotate(basis,VECTOR_New(0,0,1),120);
  BASIS_AxisRotate(basis,VECTOR_New(1,0,0),120);
 
end;



function Precache()
  LoadMdl("error");
end;  

