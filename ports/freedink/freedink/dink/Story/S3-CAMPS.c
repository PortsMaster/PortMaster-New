void main( void )
{
if (&gobpass < 5)
  {
   return;
  }

 if (&mayor == 3)
 {

  int &evil;
  int &evil2;
  int &evil3;
  int &evil4;
  //Make Em
  &evil = create_sprite(120, -30, 0, 0, 0);
  sp_brain(&evil, 0);
  sp_base_walk(&evil, 300);
  sp_speed(&evil, 1);
  sp_timing(&evil, 0);
  //set starting pic
  sp_pseq(&evil, 303);
  sp_pframe(&evil, 1);
  //Now EVIL's friend
  &evil2 = create_sprite(490, -30, 0, 0, 0);
  sp_brain(&evil2, 9);
  sp_base_walk(&evil2, 300);
  sp_speed(&evil2, 1);
  sp_timing(&evil2, 0);
  //set starting pic
  sp_pseq(&evil2, 303);
  sp_pframe(&evil2, 1);
  //One more
  &evil3 = create_sprite(310, -30, 0, 0, 0);
  sp_brain(&evil3, 9);
  sp_base_walk(&evil3, 300);
  sp_speed(&evil3, 1);
  sp_timing(&evil3, 0);
  //set starting pic
  sp_pseq(&evil3, 303);
  sp_pframe(&evil3, 1);
  //Hell
  &evil4 = create_sprite(210, 470, 0, 0, 0);
  sp_brain(&evil4, 9);
  sp_base_walk(&evil4, 300);
  sp_speed(&evil4, 1);
  sp_timing(&evil4, 0);
  //set starting pic
  sp_pseq(&evil4, 303);
  sp_pframe(&evil4, 1);
  //Done, now move on
  freeze(1);
  freeze(&evil2);
  freeze(&evil3);
  freeze(&evil4);
  //Should just be escaping from the Camp
  fade_up();
  move_stop(1, 6, 300, 1);
  move(1, 2, 210, 1);
  wait(1000);
  say_stop("Man, that was close!", 1);
  wait(500);
  say_stop("It looks like this scroll might just be the proof I need.", 1);
  wait(1000);
  playmidi("1004.mid");
  move(&evil, 2, 120, 1);
  wait(75);
  move(&evil2, 2, 174, 1);
  wait(65);
  move(&evil3, 2, 140, 1);
  wait(24);
  move(&evil4, 8, 370, 1);
  say("`4Not so fast ...", &evil);
  say_stop("`7Ha Ha Haaa", &evil2);
  wait(500);
  move(&evil2, 4, 450, 1);
  move_stop(1, 2, 290, 1);
  move_stop(1, 8, 280, 1);
  wait(400);
  say_stop("`4Looks like you have trouble learning, small one.", &evil);
  wait(250);
  say_stop("`4I thought I told you to stay away from us.", &evil);
  wait(250);
  say_stop("Yeah well, my foot still has an appointment with you.", 1);
  wait(250);
  say_stop("What do you freaks want with town anyway?", 1);
  wait(250);
  say_stop("`4Our business doesn't need to be told to the dead..", &evil);
  wait(250);
  say_stop("`4Finish him.", &evil);
  wait(250);
  screenlock(1);
  move_stop(&evil, 8, -30, 1);
  sp_active(&evil, 0);
  //Battle starts...
  sp_base_attack(&evil2, 740);
  sp_base_attack(&evil3, 740);
  sp_base_attack(&evil4, 740);
  sp_strength(&evil2, 10);
  sp_strength(&evil3, 10);
  sp_strength(&evil4, 10);      
  sp_defense(&evil2, 8);
  sp_defense(&evil3, 8);
  sp_defense(&evil4, 8);
  sp_touch_damage(&evil2, 6);
  sp_touch_damage(&evil3, 6);
  sp_touch_damage(&evil4, 6);
  sp_script(&evil2, "s3-dorks");
  sp_script(&evil3, "s3-dorks");
  sp_script(&evil4, "s3-dorks");
  sp_hitpoints(&evil2, 40);
  sp_hitpoints(&evil3, 40);
  sp_hitpoints(&evil4, 40);
  sp_target(&evil2, 1);
  sp_target(&evil3, 1);
  sp_target(&evil4, 1);
  unfreeze(1);
  unfreeze(&evil2);
  unfreeze(&evil3);
  unfreeze(&evil4);
  //Like if Dink lives ... give him the proof
  &mayor = 4;
 }
}
