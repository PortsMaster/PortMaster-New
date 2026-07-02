texture="";
ballmodel="ball";
model=-1;
diffusemap=-1;
ClampMode=0;

function Precache()
  model=MODEL_LoadOBJ(ballmodel);
    diffusemap=TEXTURE_Load(texture);
  if ClampMode~=0 then    TEXTURE_Activate(diffusemap,0); TEXTURE_SetClamp(ClampMode); TEXTURE_Activate(-1,0); TEXTURE_SetClamp(0); end;

  MDLDEF_CreateRenderList(0);
end; 



function Render(defindex)
  TEXTURE_Activate(diffusemap,0);
  MATERIAL_SetAmbient(COLOR_New(0.05,0.05,0.05,1.0));
  MATERIAL_SetDiffuse(COLOR_New(0.45,0.45,0.45,1.0));
  MATERIAL_SetSpecular(COLOR_New(0.45,0.45,0.45,1.0));
  MODEL_Render(defindex,model);
  
end;

function RenderGroup(group)
    MODEL_DrawGroup(model,group);
end;


