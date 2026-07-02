
---Color base names
s_colorset={"red","green","blue","yellow","cyan","orange","violet","magenta"};



--Color red values
s_R={0.3,0.0,0.0,0.4,0.0,0.8,0.2,0.6};

--Color green values
s_G={0.0,0.3,0.0,0.35,0.2,0.15,0.0,0.0};

--Color blue values
s_B={0.0,0.0,0.3,0.0,0.3,0.0,0.6,0.2};



----------------------------------------



t_colorset={}
t_colorstr="";

for i,v in pairs(s_colorset) do
 t_colorset[i]=TRANS_Str("color:"..v);
 if t_colorstr~="" then
   t_colorstr=t_colorstr..","..TRANS_Str("color:"..v);
 else
   t_colorstr=TRANS_Str("color:"..v);
 end;
 NumCuboColors=i;  
end;



function ActivateCuboColor(colind,add,bright_ambient,bright_diffuse,bright_specular)
   local r=s_R[colind+1]+add;
   local g=s_G[colind+1]+add;
   local b=s_B[colind+1]+add;

  MATERIAL_SetAmbient(COLOR_New(r*bright_ambient,g*bright_ambient,b*bright_ambient,1));
   MATERIAL_SetDiffuse(COLOR_New(r*bright_diffuse,g*bright_diffuse,b*bright_diffuse,1));
   MATERIAL_SetSpecular(COLOR_New(r*bright_specular,g*bright_specular,b*bright_specular,1));
end;

function ActivateCuboColorAlpha(colind,add,bright_ambient,bright_diffuse,bright_specular,alpha_factor)
  
   local r=s_R[colind+1]+add;
   local g=s_G[colind+1]+add;
   local b=s_B[colind+1]+add;

   MATERIAL_SetAmbient(COLOR_New(r*bright_ambient,g*bright_ambient,b*bright_ambient,alpha_factor));
   MATERIAL_SetDiffuse(COLOR_New(r*bright_diffuse,g*bright_diffuse,b*bright_diffuse,alpha_factor));
   MATERIAL_SetSpecular(COLOR_New(r*bright_specular,g*bright_specular,b*bright_specular,alpha_factor));
end;



function GetCuboColor(colind,add,bright,alpha_factor)
   local r=s_R[colind+1]*bright+add;
   local g=s_G[colind+1]*bright+add;
   local b=s_B[colind+1]*bright+add;
  return COLOR_New(r,g,b,alpha_factor);
end;










function ToggleCuboColor(color)
  for b=0,LEVEL_NumBlocks()-1,1 do

    tn=SIDE_GetType(6*b);
    if tn=="toggleblock" then
         local cc=BLOCK_GetVar(b,"Color");
         if cc==color then
           local ca=BLOCK_GetVar(b,"StartActive");
           BLOCK_SetVar(b,"StartActive",math.fmod(ca+1,2));
         end;
    end;

    for s=0,5,1 do
      local cs=b*6+s;
    
      local tn=SIDE_GetType(cs);
      if side~=cs and (tn=="teleport" or tn=="switch" or tn=="laser" or tn=="magnet") then
         local cc=SIDE_GetVar(cs,"Color");
         if cc==color then
           if tn~="magnet" then
             local ca=SIDE_GetVar(cs,"StartActive");
             SIDE_SetVar(cs,"StartActive",math.fmod(ca+1,2));
           else
             local ca=SIDE_GetVar(cs,"StartStrength");
             SIDE_SetVar(cs,"StartStrength",ca+1);
           end;
         end;
      end;
    end;
  end;
end;

