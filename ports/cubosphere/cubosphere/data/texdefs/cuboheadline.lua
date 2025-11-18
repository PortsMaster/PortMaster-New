xscal=0.9
yscal=0.2
ypos=0.4;
numletters=10;

diffusemap=-1;

ambient={r=1.0, g=1.0 , b=1.0, a=0.1};
diffuse={r=0.0, g=0.0 , b=0.0, a=0.1};
hispecular={r=0.0, g=0.0, b=0.0, a=0.0}; 

LetterTextures={};
Letters={"c","u","b","o","s","p","h","e1","r","e2"};
Modes={}


function Precache()
 for i=1,numletters,1 do
    local mode="normal";
    local warpname=string.format("warp/w%02dlfin",i);
    if SCORE_VarDefined(warpname)==1 then
      mode="coll";
    end;
    Modes[i]=mode;
 end;

 local gold=0;
 if SCORE_VarDefined("warp/w11lfin")==1 then gold=1; end;

 for i=1,numletters,1 do
   local mode=Modes[i];
   if gold==1 then mode="gold"; end;
   LetterTextures[i]=TEXTURE_Load("headline/"..Letters[i].."_"..mode);

 end;
end;


--All Matrix operations has to be done prior to this
function Render(side)

   MATERIAL_SetAmbient(ambient);
   MATERIAL_SetDiffuse(diffuse);
   MATERIAL_SetSpecular(hispecular);
 
  
 
 
   BLEND_Activate();
     BLEND_Function(770,771);




   MATRIX_Push()
   MATRIX_Translate(VECTOR_New(0,ypos,0));
   MATRIX_Scale(VECTOR_New(xscal,yscal,1));



   MATRIX_Scale(VECTOR_New(1.0/numletters,1,1));
   MATRIX_Translate(VECTOR_New(-0.5*(numletters-1),0,0));

 

   for i=1,numletters,1 do
   TEXTURE_Activate(LetterTextures[i],0);
    TEXDEF_Render2d();
     MATRIX_Translate(VECTOR_New(1,0,0));
   end;

   


   MATRIX_Pop();



   BLEND_Deactivate();  
 
end
