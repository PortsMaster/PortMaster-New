void main( void )
{
 //evil's modus operandi
loop:
move_stop(&current_sprite, 7, 200, 1);
kill_this_task();
}

 void hit( void )
 {
  sp_timing(&current_sprite, 0);
  sp_frame_delay(&current_sprite, 60);
  say("Come back here!", 1);
  goto loop;
 }
