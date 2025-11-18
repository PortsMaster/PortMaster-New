--This is the Boot-Script of Cubo
--Feel free to play around with the scripts...




PreferZip=1;
--Set to 0, if you are interested in developing
--You can extract files from the data-zip and modify it. If you've set PreferZip to 0, Cubo will prefer the extracted (and possibly modified) files

--VERSION
VERSION=0.3;
USING("FILESYS");


logmode=0;
desiredmod="";

function PreParseCmdLine()
  --print("COMMANDLINE");
  for i=0,ARGS_Count()-1,1 do
   local key=ARGS_Key(i);
   local var=ARGS_Val(i);

   if key=="log" then
     logmode=1;
   elseif key=="mod" then
     desiredmod=var;
   end;

  end;
  return 0;
end;



  GLOBAL_SetVar("CuboVersion",VERSION);
  PreParseCmdLine();
  LOG_Mode(logmode);

  print("Cubosphere - Beta 0.3 - starting");
  print("###############################################");
  print(" Copyright (C) 2009-2013 by the Cubosphere Team \n ");
  print(" This program comes with ABSOLUTELY NO WARRANTY; for details see readme.");
  print(" This is free software, and you are welcome to redistribute it under certain\n conditions; see readme for details. \n");
  print("###############################################");




function MountAllZips()
 local numf=FILESYS_StartListDirectory("/",true,false,false,true,".*data.*\\.zip"); --List root dir, list files, no dirs, not recursive, get the fullpath, filter *.zip
 for i=0,numf-1,1 do
   local zipfile=FILESYS_GetListDirectoryEntry(i);
   if FILESYS_MountZip(zipfile,"/")~=0 then
     print("Mounted ZIP: "..zipfile);
   end;
 end;
end;


--Mounting-Code:
--When executing this script, there is already the DATA-Dir mounted to the stack
if PreferZip==1 then
  print("Mounted HDD dir: "..DIR_GetDataDir());
  MountAllZips();
else
  MountAllZips();
  FILESYS_PopBottom(); --Remove the data-dir at the bottom..
  FILESYS_MountHDDDir(DIR_GetDataDir(),"/");
  print("Mounted HDD dir: "..DIR_GetDataDir());
end;


FILESYS_MountWriteableHDDDir(DIR_GetProfileDir(),"/user");
 print("Mounted writeable HDD dir: "..DIR_GetProfileDir().."  @  ".."/user");



if desiredmod~="" then
 if FILESYS_FileExists("/mods/"..desiredmod.."/modboot.lua")==0 then
   print("Cannot boot mod "..desiredmod);
   GLOBAL_Quit();
 else
  print("Starting Modification : "..desiredmod);
  MOD_SetName(desiredmod);
  INCLUDEABSOLUTE("/mods/"..desiredmod.."/modboot.lua");
  MENU_Load("init");
 end;
else
 MENU_Load("init");
end;


