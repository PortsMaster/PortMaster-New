diffusemap=-1;

ambient={r=1.0, g=1.0 , b=1.0, a=1.0};
diffuse={r=0.0, g=0.0 , b=0.0, a=1.0};
--emissive={r=0.0, g=0.0, b=0.0, a=0.0};
hispecular={r=0.0, g=0.0, b=0.0, a=0.0}; 

   

function Precache()
  diffusemap=TEXTURE_Load("nopreview");
end;


--All Matrix operations has to be done prior to this
function Render(side)

 


   BLEND_Deactivate();
   
 

   TEXTURE_Activate(diffusemap,0);


   --BLEND_Activate();
   --BLEND_Function(774,0);
   -- So the sprite plane has to be setup prior
    TEXDEF_Render2d();
   --Reset to SRC_Alpha. 1-SRC_alpha
   --BLEND_Function(770,771);
   --BLEND_Deactivate();

 
end
