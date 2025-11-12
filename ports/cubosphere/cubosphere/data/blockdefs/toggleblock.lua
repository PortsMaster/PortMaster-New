

INCLUDEABSOLUTE("/blockdefs/include/colors.inc");

--Brigde-Mode

--BridgeMode=0;
--You can set it to 1.. Try it... Build a brigde between two solid blocks by a phaser. If BrigdeMode=1 holds, and the Phaser vanished, you will slide down from the solid block when trying to move over it. Otherwise you'll roll around it by "normal" means :-) 
mdl=-1;
texture=-1;
textureactive=-1;

tillbreak=0.15;
tilldisappear=0.2;

snd_break=-1;

--function MayMove(side,actor,dir)
-- if dir=="rolldown" then
--   return 0;
 --end;
 --return 1;
--end;

--function MaySlideDown(side,actor)
 -- return 1;
--end;


function GetEditorInfo(name,default)
 if name=="BlockOnly" then
  return "yes";
 elseif name=="BlockItemsAllowed" then
  return "no";
 elseif name=="SideItemsAllowed" then
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



function Precache()
  mdl=MDLDEF_Load("colorframe");
  texture=TEXDEF_Load("phaser");
 textureactive=TEXDEF_Load("normal1");
  --snd_break=SOUND_Load("breakblock");
end



function RenderFrame(side)
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;

  MATRIX_Push();
  local block=SIDE_GetBlock(side);
--  MATRIX_Translate(BLOCK_GetPos(block));

  up=SIDE_GetNormal(side);
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);  

  MATRIX_MultBase(right,up,dir,SIDE_GetMidpoint(side));
--  MATRIX_Translate(SIDE_GetMidpoint(side));
  MATRIX_ScaleUniform((math.sqrt(2.5))*GLOBAL_GetScale());

--  print("Render MDL "..mdl.." at "..block);
  local add;
  if BLOCK_GetVar(block,"StartActive")==1 then
    --Add a addtional activation color punch
    local blinkspeed=10;
    add=0.025*math.sin(blinkspeed*GLOBAL_GetTime());
  else
    add=-0.04;  
  end;

  ActivateCuboColor(BLOCK_GetVar(block,"Color"),add,1.0,1.0,1.0);

  MDLDEF_Render(mdl);
  MATRIX_Pop();
end;


function RenderSide(side)
 if BLOCK_GetVar(SIDE_GetBlock(side),"StartActive")==1 then
  TEXDEF_Render(textureactive,side); 
 else
  SIDE_DistanceRender(side,CAM_ZDistance(SIDE_GetMidpoint(side)));
 end;
  RenderFrame(side);
TEXDEF_ResetLastRenderedType();
end

function DistRenderSide(side)

 local diffuse={r=0.25, g=0.25 , b=0.25, a=0.5};
 MATERIAL_SetDiffuse(diffuse);
-- BLEND_Activate();

 --CULL_Mode(0);
TEXDEF_Render(texture,side); 
  TEXDEF_ResetLastRenderedType();
--CULL_Mode(1);
 --BLEND_Deactivate();

end;

   







function BlockThink(block)
  
  if (phase~=oldphase) and (BLOCK_GetVar(block,"BridgeMode")==0) then
   --  print("Phasechange");
    if oldphase=="deactive" then
      BLOCK_AttachToNeighbors(block);
    elseif phase=="deactive" then 
      BLOCK_RemoveFromNeighbors(block);
    end;

  end;

end;


function BlockConstructor(block)
  --print("BLOCK CONSTRUCTOR "..block);
  BLOCK_SetVar(block,"timer",0);
  BLOCK_SetVar(block,"BridgeMode",1);
  BLOCK_SetVar(block,"StartActive",1);
  BLOCK_SetVar(block,"Color",0);
 -- local dummy=GetVis(block);  
end


function IsPassable(block)

 local state=BLOCK_GetVar(block,"StartActive");
 if state==0 then
  return 1;
 else
  return 0;
 end;
end

function HasTransparency(block)
    return 1;
end;
