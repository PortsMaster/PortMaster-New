diffusemap=-1;


ambient={r=0.35, g=0.35 , b=0.35, a=0.2};
diffuse={r=0.25, g=0.25 , b=0.25, a=0.2};
specular={r=0.15, g=0.15, b=0.15, a=0.3}; 
 

   



function Precache()
  diffusemap=TEXTURE_Load("warp_in_editor");
end;

function Render(side)
  if TEXDEF_GetLastRenderedType()=="warp_in_editor" then
   SIDE_RenderQuad(side); 
   return;
  end;


   TEXTURE_Activate(diffusemap,0);
   MATERIAL_SetAmbient(ambient);
   MATERIAL_SetDiffuse(diffuse);
   MATERIAL_SetSpecular(specular);
   SIDE_RenderQuad(side);

end
