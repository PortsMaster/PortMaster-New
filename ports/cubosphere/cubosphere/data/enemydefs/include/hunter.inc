USING("PATH");
USING("PARTICLE");

QuitGameOnCollide=0;
radius=GLOBAL_GetScale()/1.5;
extrascale=1;
defaultspeed=1;
rotspeedmultiply=1; --Negative for absolute
randommode=0;
shadowscale=1.0;
groundoffset=0;

beepsnd=-1;

ownvars=0;

--ToDo: Customize
function GetEditorInfo(name,default)
 if name=="NumVars" then
   return 3+ownvars;
 elseif name=="Var1" then
   return "Speed";
 elseif name=="VarType1" then
   return "float";
 elseif name=="Var2" then
   return "Interaction"; 
 elseif name=="VarType2" then
   return "string";
 elseif name=="Var3" then
   return "TiedToPlane"; 
 elseif name=="VarType3" then
   return "bool";
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

function GetRotationNumber(actor)
 local side=ACTOR_GetOnSide(actor);
 local dir=ACTOR_GetDir(actor);
 local normal=SIDE_GetNormal(side);
 local tangent=SIDE_GetTangent(side);
 local current=tangent;

 if VECTOR_Dot(dir,current)>0.8 then return 0; end;
 current=VECTOR_Cross(tangent,normal);
 if VECTOR_Dot(dir,current)>0.8 then return 1; end;
 current=VECTOR_Scale(tangent,-1);
 if VECTOR_Dot(dir,current)>0.8 then return 2; end;
 current=VECTOR_Cross(normal,tangent);
 if VECTOR_Dot(dir,current)>0.8 then return 3; end;

 return 0;

end;

function GetNearestNode(actor,destside)
 local gr=ACTOR_GetVar(actor,"PathGraph");
 if destside==-1 then return -1; end;
 local dpos=SIDE_GetMidpoint(destside);
 local nnodes=PATH_GetNumNodes(gr);
 local mindist=100000000;
 local mindex=-1;

 for i=0,nnodes-1,1 do
   local cp=SIDE_GetMidpoint(PATH_GetNode(gr,i));
   local cdist=VECTOR_Length(VECTOR_Sub(dpos,cp));
   if cdist<mindist then
     mindex=i;
     mindist=cdist;
   end;
 end;

 if mindex==-1 then return -1; end;

 return PATH_GetNode(gr,mindex);

end;

currenthunter=-1;
tiedtoplane=0;

function IsDangerous(what)
  local inter=ACTOR_GetVar(currenthunter,"Interaction");
  if string.find(inter, what) then
    return 1;
  else
    return 0;
  end;
end;

function NodeCallBack(from,to)
 --Test, if it is breaking/phasing or something like that

 if tiedtoplane==1 then
  local d=VECTOR_Dot(SIDE_GetNormal(from),SIDE_GetNormal(to));
  if d<0.9 then
   return 0;
  end;
 end;

 local sn=SIDE_GetType(to);
 if sn=="normal1" then
  return 1;
 elseif sn=="breaking1" or sn=="phaser" or sn=="teleport" then
  return 0;
 elseif sn=="spikes" or sn=="fspikes" or sn=="knife" then
  if IsDangerous("p")==1 then 
    return 0;
  else 
    return 1;
  end;
 elseif sn=="icy1" then
  if IsDangerous("i")==1 then 
    return 0;
  else 
    return 1;
  end;
 elseif sn=="icy1" then
  if IsDangerous("i")==1 then 
    return 0;
  else 
    return 1;
  end; 
elseif sn=="laser" then
  if IsDangerous("l")==1 then 
    return 0;
  else 
    return 1;
  end; 
elseif sn=="tramp" or sn=="tramphigh" then
  if IsDangerous("t")==1 then 
    return 0;
  else 
    return 1;
  end; 
end;

 
 --Check interaction
 return 1;
end;

function Think(actor)
 if (GLOBAL_GetVar("EditorMode"))==1 then
   EditorThink(actor);
   return;
 end;


 if  ACTOR_GetVar(actor,"PathGraph")==-1 then
    currenthunter=actor;
   tiedtoplane=ACTOR_GetVar(actor,"TiedToPlane");
   ACTOR_SetVar(actor,"PathGraph",PATH_NewGraph(ACTOR_GetOnSide(actor),"NodeCallBack"));
 --  PATH_GetNextMove(ACTOR_GetVar(actor,"PathGraph"),ACTOR_GetOnSide(actor),ACTOR_GetOnSide(GLOBAL_GetVar("ActivePlayer")));
 end;  

 if ACTOR_GetVar(actor,"IsAlive")~=1 then
   if ACTOR_GetVar(actor,"IsAlive")~=-1 then
     DieAnim(actor);
   end;
   return;
 end;


  local rt=ACTOR_GetVar(actor,"RotationTime");
  local rtinc=-4;

  local pt=ACTOR_GetVar(actor,"PrecessionTime");  
  local ptinc=PrecessionSpeed;

  local cmove=ACTOR_CurrentMove(actor);

  if cmove=="left" then
    rtinc=rtinc+rotspeedmultiply*1.57079633;
    ptinc=ptinc+rotspeedmultiply*1.57079633;
  elseif cmove=="right" then
     rtinc=rtinc-rotspeedmultiply*1.57079633;
    ptinc=ptinc-rotspeedmultiply*1.57079633;
  end;

  rt=rt+rtinc*LEVEL_GetElapsed();
  pt=pt+ptinc*LEVEL_GetElapsed();

 ACTOR_SetVar(actor,"RotationTime",rt);
  ACTOR_SetVar(actor,"PrecessionTime",pt);

  local sndtime=ACTOR_GetVar(actor,"SoundTimer");
  sndtime=sndtime+LEVEL_GetElapsed();

  local MaxSoundDist=12*GLOBAL_GetScale();

  if sndtime>1 then
    local dist=VECTOR_Length(VECTOR_Sub(CAM_GetPos(),ACTOR_GetPos(actor)));
    if dist<MaxSoundDist then
       local c=SOUND_Play(beepsnd,-1);   
        SOUND_Set3dFromCam(c,ACTOR_GetPos(actor),MaxSoundDist);
    end;
   
   sndtime=sndtime-1;
  end;
 
 ACTOR_SetVar(actor,"SoundTimer",sndtime);


 --TODO: This should be shifted into an Initialize, But in the Constructor it is to early, since the level might change this
 local smlt=GLOBAL_GetVar("MoveSpeedMultiply");
 ACTOR_SetSpeed(actor,ACTOR_GetVar(actor,"Speed")*smlt);

 if ACTOR_CurrentMove(actor)=="none" and LEVEL_GetTimeScale()>0 then
   --obtain the next move
   
   local rot=GetRotationNumber(actor);
  
   local nm;
   local escapemode=0;
   local besttarget=PLAYER_GetActiveActor(GLOBAL_GetVar("ActivePlayer")); 
   local bestdistance=10000000;

   for ball=0,ACTOR_NumActors()-1,1 do
     if ACTOR_IsPlayer(ball)==1 then
        destside=ACTOR_GetOnSide(ball);
        if destside==-1 then destside=ACTOR_GetLastOnSide(ball); end;

        local distance=PATH_GetDistance(ACTOR_GetVar(actor,"PathGraph"),ACTOR_GetOnSide(actor),destside);

        if ACTOR_GetVar(ball,"GodModeTimer")>0 then
         if distance==-1 then
           destside=GetNearestNode(actor,destside);
           distance=PATH_GetDistance(ACTOR_GetVar(actor,"PathGraph"),ACTOR_GetOnSide(actor),destside);
         end;
         if escapemode==0 then  besttarget=ball; bestdistance=distance; elseif distance<bestdistance then  besttarget=ball; bestdistance=distance; end;
         escapemode=1;
        elseif escapemode==0 and distance>=0 then
         if distance<bestdistance then besttarget=ball; bestdistance=distance;   end;
        end;
     end;    
   end;

  
  destside=ACTOR_GetOnSide(besttarget);
  if destside==-1 then destside=ACTOR_GetLastOnSide(besttarget); end;

    
   if escapemode==0 then
      nm=PATH_GetNextMove(ACTOR_GetVar(actor,"PathGraph"),ACTOR_GetOnSide(actor),rot,destside);
   else 
      nm=PATH_GetEscapeMove(ACTOR_GetVar(actor,"PathGraph"),ACTOR_GetOnSide(actor),rot,destside);
   end;

   if nm=="" then
     destside=GetNearestNode(actor,destside);
     if escapemode==0 then
        nm=PATH_GetNextMove(ACTOR_GetVar(actor,"PathGraph"),ACTOR_GetOnSide(actor),rot,destside);
     else 
        nm=PATH_GetEscapeMove(ACTOR_GetVar(actor,"PathGraph"),ACTOR_GetOnSide(actor),rot,destside);
     end;
   end; 



   if nm=="f" then
     ACTOR_CallMove(actor,"forward");
   elseif nm=="r" then
     ACTOR_CallMove(actor,"right");
   elseif nm=="l" then
     ACTOR_CallMove(actor,"left");
   end;
 end;


 local inlevel=ACTOR_InsideLevel(actor);
  if inlevel==0 then
   ACTOR_SetVar(actor,"IsAlive",-1);
  end;
end;

function Constructor(actor)
 local basis=BASIS_New();
 


  ACTOR_SetVar(actor,"Interaction","stp"); --(s)witches, (i)ce, (t)ramp, tele(p)ort, (b)reaking, (f)ire, s(p)ikes, (l)aser, (o)nedir 
  ACTOR_SetVar(actor,"Speed",defaultspeed); -- Speed

  ACTOR_SetVar(actor,"Temperature",0); 






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
 
  local s=ACTOR_GetRadius(actor)*extrascale;
  --BASIS_AxisRotate(basis,ACTOR_GetUp(actor),1.57079633);
  BASIS_SetScale(basis,VECTOR_New(s,s,s));
  
  ACTOR_SetVar(actor,"Basis",basis);
  ACTOR_SetVar(actor,"QuitGameOnCollide",QuitGameOnCollide);

  ACTOR_SetVar(actor,"IsAlive",1);

  ACTOR_SetVar(actor,"KilledString","");
  ACTOR_SetVar(actor,"RollPos",0);
  ACTOR_SetVar(actor,"PrecessionTime",0);
  ACTOR_SetVar(actor,"RotationTime",0.0);
  ACTOR_SetVar(actor,"SoundTimer",0.1);
ACTOR_SetVar(actor,"RestingOnIce",-1);
   ACTOR_SetVar(actor,"TiedToPlane",0);

 local penv=PARTICLE_CreateEnvOnActor(actor);
 ACTOR_SetVar(actor,"PEnv",penv); 


 if GLOBAL_GetVar("EditorMode")==1 then
  ACTOR_SetVar(actor,"PathGraph",-2);  --Never create a path graph
 else 
   ACTOR_SetVar(actor,"PathGraph",-1); --Create it in the first "think"
 end;
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
 
