--Knife block

--knife_length=1.5; --How far must the knife go into the block in order to disappear totally (adjust for your model)
--knife_collide_depth=0.8; --How far the knife can do harm. 1 = always, 0 = only when completely moved out.. choose a value between 0 and 1
--knife_collide_distance=0.5; -- Another adjustable parameter for collision detection 

texture=-1;
spikemdl=-1;
speedmult=1.0;
snd_spiked=-1;
snd_out=-1;
snd_in=-1;

depth=0;

--Adjusting the max. sound distance
knife_sound_dist=10;
--And the max. channels used by the sound
knife_max_channels=8;

--Temp storage of Basis Vectorsfor rendering
up=VECTOR_New(0,0,0);
dir=VECTOR_New(0,0,0);
right=VECTOR_New(0,0,0);
pos=VECTOR_New(0,0,0);


--Exporting the Variables to the Editor
function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no"; --No items allowed on the knife block
 elseif name=="NumVars" then
  return 3; --Three adjustables variables
 elseif name=="Var1" then
  return "Pattern"; --The first var is called "Pattern"
 elseif name=="VarType1" then
  return "string"; --and is a string
 elseif name=="Var2" then
  return "PatternIndex"; --see above
 elseif name=="VarType2" then
  return "int";
 elseif name=="Var3" then
  return "Speed";
 elseif name=="VarType3" then
  return "float";
 end;
 return default; 
end;


--Load the media
function Precache()
  texture=TEXDEF_Load("spike1");
  spikemdl=MDLDEF_Load("knife");
  snd_spiked=SOUND_Load("spiked");
  snd_in=SOUND_Load("knife_in");
  snd_out=SOUND_Load("knife_out");
  --print(spikemdl);
end


--Initializing each side <side> on creation
function SideConstructor(side)
  SIDE_SetVar(side,"Pattern","iiiiooiioo");
  SIDE_SetVar(side,"PatternIndex",0);
  SIDE_SetVar(side,"Speed",4);
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


--Create a sound if not already playing
function SSound(what,side)
 local r;

 --Have we played it already?
 if SIDE_GetVar(side,"LastSound")==what then
   return;
 end;

 --Calculated the distance to the camera
 local dist=VECTOR_Length(VECTOR_Sub(CAM_GetPos(),SIDE_GetMidpoint(side)));
 if dist>knife_sound_dist*GLOBAL_GetScale() then
  return; --Too far away to make a sound
 end;

  
 local nchan=SOUND_AllocateChannels(-1); --Get the number of sound channels
 local nsounds=0;
 for c=0,nchan-1,1 do --Test all channels, whether they are playing knife sounds
  local c_snd=SOUND_PlayedByChannel(c);
  if c_snd==snd_out or c_snd==snd_in then
     nsounds=nsounds+1; --Channel occupied by a knife sound. Increase counter
  end;
 end;
 if nsounds>knife_max_channels then
  return; --Too many knife sounds playing
 end;

 if what=="out" then
   r=SOUND_Play(snd_out,-1); --Out sound
 else
   r=SOUND_Play(snd_in,-1); --In sound
 end;
 --Set the 3d effect
 SOUND_Set3dFromCam(r,SIDE_GetMidpoint(side),knife_sound_dist*GLOBAL_GetScale());
end;

--Calculates, how far the knife is inside the block depending on the side's settings
function GetDepth(side)
  --Get the time, scale it by <Speed> and add the "phase" <PatternIndex>
  local time=LEVEL_GetTime()*SIDE_GetVar(side,"Speed")+SIDE_GetVar(side,"PatternIndex");
  --Round it downwards to an index
  local ind=math.floor(time);
  --Get the fractional part (0.0 to 0.99999999) for later interpolation of the position 
  local frac=time-ind;

  --Get the Pattern
  local pat=SIDE_GetVar(side,"Pattern");
  --Clamp the current index <ind> and next index <ind2> to the size of the <Pattern> string
  local ind=math.fmod(ind,string.len(pat))+1;
  local ind2=math.fmod(ind,string.len(pat))+1;

  --Get the letters
  local now=string.lower(string.sub(pat,ind,ind)); 
  local next=string.lower(string.sub(pat,ind2,ind2));


  if (now=="i") then 
    ind=1; --Knife in => Depth=1
  else ind=0; end; --Knife out => Depth=0

  if (next=="i") then 
    ind2=1;
  else ind2=0; end; --See above

  if (ind~=ind2) then --We have to play a sound due to the change of the state
     if ind2==1 then
       SSound("in",side);
       SIDE_SetVar(side,"LastSound","in");
     else
       SSound("out",side);
       SIDE_SetVar(side,"LastSound","out");
     
     end;
  end;

   return (1.0-frac)*ind+frac*ind2; --Interpolate the position between current and next state
  
end;




--Cubo calls this function when rendering the side
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

  depth=GetDepth(side);

 
  RenderSpike(dist,dist);
  RenderSpike(dist,-dist);
  RenderSpike(-dist,-dist);
  RenderSpike(-dist,dist);
  --Here draw the model!
end

--Check if the face may be culled
function MayCull(side)
  return 0; -- No, since we have a huge knife on the side... no backface culling allowed
end

function ActsOnActor(actor)
--Test, if enemys can be killed by this side, toofunction ActsOnActor(actor)
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

--Test the collision with the side
function SideCollisionCheck(actorid,sideid)
  knife_collide_depth=0.4;
  if ACTOR_GetVar(actorid,"IsAlive")~=1 then
    return; --When the actor/enemy is dead already, no need to check
  end;

 if ActsOnActor(actorid)==0 then
    return; --Not acting on the enemy
  end;

  local depth=GetDepth(sideid);
  if depth>knife_collide_depth then --Too deep in the block to do damage
   return;
  end;
  pp=ACTOR_GetPos(actorid);
  mp=SIDE_GetMidpoint(sideid);
  norm=SIDE_GetNormal(sideid);
  diff=VECTOR_Sub(pp,mp); --Difference between actor and side midpoint
  l=VECTOR_Length(diff);
  diff=VECTOR_Scale(diff,1.0/l);
  l=(l-ACTOR_GetRadius(actorid))/GLOBAL_GetScale(); --Reduce the length by the actor radius and normalize
  dot=VECTOR_Dot(diff,norm); --Determine angle, i.e. if you are really above the surface and in the knife
  if (dot<0.85) or (l>0.4) then 
    return; --We are Save
  end;

  
  ACTOR_SetVar(actorid,"IsAlive",0); --Outsch
  ACTOR_SetVar(actorid,"KilledString","Spiked!");

  if ACTOR_IsPlayer(actorid)==1 then
     SOUND_Play(snd_spiked,-1);
  end;
end;
