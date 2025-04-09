void main( void )
{
 //setup guy

 sp_base_walk(&current_sprite, 410);
 sp_speed(&current_sprite, 1);
 sp_brain(&current_sprite, 16);

 preload_seq(411);
 preload_seq(413);
 preload_seq(415);
 preload_seq(417);
 preload_seq(419);

wait(10);

if (&s5-jop == 1)
  {
   freeze(&temp2hold);
   freeze(&temp1hold);
   freeze(1);
   sp_dir(&temp2hold, 3);

    sp_dir(&temp1hold, 9);
   wait(700);

   say_stop("`#Look!  Someone came down!",&temp2hold);
   wait(400);
   say_stop("Hello, I'm Dink Smallwood.",1);
   wait(400);
    
   say_stop("`2Oh yes, I've read about you!  Please, did you see anyone out there?",&temp1hold);
   wait(400);
   sp_dir(1, 1);
   say_stop("Out where?  Town?",1);
   wait(400);
   say_stop("`2Yes!  Our daughter is still out there!  She'll be killed!",&temp1hold);
   wait(400);
   say_stop("Why?  I saw nothing dangerous.",1);
   wait(400);
   say_stop("`#They must have left.  We must go find her.. what if she is..",&temp2hold);
   wait(400);
   sp_dir(&temp1hold, 7);
   say_stop("`2Don't say such things!  Stay here, I will be back shortly.",&temp1hold);
   move_stop(&temp1hold, 9, 530, 1);
   //hide man
   sp_nodraw(&temp1hold, 1);
  move_stop(&temp2hold, 6, 300, 1);
  wait(500);
  say_stop("`#I cannot idly wait while my daughter is in danger!", &temp2hold);
  wait(500);
  move_stop(&temp2hold, 6, 450, 1);
  move_stop(&temp2hold, 9, 530, 1);
  sp_active(&temp2hold, 0);
  unfreeze(1);
  sp_active(&temp1hold, 0);
  say("What a very strange town.", 1);
  &s5-jop = 2;
  }
}
