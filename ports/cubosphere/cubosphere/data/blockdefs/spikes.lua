texture=-1;
spikemdl=-1;

speedmult=1.0;


snd_spiked=-1;
snd_out=-1;
snd_in=-1;

spike_sound_dist=10;

spike_max_channels=8;

up=VECTOR_New(0,0,0);
dir=VECTOR_New(0,0,0);
right=VECTOR_New(0,0,0);
pos=VECTOR_New(0,0,0);
depth=0;

function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no";
 elseif name=="NumVars" then
  return 2;
 elseif name=="Var1" then
  return "Phase";
 elseif name=="VarType1" then
  return "float";
 elseif name=="Var2" then
  return "Speed";
 elseif name=="VarType2" then
  return "float";
 end;
 return default;
end;


function Precache()
  texture=TEXDEF_Load("spike1");
  spikemdl=MDLDEF_Load("cone");
  snd_spiked=SOUND_Load("spiked");
  snd_in=SOUND_Load("spikes_in");
  snd_out=SOUND_Load("spikes_out");
  --print(spikemdl);
end

function SideConstructor(side)
  SIDE_SetVar(side,"Phase",0);
  SIDE_SetVar(side,"Speed",1);
  SIDE_SetVar(side,"LastSound","none");
end;

function RenderSpike(offsx,offsy)
  --local offs=VECTOR_Add(VECTOR_Add(pos,VECTOR_Add(VECTOR_Scale(right,GLOBAL_GetScale()*offsx),VECTOR_Scale(dir,GLOBAL_GetScale()*offsy))),VECTOR_Scale(up,-depth)); 
  local offs=VECTOR_Add(pos,VECTOR_Add(VECTOR_Scale(right,GLOBAL_GetScale()*offsx),VECTOR_Scale(dir,GLOBAL_GetScale()*offsy))); 
  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,offs);
  local s=1-depth;
  MATRIX_ScaleUniform(GLOBAL_GetScale()/30.0*s);
  --MATRIX_Translate(pos);
  MDLDEF_Render(spikemdl);
  MATRIX_Pop();
end;

function SSound(what,side)
 local r;

 if SIDE_GetVar(side,"LastSound")==what then
   return;
 end;



 local dist=VECTOR_Length(VECTOR_Sub(CAM_GetPos(),SIDE_GetMidpoint(side)));
 if dist>spike_sound_dist*GLOBAL_GetScale() then
  return;
 end;


  local nchan=SOUND_AllocateChannels(-1); --Simple Getter
 local nsounds=0;
 for c=0,nchan-1,1 do
  local c_snd=SOUND_PlayedByChannel(c);
  if c_snd==snd_out or c_snd==snd_in then
     nsounds=nsounds+1;
  end;
 end;
 if nsounds>spike_max_channels then
  return;
 end;

 if what=="out" then
   r=SOUND_Play(snd_out,-1);
  -- print("Outsound "..side);
 else
   r=SOUND_Play(snd_in,-1);
 end;
 SOUND_Set3dFromCam(r,SIDE_GetMidpoint(side),spike_sound_dist*GLOBAL_GetScale());
end;

function GetDepth(side)
  local time=LEVEL_GetTime()+SIDE_GetVar(side,"Phase")*3;
  local oldtime=time-LEVEL_GetElapsed();
  local omega=math.fmod(time*SIDE_GetVar(side,"Speed")*speedmult,3);
  local oldomega=math.fmod(oldtime*SIDE_GetVar(side,"Speed")*speedmult,3);
  if omega<0.5 then
    depth=1;
  elseif omega<0.7 then
    if oldomega<0.5 then
     SSound("out",side);
     SIDE_SetVar(side,"LastSound","out");
    end;
    depth=(0.7-omega)/(0.7-0.5);
  elseif omega<1.5 then
    depth=0
  elseif omega<2.0 then
    if oldomega<1.5 then
     SSound("in",side);
     SIDE_SetVar(side,"LastSound","in");
    end;
    depth=1-(2.0-omega)/(2.0-1.5);
  else 
    depth=1;
  end
  
  --depth=depth*GLOBAL_GetScale()*0.7;
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
  pos=SIDE_GetMidpoint(side); 
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);
  dist=0.3333333;

  GetDepth(side);


  RenderSpike(dist,dist);
  RenderSpike(dist,-dist);
  RenderSpike(-dist,-dist);
  RenderSpike(-dist,dist);

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

  GetDepth(sideid);
  if depth>0.4 then
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
  if (dot<0.85) or (l>0.4) then 
    return;
  end;

  
  ACTOR_SetVar(actorid,"IsAlive",0);
  ACTOR_SetVar(actorid,"KilledString","Spiked!");

  if ACTOR_IsPlayer(actorid)==1 then
     SOUND_Play(snd_spiked,-1);
  end;
end;
