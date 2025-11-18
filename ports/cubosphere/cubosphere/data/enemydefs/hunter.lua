
INCLUDE("/include/hunter.inc");

radius = .30*GLOBAL_GetScale()
 groundoffset = .20*GLOBAL_GetScale()
 extrascale = 1.333333333


rotspeedmultiply=-30;

PrecessionSpeed=3;

function SetupBase(actor,basis)
  
  local speed=ACTOR_GetVar(actor,"Speed");
  BASIS_SetPos(basis,ACTOR_GetPos(actor));
  BASIS_Set(basis,VECTOR_Scale(ACTOR_GetDir(actor),-1),ACTOR_GetUp(actor),ACTOR_GetSide(actor),ACTOR_GetPos(actor));


  local rt=ACTOR_GetVar(actor,"RotationTime");
  local pt=ACTOR_GetVar(actor,"PrecessionTime");  

  BASIS_AxisRotate(basis,ACTOR_GetUp(actor),rt);
  BASIS_AxisRotate(basis,ACTOR_GetSide(actor),-0.2*math.sin(pt));
  BASIS_AxisRotate(basis,ACTOR_GetDir(actor),-0.2*math.cos(pt));

 
end;



function Precache()
  LoadMdl("gyro");
  beepsnd=SOUND_Load("hunter");
end;  

