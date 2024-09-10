//script for individual arrow
void main( void )
{
        int &mcrap;
        int &scrap;

}

void damage( void )
{
    int &hold = sp_editor_num(&missile_target);

if (&missile_target == 0)
  {
     sp_speed(&current_sprite, 0);
     sp_brain(&current_sprite, 0);
    sp_nohit(&current_sprite, 1);
    playsound(41, 22050,0,0,0);
//    sp_script(&current_sprite, "");
    kill_this_task();
  }

  if (&hold != 0)
    {
      &scrap = sp_brain(&missile_target, -1);
      if (&scrap != 0)
      {
   //looks like we should not make the arrow stick
    kill_shadow(&current_sprite);
    sp_active(&current_sprite, 0);
    playsound(41, 22050,0,0,0);
     return;
      }
     sp_speed(&current_sprite, 0);
     sp_brain(&current_sprite, 0);
    playsound(41, 22050,0,0,0);
  //  sp_script(&current_sprite, "");
    return;
    }
    kill_shadow(&current_sprite);
   sp_active(&current_sprite, 0);
    playsound(41, 22050,0,0,0);
  //  sp_script(&current_sprite, "");

    kill_this_task();

   

}

   void hit( void )
   {
   playsound(37, 28050, 0,0,0);
   sp_active(&current_sprite, 0);
    sp_nohit(&current_sprite, 1);
   }

