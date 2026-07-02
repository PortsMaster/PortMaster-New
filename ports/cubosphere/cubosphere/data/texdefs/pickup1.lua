diffusemap=-1;

ambient={r=1.0, g=1.0 , b=1.0, a=1.0};
diffuse={r=0.0, g=0.0 , b=0.0, a=1.0};
--emissive={r=0.0, g=0.0, b=0.0, a=0.0};
hispecular={r=0.0, g=0.0, b=0.0, a=0.0}; 

   

function Precache()
  diffusemap=TEXTURE_Load("pickup1");
end;


--All Matrix operations has to be done prior to this
function Render(side)
 LIGHT_Disable();
   MATERIAL_SetAmbient(ambient);
   MATERIAL_SetDiffuse(diffuse);
   MATERIAL_SetSpecular(hispecular);
   --MATERIAL_SetEmissive(emissive);
   -- MATERIAL_SetSpecularPower(0.0);
   TEXTURE_Activate(diffusemap,0);
--   BLEND_Activate();
   BLEND_Function(1,1);
   -- So the sprite plane has to be setup prior
    TEXDEF_RenderDirect();
   --Reset to SRC_Alpha. 1-SRC_alpha
 --  BLEND_Function(770,771);
   BLEND_Deactivate();
 LIGHT_Enable();
end
