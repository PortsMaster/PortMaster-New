//secret 1 for area 4

void hit( void )
{
        int &rcrap = compare_sprite_script(&missle_source, "dam-bomn");
        if (&rcrap == 1)
  {
  //rock just got hit by a sprite with a script named dam-bomn, I'm gonna
  //guess it was the bomb.
  &save_x = sp_x(&current_sprite, -1);
  &save_y = sp_y(&current_sprite, -1);
  &save_y += 1;
  external("make", "gheart");

  //remove rocks hardness and sprite
  sp_hard(&current_sprite, 1);
  draw_hard_sprite(&current_sprite);
  sp_active(&current_sprite, 0);
  playsound(43, 22050, 0,0,0);



  //kill this item so it doesn't show up again for this player
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 1); 


  }

}
