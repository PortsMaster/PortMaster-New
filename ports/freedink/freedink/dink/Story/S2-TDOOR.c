void main( void )
{
 if(&thief == 2)
 {
  sp_active(&current_sprite, 0);
 }
}

void touch( void )
{
  move_stop(1, 2, 140, 1);
  say("It's locked.", 1);

}
