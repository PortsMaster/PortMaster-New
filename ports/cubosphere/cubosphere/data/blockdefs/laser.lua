INCLUDEABSOLUTE("/blockdefs/include/colors.inc");

correct_transparency=true;
--Set it to true for the correct z-order in the alpha pass. May slow down the performance!


USING("GL");


texture=-1;
lasermdl=-1;
lensmdl=-1;
ltex=-1;

snd_lasered=-1;

 dist=0.5;  --Displacement of the lasers from face center
 addscale=1.0; --Scale controller
 
 ray_radius=1.75; -- ray radius at collision check

local up=VECTOR_New(0,0,0);
local dir=VECTOR_New(0,0,0);
local right=VECTOR_New(0,0,0);
local pos=VECTOR_New(0,0,0);
depth=0;


function SideVarChanged(v,side)
   local tr=LEVEL_TraceLine(SIDE_GetMidpoint(side),SIDE_GetNormal(side));
    if tr["hit"]==1 then
       if SIDE_GetType(tr["side"])=="laser" then
         --Copy the changed var to the other side
         SIDE_SetVar(tr["side"],v,SIDE_GetVar(side,v));
       end;
    end;
end;

function Precache()
  texture=TEXDEF_Load("base");
  lasermdl=MDLDEF_Load("cyl");
  lensmdl=MDLDEF_Load("laserlens");
  snd_lasered=SOUND_Load("lasered");
  for c=0,NumCuboColors-1,1 do BuildRenderList(c); end;
 end

function GetOffs(offsx,offsy)
 return VECTOR_Add(pos,VECTOR_Add(VECTOR_Scale(right,GLOBAL_GetScale()*offsx),VECTOR_Scale(dir,GLOBAL_GetScale()*offsy)));
end;

function TransToOffs(offsx,offsy)
  local offs=GetOffs(offsx,offsy); 
  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,offs);
  
 
  return offs;
end;

function RenderLaser(offsx,offsy,sid)
  local offs=TransToOffs(offsx,offsy);
   local tr=LEVEL_TraceLine(offs,up);
  if tr["hit"]==1 then
    local factor=1;
    if SIDE_GetType(tr["side"])=="laser" then
      if tr["side"]<sid then
         MATRIX_Pop();       
         return; --The laser is spawned by the other side
      end;
    end;
    MATRIX_Scale(VECTOR_New(2*addscale,factor*tr["dist"],2*addscale));
    MDLDEF_Render(lasermdl);   
  end;
  MATRIX_Pop();
end;

function RenderLens(offsx,offsy)
  TransToOffs(offsx,offsy);
-- MATRIX_ScaleUniform(2.9*addscale);
    MDLDEF_Render(lensmdl);
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
  pos=SIDE_GetMidpoint(side); 
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);
 
  depth=0.5;


   TEXTURE_Activate(-1,0);
   SetColor(side);
   RenderLens(0,0);
 



end



LaserRenderLists={};
LaserRenderLists5={};

function CleanUp()
 for color,entry in pairs(LaserRenderLists) do
     glDeleteLists(entry,1); 
   end;
 for color,entry in pairs(LaserRenderLists5) do
     glDeleteLists(entry,1); 
   end;
end;





LastRenderID=-1;
CurrentRenderIndex=0;
IsFiveBlock={};
SideIDs={};
Offsets={};
StartDists={};
EndDists={};

  
 



function BuildRenderList(col)
  LaserRenderLists[col]=glGenLists(1);
  glBeginListCompile(LaserRenderLists[col]);
   
 MATERIAL_Invalidate();

 RayAmbientFactor=0.5;
 RayDiffuseFactor=0.5;
 RaySpecularFactor=1.0;

 ActivateCuboColor(col,0,RayAmbientFactor,RayDiffuseFactor,RaySpecularFactor);

  MATRIX_Scale(VECTOR_New(2*addscale,1,2*addscale));
 -- BLEND_Activate();
  BLEND_Function(1,1);
  DEPTH_Mask(0);
  LIGHT_Activate(1);

  MDLDEF_Render(lasermdl);

  LIGHT_Deactivate(1);
  DEPTH_Mask(1);
  BLEND_Function(770,771);
 -- BLEND_Deactivate();

  MATERIAL_Invalidate();
 glEndListCompile();


LaserRenderLists5[col]=glGenLists(1);
  glBeginListCompile(LaserRenderLists5[col]);
 ActivateCuboColor(col,0,RayAmbientFactor,RayDiffuseFactor,RaySpecularFactor);

  MATRIX_Scale(VECTOR_New(2*addscale,1,2*addscale));
 -- BLEND_Activate();
  BLEND_Function(1,1);
  DEPTH_Mask(0);
  LIGHT_Activate(1);

  MDLDEF_Render(lasermdl);
  local d=5;
  MATRIX_Translate(VECTOR_New(d,0,d));
   MDLDEF_Render(lasermdl);
  MATRIX_Translate(VECTOR_New(0,0,-2*d));
   MDLDEF_Render(lasermdl);
  MATRIX_Translate(VECTOR_New(-2*d,0,0));
   MDLDEF_Render(lasermdl);
 MATRIX_Translate(VECTOR_New(0,0,2*d));
   MDLDEF_Render(lasermdl);

  LIGHT_Deactivate(1);
  DEPTH_Mask(1);
  BLEND_Function(770,771);
--  BLEND_Deactivate();


 glEndListCompile();

end;

function SetColor(side)
  local add;
  if SIDE_GetVar(side,"StartActive")==1 then
    local blinkspeed=4;
    add=0.0175*math.sin(blinkspeed*GLOBAL_GetTime());
  else
    add=-0.0175;  
  end;
  local colind=SIDE_GetVar(side,"Color");
  ActivateCuboColor(colind,add,1.0,1.0,1.0);

end;




function CustomDistanceRender(id)

 local side=SideIDs[id];
  up=SIDE_GetNormal(side);
  pos=SIDE_GetMidpoint(side); 
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);

 MATRIX_Push();
 
 MATRIX_MultBase(right,up,dir,VECTOR_Add(Offsets[id],VECTOR_Scale(up,StartDists[id])));
 local length=EndDists[id]-StartDists[id];
 MATRIX_Scale(VECTOR_New(1,length,1));
if IsFiveBlock[id]==false then
 glCallList(LaserRenderLists[SIDE_GetVar(side,"Color")]);
else 
 glCallList(LaserRenderLists5[SIDE_GetVar(side,"Color")]);
end;
 MATRIX_Pop();
MATERIAL_Invalidate();
end;




RayLengths={}
RayOffsets={}
function GetRayLength(sid,offsx,offsy,ind)
  RayOffsets[ind]=GetOffs(offsx,offsy);
  local tr=LEVEL_TraceLine(RayOffsets[ind],up);
  if tr["hit"]==1 then
    if SIDE_GetType(tr["side"])=="laser" then
      if tr["side"]<sid then  
         RayLengths[ind]=0; return;
      end;
    end;
  else 
   RayLengths[ind]=0;
  end;
  RayLengths[ind]=tr["dist"];
end;

function SideThink(side)
 if SIDE_GetVar(side,"StartActive")==1 then
  
  up=SIDE_GetNormal(side);
  pos=SIDE_GetMidpoint(side); 
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);

if correct_transparency==true then
   GetRayLength(side,0,0,1);
   GetRayLength(side,dist,dist,2);
   GetRayLength(side,-dist,dist,3);
   GetRayLength(side,-dist,-dist,4);
   GetRayLength(side,dist,-dist,5);

   local mindist=1000000000; local maxdist=0;
   for i=1,5,1 do 
    if RayLengths[i]>maxdist then maxdist=RayLengths[i]; end;
    if RayLengths[i]<mindist then mindist=RayLengths[i]; end;
   end;
   if maxdist<0.0000001 then return; end;

    local bsize=2*GLOBAL_GetScale();
    local currd=0;

   if LastRenderID~=GAME_GetRenderPassID() then
     LastRenderID=GAME_GetRenderPassID()
     CurrentRenderIndex=0;
   end;

    while currd<maxdist-0.000001 do
      if currd<mindist then --Render five block 
            SideIDs[CurrentRenderIndex]=side;
            IsFiveBlock[CurrentRenderIndex]=true;
            Offsets[CurrentRenderIndex]=RayOffsets[1];
            StartDists[CurrentRenderIndex]=currd;
            EndDists[CurrentRenderIndex]=math.min(currd+bsize,mindist);
            local cpos=VECTOR_Add(RayOffsets[1],VECTOR_Scale(up,0.5*(StartDists[CurrentRenderIndex]+EndDists[CurrentRenderIndex])));
            LEVEL_CustomDistanceRender(CurrentRenderIndex,CAM_ZDistance(cpos));
            LEVEL_LastDistanceRenderCull(cpos,bsize);
            CurrentRenderIndex=CurrentRenderIndex+1;
      else --Single Lasers
       for l=1,5,1 do
         if RayLengths[l]>currd then
            SideIDs[CurrentRenderIndex]=side;
            IsFiveBlock[CurrentRenderIndex]=false;
            Offsets[CurrentRenderIndex]=RayOffsets[l];
            StartDists[CurrentRenderIndex]=currd;
            EndDists[CurrentRenderIndex]=math.min(currd+bsize,RayLengths[l]);
            local cpos=VECTOR_Add(RayOffsets[l],VECTOR_Scale(up,0.5*(StartDists[CurrentRenderIndex]+EndDists[CurrentRenderIndex])));
            LEVEL_CustomDistanceRender(CurrentRenderIndex,CAM_ZDistance(cpos));
            LEVEL_LastDistanceRenderCull(cpos,bsize);
            CurrentRenderIndex=CurrentRenderIndex+1;
         end;
       end;
      end;
      
      currd=currd+bsize;
    end;


else
  SIDE_DistanceRender(side,100000); 
end;


   
    
 end;
end;

function DistRenderSide(side)  


--  BLEND_Activate();
  BLEND_Function(1,1);
 up=SIDE_GetNormal(side);
  pos=SIDE_GetMidpoint(side); 
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);
  
 
 
 SetColor(side);
 --Todo: In distrendering
  DEPTH_Mask(0);
LIGHT_Activate(1);
  RenderLaser(dist,dist,side);
  RenderLaser(dist,-dist,side);
  RenderLaser(-dist,-dist,side);
  RenderLaser(-dist,dist,side);
    RenderLaser(0,0,side);
LIGHT_Deactivate(1);

  DEPTH_Mask(1);
  --Here draw the model!
   BLEND_Function(770,771);
  -- BLEND_Deactivate();
end;



function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no";
 elseif name=="NumVars" then
  return 2;
 elseif name=="Var1" then
  return "StartActive";
 elseif name=="VarType1" then
  return "bool"; 
 elseif name=="Var2" then
  return "Color";
 elseif name=="VarType2" then
  return "basecolor"; 
 else
 return default;
  end;
end;

function TestOtherside(side)
   local tr=LEVEL_TraceLine(SIDE_GetMidpoint(side),SIDE_GetNormal(side));
    if tr["hit"]==1 then
       if SIDE_GetType(tr["side"])=="laser" then
         --Copy the  vars  from the other side
         SIDE_SetVar(side,"StartActive",SIDE_GetVar(tr["side"],"StartActive"));
         SIDE_SetVar(side,"Color",SIDE_GetVar(tr["side"],"Color"))
       end;
    end;
end;




function SideConstructor(sideid)
  SIDE_SetVar(sideid,"StartActive",1);
  SIDE_SetVar(sideid,"Color",0);
  TestOtherside(sideid);
end;

actorpos=VECTOR_New(0,0,0);
actorrad=GLOBAL_GetScale()/2;

colside=-1;
colactor=-1;

function SideCollLaser(offsx,offsy)

   local offs=GetOffs(offsx,offsy);

--function SideCollLaser(i)
  -- local offs=VECTOR_Add(pos,VECTOR_New(SIDE_GetVar(colside,"LaserOffset_"..i.."_x"),SIDE_GetVar(colside,"LaserOffset_"..i.."_y"),SIDE_GetVar(colside,"LaserOffset_"..i.."_z")));
   local diff=VECTOR_Sub(actorpos,offs);
   local pl=VECTOR_Dot(diff,up);
   if pl<0 then --hinter der Laserquelle
    return 0;
   end;

   local dl=VECTOR_Dot(diff,diff);
   local ds=math.sqrt(dl-pl*pl); --Seitlicher Abstand
   
 --print("Colcheck"..colside.."   "..ds.."  vice "..actorrad);
   if ds-ray_radius>actorrad then
     return 0;
   end;



    local tr=LEVEL_TraceLine(offs,up);
    if tr["hit"]==1 and (tr["dist"]*tr["dist"]<dl) then
       return 0;
    end;

  --Ok, get the current move and vel
   local mv=ACTOR_CurrentMove(colactor);
   local uvel=ACTOR_GetUpVel(colactor);
   
   if mv=="farjump" and uvel>0 then 
     if VECTOR_Dot(diff,ACTOR_GetUp(colactor))>0 then --only jumping above the lasers!
       return 0; --We are save by jumping over with an farjump ---- This is quite a hack!
     end;
   end;

   ACTOR_SetVar(colactor,"IsAlive",0);
   ACTOR_SetVar(colactor,"KilledString","Lasered!");
   SOUND_Play(snd_lasered,-1);
   return 1;
end;

function ActsOnActor(actor)
  if ACTOR_IsPlayer(actor)==1 then
    if ACTOR_GetVar(actor,"GodModeTimer")>0 then 
      return 0
    else 
      return 1;
    end;
  end;
  local inter=ACTOR_GetVar(actor,"Interaction");
  if string.find(inter, "l") then
    return 1;
  else
    return 0;
  end;
end;


function SideCollisionCheck(actorid,sideid)

  if ACTOR_GetVar(actorid,"IsAlive")~=1 or SIDE_GetVar(sideid,"StartActive")==0 then
    return;
  end;
  
  if ActsOnActor(actorid)==0 then
   return;
  end;

  up=SIDE_GetNormal(sideid);
  pos=SIDE_GetMidpoint(sideid); 
  dir=SIDE_GetTangent(sideid);
  right=VECTOR_Cross(up,dir);
  actorpos=ACTOR_GetPos(actorid);
  actorrad=ACTOR_GetRadius(actorid);

  colside=sideid;
  colactor=actorid;

  if SideCollLaser(dist,dist)==0 then
    if SideCollLaser(-dist,dist)==0 then
      if SideCollLaser(dist,-dist)==0 then
          if SideCollLaser(-dist,-dist)==0 then
             SideCollLaser(0,0);
          end;
      end;
    end;
  end;
  
end;

