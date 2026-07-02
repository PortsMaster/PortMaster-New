INCLUDE("/include/std.inc");
extrascale=1.2;


function SetupBase(actor,basis)
  

  BASIS_SetPos(basis,ACTOR_GetPos(actor));
  BASIS_Set(basis,VECTOR_Scale(ACTOR_GetDir(actor),-1),ACTOR_GetUp(actor),ACTOR_GetSide(actor),ACTOR_GetPos(actor));

  local rspeed=ACTOR_GetVar(actor,"RollSpeed");
  local rpos=ACTOR_GetVar(actor,"RollPos");

    rpos=rpos+rspeed*LEVEL_GetElapsed();
    BASIS_AxisRotate(basis,ACTOR_GetSide(actor),rpos);
    
 
  ACTOR_SetVar(actor,"RollPos",rpos);

end;

function Precache()
  LoadMdl("gear");
end;  

