void main( void )
{
 int &crap;
 preload_seq(371);
 preload_seq(373);
 preload_seq(377);
 preload_seq(379);
 sp_brain(&current_sprite, 0);
 sp_base_walk(&current_sprite, 370);
 sp_speed(&current_sprite, 2);
 sp_timing(&current_sprite, 0);
//set starting pic
 sp_pseq(&current_sprite, 373);
 sp_pframe(&current_sprite, 1);
 //Ok Go
 freeze(1);
 //playmidi("mystery.mid");
 say_stop("`2Psst, over here", &current_sprite);
 //Move Dink
 &crap = sp_x(1, -1);
 if (&crap < 340)
 {
  &crap = sp_y(1, -1);
  if (&crap < 210)
  {
   move_stop(1, 2, 180, 1);
  }
  if (&crap > 210)
  {
   move_stop(1, 8, 180, 1);
  }
  move_stop(1, 6, 340, 1);
 }
 move_stop(1, 4, 340, 1);
 move_stop(1, 8, 210, 1);
 move_stop(1, 4, 330, 1);
 say_stop("`2You ready to do this buddy?", &current_sprite);
 wait(200);
 say_stop("Yeah, no problem.", 1);
 wait(200);
  say_stop("`2Allright, follow me...", &current_sprite);
 move_stop(&current_sprite, 8, 105, 1);
 move_stop(&current_sprite, 6, 469, 1);
 say_stop("`2In here", &current_sprite);
 move_stop(1, 6, 510, 1);
 move_stop(1, 8, 0, 0);
}
