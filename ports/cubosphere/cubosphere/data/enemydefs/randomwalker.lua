
INCLUDE("/include/random.inc");
radius=GLOBAL_GetScale()/3;
extrascale=0.8;
rotspeedmultiply=-1000;

function SetupBase(actor,basis)

  BASIS_Set(basis,VECTOR_Scale(ACTOR_GetDir(actor),-1),ACTOR_GetUp(actor),ACTOR_GetSide(actor),ACTOR_GetPos(actor));

  local cu=ACTOR_GetVar(actor,"ChargeUp");
  local rt=0.5*(3*cu+16*cu*cu);
  BASIS_AxisRotate(basis,ACTOR_GetUp(actor),rt);
  
  local pt=0.7*rt;
  BASIS_AxisRotate(basis,ACTOR_GetSide(actor),-0.2*math.sin(pt));
  BASIS_AxisRotate(basis,ACTOR_GetDir(actor),-0.2*math.cos(pt));

  GLOBAL_SetVar("RenderColor",cu);

 
end;



function Precache()
  LoadMdl("randomwalker");
  snd_effect=SOUND_Load("random");
end;  

