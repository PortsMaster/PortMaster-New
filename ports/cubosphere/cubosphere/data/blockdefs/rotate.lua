--Adjust this to the height of the model
modelheight=0.099056;

extraspeed_multiplier=1.01;

mdl=-1;
texture=-1;
snd_rotate=-1;


up=VECTOR_New(0,0,0);
dir=VECTOR_New(0,0,0);
right=VECTOR_New(0,0,0);
pos=VECTOR_New(0,0,0);



function ActsOnActor(actor)
  return ACTOR_IsPlayer(actor);
end;



function PlayActorSound(actor,side)
   SOUND_Play(snd_rotate,-1);
end;




function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no";
 elseif name=="NumVars" then
  return 1;
 elseif name=="Var1" then
  return "Clockwise";
 elseif name=="VarType1" then
  return "bool";
 else
 return default;
  end;
end;

function RotateDir(side,inp,num)
 num=math.fmod(num,4);
 local outv=VECTOR_New(inp.x,inp.y,inp.z);
 local norm=SIDE_GetNormal(side);
 for i=1,num,1 do
   outv=VECTOR_Cross(norm,outv);
 end;
 return outv;
end;



function Event_OnSide(side,actor)
  if (ActsOnActor(actor)==1) then
     local mp=SIDE_GetMidpoint(side);
     local pp=ACTOR_GetPos(actor);
     local diff=VECTOR_Sub(mp,pp);
     local l=VECTOR_Length(diff);
     if l<1.1*(ACTOR_GetRadius(actor)+ACTOR_GetGroundOffset(actor)) then
             
      if SIDE_GetVar(side,"MyActor")==-1 then
         local s=ACTOR_GetSide(actor);
         if SIDE_GetVar(side,"Clockwise")==1 then
           s=VECTOR_Scale(s,-1);
         end;
         SIDE_SetVar(side,"MyActor",actor);
         local r=0;
         for m=0,3,1 do
              local ts=RotateDir(side,SIDE_GetTangent(side),m);
              if VECTOR_Dot(ts,s)<-0.8 then
                    r=m;
                    break;
              end;
          end;
          SIDE_SetVar(side,"Rotation",r);
 
          if SIDE_GetVar(side,"Clockwise")==1 then
             SIDE_SetVar(side,"OnlyMove","right");
          else
             SIDE_SetVar(side,"OnlyMove","left");
          end;
          
          PlayActorSound(actor,side);
   
      else    
         local s=ACTOR_GetDir(actor);
         local ts=RotateDir(side,SIDE_GetTangent(side),SIDE_GetVar(side,"Rotation"));
          if VECTOR_Dot(ts,s)<-0.8 then
            SIDE_SetVar(side,"OnlyMove","forward");
            ACTOR_SetTemporaryMoveSpeedMultiplier(actor,extraspeed_multiplier);
          end;
          ACTOR_CallMove(actor,SIDE_GetVar(side,"OnlyMove"));
          ACTOR_SetForwardPressTime(actor,1000);
     end;
   else
     if SIDE_GetVar(side,"MyActor")~=-1 then
      SIDE_SetVar(side,"MyActor",-1);
      SIDE_SetVar(side,"Clockwise",1-SIDE_GetVar(side,"Clockwise"));
     end;
   end;
  end;
end;function SideCollisionCheck(actorid,sideid)
  if (ActsOnActor(actorid)==0) then
   return;
  end;

  if SIDE_GetVar(sideid,"MyActor")==actorid then
     local mp=SIDE_GetMidpoint(sideid);
     local pp=ACTOR_GetPos(actorid);
     local diff=VECTOR_Sub(mp,pp);
     local l=VECTOR_Length(diff);
     if l>1.1*(ACTOR_GetRadius(actorid)+ACTOR_GetGroundOffset(actorid)) then
      SIDE_SetVar(sideid,"MyActor",-1);
      SIDE_SetVar(sideid,"Clockwise",1-SIDE_GetVar(sideid,"Clockwise"));
     end
  end;

 local adir=ACTOR_GetUp(actorid);
 local sdir=SIDE_GetNormal(sideid);
 if VECTOR_Dot(adir,sdir)<0.8 then
  return;
 end;

  if ACTOR_GetVar(actorid,"IsAlive")~=1 then
    return;
  end;
  if ACTOR_GetOnSide(actorid)>=0 or ACTOR_GetJumpDistBlocks(actorid)==0 then
    return; --Only check when the actor tries to jump over this block
  end;
 
  pp=ACTOR_GetPos(actorid);
  mp=SIDE_GetMidpoint(sideid);
  norm=SIDE_GetNormal(sideid);
  diff=VECTOR_Sub(pp,mp);
  l=VECTOR_Length(diff);
  diff=VECTOR_Scale(diff,1.0/l);
  l=(l-ACTOR_GetRadius(actorid)-ACTOR_GetGroundOffset(actorid))/GLOBAL_GetScale();
  dot=VECTOR_Dot(diff,norm);
  if (dot<0.9) or (l>2.5) then
    return;
  end;
  ACTOR_SetJumpDistBlocks(actorid,1);
end;

function MayMove(side,actor,dir)
if (ActsOnActor(actor)==1) then
 if (dir==SIDE_GetVar(side,"OnlyMove")) then 
   return 1;
 elseif dir=="rolldown" then
   return 1;
 else
   return 0;
 end;
else 
 return 1;
end;
end;

function SideConstructor(sideid)
 SIDE_SetVar(sideid,"Rotation",0);
 SIDE_SetVar(sideid,"MyActor",-1);
 SIDE_SetVar(sideid,"Clockwise",1);
 SIDE_SetVar(sideid,"OnlyMove","left");
 SIDE_SetVar(sideid,"RotAngle",90);
end;

function Precache()
  mdl=MDLDEF_Load("rotate");
  texture=TEXDEF_Load("base");
  snd_rotate=SOUND_Load("rotate");
end




function SideThink(side)
 local rotspeed=120;

 if SIDE_GetVar(side,"MyActor")~=-1 then
  rotspeed=360/4*ACTOR_GetSpeed(SIDE_GetVar(side,"MyActor"));
 end;


 SIDE_SetVar(side,"RotAngle",SIDE_GetVar(side,"RotAngle")+GLOBAL_GetElapsed()*rotspeed*(1-2*SIDE_GetVar(side,"Clockwise")));
end;


function RenderMdl(side,height)
  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,SIDE_GetMidpoint(side));
  MATRIX_ScaleUniform(GLOBAL_GetScale()*1.0);

    MATRIX_AxisRotate(VECTOR_New(0,1,0),SIDE_GetVar(side,"RotAngle"));

  if SIDE_GetVar(side,"Clockwise")==1 then
     MATRIX_AxisRotate(VECTOR_New(1,0,0),180*SIDE_GetVar(side,"Clockwise"));
     MATRIX_Translate(VECTOR_Scale(VECTOR_New(0,1,0),-modelheight));
  else 
     MATRIX_AxisRotate(VECTOR_New(0,1,0),-90);
  end;



  GLOBAL_SetVar("RenderColor",SIDE_GetVar(side,"Clockwise"));
  MDLDEF_Render(mdl);
  MATRIX_Pop();
end;



function RenderSide(side)
  TEXDEF_Render(texture,side);
TEXDEF_ResetLastRenderedType();
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;


  up=SIDE_GetNormal(side);
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);  
  
 
  RenderMdl(side,height);
 end

function MayCull(side)
 up=SIDE_GetNormal(side); 
 local dn=VECTOR_Sub(SIDE_GetMidpoint(side),CAM_GetPos());
 local l=VECTOR_Dot(dn,dn);
 if l<0.001 then 
   return 1;
 end;
 dn=VECTOR_Scale(dn,1.0/l);
 if VECTOR_Dot(dn,up)>0.005 then
  return 1;
 end;
 return 0;

end

function MaySlideDown(side,actor)
 if  (ActsOnActor(actor)==1) then
  return 1;
 else
  return 0;
 end;
end;

