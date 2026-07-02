sky_mdl=-1;


function Precache()
  sky_mdl=MDLDEF_Load("skybox");
end


function LightSetup()
 MATRIX_Push(); 
  MATRIX_Identity();
   LIGHT_Activate(0);
   LIGHT_SetPosition(0,VECTOR_New(0,0,1));
   LIGHT_SetAmbient(0,COLOR_New(1,1,1,1));
   LIGHT_SetDiffuse(0,COLOR_New(1,1,1,1));
   LIGHT_SetSpecular(0,COLOR_New(1,1,1,1));

   LIGHT_SetPosition(1,VECTOR_New(0,1,0));
   LIGHT_SetAmbient(1,COLOR_New(1,1,1,1));
   LIGHT_SetDiffuse(1,COLOR_New(1,1,1,1));
   LIGHT_SetSpecular(1,COLOR_New(1,1,1,1));

  MATRIX_Pop();
end;

function Render()
 local campos=CAM_GetPos();
 DEPTH_Mask(0); 
 LIGHT_Disable();

 MATRIX_Push();
 MATRIX_Translate(campos);
 MATRIX_AxisRotate(VECTOR_New(0,1,0),180); --To make it fit with the old skybox orientation

--TEXTURE_MatrixMode(1);
--MATRIX_Push();
--MATRIX_ScaleUniform(1);
--MATRIX_Translate(VECTOR_New(math.sin(GLOBAL_GetTime()),0,0))

--MATRIX_ScaleUniform(100);
 MDLDEF_Render(sky_mdl);
 
--MATRIX_Pop();
--TEXTURE_MatrixMode(0);

 MATRIX_Pop();
 LIGHT_Enable();
 DEPTH_Mask(1);

 LightSetup();

end;
