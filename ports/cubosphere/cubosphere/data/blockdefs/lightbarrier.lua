INCLUDEABSOLUTE("/blockdefs/include/colors.inc");

correct_transparency=true;
--Set it to true for the correct z-order in the alpha pass. May slow down the performance!

USING("GL");

texture=-1;
lasermdl=-1;
lensmdl=-1;
diodemdl=-1;
ltex=-1;

snd_barrier=-1;

 dist=0.5;  --Displacement of the lasers from face center
 addscale=1.0; --Scale controller
 diodenscale=2.0;

 ray_radius=1.75; -- ray radius at collision check

local up=VECTOR_New(0,0,0);
local dir=VECTOR_New(0,0,0);
local right=VECTOR_New(0,0,0);
local pos=VECTOR_New(0,0,0);
depth=0;


function SideVarChanged(v,side)
   local tr=LEVEL_TraceLine(SIDE_GetMidpoint(side),SIDE_GetNormal(side));
    if tr["hit"]==1 then
       if SIDE_GetType(tr["side"])=="lightbarrier" then
         SIDE_SetVar(tr["side"],v,SIDE_GetVar(side,v));
         TestOtherside(side);
       end;
    end;
end;

function Precache()
  texture=TEXDEF_Load("base");
  lasermdl=MDLDEF_Load("lightbarrier");
 --lasermdl=MDLDEF_Load("cyl");
  lensmdl=MDLDEF_Load("barrierlens");
  diodemdl=MDLDEF_Load("photodiode");
  snd_barrier=SOUND_Load("switch_on");
  for c=0,NumCuboColors-1,1 do BuildRenderList(c); end;
 end



LaserRenderLists={};

function CleanUp()
 for color,entry in pairs(LaserRenderLists) do
     glDeleteLists(entry,1); 
   end;
end;







LastRenderID=-1;
CurrentRenderIndex=0;
SideIDs={};
Offsets={};
StartDists={};
EndDists={};





function PrepareCustomDistRender(sid)
  local l=SIDE_GetVar(sid,"Range");
  up=SIDE_GetNormal(sid);
  pos=SIDE_GetMidpoint(sid); 
  RayOffset=pos;

  local tr=LEVEL_TraceLine(pos,up);
  if tr["hit"]~=0 then
   if tr["side"]==SIDE_GetVar(sid,"OtherSide") then
     SIDE_SetVar(sid,"FullRange",tr["dist"]);
   end;
   if tr["dist"]<l then l=tr["dist"]; end;
   else
     TestOtherside(sid);
  end

   local diode_illuminated=0;
   if math.abs(SIDE_GetVar(sid,"FullRange")-l)<0.001 then
       diode_illuminated=1;
   end;
   if diode_illuminated~=SIDE_GetVar(sid,"DiodeIlluminated") and GLOBAL_GetVar("EditorMode")~=1 then
    if diode_illuminated==0 then
      ToggleCuboColor(SIDE_GetVar(sid,"Color"));
      SOUND_Play(snd_barrier,-1);
    end;
   end;
   SIDE_SetVar(sid,"DiodeIlluminated",diode_illuminated);
  
    local bsize=2*GLOBAL_GetScale();
    local currd=0;

   if LastRenderID~=GAME_GetRenderPassID() then
     LastRenderID=GAME_GetRenderPassID()
     CurrentRenderIndex=0;
   end;

    while currd<l-0.000001 do
            SideIDs[CurrentRenderIndex]=sid;
            StartDists[CurrentRenderIndex]=currd;
            EndDists[CurrentRenderIndex]=math.min(currd+bsize,l);
            local cpos=VECTOR_Add(pos,VECTOR_Scale(up,0.5*(StartDists[CurrentRenderIndex]+EndDists[CurrentRenderIndex])));
            LEVEL_CustomDistanceRender(CurrentRenderIndex,CAM_ZDistance(cpos));
            LEVEL_LastDistanceRenderCull(cpos,bsize);
            CurrentRenderIndex=CurrentRenderIndex+1;
            currd=currd+bsize;
    end;
end;

function CustomDistanceRender(id)

local side=SideIDs[id];
  up=SIDE_GetNormal(side);
  pos=SIDE_GetMidpoint(side); 
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);
 local length=EndDists[id]-StartDists[id];

 MATRIX_Push();

 MATRIX_MultBase(right,up,dir,VECTOR_Add(pos,VECTOR_Scale(up,StartDists[id])));
 
 
 MATRIX_Scale(VECTOR_New(1,length,1));
 
 TEXTURE_MatrixMode(1);
   MATRIX_Push();
   MATRIX_Identity();
   MATRIX_Translate(VECTOR_New(0,5*GLOBAL_GetTime(),0));
   MATRIX_ScaleUniform(length/10);
  glCallList(LaserRenderLists[SIDE_GetVar(side,"Color")]);
   MATRIX_Pop();
   TEXTURE_MatrixMode(0);
 MATRIX_Pop();
 MATERIAL_Invalidate();
end;


function RenderLaser(sid)
  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,pos);
   
  local l=SIDE_GetVar(sid,"Range");
  local tr=LEVEL_TraceLine(pos,up);
  if tr["hit"]~=0 then
   if tr["side"]==SIDE_GetVar(sid,"OtherSide") then
   --  print(SIDE_GetVar(sid,"FullRange").." -> "..tr["dist"]);
     SIDE_SetVar(sid,"FullRange",tr["dist"]);
   else
    -- TestOtherside(sid);
   end;
   if tr["dist"]<l then l=tr["dist"]; end;
   else
     TestOtherside(sid);
  end

   local diode_illuminated=0;
   if math.abs(SIDE_GetVar(sid,"FullRange")-l)<0.001 then
       diode_illuminated=1;
   end;
   if diode_illuminated~=SIDE_GetVar(sid,"DiodeIlluminated") and GLOBAL_GetVar("EditorMode")~=1 then
    if diode_illuminated==0 then
      ToggleCuboColor(SIDE_GetVar(sid,"Color"));
      SOUND_Play(snd_barrier,-1);
     -- print("Toggle from "..sid.."  l: "..l.."  fr: "..SIDE_GetVar(sid,"FullRange").."  r: "..SIDE_GetVar(sid,"Range"));
    end;
   end;
   SIDE_SetVar(sid,"DiodeIlluminated",diode_illuminated);
  

    if l==0 then MATRIX_Pop(); return ; end;
    MATRIX_Scale(VECTOR_New(2*addscale,l,2*addscale));

   TEXTURE_MatrixMode(1);
   MATRIX_Push();
   MATRIX_Identity();
   MATRIX_Translate(VECTOR_New(0,5*GLOBAL_GetTime(),0));
   MATRIX_ScaleUniform(l/10);
   MDLDEF_Render(lasermdl);   
   MATRIX_Pop();
   TEXTURE_MatrixMode(0);

  MATRIX_Pop();
end;

function RenderLens()
MATRIX_Push();
  MATRIX_MultBase(right,up,dir,pos);
  MATRIX_ScaleUniform(2.9*addscale);
    MDLDEF_Render(lensmdl);
   MATRIX_Pop();
end;

function RenderDiode()
MATRIX_Push();
  MATRIX_MultBase(right,up,dir,pos);
  MATRIX_ScaleUniform(2.9*diodenscale);
    MDLDEF_Render(diodemdl);
   MATRIX_Pop();
end;



function SetColor(side)

   local colind=SIDE_GetVar(side,"Color");
   ActivateCuboColor(colind,0,1.0,1.0,1.0);
end;



function BuildRenderList(col)
  LaserRenderLists[col]=glGenLists(1);
  glBeginListCompile(LaserRenderLists[col]);
  

 MATERIAL_Invalidate();

 RayAmbientFactor=1.0;
 RayDiffuseFactor=1.0;
 RaySpecularFactor=1.0;

 ActivateCuboColor(col,0,RayAmbientFactor,RayDiffuseFactor,RaySpecularFactor);

  MATRIX_Scale(VECTOR_New(2*addscale,1,2*addscale));
 -- BLEND_Activate();
  TEXTURE_Activate(-1,0);
  BLEND_Function(1,1);
  DEPTH_Mask(0);
  LIGHT_Activate(1);

  MDLDEF_Render(lasermdl);

  LIGHT_Deactivate(1);
  DEPTH_Mask(1);
  BLEND_Function(770,771);
 -- BLEND_Deactivate();


 glEndListCompile();
MATERIAL_Invalidate();
end;

function RenderSide(side)
  TEXDEF_Render(texture,side);
  TEXDEF_ResetLastRenderedType();
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,0);
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;
 
 

  up=SIDE_GetNormal(side);
  pos=SIDE_GetMidpoint(side); 
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);
 
  depth=0.5;
 SetColor(side);
  if SIDE_GetVar(side,"IsSender")==1 then 
    RenderLens(); 
    
  else 
    RenderDiode(); 
  end;
 
end

function SideThink(side)

if SIDE_GetVar(side,"IsSender")==1 then 
   SIDE_SetVar(side,"Range",SIDE_GetVar(side,"MinRange"));
   SIDE_SetVar(side,"MinRange",SIDE_GetVar(side,"FullRange"));
  if correct_transparency==false then
   SIDE_DistanceRender(side,100000); --TODO adjust distanced?
  end;

   PrepareCustomDistRender(side);

 end;
end;

function MayCull(side)
  return 0;
end

function DistRenderSide(side)  
  TEXTURE_Activate(-1,0);
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
    SetColor(side);
    RenderLaser(side);
LIGHT_Deactivate(1);
  DEPTH_Mask(1);
   BLEND_Function(770,771);
 --  BLEND_Deactivate();
end;



function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
  return "no";
 elseif name=="NumVars" then
  return 2;
 elseif name=="Var1" then
  return "Color";
 elseif name=="VarType1" then
  return "basecolor"; 
 elseif name=="Var2" then
  return "ReverseDirection";
 elseif name=="VarType2" then
  return "bool";
 else
 return default;
  end;
end;

function TestOtherside(side)
   local tr=LEVEL_TraceLine(SIDE_GetMidpoint(side),SIDE_GetNormal(side));
    if tr["hit"]==1 then
       if SIDE_GetType(tr["side"])=="lightbarrier" then
         --Copy the  vars  from the other side
         SIDE_SetVar(side,"Color",SIDE_GetVar(tr["side"],"Color"));
         local tdir=SIDE_GetVar(tr["side"],"ReverseDirection");
         SIDE_SetVar(side,"ReverseDirection",tdir);
         local fact=1; if tdir==1 then fact=-1; end;
         if tr["side"]*fact<side*fact then 
           SIDE_SetVar(tr["side"],"Range",tr["dist"]);
           SIDE_SetVar(tr["side"],"FullRange",tr["dist"]);
           SIDE_SetVar(tr["side"],"MinRange",tr["dist"]);
           SIDE_SetVar(tr["side"],"DiodeIlluminated",1);
           SIDE_SetVar(side,"Range",0);
           SIDE_SetVar(tr["side"],"IsSender",1);
           SIDE_SetVar(side,"IsSender",0);
         else
           SIDE_SetVar(side,"Range",tr["dist"]);
           SIDE_SetVar(side,"FullRange",tr["dist"]);
           SIDE_SetVar(side,"MinRange",tr["dist"]);
           SIDE_SetVar(side,"DiodeIlluminated",1);
           SIDE_SetVar(tr["side"],"Range",0);
           SIDE_SetVar(side,"IsSender",1);
           SIDE_SetVar(tr["side"],"IsSender",0);
         end;
         SIDE_SetVar(side,"OtherSide",tr["side"]);
         SIDE_SetVar(tr["side"],"OtherSide",side);
         return;   
       end;
    end;
   SIDE_SetVar(side,"Range",0);
   SIDE_SetVar(side,"IsSender",0);
 SIDE_SetVar(side,"OtherSide",-1);
end;




function SideConstructor(sideid)
  SIDE_SetVar(sideid,"Color",0);
  SIDE_SetVar(sideid,"Range",0);
  SIDE_SetVar(sideid,"FullRange",0);
  SIDE_SetVar(sideid,"MinRange",0);
  SIDE_SetVar(sideid,"LastMinRange",0);
  SIDE_SetVar(sideid,"ReverseDirection",0);
  SIDE_SetVar(sideid,"IsSender",0);
  SIDE_SetVar(sideid,"OtherSide",-1);
  SIDE_SetVar(sideid,"DiodeIlluminated",0);
  TestOtherside(sideid);
end;

actorpos=VECTOR_New(0,0,0);
actorrad=GLOBAL_GetScale()/2;

colside=-1;
colactor=-1;

function SideCollLaser(side)
   local diff=VECTOR_Sub(actorpos,pos);
   local pl=VECTOR_Dot(diff,up);
   if pl<0 then --hinter der Laserquelle
    return;
   end;

   local dl=VECTOR_Dot(diff,diff);
   local ds=dl-pl*pl;
   if ds<0 then ds=0; end;
   ds=math.sqrt(ds); --Seitlicher Abstand
   dl=math.sqrt(dl);
   if (ds-ray_radius>actorrad) or (SIDE_GetVar(side,"FullRange")<dl) then
     return;
   else 
     dl=dl-math.sqrt(actorrad*actorrad-(ds-ray_radius)*(ds-ray_radius))+ray_radius;
     if SIDE_GetVar(side,"MinRange")>dl then SIDE_SetVar(side,"MinRange",dl);  end; 
   end;

end;




function SideCollisionCheck(actorid,sideid)

  if SIDE_GetVar(sideid,"OtherSide")==-1 or SIDE_GetVar(sideid,"IsSender")==0 then
   return;
  end; 

  if ACTOR_GetVar(actorid,"IsAlive")~=1 then
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

  SideCollLaser(sideid)
  
end;

