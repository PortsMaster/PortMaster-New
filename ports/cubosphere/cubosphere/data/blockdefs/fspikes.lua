texture=-1;
spikemdl=-1;

snd_spiked=-1;

up=VECTOR_New(0,0,0);
dir=VECTOR_New(0,0,0);
right=VECTOR_New(0,0,0);
pos=VECTOR_New(0,0,0);
depth=0;

function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no";
 end;
 return default;
end;


function Precache()
  texture=TEXDEF_Load("base_spike");
  spikemdl=MDLDEF_Load("spikes");
  snd_spiked=SOUND_Load("spiked");
  --print(spikemdl);
end


function RenderSide(side)
  TEXDEF_Render(texture,side);
TEXDEF_ResetLastRenderedType();
  up=SIDE_GetNormal(side);
  pos=SIDE_GetMidpoint(side); 
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);
  
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;

  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,pos);
  MATRIX_ScaleUniform(GLOBAL_GetScale()*math.sqrt(2));
  --MATRIX_Translate(pos);
  MDLDEF_Render(spikemdl);
  MATRIX_Pop();
end


--Check if the face may be culled
function MayCull(side)
  return 0;
end


function ActsOnActor(actor)
  if ACTOR_IsPlayer(actor)==1 then
    if ACTOR_GetVar(actor,"GodModeTimer")>0 then 
      return 0
    else 
      return 1;
    end;
  end;
  local inter=ACTOR_GetVar(actor,"Interaction");
  if string.find(inter, "p") then
    return 1;
  else
    return 0;
  end;
end;

function SideCollisionCheck(actorid,sideid)


  if ACTOR_GetVar(actorid,"IsAlive")~=1 then
    return;
  end;

  if ActsOnActor(actorid)==0 then
    return;
  end;
  
  pp=ACTOR_GetPos(actorid);
  mp=SIDE_GetMidpoint(sideid);
  norm=SIDE_GetNormal(sideid);
  diff=VECTOR_Sub(pp,mp);
  l=VECTOR_Length(diff);
  diff=VECTOR_Scale(diff,1.0/l);
  l=(l-ACTOR_GetRadius(actorid))/GLOBAL_GetScale();
  dot=VECTOR_Dot(diff,norm);
  if (dot<0.75) or (l>0.2) then 
    return;
  end;

  
  ACTOR_SetVar(actorid,"IsAlive",0);
  ACTOR_SetVar(actorid,"KilledString","Spiked!");
  if ACTOR_IsPlayer(actorid)==1 then
     SOUND_Play(snd_spiked,-1);
  end;
end;
