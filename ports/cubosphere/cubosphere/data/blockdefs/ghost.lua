texture=-1;


function GetEditorInfo(name,default)
 if name=="BlockOnly" then
  return "yes";
 end;
 return default;
end;

function Precache()
  texture=TEXDEF_Load("ghostblock");
 --texture=TEXDEF_Load("icy1");
end

function RenderSide(side)
  SIDE_DistanceRender(side,CAM_ZDistance(SIDE_GetMidpoint(side)));
end



function DistRenderSide(side)

  local vis=0.5;

plr=GLOBAL_GetVar("ActivePlayer");
local act=-1;
if GLOBAL_GetVar("ActivePlayer")>=0 then
 act=PLAYER_GetActiveActor(plr);
end;
if (GLOBAL_GetVar("EditorMode")~=1) and (act>=0) and (ACTOR_GetVar(act,"GogglesActive")==0) and PLAYER_InCameraPan(plr)==0 then
 
 local block=SIDE_GetBlock(side);
 
 local diff=VECTOR_Sub(ACTOR_GetPos(act),BLOCK_GetPos(block));
 local dist=2*VECTOR_Length(diff)/GLOBAL_GetScale();
 --print(dist);
 if (dist>12) then
   return;
 end;
 SIDE_SetAlphaFunc("SideAlpha");

else 
  vis=0.01;
  if plr>=0 then if PLAYER_InCameraPan(plr)~=0 then SIDE_SetAlphaFunc("SideAlpha"); end; end;
end;

   
 if vis<0 then 
 --   BLEND_Deactivate();
   return 
 end;

 if vis>0.5 then
   vis=0.5;
 end;

 --print(vis);


 local diffuse={r=0.25, g=0.25 , b=0.25, a=0.4};
 MATERIAL_SetDiffuse(diffuse);
 --BLEND_Activate();
 
 --CULL_Mode(0);
 TEXDEF_Render(texture,side); 
 
 --CULL_Mode(1);
-- BLEND_Deactivate();
 SIDE_SetAlphaFunc("");
end

function VisForActor(edge,act)
 if (ACTOR_GetVar(act,"GogglesActive")~=0) then
   return 0.33;
 end;

 local diff=VECTOR_Sub(ACTOR_GetPos(act),edge);
 local dist=2*VECTOR_Length(diff)/GLOBAL_GetScale();
 --print(dist);
 if (dist>10) then
   return 0.0;
 elseif (dist<4) then
   return 0.0; 
 else
   return 0.0*(1.0-(dist-4.0)/6.0);
 end;

end;

function SideAlpha(x,y,z)
 local edge=VECTOR_New(x,y,z);

 plr=GLOBAL_GetVar("ActivePlayer");
 local act=PLAYER_GetActiveActor(plr);

 if PLAYER_InCameraPan(plr)==0 then 
   return VisForActor(edge,act);
 else
   local ci=PLAYER_GetCamInterpolation(plr); 
   return VisForActor(edge,act)*ci+VisForActor(edge,PLAYER_GetLastActiveActor(plr))*(1.0-ci);
 end;
 
end;

function MayCull(side)
  return 0;
end;

function HasTransparency(block)
  return 1;
end
