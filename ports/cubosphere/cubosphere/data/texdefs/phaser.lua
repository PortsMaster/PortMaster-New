diffusemap=-1;
shader=-1;

ambient={r=0.35*1.5, g=0.35*1.5 , b=0.35*1.5, a=0.35*1.5};

--emissive={r=0.0, g=0.0, b=0.0, a=0.0};
specular={r=0.15, g=0.15, b=0.15, a=0.15}; 
hispecular={r=0.6, g=0.6, b=0.6, a=0.6}; 

   

function Precache()
  diffusemap=TEXTURE_Load("tile1");
end;




function Render(side)
  if TEXDEF_GetLastRenderedType()=="phaser" then
   
   SIDE_RenderQuad(side); 
   return;
  end;


     if GLOBAL_GetVar("ShadersActive")>0 then
           --SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;



  MATERIAL_SetAmbient(ambient);
   --MATERIAL_SetDiffuse(diffuse);
   MATERIAL_SetSpecular(hispecular);
   --MATERIAL_SetEmissive(emissive);
   -- MATERIAL_SetSpecularPower(0.0);
   TEXTURE_Activate(diffusemap,0);
   SIDE_RenderQuad(side);


end
