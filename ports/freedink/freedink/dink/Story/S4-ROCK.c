void hit( void )
{
int &rcrap = compare_sprite_script(&missle_source, "dam-bomn");
if (&rcrap == 1)
  {
  //rock just got hit by a sprite with a script named dam-bomn, I'm gonna
  //guess it was the bomb.

  //remove rocks hardness and sprite
  sp_hard(&current_sprite, 1);
  draw_hard_map(&current_sprite);
  sp_active(&current_sprite, 0);

  //remove the cracks as well, as they would look silly now

  &rcrap = sp(16);
  sp_active(&rcrap, 0);
  &rcrap = sp(26);
  sp_active(&rcrap, 0);

  //play 'found something special' sound

  playsound(43, 22050, 0,0,0);
  &s4-duck = 1;
  }

}

  