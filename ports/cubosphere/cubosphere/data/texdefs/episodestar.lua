diffusemap=-1;
border=-1;
empty=-1;

ambient={r=1.0, g=1.0 , b=1.0, a=0.1};
diffuse={r=0.0, g=0.0 , b=0.0, a=0.1};
--emissive={r=0.0, g=0.0, b=0.0, a=0.0};
hispecular={r=0.0, g=0.0, b=0.0, a=0.0}; 

   

function Precache()
  diffusemap=TEXTURE_Load("episodestar");
  border=TEXTURE_Load("episodestar_border");
  empty=TEXTURE_Load("episodestar_empty");

end;


--All Matrix operations has to be done prior to this
function Render(side)
local emptystar=GLOBAL_GetVar("RenderColor");
   MATERIAL_SetAmbient(ambient);
   MATERIAL_SetDiffuse(diffuse);
   MATERIAL_SetSpecular(hispecular);
   --MATERIAL_SetEmissive(emissive);
  -- MATERIAL_SetSpecularPower(0.0);

  
   --BLEND_Deactivate();
   BLEND_Activate();
   --BLEND_Function(774,0);

if emptystar==0 then
 BLEND_Function(774,0);

   TEXTURE_Activate(empty,0);
    TEXDEF_Render2d();
  TEXDEF_Render2d();

   BLEND_Function(1,1);
   TEXTURE_Activate(diffusemap,0);
    TEXDEF_Render2d();
   TEXDEF_Render2d();TEXDEF_Render2d();
 BLEND_Function(774,0);
   TEXTURE_Activate(border,0);
    TEXDEF_Render2d();
else 
 BLEND_Function(774,0);

   TEXTURE_Activate(empty,0);
    TEXDEF_Render2d();

   TEXTURE_Activate(border,0);
    TEXDEF_Render2d();
end;



   --Reset to SRC_Alpha. 1-SRC_alpha
   BLEND_Function(770,771);
   BLEND_Deactivate();

  
end
