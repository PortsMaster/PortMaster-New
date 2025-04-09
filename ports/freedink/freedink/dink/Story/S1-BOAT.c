void main( void )
{
 if(&boat == 1)
 {
  sp_active(&current_sprite, 0);
  return;
 }
 &boat = 1;
 playsound(35, 22050, 0, 0, 0);
 sp_speed(&current_sprite, 1);
 move_stop(&current_sprite, 3, 750, 1);
 sp_active(&current_sprite, 0);
}
