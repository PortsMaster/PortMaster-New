//generic script for killing things so they don't come back

void main( void )
{
sp_hitpoints(&current_sprite, 1);
preload_seq(21);
preload_seq(23);
preload_seq(24);
preload_seq(26);
preload_seq(27);
preload_seq(29);

preload_seq(111);
preload_seq(113);
preload_seq(117);
preload_seq(119);

preload_seq(121);
preload_seq(121);
preload_seq(121);
preload_seq(121);

}

void die( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 
}
