--Global variable to save the mdldef of the skybox
sky_mdl=-1;


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


--This function is called once after loading this script 
function Precache()
  --Open the mdldef and reference it by <sky_mdl>
  sky_mdl=MDLDEF_Load("skybox");
end

--In each frame, this is function is called, when the game is rendering
--The rendering of the skybox is always the first thing to render
function Render()
 --Get the camera position, as we have to center the skybox around the camera
 local campos=CAM_GetPos();

 --Deactivate writing into the Z-Buffer. Needed for skyboxes, since they should look, as if they were far, far away
 DEPTH_Mask(0); 

--Disable Lighting calculation
 LIGHT_Disable();

--Save the current ModelView-Matrix (i.e. the numbers describing the position, rotation and extends of the camera, in this case)
 MATRIX_Push();

--Shift the skybox to be centered around the camera position
 MATRIX_Translate(campos);

--Rotatate the  Skybox around all three cartesian axes by some time dependent angles
  MATRIX_AxisRotate(VECTOR_New(0,1,0),0.2*120*math.sin(3+0.25*GLOBAL_GetTime()));
   
--And render the <sky_mdl>
 MDLDEF_Render(sky_mdl);
 
--Restore the above Translation and Rotation
 MATRIX_Pop();

--Switch on the lights again for the next objects
 LIGHT_Enable();

--And allow Z-Writing again. This ensures, that the following objects are shown in the correct order - i.e. near objects are always displayed in front of far objects
 DEPTH_Mask(1);

LightSetup();
end;
