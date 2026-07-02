USING("PARTICLE");


QuitGameOnCollide=0;

SpeedfactorIncrement=0.2;

radius=GLOBAL_GetScale()/1.5;
extrascale=1;
defaultspeed=3;
rotspeedmultiply=1; --Negative for absolute
helixmode=0;
shadowscale=1.0;
groundoffset=0;

ownvars=0;

--ToDo: Customize
function GetEditorInfo(name,default)
 if name=="NumVars" then
   return 4+ownvars;
 elseif name=="Var1" then
   return "Movement";
 elseif name=="VarType1" then
   return "string";
 elseif name=="Var2" then
   return "MoveIndex";
 elseif name=="VarType2" then
   return "int";
 elseif name=="Var3" then
   return "Speed";
 elseif name=="VarType3" then
   return "float";
 elseif name=="Var4" then
   return "Interaction"; 
 elseif name=="VarType4" then
   return "string";
 elseif ownvars>0 then
   return CustomEditorInfo(name,default);
 end;
 return default;
end;


function LoadMdl(name)
  mdl=MDLDEF_Load(name);
  stex=TEXDEF_Load("pshadow1");
end;


function DieAnim(actor)
  local ks=ACTOR_GetVar(actor,"IsAlive");
  ks=ks-LEVEL_GetElapsed();
  if (ks<-1) then
    ks=-1;
  end;
  ACTOR_SetVar(actor,"IsAlive",ks);
end;

function EditorThink(actor)
 --Nothing right now
end;

function Think(actor)
 if (GLOBAL_GetVar("EditorMode"))==1 then
   EditorThink(actor);
   return;
 end;

 if ACTOR_GetVar(actor,"IsAlive")~=1 then
   if ACTOR_GetVar(actor,"IsAlive")~=-1 then
     DieAnim(actor);
   end;
   return;
 end;

 --TODO: This should be shifted into an Initialize, But in the Constructor it is to early, since the level might change this

 if ACTOR_GetVar(actor,"StartSide")==-1 then
   ACTOR_SetVar(actor,"StartSide",ACTOR_GetOnSide(actor));
--   ACTOR_SetVar(actor,"StartRotation",0);
   local smlt=GLOBAL_GetVar("MoveSpeedMultiply");
   ACTOR_SetSpeed(actor,ACTOR_GetVar(actor,"Speed")*smlt);
   ACTOR_SetVar(actor,"BasicSpeed",ACTOR_GetVar(actor,"Speed")*smlt);
   ACTOR_SetVar(actor,"Speedfactor",1);
 end;

 local ms=ACTOR_GetVar(actor,"Movement");
 if ACTOR_CurrentMove(actor)=="none" and ms~="" and LEVEL_GetTimeScale()>0 then
   --obtain the next move
   
   --increment the Moveindex
   local mi=math.fmod(ACTOR_GetVar(actor,"MoveIndex"),string.len(ms))+1;
   local nm=string.lower(string.sub(ms,mi,mi));
   if nm=="f" then
     ACTOR_CallMove(actor,"forward");
   elseif nm=="r" then
     ACTOR_CallMove(actor,"right");
   elseif nm=="l" then
     ACTOR_CallMove(actor,"left");
   elseif nm=="j" then
     ACTOR_CallMove(actor,"forward");
     ACTOR_CallMove(actor,"jump");
   elseif nm=="u" then
     ACTOR_CallMove(actor,"jump");
   elseif nm=="h" then
      ACTOR_CallMove(actor,"forward");
     ACTOR_CallMove(actor,"highjump");
   elseif nm=="d" then
      ACTOR_CallMove(actor,"forward");
     ACTOR_CallMove(actor,"farjump");
   elseif nm=="w" then
     local wt=ACTOR_GetVar(actor,"WaitTimer");
     --Perform a wait
     if wt==0 then
       ACTOR_SetVar(actor,"WaitTimer",0.20);
       mi=ACTOR_GetVar(actor,"MoveIndex");
     else 
       wt=wt-LEVEL_GetElapsed();
       if wt>0 then
         mi=ACTOR_GetVar(actor,"MoveIndex");
       else 
         wt=0;
       end;
       ACTOR_SetVar(actor,"WaitTimer",wt);
     end;
   elseif nm=="t" then
      ACTOR_SetStart(actor,ACTOR_GetVar(actor,"StartSide"),ACTOR_GetStartRotation(actor));
   elseif nm=="p" then
      local sf=ACTOR_GetVar(actor,"Speedfactor");
      sf=sf+SpeedfactorIncrement; 
      ACTOR_SetVar(actor,"Speedfactor",sf);
      ACTOR_SetSpeed(actor,ACTOR_GetVar(actor,"BasicSpeed")*sf);   
   elseif nm=="m" then
      local sf=ACTOR_GetVar(actor,"Speedfactor");
      sf=sf-SpeedfactorIncrement; if sf<SpeedfactorIncrement then sf=SpeedfactorIncrement; end 
      ACTOR_SetVar(actor,"Speedfactor",sf);
      ACTOR_SetSpeed(actor,ACTOR_GetVar(actor,"BasicSpeed")*sf);   
   elseif CustomMoveStringFunction~=nil then
     CustomMoveStringFunction(actor,nm);
   end;
   ACTOR_SetVar(actor,"MoveIndex",mi);
 end;


 local inlevel=ACTOR_InsideLevel(actor);
  if inlevel==0 then
   ACTOR_SetVar(actor,"IsAlive",-1);
   --print("Enemy "..actor.." dropped into the deep abyss!");
  end;
end;

function Constructor(actor)
 local basis=BASIS_New();
 
if helixmode==1 then
 ACTOR_SetVar(actor,"Movement","u"); 
else
 ACTOR_SetVar(actor,"Movement","f"); --These must be setable in editor (as well as a rotation)
end;  

  ACTOR_SetVar(actor,"MoveIndex","0");
  ACTOR_SetVar(actor,"Interaction","stp"); --(s)witches, (i)ce, (t)ramp, tele(p)ort, (b)reaking, (f)ire, s(p)ikes, (l)aser, (o)nedir 
  ACTOR_SetVar(actor,"Speed",defaultspeed); -- Speed
  ACTOR_SetVar(actor,"WaitTimer",0); -- For waiting

  ACTOR_SetVar(actor,"Temperature",0); -- TODO: Implement Temperature variations for color + sounds
  
--Add an additional rotationspeed multiplier

 ACTOR_SetVar(actor,"RollSpeed",0.0);
ACTOR_SetVar(actor,"RestingOnIce",-1);


 ACTOR_SetRadius(actor,radius);
 ACTOR_SetGroundOffset(actor,groundoffset);

 local scl=GLOBAL_GetScale();
 local smlt=GLOBAL_GetVar("MoveSpeedMultiply");
 ACTOR_SetSpeed(actor,ACTOR_GetVar(actor,"Speed")*smlt);
 if rotspeedmultiply<0 then
   ACTOR_SetRotSpeed(actor,0-rotspeedmultiply);
 else
   ACTOR_SetRotSpeed(actor,ACTOR_GetSpeed(actor)*rotspeedmultiply);  
 end;
  ACTOR_SetJumpParams(actor,scl*16.0*smlt,scl*18*smlt,scl*42*smlt,scl*70*smlt*smlt,scl*30*smlt);


ACTOR_SetJumpDistances(actor,2,3,2);
 
 if helixmode==1 then
    ACTOR_SetJumpParams(actor,scl*5.0*smlt,scl*9*smlt,scl*16*smlt,scl*10.5*smlt*smlt,scl*15*smlt);
 end;

  local s=ACTOR_GetRadius(actor)*extrascale;
  --BASIS_AxisRotate(basis,ACTOR_GetUp(actor),1.57079633);
  BASIS_SetScale(basis,VECTOR_New(s,s,s));
  
  ACTOR_SetVar(actor,"Basis",basis);


  ACTOR_SetVar(actor,"IsAlive",1);

  ACTOR_SetVar(actor,"KilledString","");

  ACTOR_SetVar(actor,"QuitGameOnCollide",QuitGameOnCollide);

  
  
  ACTOR_SetVar(actor,"RollPos",0);

  ACTOR_SetVar(actor,"StartSide",-1);

 local penv=PARTICLE_CreateEnvOnActor(actor);
 ACTOR_SetVar(actor,"PEnv",penv); 
  
end;

function ChangeMove(actor,newmove)

 local ar=0.0;
 local rad=ACTOR_GetRadius(actor);
 local scale=GLOBAL_GetScale();
 local linmove=ACTOR_GetSpeed(actor)*scale;
 
 if (newmove=="forward") then
   ar=linmove/rad;
 elseif (newmove=="down") then
  --ar=(linmove*scale/(scale-rad))/rad;
    ar=linmove/rad;
  
 elseif (newmove=="up") then
  --ar=(linmove*scale/(scale+rad))/rad;
    ar=linmove/rad;
 
 elseif (newmove=="jumpahead") then
  ar=linmove/rad;
  
 elseif (newmove=="slidedown") then
  ar=linmove/rad;
  
 
 end;


  ACTOR_SetVar(actor,"RollSpeed",ar);
  
end;


function Event(id,ev)

end;


function RenderShadow(side,scale,pos)
  local block=SIDE_GetBlock(side);
   if BLOCK_HasTransparency(block)>0 then
    return;
   end;

  MATRIX_Push();
  local dir=SIDE_GetTangent(side);
  local up=SIDE_GetNormal(side);
  local right=VECTOR_Cross(up,dir);
  local pos=VECTOR_Add(pos,VECTOR_Scale(up,0.05*GLOBAL_GetScale()));
  MATRIX_MultBase(right,up,dir,pos);
  MATRIX_ScaleUniform(scale);
  TEXDEF_Render(stex,side);
  MATRIX_Pop();
end;

function VectPositive(v)
  local w=VECTOR_New(v.x,v.y,v.z);
  if (w.x<0) then 
   w.x=-w.x;
  end;
  if (w.y<0) then 
   w.y=-w.y;
  end;
  if (w.z<0) then 
   w.z=-w.z;
  end;
  return w;
end;

function Render(actor)

 if ACTOR_GetVar(actor,"IsAlive")<=-1 then
   return;
 end;

 

  local ks=ACTOR_GetVar(actor,"KilledString");

  local scal=1.0;

local red,green,blue=0.5,0.5,0.5;


if (ks=="Lasered!") or (ks=="Captured!") or (ks=="Spiked!") then 
    
    local ia=ACTOR_GetVar(actor,"IsAlive");
      local c=0.1+0.4*(1.0+math.cos(20*ACTOR_GetVar(actor,"IsAlive")));
    red=c/2; green=0.05; blue=0.05;
   
    ia=1.0+ia;
    local fadetime=0.05;
    if ia<fadetime then
     --print(ia);
     scal=ia/fadetime;
    end;   

end;
  
MATERIAL_SetMultiply(COLOR_New(2*red,2*green,2*blue,1));

  local basis=ACTOR_GetVar(actor,"Basis");

  SetupBase(actor,basis); 



  BASIS_Push(basis);  
   
  if scal~=1.0 then
    MATRIX_ScaleUniform(scal);
  end; 
  
  MDLDEF_Render(mdl);
  BASIS_Pop(basis);
MATERIAL_SetMultiply(COLOR_New(1,1,1,1));
  ACTOR_DistanceRender(actor,10000); --Right???
end;

function DistRender(actor)
--Trace a line
  local tr=LEVEL_TraceLine(ACTOR_GetPos(actor),VECTOR_Scale(ACTOR_GetUp(actor),-1));
  if tr["hit"]==1 then
     local ssize=ACTOR_GetRadius(actor)*2*extrascale*shadowscale;
     if ssize>GLOBAL_GetScale()*1.5*extrascale then
       ssize=GLOBAL_GetScale()*1.5*extrascale;
     end;
     local spos=VECTOR_Add(ACTOR_GetPos(actor),VECTOR_Scale(ACTOR_GetUp(actor),-1*tr["dist"]));
     RenderShadow(tr["side"],ssize,spos);
  end;
end;
 
