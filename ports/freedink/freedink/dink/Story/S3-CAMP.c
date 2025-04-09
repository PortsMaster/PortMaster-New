void main( void )
{
 if (&mayor == 3)
 {
  if (&gobpass < 5)
  return;

  preload_seq(429);
  preload_seq(424);
  preload_seq(301);
  preload_seq(307);
  preload_seq(309);
  preload_seq(303);
  //Playmidi("Sneaky.mid");
  int &evil;
  int &evil2;
  freeze(1);
  //Do the Palette fade ...
  &vision = 1;
  //Spawn a bad guy
  &evil = create_sprite(350, 280, 0, 0, 0);
  sp_brain(&evil, 0);
  sp_base_walk(&evil, 300);
  sp_speed(&evil, 1);
  sp_timing(&evil, 0);
  //set starting pic
  sp_pseq(&evil, 303);
  sp_pframe(&evil, 1);
  //His friend
  &evil2 = create_sprite(620, 50, 0, 0, 0);
  sp_brain(&evil2, 0);
  sp_base_walk(&evil2, 300);
  sp_speed(&evil2, 1);
  sp_timing(&evil2, 0);
  //set starting pic
  sp_pseq(&evil2, 303);
  sp_pframe(&evil2, 1);
  //Done
  move(&evil, 6, 660, 1);
  move(&evil2, 4, -20, 1);
  wait(3000);
  say_stop("This must be it!", 1);
  say_stop("I have to make it into that tent.", 1);
  move_stop(1, 4, 50, 1);
  wait(1000);
  move_stop(1, 8, 250, 1);
  wait(500);
  move_stop(1, 6, 169, 1);
  wait(1000);
  move_stop(1, 8, 215, 1);
  wait(500);
  say("Here goes nothing...", 1);
  move_stop(&evil2, 2, 270, 1);
  move(1, 8, 214, 1);
  //Uhhh ??? 
  sp_nodraw(1, 1);
  move_stop(&evil2, 6, 310, 1);
  move(&evil2, 8, 0, 1);
  wait(1000);
  sp_dir(1, 2);
  sp_nodraw(1, 0);
  say("Gotta run!!  Gotta run!!", 1);
  move_stop(1, 1, 70, 1);
  move(&evil2, 2, 370, 1);
  say("`5Hey!!", &evil2);
  move(1, 2, 410, 1);
  fade_down();
  //Fade out & stuff
 }
}
