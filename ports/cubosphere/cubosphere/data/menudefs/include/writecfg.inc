


confdir="/user";

print("writing configuration to file ("..confdir.."/config.cdef)");

cfg=CONFIG_Open(confdir.."/config.cdef");
if cfg~=0 then
 CONFIG_Write(cfg,"ShadersActive");
   CONFIG_Write(cfg,"TextureSize");
   CONFIG_Write(cfg,"ScreenWidth");
   CONFIG_Write(cfg,"ScreenHeight");
   CONFIG_Write(cfg,"HardwareActive");
   CONFIG_Write(cfg,"FullScreenActive");
   CONFIG_Write(cfg,"ShowFPS");
   CONFIG_Write(cfg,"SoundVolume");
   CONFIG_Write(cfg,"MusicVolume");

   CONFIG_Write(cfg,"Key_Forward");
   CONFIG_Write(cfg,"Key_Left");
   CONFIG_Write(cfg,"Key_Right");
   CONFIG_Write(cfg,"Key_Jump");
   CONFIG_Write(cfg,"Key_Special");
   CONFIG_Write(cfg,"Key_LookUp");
   CONFIG_Write(cfg,"Key_LookDown");

   CONFIG_Write(cfg,"Key_Forward_p2");
   CONFIG_Write(cfg,"Key_Left_p2");
   CONFIG_Write(cfg,"Key_Right_p2");
   CONFIG_Write(cfg,"Key_Jump_p2");
   CONFIG_Write(cfg,"Key_Special_p2");
   CONFIG_Write(cfg,"Key_LookUp_p2");
   CONFIG_Write(cfg,"Key_LookDown_p2");

   CONFIG_Write(cfg,"Joy_Forward");
   CONFIG_Write(cfg,"Joy_Backward");
   CONFIG_Write(cfg,"Joy_Left");
   CONFIG_Write(cfg,"Joy_Right");
   CONFIG_Write(cfg,"Joy_Jump");
   CONFIG_Write(cfg,"Joy_Cancel");
   CONFIG_Write(cfg,"Joy_Special");
   CONFIG_Write(cfg,"Joy_LookUp");
   CONFIG_Write(cfg,"Joy_LookDown");

   CONFIG_Write(cfg,"Joy_Forward_p2");
   CONFIG_Write(cfg,"Joy_Backward_p2");
   CONFIG_Write(cfg,"Joy_Left_p2");
   CONFIG_Write(cfg,"Joy_Right_p2");
   CONFIG_Write(cfg,"Joy_Jump_p2");
   CONFIG_Write(cfg,"Joy_Cancel_p2");
   CONFIG_Write(cfg,"Joy_Special_p2");
   CONFIG_Write(cfg,"Joy_LookUp_p2");
   CONFIG_Write(cfg,"Joy_LookDown_p2");


   CONFIG_Write(cfg,"Language");
   CONFIG_Write(cfg,"ViewAutoReset");
   CONFIG_Write(cfg,"ViewAutoReset_p2");

   CONFIG_Write(cfg,"HighQualityModels");
   CONFIG_Write(cfg,"UseParticles");
   CONFIG_Write(cfg,"FSAA");
   --CONFIG_Write(cfg,"VSync");


   CONFIG_Write(cfg,"FinalUnlocked");
   CONFIG_Write(cfg,"FlushOrFinishBeforeSwap");

   CONFIG_Close(cfg);
else
  print("Config-File could not be written!");
end;
