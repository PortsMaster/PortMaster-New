INCLUDE("/include/std.inc");
extrascale=1.0;
radius=GLOBAL_GetScale()/3.1;


local oldthink=Think;
local oldrender=Render;
local olddistrender=DistRender;


function Think(actor)
 ACTOR_SetVar(actor,"IsAlive",1);
 oldthink(actor);
 ACTOR_SetVar(actor,"IsAlive",0);
end;

function DistRender(actor)
 
  local basis=ACTOR_GetVar(actor,"Basis");
  SetupBase(actor,basis); 

  BASIS_Push(basis);  
  
  local alpha=0.4;
  if GLOBAL_GetVar("EditorMode")~=1 then
    local plr=GLOBAL_GetVar("ActivePlayer");  
    if plr>=0 then
      plr=PLAYER_GetActiveActor(plr);
      local dist=VECTOR_Length(VECTOR_Sub(ACTOR_GetPos(plr),ACTOR_GetPos(actor)))/GLOBAL_GetScale();
      if dist<1.5 then
        if dist<0.5 then 
          alpha=0;
        else
          alpha=alpha*(dist-0.5);
        end;
      end;
    end;
  end;
  GLOBAL_SetVar("RenderColor",alpha);

  MDLDEF_Render(mdl);
  BASIS_Pop(basis);
  olddistrender(actor);
end;

function Render(actor)
-- ACTOR_SetVar(actor,"IsAlive",1);
-- oldrender(actor);
-- ACTOR_SetVar(actor,"IsAlive",0);
  ACTOR_DistanceRender(actor,CAM_ZDistance(ACTOR_GetPos(actor)));
end;



function SetupBase(actor,basis)
  

  BASIS_SetPos(basis,ACTOR_GetPos(actor));
--  BASIS_Set(basis,VECTOR_Scale(ACTOR_GetDir(actor),-1),ACTOR_GetUp(actor),ACTOR_GetSide(actor),ACTOR_GetPos(actor));

  local rspeed=ACTOR_GetVar(actor,"RollSpeed");
--  local rpos=ACTOR_GetVar(actor,"RollPos");

--    rpos=rpos+rspeed*LEVEL_GetElapsed();
--    BASIS_AxisRotate(basis,ACTOR_GetSide(actor),rpos);
  BASIS_AxisRotate(basis,ACTOR_GetSide(actor),rspeed*LEVEL_GetElapsed());
    
 
--  ACTOR_SetVar(actor,"RollPos",rpos);

end;

function Precache()
  LoadMdl("tutorialball");
end;  

