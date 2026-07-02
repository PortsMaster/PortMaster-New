INCLUDEABSOLUTE("/blockdefs/include/colors.inc");

diffusemap=-1;

local factor=0.81;

diffuse={r=0.0, g=0.0 , b=0.0, a=1.0};
hispecular={r=0.0, g=0.0, b=0.0, a=0.0}; 

   

function Precache()
  diffusemap=TEXTURE_Load("lightcast");
end;

function SetInnerColor()
   local colind=GLOBAL_GetVar("RenderColor");
   local add=GLOBAL_GetVar("RenderColorAdder");

   MATERIAL_SetColor(GetCuboColor(colind,add,1.0,1.0));

end;



--All Matrix operations has to be done prior to this
function Render(side)
 LIGHT_Disable();
   SetInnerColor();
   MATERIAL_SetDiffuse(diffuse);
   MATERIAL_SetSpecular(hispecular);




   TEXTURE_Activate(diffusemap,0);
  -- BLEND_Activate();
      BLEND_Function(1,1);
   -- So the sprite plane has to be setup prior

    TEXDEF_RenderDirect();
   --Reset to SRC_Alpha. 1-SRC_alpha
 MATERIAL_SetColor(COLOR_New(1,1,1,1));
   BLEND_Function(770,771);
 --  BLEND_Deactivate();
 LIGHT_Enable();
 end
