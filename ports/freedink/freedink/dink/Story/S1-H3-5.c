void main( void )
{
 int &man;
 &man = sp(23);
  if (&farmer_quest > 1)
  {
   sp_active(&current_sprite, 0);
   return;   
  }
 sp_touch_damage(&current_sprite, -1);

}

void touch( void )

{
  freeze(1);
  //move him a bit?
  if (sp_dir(1, -1) == 8)
  {
   move_stop(1, 2, 177, 1);
  }
  if (sp_dir(1, -1) == 7)
  {
   move_stop(1, 2, 177, 1);
  }
  if (sp_dir(1, -1) == 4)
  {
   move_stop(1, 6, 166, 1);
  }
  say("`7Not so fast, Smallwood!", &man);
  unfreeze(1);
}
