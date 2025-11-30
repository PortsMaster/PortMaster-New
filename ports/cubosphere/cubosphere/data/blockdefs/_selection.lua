--Please use only in Editor MODE
border=-1;




function Precache()
  border=MDLDEF_Load("selection");
end

function MayCull(side)
 return 0;
end;


function RenderSide(side)
  if GLOBAL_GetVar("EditorMode")~=1 then
   return;
  end;

  if GLOBAL_GetVar("RenderingPrevPic")==1 then
    return;
  end;

  local dr;
  
  if ( (math.fmod(side-GLOBAL_GetVar("Editor_SelectedSide"),6)==0) and (GLOBAL_GetVar("Editor_SelectedSide")>=0)) or (GLOBAL_GetVar("Editor_SelectedBlock")>=0) then
    dr=1;
  else 
   dr=0;
  end;

  GLOBAL_SetVar("Editor_DrawRed",dr);
   

  local mp=SIDE_GetMidpoint(side);
  local up=SIDE_GetNormal(side);
  local dir=SIDE_GetTangent(side);
  local right=VECTOR_Cross(up,dir);  
  
  MATRIX_Push();
  MATRIX_MultBase(right,up,dir,mp);
  MATRIX_ScaleUniform((math.sqrt(2.5))*GLOBAL_GetScale());
  MDLDEF_Render(border);
  MATRIX_Pop();
end
