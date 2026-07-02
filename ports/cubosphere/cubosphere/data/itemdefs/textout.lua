--Load the helper file, which contains functions for almost all items
INCLUDE("/include/std.inc");

mdl=-1;

--Is called once, after loading the this script
function Precache()
 -- if GLOBAL_GetVar("EditorMode")==1 then
    mdl=MDLDEF_Load("textout"); --Use the MDLDEF of the goblet for testing purposes
    PrecacheShadow(); --Call the helper file to load the shadow texture
 -- end
end;

--This function exports variables to the Level editor
function GetEditorInfo(name,default)
 if name=="NumVars" then --When the Editor needs to know, how many variables the item has,
   return 1; --it will answer with "2"
 elseif name=="Var1" then --When we ask for the name of the first variable
   return "Message"; --return it
 elseif name=="VarType1" then --And for the type of the first varible
   return "string"; --we say it is an integer
 --elseif name=="Var2" then --Same stuff for the second variable
 --  return "VisibleFor";
-- elseif name=="VarType2" then
 --  return "float";
 --elseif name=="Var3" then --Same stuff for the second variable
 --  return "HowOften";
 --elseif name=="VarType3" then
  -- return "int"; 
 else
   return default;  --All other querys are answered by the default value
 end;
  return default;
end;

--Called by each item (referenced by <id>) when created
function Constructor(id)
  ITEM_SetVar(id,"Phase",math.random()); --Random phase of the item rotation
  --ITEM_SetVar(id,"PickedUp",0); --How often the text was shown
  ITEM_SetVar(id,"Message","Text"); --Default values for the exported variables
  ITEM_SetVar(id,"SpecialProtect",0); -- Avoid the special button closing the Message popping up it again
end;


function KEYB_GetKeyNameT(kn)
  local k=KEYB_GetKeyName(GLOBAL_GetVar("Key_"..kn));
  return TRANS_StrD("key:"..k,k);
end;

function SubstKeys(s)
 local str=string.gsub(s, "<KEY:JUMP>", KEYB_GetKeyNameT("Jump"));
 str=string.gsub(str, "<KEY:FORWARD>", KEYB_GetKeyNameT("Forward"));
 str=string.gsub(str, "<KEY:LEFT>", KEYB_GetKeyNameT("Left"));
 str=string.gsub(str, "<KEY:RIGHT>", KEYB_GetKeyNameT("Right"));
 str=string.gsub(str, "<KEY:LOOKUP>", KEYB_GetKeyNameT("LookUp"));
 str=string.gsub(str, "<KEY:LOOKDOWN>", KEYB_GetKeyNameT("LookDown"));
 str=string.gsub(str, "<KEY:SPECIAL>", KEYB_GetKeyNameT("Special"));
 str=string.gsub(str, "<KEY:CANCEL>",   TRANS_StrD("key:escape","ESC"));
 return str;
end;

function StrCopy(inp,from,num)
  local ende=from+num-1;
  if ende>string.len(inp) then
    ende=string.len(inp);
  end;
  local res="";
  --print("Copy <"..inp.."> from "..from.." to "..ende); 
  for ind=from,ende,1 do
    res=res..string.sub(inp,ind,ind);
  end;
  --print("   returns <"..res..">");
  return res;
end;

function JOY_GetKeyNameT(forwhat)
 local jstr=GLOBAL_GetVar("Joy_"..forwhat);
 local c=string.find(jstr,",");
 local res;
 if c then
   stick=1+StrCopy(jstr,1,c-1);
   tstr=StrCopy(jstr,c+1,string.len(jstr));
   res=tstr;
   c=string.find(tstr,",");
   if c then
     ty=0+StrCopy(tstr,1,c-1);
     index=1+StrCopy(tstr,c+1,string.len(tstr));
     local js=TRANS_Str("controloptions:joy:joystring");
     local postfix="";
     if ty==0 then
       tystr=TRANS_Str("controloptions:joy:joybutton");
     elseif ty==1 then
       tystr=TRANS_Str("controloptions:joy:joyaxis");
       postfix=TRANS_Str("controloptions:joy:joyaxis:plus");
     else
       tystr=TRANS_Str("controloptions:joy:joyaxis");
       postfix=TRANS_Str("controloptions:joy:joyaxis:minus");
     end;
     tystr=string.gsub(string.gsub(tystr,", ",""),",","");
     res=tystr..index..postfix;

   else 
    res=jstr;
   end;
 else 
   res=jstr;
 end;
 return res;
end;

function SubstButtons(s)
 local str=string.gsub(s, "<JOY:JUMP>", JOY_GetKeyNameT("Jump"));
 str=string.gsub(str, "<JOY:FORWARD>", JOY_GetKeyNameT("Forward"));
 str=string.gsub(str, "<JOY:LEFT>", JOY_GetKeyNameT("Left"));
 str=string.gsub(str, "<JOY:RIGHT>", JOY_GetKeyNameT("Right"));
 str=string.gsub(str, "<JOY:LOOKUP>", JOY_GetKeyNameT("LookUp"));
 str=string.gsub(str, "<JOY:LOOKDOWN>", JOY_GetKeyNameT("LookDown"));
 str=string.gsub(str, "<JOY:CANCEL>", JOY_GetKeyNameT("Cancel"));
 str=string.gsub(str, "<JOY:SPECIAL>", JOY_GetKeyNameT("Special"));
 return str;
end;

--When an actor <actorid> and an item <itemid> collide, this is called
function ShowText(itemid)
 -- print("TEXTOUT: "..ITEM_GetVar(itemid,"Message"));

  local txt=ITEM_GetVar(itemid,"Message");
  txt=TRANS_StrD(txt,txt);

  txt=SubstKeys(txt);
  txt=SubstButtons(txt);

  GLOBAL_SetVar("TextOutString",txt);
  GLOBAL_SetVar("TextOutItem",itemid);

 -- local visfor=ITEM_GetVar(itemid,"VisibleFor");
--  if visfor<=0 then 
    GLOBAL_SetVar("TextOutTimer",0);
    MENU_Load("textout");
    GLOBAL_SetVar("TutorialString","<->");
    MENU_Activate();
--  else
--   GLOBAL_SetVar("TextOutTimer",visfor);
--  end;
end

--Is called, whenever the game logic test collision between actor an item
function CollisionCheck(actorid,itemid)
  if ACTOR_IsPlayer(actorid)==0 or LEVEL_GetTimeScale()==0 then
   return;
  end;

 

-- if ACTOR_GetVar(actorid,"specialpressed")==0 then
--  return;
-- end;

-- local picked=ITEM_GetVar(itemid,"PickedUp");
-- local ho=ITEM_GetVar(itemid,"HowOften");
-- if ho>0 and picked>=ho then 
--   return;
-- end;
 local playerpos=ACTOR_GetPos(actorid);
 local itempos=GetBasePos(itemid);
 local diff=VECTOR_Sub(playerpos,itempos);
 local l=VECTOR_Length(diff);
 local mindist=(itemsize+ACTOR_GetRadius(actorid));
 
 if l<=mindist then
  -- if lc<0 then
  --   ShowText(itemid);
  --   ITEM_SetVar(itemid,"LastCollide",actorid);
  --   if ho>0 then
  --    ITEM_SetVar(itemid,"PickedUp",picked+1);
  --   end;
  -- end;
  
    local atxt="textout:ingame:hint";
    stxt=TRANS_StrD(atxt,atxt);

    stxt=SubstKeys(stxt);
    stxt=SubstButtons(stxt);

    GLOBAL_SetVar("TextOutStringInGame",stxt);
    GLOBAL_SetVar("TextOutTimer",0.25);

   -- print(ACTOR_GetVar(actorid,"specialpressed").."  -  "..ACTOR_GetVar(actorid,"lastspecialpressed"));

   ACTOR_SetVar(actorid,"OnTextout",1);

    if ACTOR_GetVar(actorid,"specialpressed")==1 and ACTOR_GetVar(actorid,"lastspecialpressed")==0 and ITEM_GetVar(itemid,"SpecialProtect")==0 then
      ShowText(itemid);
      --print("Call show text");
   
    end;

    
 end
  if actorid==PLAYER_GetActiveActor(GLOBAL_GetVar("ActivePlayer")) then ITEM_SetVar(itemid,"SpecialProtect",0); end;
end

--Render the model
function RenderMdl(item,height)
  BeginRender(item,height,0.45,GetPhase(item));
  MDLDEF_Render(mdl);
  EndRender();
end;


--Render call: Render model and add the SHADOW-Render to the Distance Render List (as is has transparency effects)
function Render(item)
 --if GLOBAL_GetVar("EditorMode")==1 then
 
    local height=GetHeight(item);
    GetBasis(item,height);
    RenderMdl(item,height);
 
  ITEM_DistanceRender(item,CAM_ZDistance(pos));
 --end;
end

--Render the shadow
function DistRender(item)
   local height=GetHeight(item);
   RenderShadow(item,height,GLOBAL_GetScale()*0.08);
end

