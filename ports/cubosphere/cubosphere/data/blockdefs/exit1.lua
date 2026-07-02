mdl=-1;
texture=-1;


height=GLOBAL_GetScale()*1.0;

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
   return "Next_Level";
 elseif name=="VarType1" then
   return "filename";
 end;
 return default;
end;

function SideConstructor(side)
 SIDE_SetVar(side,"Next_Level","nextlevel");
 SIDE_SetVar(side,"Raised",0);
 BLOCK_SetCullRadius(SIDE_GetBlock(side),2*math.sqrt(3.0)*GLOBAL_GetScale());
end;


function Precache()
  mdl=MDLDEF_Load("exitarrow");
  texture=TEXDEF_Load("exittile1");
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
  SIDE_DistanceRender(side,CAM_ZDistance(GetPos(side)));
end



function DistRenderSide(side)
  
--  BLEND_Activate();
  
  up=SIDE_GetNormal(side);
  dir=SIDE_GetTangent(side);
  right=VECTOR_Cross(up,dir);  

--  LIGHT_Activate(1);
  RenderMdl(side,height);
--  BLEND_Deactivate();
--  LIGHT_Deactivate(1);
end


function MayCull(side)
  return 0; 
end


