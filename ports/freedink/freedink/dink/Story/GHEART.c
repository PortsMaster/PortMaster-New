//this script fills life up, touch_damage must be set to -1. (run script mode)

void main( )
{
        sp_seq(&current_sprite, 53);
        sp_frame(&current_sprite, 1); //so the seq will start
        sp_brain(&current_sprite, 6);
        sp_touch_damage(&current_sprite, -1);
        sp_nohit(&current_sprite, 1);

}

void touch( void )
{
&lifemax += 10;
Playsound(10,22050,0,0,0);
Playsound(22,22050,0,0,0);
//grow to this percent then die
sp_brain_parm(&current_sprite, 500);
sp_brain(&current_sprite, 12);
sp_touch_damage(&current_sprite, 0);
sp_timing(&current_sprite, 0);

  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
    {
     //this was placed by the editor, lets make it not come back
     editor_type(&hold, 1); 
     //kill food forever
    }



}

