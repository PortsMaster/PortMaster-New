//script for barrel with random medium thing in it

void main( void)
{
preload_seq(173);
preload_seq(421);

}

void hit ( void )
 {
  //play noise
  playsound(37, 22050, 0,0,0);
  
  int &hold = sp_editor_num(&current_sprite);

  if (&hold != 0)
    {
     //this was placed by the editor, lets make the barrel stay flat
     editor_type(&hold, 3); 
     editor_seq(&hold, 173);
     editor_frame(&hold, 6);
     //type means show this seq/frame combo as background in the future
    }
  sp_seq(&current_sprite, 173);
  sp_brain(&current_sprite, 5);
  sp_notouch(&current_sprite, 1);
  sp_nohit(&current_sprite, 1);
  &save_x = sp_x(&current_sprite, -1);
  &save_y = sp_y(&current_sprite, -1);
  external("emake", "medium");
  sp_hard(&current_sprite, 1);
  //sprite ain't hard no more!  Let's redraw the hard map, although it's
  //slow...
  draw_hard_sprite(&current_sprite);
  kill_this_task();
 }
