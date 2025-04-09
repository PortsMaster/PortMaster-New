//script for individual super fireball
void main( void )
{
        int &mcrap;
        int &scrap;
        int &crapx;
        int &crapy;
       int &junk;

}

void damage( void )
{
        playsound(18, 8000,0,0,0);
        
        &crapx = sp_x(&current_sprite, -1);
        &crapy = sp_y(&current_sprite, -1);

        if (&missile_target == 0)
        {
        kill_shadow(&current_sprite);
        sp_active(&current_sprite, 0);
        }

        if (sp_brain(&missile_target, -1) == 0)
        {
        kill_shadow(&current_sprite);
        sp_active(&current_sprite, 0);
        }
        if (sp_brain(&missile_target, -1) == 6)
        {
        kill_shadow(&current_sprite);
        sp_active(&current_sprite, 0);
        }


        &scrap = create_sprite(&crapx , &crapy, 0 , 167, 1);
        sp_seq(&scrap, 167);
        sp_pseq(&scrap, 167);
        sp_frame(&scrap, 1);
        sp_brain(&scrap, 7);
        sp_nohit(&scrap, 1);  

        &mcrap = sp_y(&scrap, -1);
        &mcrap -= 35;
        sp_y(&scrap, &mcrap);

 &mcrap = sp_pseq(&missile_target, -1);
 &scrap = sp_pframe(&missile_target, -1);

  if (&mcrap == 32)
  {

   if (&scrap == 1)
   {
   //they hit a tree, lets burn the thing
  int &hold = sp_editor_num(&missile_target);
   sp_hard(&missile_target, 1);
   draw_hard_sprite(&missile_target);

  &junk = is_script_attached(&missile_target);
  if (&junk > 0)
  {
 //Script is attached to this tree!  Let's run it's die script
  run_script_by_number(&junk, "DIE");
   return;
  }



  if (&hold != 0)
    {
     //this was placed by the editor, lets make the tree stay burned
     editor_type(&hold, 4); 
     editor_seq(&hold, 20);
     editor_frame(&hold, 29);
     //type means show this seq/frame combo as background in the future
    }

    sp_pseq(&missile_target, 20);
    sp_pframe(&missile_target, 29);
    sp_hard(&missile_target, 0);
    draw_hard_sprite(&missile_target);
    sp_seq(&missile_target, 20);
    playsound(6, 10000,0,&missile_target,0);
  
   }
  }

}
