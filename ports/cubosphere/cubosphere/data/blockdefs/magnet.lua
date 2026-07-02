INCLUDEABSOLUTE("/blockdefs/include/colors.inc");

mdl=-1;
texture=-1;
snd_effect=-1;


ray_effect_speed=0.5;
attractionspeed=8;

--How fast is the beam collapsing or building up when it is toggled 
beamspeed=attractionspeed*0.2;


up=VECTOR_New(0,0,0);
dir=VECTOR_New(0,0,0);
right=VECTOR_New(0,0,0);
pos=VECTOR_New(0,0,0);

raytex=-1;

USING("GL");

RayRenderLists={}


function SetupMaterial(side)
  local type;
  local ts=SIDE_GetVar(side,"TwoState");
  local dist=SIDE_GetVar(side,"Distance");
  if dist==0 then
    return GLOBAL_SetVar("MagnetType",2);
  elseif ts==0 then
    if dist>0 then
      GLOBAL_SetVar("MagnetType",0);
    else
      GLOBAL_SetVar("MagnetType",1);
    end; 
  else 
    GLOBAL_SetVar("MagnetType",2);
  end;
end;

function GetStrength(side)
 local ts=SIDE_GetVar(side,"TwoState");
 local dist=SIDE_GetVar(side,"Distance");
 local ss=SIDE_GetVar(side,"StartStrength");
 if dist==0 then
  return math.fmod(ss,2);
 elseif ts==0 then
   if dist>0 then
     return math.fmod(ss,3);
   else
     return 2-math.fmod(ss,3);
   end; 
 else 
   if dist>0 then
     return 1+math.fmod(ss,2);
   else
     return 2*math.fmod(ss,2);
   end; 
 end;
end;


function ColorFunc(color,alpha_factor)
 ActivateCuboColorAlpha(color,0,1.0,1.0,1.0,alpha_factor);
end;

function RenderRayDirect(dist,color)
 local numphi=18;
 local rad1=0.65;
 local rad2=0.85;
 local hei=dist;
 local maxalpha=0.5;
 local texture_u_reps=8;
 local texture_v_reps=0.25;
 local theX=rad1/rad2*(dist+0.5)/(1.0-rad1/rad2);
 local radm=(theX+dist)/(theX)*rad1;
 local radn=(theX+0.5)/(theX)*rad1;

 if dist<0.5 then return end;
 local rad=radn;
   glBegin("GL_QUAD_STRIP");
   for i=0,numphi,1 do
     local phi=i*2*math.pi/numphi;
     glNormal3f(math.cos(phi),0,math.sin(phi)); --Not exact!
     glTexCoord2f(i/numphi*texture_u_reps,0);
     ColorFunc(color,0);
     glVertex3f(rad1*math.cos(phi),0.0,rad1*math.sin(phi));
     glTexCoord2f(i/numphi*texture_u_reps,0.5*texture_v_reps);
     ColorFunc(color,maxalpha);
     glVertex3f(rad*math.cos(phi),0.5,rad*math.sin(phi));
   end;
   glEnd();
  
  -- if dist>0.5 then
   local rads=rad;
   rad=radm; 
   glBegin("GL_QUAD_STRIP");
   for i=0,numphi,1 do
     local phi=i*2*math.pi/numphi;
     glNormal3f(math.cos(phi),0,math.sin(phi)); --Not exact!
     glTexCoord2f(i/numphi*texture_u_reps,0.5*texture_v_reps);
     ColorFunc(color,maxalpha);
     glVertex3f(rads*math.cos(phi),0.5,rads*math.sin(phi));
     glTexCoord2f(i/numphi*texture_u_reps,dist*texture_v_reps);
     ColorFunc(color,maxalpha);
     glVertex3f(rad*math.cos(phi),dist,rad*math.sin(phi));
   end;
   glEnd();
--   end;
 

   glBegin("GL_QUAD_STRIP");
   for i=0,numphi,1 do
     local phi=i*2*math.pi/numphi;
    glNormal3f(math.cos(phi),0,math.sin(phi)); --Not exact!
     glTexCoord2f(i/numphi*texture_u_reps,dist*texture_v_reps);
     ColorFunc(color,maxalpha);
     glVertex3f(rad*math.cos(phi),dist,rad*math.sin(phi));
     glTexCoord2f(i/numphi*texture_u_reps,(dist+0.5)*texture_v_reps);
     ColorFunc(color,0);
     glVertex3f(rad2*math.cos(phi),dist+0.5,rad2*math.sin(phi));
   end;
   glEnd();
end;

function CreateRayList(dist,color)
 if RayRenderLists[color]~=nil then
   if RayRenderLists[color][dist]~=nil then
      return RayRenderLists[color][dist];
   end;
 else
   RayRenderLists[color]={};
 end;
 local raylist=glGenLists(1);
 if raylist==0 then
  print("Error creating DisplayList");
  return;
 end;


 glBeginListCompile(raylist);
  RenderRayDirect(dist,color);


 glEndListCompile();
 RayRenderLists[color][dist]=raylist;
 return raylist;
end;

function CleanUp()
 for color,disttable in pairs(RayRenderLists) do
   for dist,entry in pairs(disttable) do
     glDeleteLists(entry,1); 
   end;
 end;
end;


function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no";
 elseif name=="NumVars" then
  return 4;
 elseif name=="Var1" then
  return "Distance";
 elseif name=="VarType1" then
  return "int";
 elseif name=="Var2" then
  return "StartStrength";
 elseif name=="VarType2" then
  return "int";
 elseif name=="Var3" then
  return "Color";
 elseif name=="VarType3" then
  return "basecolor";
 elseif name=="Var4" then
  return "TwoState";
 elseif name=="VarType4" then
  return "bool";
 
 else
 return default;
  end;
end;

function CheckLastActor(actor,side)
 if ACTOR_CurrentMove(actor)=="changegravity" then
   return 1;
  end; 
  return 0;
end;

function SideCollisionCheck(actorid,sideid)

   local sstr=GetStrength(sideid);
   local sdist=SIDE_GetVar(sideid,"CDistance");
  if sstr==0 and sdist==0 then
   return;
  end;

  if ACTOR_GetVar(actorid,"IsAlive")~=1 then
    return;
  end;
 

 local adir=ACTOR_GetDir(actorid);
 --local sdist=math.abs(SIDE_GetVar(sideid,"Distance"));

  if ACTOR_GetOnSide(actorid)==sideid  then
    if sstr==2 then
     SIDE_SetVar(sideid,"LastActor",-1);
     SIDE_SetVar(sideid,"AttractSpeed",beamspeed*6);
    end;
    return; 
  end;
  
  if sstr==1 and sdist==0 then
   return;
  end;

  if ACTOR_CurrentMove(actorid)=="changegravity" then
   return;
  end; 

  pp=ACTOR_GetPos(actorid);
  mp=SIDE_GetMidpoint(sideid);
  norm=SIDE_GetNormal(sideid);
  diff=VECTOR_Sub(pp,mp);
  
  dist=VECTOR_Dot(diff,norm);
  if dist>GLOBAL_GetScale()*(sdist+0.25) or dist<0 then
   return 0;
  end;

  mp=VECTOR_Add(mp,VECTOR_Scale(norm,dist));
  diff=VECTOR_Sub(pp,mp);
  local rdist=VECTOR_Length(diff);
  
  if rdist>0.75*GLOBAL_GetScale() then
   return 0;
  end;
  
  if VECTOR_Dot(ACTOR_GetUp(actorid),norm)>0.8 then
    if ACTOR_GetOnSide(actorid)>=0 or ACTOR_GetJumpDistBlocks(actorid)==0 then
      return; --Only check when the actor tries to jump over this block
    elseif ACTOR_CurrentMove(actorid)=="farjump" then
    --  print("MOVE: "..ACTOR_CurrentMove(actorid));
      if VECTOR_Dot(diff,ACTOR_GetDir(actorid))>0.8*VECTOR_Length(diff) then
        return;
      end;
    end;
  end;
  
  dist=dist/GLOBAL_GetScale();
  if dist<0.5 then dist=0.5; end; if dist>6 then dist=6; end; 
  local speed=attractionspeed/dist; 
--Change the gravity
   local r=ACTOR_ChangeGravity(actorid,VECTOR_Scale(norm,-1),VECTOR_Add(SIDE_GetMidpoint(sideid),VECTOR_Scale(norm,ACTOR_GetRadius(actorid)+ACTOR_GetGroundOffset(actorid))),speed,1);
    
   if r~=-1 then
     ACTOR_SetJumpDistBlocks(actorid,0);
     --Emit sound
     SIDE_SetVar(sideid,"AttractSpeed",speed);
     SIDE_SetVar(sideid,"LastActor",actorid);
     SOUND_Play(snd_effect,-1);
   end;
  
end;

function MayMove(side,actor,dir)
if ACTOR_IsPlayer(actor)~=0 then

   local sstr=GetStrength(side);
   local cdist=SIDE_GetVar(side,"CDistance");
  if sstr==0 and cdist==0 then
   return 1;
  end;

 ACTOR_SetForwardPressTime(actor,1000);
 if (dir=="jumpahead" or dir=="jumpup" or dir=="jumpfar") then 
    return 0;
 else 
   return 1;
 end;

end;
 return 1;
end;

function SideConstructor(sideid)
 SIDE_SetVar(sideid,"FirstThink",1);
 SIDE_SetVar(sideid,"Distance",4);
 SIDE_SetVar(sideid,"CDistance",4);
 SIDE_SetVar(sideid,"StartStrength",2);
 SIDE_SetVar(sideid,"AttractSpeed",0);
 SIDE_SetVar(sideid,"LastActor",-1);
 SIDE_SetVar(sideid,"Color",0);
 SIDE_SetVar(sideid,"TwoState",0);
end;

function Precache()
GLOBAL_SetVar("MagnetType",0);
GLOBAL_SetVar("MagnetEffectRender",0);
GLOBAL_SetVar("RenderColor",0);
GLOBAL_SetVar("RenderColorAdder",0);

  mdl=MDLDEF_Load("magnet");
  texture=TEXDEF_Load("base");
  snd_effect=SOUND_Load("gravityrotate");
  raytex=TEXTURE_Load("magnet_ray_pattern");
end




function RenderMdl(side,height)
 local CDist=SIDE_GetVar(side,"CDistance");
  local stre=GetStrength(side);
  if stre~=0  then
    local blinkspeed=4;
    GLOBAL_SetVar("RenderColorAdder",0.0175*math.sin(blinkspeed*GLOBAL_GetTime()));
  else
    GLOBAL_SetVar("RenderColorAdder",-0.0175);  
  end;

  GLOBAL_SetVar("RenderColor",SIDE_GetVar(side,"Color"));

  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,SIDE_GetMidpoint(side));
  MATRIX_ScaleUniform(GLOBAL_GetScale()*0.8);

  local s=GLOBAL_GetVar("MagnetEffectRender");
  SetupMaterial(side);


if s~=0 then 
       CULL_Mode(0);
DEPTH_Mask(0);
end;
  
  MDLDEF_Render(mdl);


  if CDist>0 and s~=0 then
  BLEND_Function(770,1);
 --   BLEND_Activate();
  DEPTH_Mask(0);
 CULL_Mode(0);
   local raylist=-1;
   if CDist==SIDE_GetVar(side,"Distance") or CDist==1 then raylist=CreateRayList(CDist,SIDE_GetVar(side,"Color")); end;

 LIGHT_Activate(1);

 TEXTURE_Activate(raytex,0);
 TEXTURE_MatrixMode(1);
   MATRIX_Push();
   MATRIX_Translate(VECTOR_New(0,GLOBAL_GetTime()*ray_effect_speed,0));
    CULL_Mode(2);
    if raylist==-1 then RenderRayDirect(CDist,SIDE_GetVar(side,"Color")); else glCallList(raylist); MATERIAL_Invalidate(); end;
    CULL_Mode(1);
    if raylist==-1 then RenderRayDirect(CDist,SIDE_GetVar(side,"Color")); else glCallList(raylist); MATERIAL_Invalidate(); end;
   MATRIX_Pop();
  TEXTURE_MatrixMode(0);
  end;
 
  if s~=0 or CDist>0 then
       CULL_Mode(1);
    BLEND_Function(770,771);
--    BLEND_Deactivate();
 DEPTH_Mask(1);
  end;

 LIGHT_Deactivate(1);
  MATRIX_Pop();
end;

function RenderModel(side)
 up=SIDE_GetNormal(side);
 dir=SIDE_GetTangent(side);
 right=VECTOR_Cross(up,dir);  

    RenderMdl(side,height);

end;

function RenderSide(side)
  TEXDEF_Render(texture,side);
  TEXDEF_ResetLastRenderedType();
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;


  GLOBAL_SetVar("MagnetEffectRender",0);
  RenderModel(side)
 if GetStrength(side)==1 then
  SIDE_DistanceRender(side,CAM_ZDistance(SIDE_GetMidpoint(side)));
 end;

end


function SideThink(side)
  local cdist=SIDE_GetVar(side,"CDistance");
  local dist=SIDE_GetVar(side,"Distance");
  if dist<0 then dist=-dist; end;
  local ldist=dist;
 if ldist<0.5 then ldist=0.5; end; if ldist>6 then ldist=6; end; 
  local bs=beamspeed*ldist;

 local fs=SIDE_GetVar(side,"FirstThink");
  
if fs==1 or GLOBAL_GetVar("EditorMode")==1 then
  if GetStrength(side)==2 then SIDE_SetVar(side,"CDistance",dist); else SIDE_SetVar(side,"CDistance",0); end; 
  if GLOBAL_GetVar("EditorMode")~=1 then
   SIDE_SetVar(side,"FirstThink",0);
  end;
else
 if SIDE_GetVar(side,"AttractSpeed")~=0 then
  local as=SIDE_GetVar(side,"AttractSpeed")*beamspeed;
  if cdist>0.5 then cdist=cdist-GLOBAL_GetElapsed()*as; end;
  if cdist<0.5 then cdist=0.5; end;
 elseif GetStrength(side)==2 then
  if cdist<dist then cdist=cdist+GLOBAL_GetElapsed()*bs; end;
  if cdist>dist then cdist=dist; end;
 else
  if cdist>0 then cdist=cdist-GLOBAL_GetElapsed()*bs; end;
  if cdist<0 then cdist=0; end;
 end;  
  SIDE_SetVar(side,"CDistance",cdist);
end;

 if cdist>0 then
  SIDE_DistanceRender(side,CAM_ZDistance(SIDE_GetMidpoint(side)));
 end;

 if SIDE_GetVar(side,"AttractSpeed")~=0 then
  local ch=0;
  local la=SIDE_GetVar(side,"LastActor");
  if la>=0 then 
    ch=CheckLastActor(la,side);
  end;
  if ch==0 then
    SIDE_SetVar(side,"AttractSpeed",0)
   end;
 end;
end;

function DistRenderSide(side)
  local stre=GetStrength(side); 
  if stre==0 then stre=1; end;

  GLOBAL_SetVar("MagnetEffectRender",stre);
  RenderModel(side)
  
end




function MayCull(side)
  return 0;
end

