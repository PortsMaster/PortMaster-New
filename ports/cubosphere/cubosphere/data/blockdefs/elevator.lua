
texture=-1;


zweiPi=6.28318531;

function GetEditorInfo(name,default)
 if name=="BlockOnly" then
  return "yes";
 elseif name=="NumVars" then
   return 5;
 elseif name=="Var1" then
   return "Amplitude";
 elseif name=="VarType1" then
   return "float";
 elseif name=="Var2" then
   return "Speed";
 elseif name=="VarType2" then
   return "float";
 elseif name=="Var3" then
   return "Phase";
 elseif name=="VarType3" then
   return "float";
 elseif name=="Var4" then
   return "Direction";
 elseif name=="VarType4" then
   return "int";
 elseif name=="Var5" then
   return "DelayTime";
 elseif name=="VarType5" then
   return "float";
 
 end;
 return default;
end;

function IsMoving(block)
 return 1;
end;

function BlockConstructor(block)
 local v=BLOCK_GetPos(block);
 BLOCK_SetVar(block,"sx",v.x);
 BLOCK_SetVar(block,"sy",v.y);
 BLOCK_SetVar(block,"sz",v.z);
 BLOCK_SetVar(block,"timer",0);
 BLOCK_SetVar(block,"Speed",1);
 BLOCK_SetVar(block,"Phase",0.0);
 BLOCK_SetVar(block,"Amplitude",4);
 BLOCK_SetVar(block,"Direction",0);
 BLOCK_SetVar(block,"DelayTime",0.5);
end;

function SinoidMove(block,timeoffs)
 local offs=GLOBAL_GetScale()*BLOCK_GetVar(block,"Amplitude")*math.sin(BLOCK_GetVar(block,"Speed")*(BLOCK_GetVar(block,"timer")+timeoffs)+zweiPi*BLOCK_GetVar(block,"Phase"));
 return offs;
end;

function LinearMove(block,timeoffs)
 local t=timeoffs+BLOCK_GetVar(block,"timer");
 local FullT=2*(BLOCK_GetVar(block,"Amplitude")/BLOCK_GetVar(block,"Speed")+BLOCK_GetVar(block,"DelayTime"));
 t=t+BLOCK_GetVar(block,"Phase")*FullT;

 local itime=math.floor(t/FullT)*FullT;
 local t=t-itime;
 
 local sign=1;
 if t>FullT/2 then
  sign=-1;
  t=t-FullT/2;
 end;

 local offs;

 if (t>=FullT/4-BLOCK_GetVar(block,"DelayTime")/2) and (t<FullT/4+BLOCK_GetVar(block,"DelayTime")/2) then
  offs=BLOCK_GetVar(block,"Amplitude");
 elseif t<FullT/4-BLOCK_GetVar(block,"DelayTime")/2 then
  offs=2*t*BLOCK_GetVar(block,"Speed");
 else
  offs=2*(FullT/2-t)*BLOCK_GetVar(block,"Speed");
 end;

 return GLOBAL_GetScale()*offs*sign;
end;



function Precache()
  texture=TEXDEF_Load("elevator");
end


function GetPosFromTime(block,timeoffs)
 local dev;
 if BLOCK_GetVar(block,"DelayTime")>0 then
   dev=LinearMove(block,timeoffs);
 else
   dev=SinoidMove(block,timeoffs);
 end;
 local moddir=math.fmod(BLOCK_GetVar(block,"Direction"),3);
 local offsv=VECTOR_New(0,0,0);
 if moddir==0 then
   offsv=VECTOR_New(BLOCK_GetVar(block,"sx")+dev,BLOCK_GetVar(block,"sy"),BLOCK_GetVar(block,"sz"));
 elseif moddir==1 then
   offsv=VECTOR_New(BLOCK_GetVar(block,"sx"),BLOCK_GetVar(block,"sy")+dev,BLOCK_GetVar(block,"sz"));
 else
   offsv=VECTOR_New(BLOCK_GetVar(block,"sx"),BLOCK_GetVar(block,"sy"),BLOCK_GetVar(block,"sz")+dev);
 end;
 return offsv;
end;

function BlockThink(block)
  if (GLOBAL_GetVar("EditorMode")==1) then
   return;
  end;
  BLOCK_SetVar(block,"timer",BLOCK_GetVar(block,"timer")+LEVEL_GetElapsed());
  --print(offs);
  local boffs=GetPosFromTime(block,0);
  --print(boffs.x);
  BLOCK_SetPosf(block,boffs);
end;


function RenderSide(side)
  TEXDEF_Render(texture,side);
end





