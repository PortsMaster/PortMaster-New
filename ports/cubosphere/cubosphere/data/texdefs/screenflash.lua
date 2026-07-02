   

function Precache()
  
end;


--All Matrix operations has to be done prior to this
function Render(side)

   BLEND_Activate();
   BLEND_Function(1,1);
 BLEND_Function(770,771);
   TEXTURE_Activate(-1,0);
   TEXDEF_Render2d();
   BLEND_Function(770,771);
   BLEND_Deactivate();

 
end
