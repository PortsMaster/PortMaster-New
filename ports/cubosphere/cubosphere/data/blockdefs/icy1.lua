
--This controls whether you are allowed to roll down (falling) to the side if you have been blocked by another ball
may_roll_down_if_resting=1;

texture=-1;

cool_speed=2;


function Precache()
 -- print("Precache BDEF");
  texture=TEXDEF_Load("icy1");
end

function RenderSide(side)
  TEXDEF_Render(texture,side); 
end


function ActsOnActor(actor)
  if ACTOR_IsPlayer(actor)==1 then
   return 1;
  end;
--  local inter=ACTOR_GetVar(actor,"Interaction");
--  if string.find(inter, "i") then
--    return 1;
 -- else
    return 0;
--  end;
end;

-- is called every frame while the player is on this side
-- we provide an actor ID too
function Event_OnSide(side,actor)
  if (ActsOnActor(actor)==1) then
    ACTOR_SetVar(actor,"Temperature",ACTOR_GetVar(actor,"Temperature")-LEVEL_GetElapsed()*cool_speed); 
    local msm=ACTOR_GetTemporaryMoveSpeedMultiplier(actor);
    if msm<0 or ACTOR_GetVar(actor,"RestingOnIce")==side then
      ACTOR_SetVar(actor,"RestingOnIce",side);
    else
      ACTOR_SetVar(actor,"RestingOnIce",-1);
      ACTOR_CallMove(actor,"forward");
    end;
  end;
end;

tempprotect_latefw=0;

function MayMove(side,actor,dir)
if ActsOnActor(actor)==1 and ACTOR_GetVar(actor,"RestingOnIce")~=side then
 tempprotect_latefw=0;
 if (dir=="left") then return 0;
 elseif (dir=="right") then return 0;
 elseif (dir=="jumpup") then 
     ACTOR_CallMove(actor,"forward");
     ACTOR_CallMove(actor,"jump");
     return 0;
 else return 1;
 end;
else 
 if ACTOR_GetVar(actor,"RestingOnIce")==side then
   if dir~="left" and dir~="right" then
     if dir=="forward" and may_roll_down_if_resting==0 then
       --Check if it is a slide down event
       --First, test the block in front of me (facing to me, i.e. roll up)
       local cmove=0;
       local ob=SIDE_GetBlock(side);
       local tr=LEVEL_TraceLine(ACTOR_GetPos(actor),ACTOR_GetDir(actor));
       if tr["hit"]==1 and tr["dist"]<1.1*GLOBAL_GetScale() then
         if BLOCK_GetBlocking(tr["block"])~=0 then
           cmove=1;
         end;
       end;
       if cmove==0 then
          local nb=BLOCK_GetNeighbor(ob,ACTOR_GetDir(actor)); --Simple Forward motion
          if nb>=0 then
            if BLOCK_GetBlocking(nb)~=0 then cmove=1 ;end;
          end;
       end;
       if cmove==0 then
          local nb1=BLOCK_GetNeighbor(ob,ACTOR_GetSide(actor)); --Roll down motion
          local nb2=BLOCK_GetNeighbor(ob,VECTOR_Scale(ACTOR_GetSide(actor),-1));
          if nb1>=0 then nb1=2*BLOCK_GetBlocking(nb1)-1; end;
          if nb2>=0 then nb2=2*BLOCK_GetBlocking(nb2)-1; end;
          if nb1<0 and nb2<0 then cmove=1; end;
       end;
       if cmove==0 then tempprotect_latefw=0; return 0; end; 
     end;

     if dir=="jumpup" then 
       tempprotect_latefw=1;
       return 1;
     elseif dir=="jumpahead" and  tempprotect_latefw==1 then
       ACTOR_SetVar(actor,"RestingOnIce",side);
     else
       ACTOR_SetVar(actor,"RestingOnIce",-1);
       tempprotect_latefw=0;
     end;

   end;
 end;
 tempprotect_latefw=0;
 return 1;
end;
end;

--Oh, we can actually move and slide down the block // For icy blocks esp. useful
function MaySlideDown(side,actor)
 local sw=1;
 if may_roll_down_if_resting==0 and ACTOR_GetVar(actor,"RestingOnIce")~=side then
   sw=0;
 end; 
 if  (ActsOnActor(actor)==1) then
  return sw;
 else
  return 0;
 end;
end;
