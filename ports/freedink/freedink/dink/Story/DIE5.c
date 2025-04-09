//generic script for killing things so they don't come back

void main( void )
{
sp_hitpoints(&current_sprite, 1);
}

void die( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 
}
