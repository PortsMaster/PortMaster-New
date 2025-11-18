texture=-1;

function Precache()
  texture=TEXDEF_Load(texname);
end

function RenderSide(side)
  TEXDEF_Render(texture,side); 
end
