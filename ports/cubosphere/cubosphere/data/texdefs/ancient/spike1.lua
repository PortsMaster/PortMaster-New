diffusemap=-1;
normalmap=-1;
glossmap=-1;
shader=-1;

ambient={r=0.35, g=0.35 , b=0.35, a=1.0};
diffuse={r=0.25, g=0.25 , b=0.25, a=1.0};
--emissive={r=0.0, g=0.0, b=0.0, a=0.0};
specular={r=0.15, g=0.15, b=0.15, a=1.0}; 
hispecular={r=1.0, g=1.0, b=1.0, a=1.0}; 

   

function Precache()
  --print("Precache TDEF");
  diffusemap=TEXTURE_Load("spiketile");
   if GLOBAL_GetVar("ShadersActive")>0 then
      normalmap=TEXTURE_Load("spiketile_nm");
  glossmap=TEXTURE_Load("spiketile_sm");

     shader=SHADER_Load("distglossbump");
  end
end;


function Render(side)
 if TEXDEF_GetLastRenderedType()=="spike1" then
   if GLOBAL_GetVar("ShadersActive")>0 then
    SHADER_SetVector3("tangent",SIDE_GetTangent(side));
   end;
   SIDE_RenderQuad(side); 
   return;
  end;



  if GLOBAL_GetVar("ShadersActive")>0 then
    MATERIAL_SetAmbient(ambient);
   MATERIAL_SetDiffuse(diffuse);
   MATERIAL_SetSpecular(hispecular);
   --MATERIAL_SetEmissive(emissive);
   -- MATERIAL_SetSpecularPower(40.0);
    SHADER_Activate(shader);
    TEXTURE_Activate(diffusemap,0);
    TEXTURE_Activate(normalmap,1);
    TEXTURE_Activate(glossmap,2);
    SHADER_SetInt("base",0);
    SHADER_SetInt("normalMap",1);
    SHADER_SetInt("glossMap",2);
    SHADER_SetVector3("tangent",SIDE_GetTangent(side));
    
    SHADER_SetFloat("mindist",GLOBAL_GetScale()*3.0);
    SHADER_SetFloat("factor",0.75);

    
    SIDE_RenderQuad(side);
    --SHADER_Deactivate();
    --TEXTURE_Deactivate(1);
    --TEXTURE_Deactivate(2);
 else 
   TEXTURE_Activate(diffusemap,0);
   MATERIAL_SetAmbient(ambient);
   MATERIAL_SetDiffuse(diffuse);
   MATERIAL_SetSpecular(specular);
   --MATERIAL_SetEmissive(emissive);
   -- MATERIAL_SetSpecularPower(50.0);
   SIDE_RenderQuad(side);
 end
end
