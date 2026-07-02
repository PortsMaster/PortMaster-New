mdl=-1;
texture=-1;

--Adjust the height of the model (if the ball is far away)
height=GLOBAL_GetScale()*1.0;

texturetype="base";

function GetEditorInfo(name,default)
 if name=="SideItemsAllowed" then
   return "no";
 end;
 return default;
end;

function SideConstructor(side)
 SIDE_SetVar(side,"Raised",0);
 BLOCK_SetCullRadius(SIDE_GetBlock(side),2*math.sqrt(3.0)*GLOBAL_GetScale());
end;


function Precache()
  mdl=MDLDEF_Load("stopper");
  texture=TEXDEF_Load(texturetype);
end


function GetPos(side)
  local up=SIDE_GetNormal(side);
  local pos=SIDE_GetMidpoint(side); 
  
  local offs=VECTOR_Add(pos,VECTOR_Scale(up,height)); 

  local player=GLOBAL_GetVar("ActivePlayer");

 
 if GLOBAL_GetVar("EditorMode")~=1 and player>=0 then
  local maxt=SIDE_GetVar(side,"Raised")-LEVEL_GetElapsed();

    local nballs=PLAYER_NumActors(player);
 
  for ballc=0,nballs-1,1 do
    local balli=PLAYER_GetActor(player,ballc);
    if ACTOR_GetVar(balli,"IsAlive")>-1 then
     local diff=VECTOR_Sub(ACTOR_GetPos(balli),offs);
     local dist=VECTOR_Length(diff)/GLOBAL_GetScale();
  
     if dist<2.0 then
      local t;
      if dist<1.0 then 
        t=1.0;
      else 
        t=2.0-dist;
      end;
      if t>maxt then maxt=t; end;
     end;
    end;
  end;

  if maxt<0 then maxt=0; end;
  SIDE_SetVar(side,"Raised",maxt); 

  offs=VECTOR_Add(offs,VECTOR_Scale(up,maxt*GLOBAL_GetScale()));
 end;

  return offs;
end






function RenderMdl(side,height)
  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,GetPos(side));
  MATRIX_ScaleUniform(GLOBAL_GetScale()*1.0);
  MATRIX_AxisRotate(VECTOR_New(0,1,0),GLOBAL_GetTime()*100);
  MDLDEF_Render(mdl);
  MATRIX_Pop();
end;



function RenderSide(side)
  TEXDEF_Render(texture,side);

  up=SIDE_GetNormal(side);
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);  
   SIDE_DistanceRender(side,CAM_ZDistance(GetPos(side)));
end

function DistRenderSide(side)
  
--  BLEND_Activate();
  up=SIDE_GetNormal(side);
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);  
  RenderMdl(side,height);
  --BLEND_Deactivate();
end


function MayCull(side)
  return 0; 
end
