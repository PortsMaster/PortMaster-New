

--LUA
GLOBAL_SetVar("LastLevelIndexInEpisode",-1);
NEXTLEVEL="";
GameTime=0.0;
yrot=0;
selectblock=-1;
selblock=-1;
firstthink=1;
selside=-1;
CamBasis=-1;
crosshair=-1;
changed=0;
showhelp=0;
infostring="";
infotime=0;
drawmenu=1;

--Some opts for preview pic
ClearCol=COLOR_New(0,0,0,1);
prevpicW=256;
prevpicH=128;
--prevpicW=512;
--prevpicH=512;

PreviewPicDist=1.6;
PreviewPicBasis=BASIS_New()
BASIS_Set(PreviewPicBasis,VECTOR_New(0.707106781,0,-0.707106781),VECTOR_New(0,1,0),VECTOR_New(0.707106781,0,0.707106781),VECTOR_New(0,0,0));
BASIS_AxisRotate(PreviewPicBasis,VECTOR_New(0.707106781,0,-0.707106781),-0.5);

startblock=-1;
startside=-1;
startrotation=0;
startmarker=-1;

SelBlockX=0;
SelBlockY=0;
SelBlockZ=0;

GetKeys=1;

BallType="ball1";

GLOBAL_SetVar("RenderingPrevPic",0);
GLOBAL_SetVar("Editor_StartpointValid",0);
GLOBAL_SetVar("StartTime",90);
GLOBAL_SetVar("MaxTime",90);
GLOBAL_SetVar("GoggleTime",15);
GLOBAL_SetVar("LevelMusic",GLOBAL_GetVar("MusicTrack"));

SideStrings={"up","down","left","right","front","back"};

LeftButton=0;
RightButton=0;
MouseWheelUp=0;
MouseWheelDown=0;

menuactive=0;

snd_nav=SOUND_Load("menunav");
snd_sel=SOUND_Load("menusel");

blockdefs={};

PI_HALBE=math.pi/2

MenuSelection=0;

InScene="editing";
blocktype="normal1";

darkbg=-1;

local menu_sections = {
	continue = 0,
	settings = 1,
	new = 2,
	load = 3,
	save = 4,
	manual = 5,
	overview = 6,
	test = 7,
	quit = 8
}

local menu_length = 9

local manual_url = TRANS_StrD('editor:manual_url', 'https://github.com/cubosphere/cubosphere-code/wiki')

local open_cmd -- this needs to stay outside the function, or it'll re-sniff every time...
local function open_url(url) -- It's from StackOverflow
    if not open_cmd then
        if package.config:sub(1,1) == '\\' then -- windows
            open_cmd = function(url)
                -- Should work on anything since (and including) win'95
                os.execute(string.format('start "%s"', url))
            end
        -- the only systems left should understand uname...
        elseif (io.popen("uname -s"):read'*a') == "Darwin" then -- OSX/Darwin ? (I can not test.)
            open_cmd = function(url)
                -- I cannot test, but this should work on modern Macs.
                os.execute(string.format('open "%s"', url))
            end
        else -- that ought to only leave Linux
            open_cmd = function(url)
                -- should work on X-based distros.
                os.execute(string.format('xdg-open "%s"', url))
            end
        end
    end

    open_cmd(url)
end

local function continue_editing()
	MOUSE_Snap(1)
	InScene="editing"
end

function CheckDefExchange(defname,typestr)
 --Check older versions --TODO:Remove soon
if typestr=="item" then
   if     defname=="time plus" then defname="time_plus";
   elseif defname=="time minus" then defname="time_minus";
   elseif defname=="jump plus" then defname="jump_plus";
   elseif defname=="jump minus" then defname="jump_minus";
   end;
 end;

  return defname;
end;

function BackwardCompatibility(lvlversion,when)
 -- Later changes if the level desc is changing
end;

function CheckStartPos()
 GLOBAL_SetVar("Editor_StartpointValid",0);
 local numballs=0;

 for ball=0,ACTOR_NumActors()-1,1 do
  if ACTOR_IsPlayer(ball)==1 then
   local startside=ACTOR_GetOnSide(ball); 
   local sp;
   if startside<0 then
    sp=ACTOR_GetPos(ball);
   else 
    sp=VECTOR_Add(SIDE_GetMidpoint(startside),VECTOR_Scale(SIDE_GetNormal(startside),GLOBAL_GetScale()*0.5));  
   end;
   local bi=BLOCK_AtPos(sp); 
   if bi<0 then
     numballs=numballs+1;
   end;
  end;
 end;

 if numballs>0 then
   GLOBAL_SetVar("Editor_StartpointValid",1);
 end;
end;


function ShowInfo(str)
  infostring=str;
  infotime=2;
end;




function SaveToFile(name)
  GLOBAL_SetVar("Editor_SaveFileName",name);
  INCLUDEABSOLUTE("/editor/include/savelvl.inc");
 if name~="_selection" then
    local sw=GLOBAL_GetVar("ScreenWidth");
    local sh=GLOBAL_GetVar("ScreenHeight");
    local ratio=(sw*480)/(sh*640);
    if ratio>1 then
      sw= math.floor(sw/ratio);
    elseif ratio<1 then
      sh= math.floor(sh*ratio);
    end;
 
   GLOBAL_SetVar("RenderingPrevPic",1);
    GAME_Think();
    DEVICE_Viewport(sw,sh);
    DEVICE_Clear(ClearCol);

 
    local BackUpBasis=BASIS_New();
    local cpos=CAM_GetPos();
    local cdir=CAM_GetDir();
    local cside=CAM_GetSide();
    local cup=CAM_GetUp();
    BASIS_Set(BackUpBasis,cside,cup,cdir,cpos);
    
    
    CAM_FromBasis(PreviewPicBasis);
    CAM_SetPos(VECTOR_Add(LEVEL_GetCenter(),VECTOR_Scale(CAM_GetDir(),PreviewPicDist*LEVEL_GetRadius())));
 


    LEVEL_Render();
    
    CAM_FromBasis(BackUpBasis);
    GLOBAL_SetVar("RenderingPrevPic",0);
    

    svname="/user/levels/"..GLOBAL_GetVar("Editor_SaveFileName")..".png";
    DEVICE_SaveFramePic(svname,prevpicW,prevpicH);
    DEVICE_Viewport(GLOBAL_GetVar("ScreenWidth"),GLOBAL_GetVar("ScreenHeight"));
 
  end;
end;


function ChangeBlockType(nt)
  changed=1;
  blocktype=nt; 
end;


function ChangeItemType(ni)
 -----------if (ni~="") and ( (BLOCK_GetEditorInfo(SIDE_GetBlock(selside),"BlockItemsAllowed","yes")=="no") or (SIDE_GetEditorInfo(selside,"SideItemsAllowed","yes")=="no")) then
 if (ni~="") and ( (SIDE_GetEditorInfo(selside,"SideItemsAllowed","yes")=="no")) then
  ShowInfo(TRANS_Str("editor:info:noitem"));
  return;
 end;
  changed=1;
  LEVEL_SetSideItem(selside,ni);
end;

function GetItemOnSide(sid)
 for i=0,LEVEL_NumItems("")-1,1 do
   if (ITEM_GetSide(i)==sid) then
     return i;
   end;
 end;
 return -1;
end;

function GetEnemyOnSide(sid)
 for i=0,ACTOR_NumActors()-1,1 do
   if (ACTOR_GetOnSide(i)==sid) and (ACTOR_IsPlayer(i)==0) then
     return i;
   end;
 end;
 return -1;
end;

function GetPlayerOnSide(sid)
 for i=0,ACTOR_NumActors()-1,1 do
   if (ACTOR_GetOnSide(i)==sid) and (ACTOR_IsPlayer(i)==1) then
     return i;
   end;
 end;
 return -1;
end;

function ChangePlayerType(ni)
   local sact=GetPlayerOnSide(selside);
  if sact~=-1 then
    if ACTOR_GetType(sact)==ni then 
      return;
    end;
    ACTOR_Delete(sact);
    changed=1;
  end;
  if ni=="" then
    return;
  end;
  local ne=ACTOR_New(ni);
  ACTOR_SetStart(ne,selside,0);
  changed=1;
end;


function ChangeEnemyType(ni)
 if (ni~="") and ( (SIDE_GetEditorInfo(selside,"SideEnemiesAllowed","yes")=="no")) then
  ShowInfo(TRANS_Str("editor:info:noenemy"));
  return;
 end;
  local sact=GetEnemyOnSide(selside);
  if sact~=-1 then
    if ACTOR_GetType(sact)==ni then 
      return;
    end;
    ACTOR_Delete(sact);
    changed=1;
  end;
  if ni=="" then
    return;
  end;
  local ne=ENEMY_New(ni);
  ACTOR_SetStart(ne,selside,0);
  changed=1;
end;


function LeftClick()
  if GetKeys==0 then
    return;
  end;
  local tr=LEVEL_TraceLine(CAM_GetPos(),VECTOR_Scale(CAM_GetDir(),-1));
  if tr["hit"]==1 then
    --print("hit "..tr["dist"]);
    selblock=-1;
    selside=tr["side"];
    --print("SELECTED SIDE: "..tr["side"]);
       GLOBAL_SetVar("Editor_SelectedSide",selside);
    -- Move the cursor
    BLOCK_SetPos(selectblock,BLOCK_GetPos(tr["block"]));
    return 1;
  end;
  return 0;
end;

function SetStartPos()
  local tr=LEVEL_TraceLine(CAM_GetPos(),VECTOR_Scale(CAM_GetDir(),-1));
  if tr["hit"]==1 then
     if tr["side"]~=startside then
       startside=tr["side"];
       startblock=tr["block"]; 
       ShowInfo(TRANS_Str("editor:info:startset"));
     else
       startrotation=math.fmod(startrotation+1,4);
       ShowInfo(TRANS_Str("editor:info:startrot"));
     end;
  end;
end;



function PostRender()
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;
end;



function PreRender()
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;
  --MATERIAL_SetAmbient(COLOR_New(0.1,0.1,0.1,1.0));
  --MATERIAL_SetDiffuse(COLOR_New(0.9,0.9,0.9,1.0));
  --MATERIAL_SetSpecular(COLOR_New(0.9,0.9,0.9,1.0));
  --MATERIAL_SetSpecularPower(50.0);

if GLOBAL_GetVar("RenderingPrevPic")==0 then
 for acti=0,ACTOR_NumActors()-1,1 do
   local ss=ACTOR_GetOnSide(acti);
if ss>=0 then
   local mp=SIDE_GetMidpoint(ss);
   local up=SIDE_GetNormal(ss);
   local dir=VECTOR_Scale(ACTOR_GetDir(acti),-1);
   local right=VECTOR_Cross(up,dir);
   MATRIX_Push();
   MATRIX_MultBase(right,up,dir,VECTOR_Add(mp,VECTOR_Scale(up,GLOBAL_GetScale()*(-0.05))));
   MATRIX_ScaleUniform(GLOBAL_GetScale());
   --MATRIX_AxisRotate(VECTOR_New(0,1,0),startrotation*90);
   MDLDEF_Render(startmarker);
   MATRIX_Pop();
end;
 end; 
end;
 
end;

function Think()
 if GLOBAL_GetVar("RenderingPrevPic")==1 then
   return;
 end;
 if firstthink==1 then
  GLOBAL_SetVar("EditorToolCommand","none");
  firstthink=0;
  --GLOBAL_SetVar("EditorTool","Editing");
  --menuactive=0;
  return;
 end;

  if GLOBAL_GetVar("EditorTool")=="Editing" then
    if GLOBAL_GetVar("EditorToolCommand")=="NoSave" then
     menuactive=1;
    end;
  end;

 if menuactive==1 then
   
   if GLOBAL_GetVar("EditorTool")=="Editing" then
     --print("Ret");
     drawmenu=1;
     local cmd=GLOBAL_GetVar("EditorToolCommand");
     if cmd=="ChangeBlockType" then
       ShowInfo(TRANS_Str("editor:info:blocktypechanged"));
       ChangeBlockType(GLOBAL_GetVar("EditorNewBlockType"));
       GetKeys=1;
     elseif cmd=="ChangeItemType" then
       ShowInfo(TRANS_Str("editor:info:itemset"));
       ChangeItemType(GLOBAL_GetVar("EditorNewItemType"));
       GetKeys=1;
     elseif cmd=="ChangeEnemyType" then
       ShowInfo(TRANS_Str("editor:info:enemyset"));
       ChangeEnemyType(GLOBAL_GetVar("EditorNewEnemyType"));
       GetKeys=1;
     elseif cmd=="ChangePlayerType" then
       ShowInfo(TRANS_Str("editor:info:startposset"));
       ChangePlayerType(GLOBAL_GetVar("EditorNewEnemyType"));
       GetKeys=1;
     elseif cmd=="Save" then
       GetKeys=1;
       SaveToFile(GLOBAL_GetVar("TextInput_Text"));
       ShowInfo(TRANS_Str("editor:info:levelsaved"));
       --And leave the menu
       changed=0;
       
       if GLOBAL_GetVar("Editor_DesiredMenu")~=""  then
         
         MENU_Activate();
         LEVEL_Deactivate();
         MENU_Load(GLOBAL_GetVar("Editor_DesiredMenu"));
         print(GLOBAL_GetVar("Editor_DesiredMenu"));   
         return;
       end;
       continue_editing();
    elseif cmd=="NoSave" then
         GetKeys=1;
         continue_editing();
         GLOBAL_SetVar("EditorToolCommand","");
    elseif cmd=="Return" then
       continue_editing();
       drawmenu=1;
       GetKeys=1;
    elseif cmd=="changed" then
       changed=1;
       drawmenu=1;
       GetKeys=1;
    end;
    menuactive=0;
   end;
   return;
 end;

 local speed=1.0/200.0;
 local ms=MOUSE_GetState();
 --print(ms.dx.."  "..ms.dy);
 CAM_AxisRotate(VECTOR_New(0,1,0),-ms.dx*speed);
 --Test if we can rotate up and down
 
 local nyrot=yrot-ms.dy*speed;

 if ( nyrot < PI_HALBE ) and (nyrot > -PI_HALBE) then
   
 elseif (nyrot < PI_HALBE )  then
   ms.dy=(PI_HALBE+yrot)/speed;
 else
   ms.dy=(-PI_HALBE+yrot)/speed;
 end;

 yrot=yrot-ms.dy*speed;
 CAM_AxisRotate(CAM_GetSide(),-ms.dy*speed);
   
 if ms["button1"]==0 and LeftButton==1 then
  LeftClick(); 

 end;
 LeftButton=ms["button1"];

 if ms["button3"]==0 and RightButton==1 then
  if LeftClick()==1 then
    ReturnPressed();
  end;
 end;
 RightButton=ms["button3"];


 
end;

function TabPressed()
if GetKeys==0 then
    return;
  end;
  local tr=LEVEL_TraceLine(CAM_GetPos(),VECTOR_Scale(CAM_GetDir(),-1));
  if tr["hit"]==1 then
    blocktype=SIDE_GetType(tr["side"]);
    ShowInfo(TRANS_Str("editor:info:blocktypecopied"));
  end;
end;


function ReturnPressed()
if GetKeys==0 then
    return;
  end;
 local bi=BLOCK_AtPos(BLOCK_GetPos(selectblock));
   
 if selside<0 then
   if bi<0 then
     return;
   else 
     changed=1;
     LEVEL_ChangeBlock(bi,blocktype);
     --Testing if items must be removed
     if (BLOCK_GetEditorInfo(bi,"BlockItemsAllowed","yes")=="no") or (BLOCK_GetEditorInfo(bi,"SideItemsAllowed","yes")=="no") then
       --Remove all items
       for s=0,5,1 do
         LEVEL_SetSideItem(bi*6+s,"");
       end; 
     end;
     ShowInfo(TRANS_Str("editor:info:blockapply"));
   end;
 else
   changed=1;
   LEVEL_ChangeSide(bi,SideStrings[math.fmod(selside,6)+1],blocktype);
   ShowInfo(TRANS_Str("editor:info:sideapply"));
   if (BLOCK_GetEditorInfo(bi,"BlockOnly","no")=="yes") or (SIDE_GetEditorInfo(selside,"BlockOnly","no")=="yes") then
          LEVEL_ChangeBlock(bi,blocktype);
          ShowInfo(TRANS_Str("editor:info:wholeblockapply"));
   end;
   if (SIDE_GetEditorInfo(selside,"SideItemsAllowed","yes")=="no") then
         LEVEL_SetSideItem(selside,"");
       
     end;
 end;
end;

function SpacePressed()
if GetKeys==0 then
    return;
  end;
 local bi=BLOCK_AtPos(BLOCK_GetPos(selectblock));
 if selblock>=0 then
   selblock=-1;
   selside=-1;
   --changed=1;
   GLOBAL_SetVar("Editor_SelectedBlock",selblock);
 elseif bi<0 then
  selside=-1;
   local sp=VECTOR_Scale(BLOCK_GetPos(selectblock),1.0/(2*GLOBAL_GetScale()));
   changed=1;
   LEVEL_AddBlock(sp.x,sp.y,sp.z,blocktype);
   ShowInfo(TRANS_Str("editor:info:newblock"));
 else 
   selblock=bi;
   selside=-1;
   --changed=1;
   GLOBAL_SetVar("Editor_SelectedBlock",selblock);
 end;
end;

function BackSpacePressed()
if GetKeys==0 then
    return;
  end;
 local bi=BLOCK_AtPos(BLOCK_GetPos(selectblock));
 local startblockpos;
 if bi<0 then
   return;
 else 
 --print("Deleting block with index"..bi);
   selblock=-1;
   selside=-1;
   GLOBAL_SetVar("Editor_SelectedBlock",-1);
   if (startblock==bi) or (startblock<0) then
     startblock=-1;
     startside=-1;
     startrotation=0;
   else
     startblockpos=BLOCK_GetPos(startblock);
     startside=math.fmod(startside,6);
   end;

   --Killing all enemies on bi
   for si=0,5,1 do
     local ei=GetEnemyOnSide(6*bi+si);
     if (ei>=0) then
       ACTOR_Delete(ei);
     end;
    local pl=GetPlayerOnSide(6*bi+si);
     if (pl>=0) then
       ACTOR_Delete(pl);
     end;
   end;

   LEVEL_DeleteBlock(bi);
   ShowInfo(TRANS_Str("editor:info:blockdeleted"));
   changed=1;
   selectblock=LEVEL_GetEditorSelector();

   if startblock>=0 then
    startblock=BLOCK_AtPos(startblockpos);
    startside=startblock*6+startside;
   end;
 end;
end;

function MoveSelBlock()
 if selblock<0 then
  return;
 end;
 local bi=BLOCK_AtPos(BLOCK_GetPos(selectblock));
 if bi>0 and bi~=selblock then
  selblock=-1;
   GLOBAL_SetVar("Editor_SelectedBlock",-1);
   
  return;
 end;

 local diff=VECTOR_Sub(BLOCK_GetPos(selblock),BLOCK_GetPos(selectblock));
 if VECTOR_Dot(diff,diff)<0.0001 then
  return;
 end;

 
 changed=1;
 --Move all enemies with it, Move all to the selectblock first
 for si=0,5,1 do
   local en=GetEnemyOnSide(6*selblock+si);
   if en~=-1 then
     ACTOR_SetStart(en,6*selectblock+si,ACTOR_GetStartRotation(en));
   end;
  local pl=GetPlayerOnSide(6*selblock+si);
   if pl~=-1 then
     ACTOR_SetStart(pl,6*selectblock+si,ACTOR_GetStartRotation(pl));
   end;
 end;
 BLOCK_SetPos(selblock,BLOCK_GetPos(selectblock));
 --Now attach all enemies to the block again
 for si=0,5,1 do
   local en=GetEnemyOnSide(6*selectblock+si);
   if en~=-1 then
     ACTOR_SetStart(en,6*selblock+si,ACTOR_GetStartRotation(en));
   end;
  local pl=GetPlayerOnSide(6*selectblock+si);
   if pl~=-1 then
     ACTOR_SetStart(pl,6*selblock+si,ACTOR_GetStartRotation(pl));
   end;
 end;
end;


function EditorKey(key,down,toggle)
if GetKeys==0 then
    return;
  end;
 if down==0 then
  return;
 end;
 keyn=KEYB_GetKeyName(key);
--print(keyn);
 local speed=15*GLOBAL_GetScale()*GLOBAL_GetElapsed();
 if keyn=="Up" then
   CAM_SetPos(VECTOR_Add(CAM_GetPos(),VECTOR_Scale(CAM_GetDir(),-speed)));
 elseif keyn=="Down" then
   CAM_SetPos(VECTOR_Add(CAM_GetPos(),VECTOR_Scale(CAM_GetDir(),speed)));
 elseif keyn=="Left" then
   CAM_SetPos(VECTOR_Add(CAM_GetPos(),VECTOR_Scale(CAM_GetSide(),-speed)));
 elseif keyn=="Right" then
   CAM_SetPos(VECTOR_Add(CAM_GetPos(),VECTOR_Scale(CAM_GetSide(),speed)));
 

 elseif keyn=="W" and toggle==1 then
   BLOCK_SetPos(selectblock,VECTOR_Add(BLOCK_GetPos(selectblock),VECTOR_New(0,0,-2*GLOBAL_GetScale()))); selside=-1;
 elseif keyn=="S" and toggle==1 then
   BLOCK_SetPos(selectblock,VECTOR_Add(BLOCK_GetPos(selectblock),VECTOR_New(0,0,2*GLOBAL_GetScale()))); selside=-1;
 elseif keyn=="D" and toggle==1 then
   BLOCK_SetPos(selectblock,VECTOR_Add(BLOCK_GetPos(selectblock),VECTOR_New(2*GLOBAL_GetScale(),0,0))); selside=-1;
 elseif keyn=="A" and toggle==1 then
   BLOCK_SetPos(selectblock,VECTOR_Add(BLOCK_GetPos(selectblock),VECTOR_New(-2*GLOBAL_GetScale(),0,0))); selside=-1;
 elseif keyn=="E" and toggle==1 then
   BLOCK_SetPos(selectblock,VECTOR_Add(BLOCK_GetPos(selectblock),VECTOR_New(0,2*GLOBAL_GetScale(),0))); selside=-1;
 elseif keyn=="Q" and toggle==1 then
   BLOCK_SetPos(selectblock,VECTOR_Add(BLOCK_GetPos(selectblock),VECTOR_New(0,-2*GLOBAL_GetScale(),0))); selside=-1;
 elseif keyn=="Space" and toggle==1 then
   SpacePressed();
 --elseif keyn=="o" and toggle==1 then
   --DEBUG();

 elseif keyn=="Backspace" and toggle==1 then
   BackSpacePressed();
 elseif keyn=="Return" and toggle==1 then
   ReturnPressed();
 elseif keyn=="F1" and toggle==1 then
   if showhelp==0 then
     showhelp=1;
   else
     showhelp=0;
   end;
 
-- elseif keyn=="p" and toggle==1 then
--   SetStartPos();
 elseif keyn=="P" and toggle==1 then
    if selside>=0 then
      SOUND_Play(snd_sel,-1);
    local pl=GetPlayerOnSide(selside);
    if pl==-1 then
     MENU_Load("editorplayersel");   
     GLOBAL_SetVar("EditorNewEnemyType","");
     GLOBAL_SetVar("EditorTool","PlayerSel");
    else
     MENU_Load("editorplayer");   
     GLOBAL_SetVar("EditorCurrentEnemy",pl);
     GLOBAL_SetVar("EditorTool","Player");
    end; 
     MENU_Activate();
     menuactive=1;
     GetKeys=0;
    end;
 elseif keyn=="B" and toggle==1 then
   --Call the Block Selector
   SOUND_Play(snd_sel,-1);
   MENU_Load("editorblocksel");
   MENU_Activate();
   GLOBAL_SetVar("EditorNewBlockType","");
   GLOBAL_SetVar("EditorTool","BlockSel");
   menuactive=1;
   GetKeys=0;
 elseif keyn=="V" and toggle==1 and selside>=0 then
   --Call the Side Attribute selection
   GLOBAL_SetVar("Editor_SelectedSide",selside);
   GLOBAL_SetVar("EditorTool","SideAttribs");
   GLOBAL_SetVar("EditorToolCommand","");
   SOUND_Play(snd_sel,-1);
   MENU_Load("editorsideattribs");
   MENU_Activate();
   menuactive=1;
   GetKeys=0;
 elseif keyn=="I" and toggle==1 then
    if selside>=0 then
     --Call the Item Selector
     SOUND_Play(snd_sel,-1);

     local sideitem=GetItemOnSide(selside);
     local itemnumvars=0;
     if sideitem~=-1 then --Check, if there are vars
      itemnumvars=ITEM_GetEditorInfo(sideitem,"NumVars","0")+0;
     end;
     if itemnumvars==0 then
       MENU_Load("editoritemsel");
       GLOBAL_SetVar("EditorNewItemType","");
       GLOBAL_SetVar("EditorTool","ItemSel");
     else
        MENU_Load("editoritem");   
        GLOBAL_SetVar("EditorCurrentItem",sideitem);
        GLOBAL_SetVar("EditorTool","Item");
     end;
     MENU_Activate(); 
     menuactive=1;
     GetKeys=0;
    end;
 elseif keyn=="O" and toggle==1 then
    if selside>=0 then
     --Call the Enemy Selector
     SOUND_Play(snd_sel,-1);
    local en=GetEnemyOnSide(selside);
    if en==-1 then
     MENU_Load("editorenemysel");   
     GLOBAL_SetVar("EditorNewEnemyType","");
     GLOBAL_SetVar("EditorTool","EnemySel");
    else
     MENU_Load("editorenemy");   
     GLOBAL_SetVar("EditorCurrentEnemy",en);
     GLOBAL_SetVar("EditorTool","Enemy");
    end; 
     MENU_Activate();
     menuactive=1;
     GetKeys=0;
    end;
 elseif keyn=="Tab" and toggle==1 then
   TabPressed();
  elseif keyn=="PrintScreen" and toggle==1 then
    DEVICE_ScreenShot();
 end;
 MoveSelBlock();
 GLOBAL_SetVar("Editor_SelectedSide",selside);
end;

function OnKeyPressed(key,down,toggle)
 if GetKeys==0 then
    return;
  end;

 if menuactive==1 then
   if GLOBAL_GetVar("EditorTool")~="EditorMenu" then
     return;
   end;
 end;

 keyn=KEYB_GetKeyName(key);
 
 --print(keyn.."  "..key);

 if (InScene=="editing") then
  if down==1 then
   if (keyn=="Escape") and (toggle==1) then
      SOUND_Play(snd_sel,-1);
      CheckStartPos(); --Check if it is sane
      InScene="pause"; 
      MenuSelection=0;
      GLOBAL_SetVar("EditorTool","EditorMenu");
      menuactive=1;
	  MOUSE_Snap(0);
   else
      ---CHECK EDITOR KEYS
 
     EditorKey(key,down,toggle);
   end;
  end;
 elseif ((InScene=="pause") and (toggle==1)) then
   if keyn=="Escape" then
     SOUND_Play(snd_sel,-1);
     continue_editing();
     GLOBAL_SetVar("EditorTool","Editing");
     menuactive=0;
     --LEVEL_SetTimeScale(1);
   elseif (keyn=="Down") then
     SOUND_Play(snd_nav,-1);
     MenuSelection=math.fmod((MenuSelection+1),menu_length);
   elseif (keyn=="Up") then
     SOUND_Play(snd_nav,-1);
     MenuSelection=MenuSelection-1;
     if MenuSelection<0 then
       MenuSelection = menu_length-1;
     end;
   elseif (keyn=="Space") or (keyn=="Return") then
     SOUND_Play(snd_sel,-1);
     if MenuSelection == menu_sections.continue then
       continue_editing();
       GLOBAL_SetVar("EditorTool","Editing");
       menuactive=0;
       drawmenu=1;
       --LEVEL_SetTimeScale(1);
     elseif MenuSelection == menu_sections.save then
       --SaveToFile("Bla");
       --print("SAVED");
        CheckStartPos(); 
        if GLOBAL_GetVar("Editor_StartpointValid")==0 then
            --LEVEL_Deactivate();
            drawmenu=0;
            MENU_Load("editornostartpos");
            MENU_Activate();
             --menuactive=1;
            GetKeys=0;
            return;
         end;
       GLOBAL_SetVar("TextInput_Text",GLOBAL_GetVar("Editor_Filename"));
       GLOBAL_SetVar("TextInput_Caption",TRANS_Str("editor:save:fileprompt"));
       GLOBAL_SetVar("TextInput_OkMenu","editorsave");
       GLOBAL_SetVar("TextInput_CancelMenu","editornotsave");
       GLOBAL_SetVar("TextInput_Type","userlevel_save");
       
       GLOBAL_SetVar("EditorTool","Save");
       GLOBAL_SetVar("Editor_DesiredMenu","");
       --LEVEL_Deactivate();
       MENU_Load("textinput");
       MENU_Activate();
       menuactive=1;
       drawmenu=0;
       GetKeys=0;
     elseif MenuSelection == menu_sections.load then
       
      --LEVEL_Deactivate();
       
       if changed==0 then
         MENU_Load("editorload");
       else
         GLOBAL_SetVar("Editor_DesiredMenu","editorload");
         drawmenu=0;
         GLOBAL_SetVar("EditorTool","SaveChanges");
         MENU_Load("editorsavechanges");
       end;
       
       MENU_Activate();
       menuactive=1;
       drawmenu=0;
       GetKeys=0;
    elseif MenuSelection == menu_sections.new then
       
       --LEVEL_Deactivate();
       
       if changed==0 then
         
         GLOBAL_SetVar("Editor_LoadLevel","");
         GLOBAL_SetVar("Editor_Filename","");
         GetKeys=0;
         MENU_Load("editorstart");
       else
         
         GLOBAL_SetVar("Editor_DesiredMenu","editornew");
         drawmenu=0;
         GetKeys=0;
         GLOBAL_SetVar("EditorTool","SaveChanges");
         MENU_Load("editorsavechanges");
       end;
       
       MENU_Activate();
       menuactive=1;
       drawmenu=0;  
       GetKeys=0;
    elseif MenuSelection == menu_sections.settings then
       
      -- CheckStartPos(); 
      --  if GLOBAL_GetVar("Editor_StartpointValid")==0 then
      --      LEVEL_Deactivate();
      --      MENU_Load("editornostartpos");
      --      MENU_Activate();
      --      return;
      --   end;
       --LEVEL_Deactivate();
       
       
       MENU_Load("editorsettings");
       SaveToFile("_selection"); -- For changing themes.. Reloading 
       
       MENU_Activate();
       --LEVEL_Deactivate();
       GLOBAL_SetVar("EditorTool","Settings");
       GLOBAL_SetVar("EditorToolCommand","Return");
       menuactive=1;
       drawmenu=0;
       GetKeys=0;
  --[[  elseif MenuSelection==5 then
        SaveToFile("_selection");
        GLOBAL_SetVar("EditorMode",2);
        GLOBAL_SetVar("StartUserLevel","_selection");
        LEVEL_Deactivate();
        MENU_Activate();
        MENU_Activate();
        MENU_Load("startgame"); ]]
    elseif MenuSelection == menu_sections.overview or MenuSelection == menu_sections.test then
       --Testing
        CheckStartPos();
        if GLOBAL_GetVar("Editor_StartpointValid")==0 then
            --LEVEL_Deactivate();
            MENU_Load("editornostartpos");
            MENU_Activate();
            GLOBAL_SetVar("EditorTool","Editing");
            GLOBAL_SetVar("EditorToolCommand","NoSave");
            drawmenu=0;
            GetKeys=0;
            return;
         end;

       GLOBAL_SetVar("Editor_Changed",changed);
        
       SaveToFile("_selection");
       if MenuSelection == menu_sections.test then 
         GLOBAL_SetVar("EditorMode",2); -- 2 Means testing
       else
         GLOBAL_SetVar("EditorMode",3); -- Overview
       end;
       GLOBAL_SetVar("StartUserLevel","_selection");
       LEVEL_Deactivate();
       GLOBAL_SetVar("TotalScore",0);
       GLOBAL_SetVar("CurrentLevelNum",0);
       GLOBAL_SetVar("InsideFinal",0);
       GLOBAL_SetVar("TwoPlayers",0);
       MENU_Activate();
       
       MENU_Load("startgame");
       GetKeys=0;
    elseif MenuSelection == menu_sections.quit then
       
       if changed==1 then  
         menuactive=1;
         drawmenu=0;
         GLOBAL_SetVar("Editor_DesiredMenu","main");
         GLOBAL_SetVar("EditorTool","SaveChanges");
         MENU_Load("editorsavechanges");
         GetKeys=0;
       else 
         LEVEL_Deactivate();
         MENU_Load("main");
       end;
       
       --LEVEL_Deactivate();
       MENU_Activate();
       
	elseif MenuSelection == menu_sections.manual then
		open_url(manual_url)
     end;
   end;

 end;
end;


function RenderMenuString(i,text,ypos)
 if MenuSelection == i then
   MATERIAL_SetColor(COLOR_New(0.95,0.95,0.0,1));
   FONT_SetSize(0.04);
 else
   MATERIAL_SetColor(COLOR_New(0.5,0.5,0.5,1));
   FONT_SetSize(0.03);
   
 end;
   FONT_Goto(0,ypos+0.1);
   FONT_TextOut(text);
 end;



function ShowPauseHUD()

if drawmenu~=1 then
 return;
end;
--return;
 --print("PAUSE HUD");
--return; 
-- FONT_Begin();
 --FONT_Load(TRANS_Str("font"));
 FONT_Load(TRANS_Str("font"));
FONT_Begin();
 

 MATRIX_Push();
 TEXDEF_Render(darkbg,0);
 MATRIX_Pop();

 --FONT_End();

 
 FONT_Load(TRANS_Str("font"));
 FONT_Begin();
 
 --MATERIAL_SetDiffuse(COLOR_New(1,1,1,1));
 MATERIAL_SetColor(COLOR_New(0.75,0.75,0.75,1));
 --MATERIAL_SetSpecular(COLOR_New(0,0,0,0));
 FONT_SetSize(0.05);
 FONT_SetAlign("center","center");
 FONT_Goto(0,0.25);
 FONT_TextOut(TRANS_Str("editormenu:title"));
 RenderMenuString(menu_sections.continue, TRANS_Str("editormenu:continue"),0.0);
 RenderMenuString(menu_sections.settings, TRANS_Str("editormenu:levelsettings"),-0.05);
 RenderMenuString(menu_sections.new, TRANS_Str("editormenu:new"),-0.1);
RenderMenuString(menu_sections.load, TRANS_Str("editormenu:load"),-0.15);
RenderMenuString(menu_sections.save, TRANS_Str("editormenu:save"),-0.2);
RenderMenuString(menu_sections.manual, TRANS_Str("editormenu:manual"),-0.25);
RenderMenuString(menu_sections.overview, TRANS_Str("editormenu:overview"),-0.3);
RenderMenuString(menu_sections.test, TRANS_Str("editormenu:test"),-0.35);
RenderMenuString(menu_sections.quit, TRANS_Str("editormenu:quit"),-0.4);
 FONT_End();
end;


function AddBall(typ,sbp,ss,sr)
  local act=ACTOR_New(typ);
  local sb=BLOCK_AtPos(sbp);
  local startside=sb*6+ss;
  ACTOR_SetStart(act,startside,sr);
end;

function InitLevel()
 LEVEL_SetCollisionChecksActive(0);
 print("Level-Data loaded, loading the rest");
 
 GLOBAL_SetVar("ActivePlayer",-1);
 GLOBAL_SetVar("Editor_SelectedBlock",-1);
 GLOBAL_SetVar("Editor_SelectedSide",selside);
 GLOBAL_SetVar("EditorTool","Editing");
 
if InitActors~=nil then
 InitActors();
else
 AddBall(BallType,startblockpos,startside,startrotation); --old version
end;


 GLOBAL_SetVar("ThemeOverride","");

 LEVEL_AddBlock(SelBlockX/(2*GLOBAL_GetScale()),SelBlockY/(2*GLOBAL_GetScale()),SelBlockZ/(2*GLOBAL_GetScale()),"_selection");
 selectblock=LEVEL_LastBlock();


 CAM_Identity();
 CAM_Attach(-1);
 
 CAM_SetPos(VECTOR_New(0,0,5*GLOBAL_GetScale()));
 CAM_Identity();
  CAM_SetPos(VECTOR_New(0,0,5*GLOBAL_GetScale()));

 if CamBasis>=0 then --Retrieved a saved Editor-Cam-Pos
  CAM_FromBasis(CamBasis);
 end;

local cdir=CAM_GetDir();
  yrot=math.sqrt(cdir.x*cdir.x+cdir.z*cdir.z);
  if yrot<0.00001 then
    if cdir.y>0 then 
      yrot=-PI_HALBE;
    else
      yrot=PI_HALBE;
    end;
  else
    yrot=-math.atan(cdir.y/yrot);
  end;


 if startside>=0 then
   startblock=BLOCK_AtPos(startblockpos);
   startside=startblock*6+startside;
   CheckStartPos();
 end;


 FONT_Load(TRANS_Str("font"));
 LEVEL_SetTimeScale(0);

 crosshair=TEXDEF_Load("crosshair");
 startmarker=MDLDEF_Load("startmarker");
 --When we return from testing
 changed=GLOBAL_GetVar("Editor_Changed");
 GLOBAL_SetVar("Editor_Changed",0);

 GLOBAL_SetVar("EditorBall",BallType);
 darkbg=TEXDEF_Load("darkbg");

 --print(GLOBAL_GetVar("LevelMusic"));
 if GLOBAL_GetVar("MusicTrack")~=GLOBAL_GetVar("LevelMusic") then
     GLOBAL_SetVar("MusicTrack",GLOBAL_GetVar("LevelMusic"));
     local mus=SOUND_LoadMusic(GLOBAL_GetVar("MusicTrack"));
     SOUND_PlayMusic(mus);
 end;
end;

function DrawHUD()
 LIGHT_Disable();
 MATERIAL_SetColor(COLOR_New(1,1,1,1));
 
 if InScene=="pause" then
   ShowPauseHUD();
   return;
 end;

if menuactive==1 then
  return;
 end;


  FONT_Begin();
FONT_Load(TRANS_Str("font"));

MATRIX_Push();
 --MATRIX_AxisRotate(VECTOR_New(1,0,0),270);
 --MATRIX_Translate(VECTOR_New(0,0,-10));
MATRIX_ScaleUniform(0.03);
 TEXDEF_Render(crosshair,0);
 MATRIX_Pop();



FONT_Begin();
  FONT_Load(TRANS_Str("font"));


-- MATERIAL_SetDiffuse(COLOR_New(0.2,1,0.2,1));
 MATERIAL_SetColor(COLOR_New(0.75,0.75,0.75,1));
-- MATERIAL_SetSpecular(COLOR_New(0,0,0,0));
 FONT_SetSize(0.02);
 FONT_SetAlign("left","bottom");
 FONT_Goto(-0.45,-0.45);
FONT_TextOut(TRANS_Str("editor:caption:blocktype")..": "..TRANS_StrD("block:type:"..blocktype,blocktype)); 

if selside>=0 then
 FONT_Goto(-0.45,-0.475);
 FONT_TextOut(TRANS_Str("editor:caption:selectedsideid")..": "..selside); 
end;

if infotime>0 then
  MATERIAL_SetColor(COLOR_New(0.1,0.85,0.1,1));
  FONT_Goto(-0.45,-0.5);
  FONT_TextOut(infostring); 
  infotime=infotime-GLOBAL_GetElapsed();
end;
--Draw the help

if showhelp==1 then
  MATERIAL_SetColor(COLOR_New(0.95,0.95,0.25,1));
  FONT_SetSize(0.02);
  FONT_SetAlign("left","top");
  FONT_Goto(-0.48,0.48);
  FONT_TextOut(TRANS_Str("editor:caption:helpfunc"));
  FONT_SetAlign("right","top");
  FONT_Goto(0.48,0.48);
  FONT_TextOut(TRANS_Str("editor:caption:helpkeys"));
else 
  MATERIAL_SetColor(COLOR_New(0.95,0.95,0.25,1));
  FONT_SetSize(0.02);
  FONT_SetAlign("left","top");
  FONT_Goto(-0.48,0.48);
  FONT_TextOut(TRANS_Str("editor:caption:f1forhelp"));
end;

 FONT_End();
 
end;
