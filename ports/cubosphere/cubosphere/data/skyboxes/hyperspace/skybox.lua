--Global variable to save the mdldef of the skybox
sky_mdl=-1;

--This function is called once after loading this script 
function Precache()
  --Open the mdldef and reference it by <sky_mdl>
  sky_mdl=MDLDEF_Load("warp");
end

tx=0.4;

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

--In each frame, this is function is called, when the game is rendering
--The rendering of the skybox is always the first thing to render
function Render()

--Get the camera position, as we have to center the skybox around the camera
 local campos=CAM_GetPos();

--DEPTH_Mask(0); --We may not deactivate Z-Checking -> Errors in the appearance of the warp tunnel 

--Disable Lighting calculation
 LIGHT_Disable();

--Save the current ModelView-Matrix (i.e. the numbers describing the position, rotation and extends of the camera, in this case)
 MATRIX_Push();

--Shift the skybox to be centered around the camera position
 MATRIX_Translate(campos);

--Switching to Texture Matrix. All Matrix commands are influencing the 2d-Texture Coordinates [u,v] , not the 3d-World Coordinates [x,y,z] 
TEXTURE_MatrixMode(1);

--Save the Texture Matrix
MATRIX_Push();

--Will cause that the texture is drawn 6x6 times onto the warp tunnel
MATRIX_ScaleUniform(1);

--Shift the texture to create the effect of a moving tunnel
MATRIX_Translate(VECTOR_New(math.sin(0.15*GLOBAL_GetTime()),tx,0))
tx=tx+GLOBAL_GetElapsed()*0.03;
--Render
 MDLDEF_Render(sky_mdl);
 
--Restore texture matrix
MATRIX_Pop();

--Set MATRIX commands to apply on World coordinates again
TEXTURE_MatrixMode(0);

--Restore the ModelViewMatrix
 MATRIX_Pop();

--Switch on the lights again for the next objects
 LIGHT_Enable();

--Clear the Z-buffer. This assures, that the warp-tunnel always appears to be bigger then the level
 DEPTH_Clear();

 LightSetup();
end;
