texture=-1;
mdl=-1;

tilldisappear=0.2;

snd_break=-1;
snd_decrement=-1;

function ActsOnActor(actor)
  if ACTOR_IsPlayer(actor)==1 then
   return 1;
  end;
  return 0; --No enemy interaction possible for now
end;


function GetEditorInfo(name,default)
 if name=="BlockOnly" then
  return "yes";
 elseif name=="BlockItemsAllowed" then
  return "no";
elseif name=="SideItemsAllowed" then
  return "no";
 elseif name=="NumVars" then
  return 1;
 elseif name=="Var1" then
  return "Counter";
 elseif name=="VarType1" then
  return "int";
 end;
 return default;
end;

function Precache()
  texture=TEXDEF_Load("breaking1");
  snd_break=SOUND_Load("breakblock");
  snd_decrement=SOUND_Load("count");
  mdl=MDLDEF_Load("counter");
end






function RenderMdl(side,size)
   MATRIX_Push();
  MATRIX_MultBase(right,up,dir,VECTOR_Sub(SIDE_GetMidpoint(side),VECTOR_Scale(up,GLOBAL_GetScale()*(1-size))));
  MATRIX_ScaleUniform(GLOBAL_GetScale()*0.3*size);
  
  local count=BLOCK_GetVar(SIDE_GetBlock(side),"Counter");

  if count<1 then
    count=1;
    BLOCK_SetVar(SIDE_GetBlock(side),"Counter",1);
  elseif count>5 then
    count=5;
    BLOCK_SetVar(SIDE_GetBlock(side),"Counter",5);
  end;

  GLOBAL_SetVar("RenderColorAdder",0.03*math.sin(5*GLOBAL_GetTime()));

  GLOBAL_SetVar("RenderColor",count-1);

  MDLDEF_Render(mdl);
  MATRIX_Pop();
end;



function RenderSide(side)
  block=SIDE_GetBlock(side);
  time=BLOCK_GetVar(block,"timer");
  if time<tilldisappear then
    TEXDEF_Render(texture,side); 
TEXDEF_ResetLastRenderedType();
    up=SIDE_GetNormal(side);
    dir=SIDE_GetTangent(side);
    right=VECTOR_Cross(up,dir);  

     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;

    RenderMdl(side,BLOCK_GetVar(block,"scale"));
  end;
end


function BlockThink(block)
  time=BLOCK_GetVar(block,"timer");
  if time>0 then
    if time>tilldisappear then
       return;
    end;
    time=time+GLOBAL_GetElapsed()*GLOBAL_GetVar("MoveSpeedMultiply");
    size=1-(time)/tilldisappear;
    BLOCK_SetScale(block,size);
    BLOCK_SetVar(block,"timer",time);
    BLOCK_SetVar(block,"scale",size);
    return;
  end;


  local aob=BLOCK_GetVar(block,"OnBlock");
  
  if aob~=0 then
   local actor_on_it=0;
   local cnt=BLOCK_GetVar(block,"Counter")  
     local oldcnt=cnt;

   for ball=0,ACTOR_NumActors()-1,1 do 
     local bs=ACTOR_TraceOnSide(ball);
     if ACTOR_IsPlayer(ball)==1 and bs>=0 then
       if SIDE_GetBlock(bs)==block then
         actor_on_it=1;
         break;
       end;
     end;
   end;

     if actor_on_it==0 then
        cnt=cnt-1;
        BLOCK_SetVar(block,"OnBlock",0);
     end;
     if cnt<1 then
       cnt=1;
       BLOCK_RemoveFromNeighbors(block);  
       PLAYER_SetVar(GLOBAL_GetVar("ActivePlayer"),"Score",PLAYER_GetVar(GLOBAL_GetVar("ActivePlayer"),"Score")+25);     --Score for destruction?
       SOUND_Play(snd_break,-1);
       BLOCK_SetVar(block,"timer",LEVEL_GetElapsed());
     elseif oldcnt>cnt then
       --Play the decrement sound
       SOUND_Play(snd_decrement,-1);
     end;
     BLOCK_SetVar(block,"Counter",cnt);
  end;


end;


function BlockConstructor(block)
  BLOCK_SetVar(block,"timer",0);
  BLOCK_SetVar(block,"Counter",5);
  BLOCK_SetVar(block,"OnBlock",0);
  BLOCK_SetVar(block,"scale",1);
end

function Event_OnSide(sideid,actorid)
   if ACTOR_IsPlayer(actorid)==0 then
        return; 
  end;
  local block=SIDE_GetBlock(sideid);
  local cnt=BLOCK_GetVar(block,"Counter");
  BLOCK_SetVar(block,"OnBlock",1);
end

function IsPassable(block)
  time=BLOCK_GetVar(block,"timer");
  if time==0 then
    return 0;
  else 
    return 1;
  end;
end

function HasTransparency(block)
  time=BLOCK_GetVar(block,"timer");
  if time==0 then
    return 0;
  else 
    return 1;
  end;
end;

function MayCull(side)
 --Normaly, it should not be culled, but it will prevent clipping errors when the cam is inside such a block
 -- May be 1 will work too, since the model is not that high
 up=SIDE_GetNormal(side); 
 local dn=VECTOR_Sub(SIDE_GetMidpoint(side),CAM_GetPos());
 local l=VECTOR_Dot(dn,dn);
 if l<0.001 then 
   return 1;
 end;
 dn=VECTOR_Scale(dn,1.0/l);
 if VECTOR_Dot(dn,up)>0.005 then
  return 1;
 end;
 return 0;

end
