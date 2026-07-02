logotxt=-1;
cuboheadline=-1;

MenuXOffs=0;
MenuYOffs=0;

EntrySize=0.03;
SelectedSize=0.04;

local doscroll=0;

local scrollarrow=TEXDEF_Load("scrollarrow");

Entries={}
Hints={};
NumEntries=0;
logoactive=1; -- Set it to 0 for overmenus

--Use for Left Right Arrow selections
useleftright=0;

TimeTillFirstSelect=0.3;
TimeTillNextSelect=0.12;

UpTime=0;
DownTime=0;
LeftTime=0;
RightTime=0;

Selected=0;


  --Select the previous selected
  if GLOBAL_VarDefined("MENUSELECTION_"..menuname)>0 then
   Selected=GLOBAL_GetVar("MENUSELECTION_"..menuname);
   
   --print("MENUSELECTION_"..menuname.." = "..Selected);
  end;


logotxt=TEXDEF_Load("logo");
cuboheadline=TEXDEF_Load("cuboheadline");

snd_nav=SOUND_Load("menunav");
snd_sel=SOUND_Load("menusel");

function ResetStoredSelection()
 GLOBAL_SetVar("MENUSELECTION_"..menuname,0);
end;


function RenderCuboHeadLine()
 TEXDEF_Render(cuboheadline,0);
end;

function StartMenu()
       SOUND_SetPostEffect("",0,0,0);
     if GLOBAL_GetVar("ShadersActive")>0 then
           SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;

 MATERIAL_SetColor(COLOR_New(1,1,1,1));
 FONT_Load(TRANS_Str("font"));
 FONT_Begin(); 
 LIGHT_Disable();
 if (logoactive==1) then
 MATRIX_Push();
 TEXDEF_Render(logotxt,0);
 RenderCuboHeadLine();
 MATRIX_Pop();
 end;

 FONT_Load(TRANS_Str("font"));
 FONT_Begin(); 

end; 

function Headline(Menuname)
 FONT_SetAlign("center","center");
 FONT_Goto(0,0.25);
 FONT_SetSize(0.05);
 MATERIAL_SetColor(COLOR_New(0.9,0.65,0.05,1));
 FONT_TextOut(Menuname);
end;

local top=0.2;
local cutupper=0;
local cutlower=0;

function RenderArrows()
 if cutupper==0 and cutlower==0 then
   return;
 end;

if cutlower==1 then
 MATRIX_Push();
 MATRIX_Translate(VECTOR_New(MenuXOffs,-0.43,1));
 MATRIX_Scale(VECTOR_New(0.07,0.02,1));
 TEXDEF_Render(scrollarrow,0);
 MATRIX_Pop();
end;

if cutupper==1 then
 MATRIX_Push();
 MATRIX_AxisRotate(VECTOR_New(0,0,1),180);
 MATRIX_Translate(VECTOR_New(-MenuXOffs,-0.15,1));
 MATRIX_Scale(VECTOR_New(0.07,0.02,1));
 TEXDEF_Render(scrollarrow,0);
 MATRIX_Pop();
end;

 FONT_Load(TRANS_Str("font"));
 FONT_Begin(); 

end;

function ScrollSizeMulti(of)
  if of>=0.1 then 
    cutupper=1;
    return 0;
  elseif of<=-0.4 then
    cutlower=1;
    return 0;
  else
    return 1;
  end;  
end;


function RenderMenu()
--print(table.getn(Entries));
 if table.getn(Entries)*SelectedSize*5.0/4.0>0.45+MenuYOffs then
   doscroll=1;
 else
   doscroll=0;
 end;

 local scrollcenter=doscroll*Selected*SelectedSize*5.0/4.0;

 local pos=0.0;

 if doscroll==1 then
  pos=scrollcenter-0.2;
  if Selected*SelectedSize*5.0/4.0<=0.2 then 
     pos=0;
  elseif (table.getn(Entries)-Selected)*SelectedSize*5.0/4.0<=0.2 then 
     pos=(table.getn(Entries))*SelectedSize*5.0/4.0-0.4;
  end;
 end;

 cutupper=0;
 cutlower=0;

 NumEntries=0;
 for i,v in pairs(Entries) do
            local Multipl=1;
            if doscroll==1 then 
                Multipl=ScrollSizeMulti(pos);
            end;
            if Multipl>0 then
            if Selected==i-1 then
              FONT_SetSize(SelectedSize*Multipl);
              MATERIAL_SetColor(COLOR_New(0.95,0.95,0.0,1));
            else 
              FONT_SetSize(EntrySize*Multipl);
              MATERIAL_SetColor(COLOR_New(0.5,0.5,0.5,1));
              
            end;

            FONT_Goto(MenuXOffs,pos+MenuYOffs);
            FONT_TextOut(Entries[i]);
            end;
            pos=pos-SelectedSize*5.0/4.0;
            NumEntries=NumEntries+1;
        end

 if NumEntries==0 then
  return;
 end;
 FONT_SetSize(0.02);
 MATERIAL_SetColor(COLOR_New(0.5,0.95,0.5,1));
 FONT_SetAlign("center","bottom");
 FONT_Goto(0,-0.5);
 FONT_TextOut(Hints[Selected+1]);
 if doscroll==1 then
   RenderArrows();
 end;
end;

function EndMenu()
  FONT_End();
   MATERIAL_SetColor(COLOR_New(1,1,1,1));
  LIGHT_Enable();
end;


function MakeJoystickString(stick,button,dir)
	local joystick = require "Joystick"
	local joy = joystick.Get(stick) 
	return (joy:GetGUID()..","..dir..","..button);
end;


function OnJoyButton(stick,button,dir,val,toggle)
  local bn=MakeJoystickString(stick,button,dir);
  -- print(bn.." -> "..val.." / "..toggle);
  local key;
for ip,pl in pairs({"","_p2"}) do
  if key then break; end;
  if (bn==GLOBAL_GetVar("Joy_Forward"..pl)) then
      key=KEYB_GetKeyConst("Up");
  elseif (bn==GLOBAL_GetVar("Joy_Backward"..pl)) then
      key=KEYB_GetKeyConst("Down");
  elseif (bn==GLOBAL_GetVar("Joy_Left"..pl)) then
      key=KEYB_GetKeyConst("Left");
  elseif (bn==GLOBAL_GetVar("Joy_Right"..pl)) then
      key=KEYB_GetKeyConst("Right");
  elseif (bn==GLOBAL_GetVar("Joy_Jump"..pl)) then
      key=KEYB_GetKeyConst("Return");
  elseif (bn==GLOBAL_GetVar("Joy_Cancel"..pl)) then
      key=KEYB_GetKeyConst("Escape");
  end;
end;

  if key==nil then
   if SpecialJoyHandler then
    SpecialJoyHandler(stick,button,dir,val,toggle);
   end;
    return;
  end;
    OnKeyPressed(key,val,toggle);
 
end;

function OnKeyPressed(key,down,toggle)
  keyn=KEYB_GetKeyName(key);
  
  if down==0 then
   UpTime=0;
   DownTime=0;
   LeftTime=0;
   RightTime=0;
   return;
  end;

 
  if toggle==0 then
     if keyn=="Up" then
       UpTime=UpTime+GLOBAL_GetElapsed();
       if UpTime>TimeTillFirstSelect then
         toggle=1;
         UpTime=TimeTillFirstSelect-TimeTillNextSelect;
       end;
     elseif keyn=="Down" then
       DownTime=DownTime+GLOBAL_GetElapsed();
       if DownTime>TimeTillFirstSelect then
         toggle=1;
         DownTime=TimeTillFirstSelect-TimeTillNextSelect;
       end;
     elseif keyn=="Left" then
       LeftTime=LeftTime+GLOBAL_GetElapsed();
       if LeftTime>TimeTillFirstSelect then
         toggle=1;
         LeftTime=TimeTillFirstSelect-TimeTillNextSelect;
       end;
     elseif keyn=="Right" then
       RightTime=RightTime+GLOBAL_GetElapsed();
       if RightTime>TimeTillFirstSelect then
         toggle=1;
         RightTime=TimeTillFirstSelect-TimeTillNextSelect;
       end;
     end;
  end;

  if toggle==0 then 
    return;
  end;

  --print(KEYB_GetKeyName(key).."___");

  if keyn=="Up" then
    SOUND_Play(snd_nav,-1);
    Selected=Selected-1;
    if (Selected<0) then 
       Selected=NumEntries-1;
    end;
    if Entries[Selected+1]=="" then
      Selected=Selected-1;
    end;
    if (Selected<0) then 
       Selected=NumEntries-1;
    end;
      if OnNavigate then 
         OnNavigate(-1);
    end;
  
  elseif keyn=="Down" then
   SOUND_Play(snd_nav,-1); 
   Selected=Selected+1;
    if (Selected>=NumEntries) then 
       Selected=0;
    end;
    if Entries[Selected+1]=="" then
      Selected=Selected+1;
    end;
    if (Selected>=NumEntries) then 
       Selected=0;
    end;
      if OnNavigate then 
         OnNavigate(1);
    end;
  
  elseif (keyn=="Return") or (keyn=="Space") then
    GLOBAL_SetVar("MENUSELECTION_"..menuname,Selected);
    SOUND_Play(snd_sel,-1);
    HandleSelection(Selected);
  elseif (keyn=="Escape") then
    SOUND_Play(snd_sel,-1);
    HandleSelection(-1);
  elseif (keyn=="Left") and (useleftright==1) then
    HandleLeftRight("left",Selected);
  elseif (keyn=="Right") and (useleftright==1) then
    HandleLeftRight("right",Selected);
  elseif SpecialKeyHandler then
    SpecialKeyHandler(key,down,toggle);
  end;
end;
