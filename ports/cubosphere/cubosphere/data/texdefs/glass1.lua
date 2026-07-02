diffusemap=-1;

ambient={r=0.35, g=0.35 , b=0.35, a=0.2};

--emissive={r=0.0, g=0.0, b=0.0, a=0.0};
specular={r=0.15, g=0.15, b=0.15, a=0.8}; 
hispecular={r=0.6, g=0.6, b=0.6, a=0.6}; 

   

function Precache()
  diffusemap=TEXTURE_Load("glass1");
end;


function Render(side)
--   if TEXDEF_GetLastRenderedType()=="glass1" then
--   SIDE_RenderQuad(side); 
--   return;
--  end;

     if GLOBAL_GetVar("ShadersActive")>0 then
           --SHADER_Deactivate();
           TEXTURE_Activate(-1,1);
           TEXTURE_Activate(-1,2);
     end;



  MATERIAL_SetAmbient(ambient);
   MATERIAL_SetSpecular(hispecular);
   TEXTURE_Activate(diffusemap,0);
   SIDE_RenderQuad(side);


end
