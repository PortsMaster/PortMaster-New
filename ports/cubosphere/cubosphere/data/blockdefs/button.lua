INCLUDEABSOLUTE("/blockdefs/include/colors.inc");


mdl=-1;
texture=-1;
ltex=-1;

snd_deactivate=-1;

up=VECTOR_New(0,0,0);
dir=VECTOR_New(0,0,0);
right=VECTOR_New(0,0,0);
pos=VECTOR_New(0,0,0);


function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no";
 elseif name=="NumVars" then
  return 1;
 elseif name=="Var1" then
  return "Color";
 elseif name=="VarType1" then
  return "basecolor"; 
 else
  return default;
 end;
end;


function SideConstructor(sideid)
  SIDE_SetVar(sideid,"StartActive",1);
  SIDE_SetVar(sideid,"Color",0);
  SIDE_SetVar(sideid,"Toggled",0);
  SIDE_SetVar(sideid,"PrevToggled",0);
  SIDE_SetVar(sideid,"PrevToggledBy",-1);
end;

function Precache()
  mdl=MDLDEF_Load("button2");
  texture=TEXDEF_Load("base");
  snd_deactivate=SOUND_Load("switch_off");
  ltex=TEXDEF_Load("lightcast");
end





function RenderMdl(side,height)

  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,VECTOR_Sub(SIDE_GetMidpoint(side),VECTOR_Scale(up,0.05*GLOBAL_GetScale()*SIDE_GetVar(side,"StartActive"))));
  MATRIX_ScaleUniform(GLOBAL_GetScale()*0.3);
  
  local coladd;
  if SIDE_GetVar(side,"StartActive")==1 then
    --Add a addtional activation color punch
    local blinkspeed=10;
    coladd=0.025*math.sin(blinkspeed*GLOBAL_GetTime());
  else
    coladd=-0.1;  
  end;
--  SetInnerColor(SIDE_GetVar(side,"Color"),coladd);
  ActivateCuboColor(SIDE_GetVar(side,"Color"),coladd,1.0,1.0,1.0);

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

  if SIDE_GetVar(side,"StartActive")==1 then
    --Add some effects here
    SIDE_DistanceRender(side,CAM_ZDistance(SIDE_GetMidpoint(side))); -- Blabla
  end;

  RenderMdl(side,height);
 

end

function MayCull(side)
  return 1; 
  --This model is far to small to be not culled by side's normal
end


function EnemyTogglingSwitches(en)
  local inter=ACTOR_GetVar(en,"Interaction");
  if string.find(inter, "s") then
    return 1;
  else
    return 0;
  end;
end;

function SideCollisionCheck(actorid,sideid)

  if ACTOR_GetVar(actorid,"IsAlive")~=1 then
    if SIDE_GetVar(sideid,"PrevToggledBy")==actorid then
      SIDE_SetVar(sideid,"PrevToggled",0);
      SIDE_SetVar(sideid,"PrevToggledBy",-1);
    end;
    return;
  end;

  if ACTOR_IsPlayer(actorid)==0 then
      if EnemyTogglingSwitches(actorid)==0 then
        return; 
      end;
  end;
  
  pp=ACTOR_GetPos(actorid);
  mp=SIDE_GetMidpoint(sideid);
  norm=SIDE_GetNormal(sideid);
  diff=VECTOR_Sub(pp,mp);
  l=VECTOR_Length(diff);
  diff=VECTOR_Scale(diff,1.0/l);
  l=(l-ACTOR_GetRadius(actorid)-ACTOR_GetGroundOffset(actorid))/GLOBAL_GetScale();
  dot=VECTOR_Dot(diff,norm);
  if (dot<0.75) or (l>0.2) then 
    if SIDE_GetVar(sideid,"PrevToggledBy")==actorid then
      SIDE_SetVar(sideid,"PrevToggled",0);
      SIDE_SetVar(sideid,"PrevToggledBy",-1);
    end;
    return;
  end;

  if SIDE_GetVar(sideid,"Toggled")==0 then
    if SIDE_GetVar(sideid,"PrevToggled")==0 then
      --SOUND_Play(snd_tele,-1);
      SIDE_SetVar(sideid,"Toggled",1);
      SIDE_SetVar(sideid,"PrevToggled",1);
      SIDE_SetVar(sideid,"PrevToggledBy",actorid);
      SIDE_SetVar(sideid,"StartActive",math.fmod(SIDE_GetVar(sideid,"StartActive")+1,2));
      SOUND_Play(snd_deactivate,-1);
      ToggleCuboColor(SIDE_GetVar(sideid,"Color"));
    end;
  end;
end;




function RenderLight(side,scale)
  
  MATRIX_Push();
  local dir=SIDE_GetTangent(side);
  local up=SIDE_GetNormal(side);
  local right=VECTOR_Cross(up,dir);
  local pos=VECTOR_Add(SIDE_GetMidpoint(side),VECTOR_Scale(up,0.025*GLOBAL_GetScale()));
  MATRIX_MultBase(right,up,dir,pos);
  MATRIX_ScaleUniform(scale);

  local blinkspeed=10;
  GLOBAL_SetVar("RenderColorAdder",0.05*math.sin(blinkspeed*GLOBAL_GetTime()));
  GLOBAL_SetVar("RenderColor",SIDE_GetVar(side,"Color"));


  TEXDEF_Render(ltex,side);
  MATRIX_Pop();
end;

--Dito
function DistRenderSide(side)
  ActivateCuboColor(SIDE_GetVar(side,"Color"),0,1.0,1.0,1.0);
  RenderLight(side,1.5*GLOBAL_GetScale());
end
