void main( void)
{
 if (&story == 4)
  {
  //the old lady
  int &person1 = create_sprite(520, 300, 0, 231, 5);
  sp_speed(&person1, 1);
  sp_base_walk(&person1, 230);
  //girl
  int &person2 = create_sprite(520, 120, 0, 221, 5);
  sp_speed(&person2, 1);
  sp_base_walk(&person2, 220);

  if (&old_womans_duck != 3)
  {
  if (&old_womans_duck != 5)
   {
  int &duck1 = create_sprite(470, 270, 0, 24, 2);
   }
   }
  //Silver knight?
  int &person3 = create_sprite(600, 310, 0, 411, 1);
  sp_speed(&person3, 1);
  sp_base_walk(&person3, 410);
  //Girl2 at bottom
  int &person4 = create_sprite(545, 360, 0, 257, 2);
  sp_speed(&person4, 1);
  sp_base_walk(&person4, 250);
  &vision = 1;
  freeze(1);
  //move(int sprite, int direction, int destination, int nohard);
  move(&person1, 4, 500, 0);
  move(&person2, 2, 210, 0);
  move(&person3, 4, 570, 0);
  say_stop("`4Dink!!!", &person2);
  move(&person4, 4, 515, 1);
  move_stop(1, 6, 437, 1);
  say_stop("I .. I couldn't save her", 1);
  wait(500);
  say_stop("I was too late.", 1);
  say_stop("`3It's not your fault Dink.", &person1);
  if (&old_womans_duck == 3)
  {
  wait(250);
  say_stop("`3I hope my duck wasn't in there!", &person1);
  }
  if (&old_womans_duck == 5)
  {
  wait(250);
  say_stop("`3But, if you hadn't killed my duck, your mom might still be alive.", &person1);
  wait(250);
  say_stop("And just what is that supposed to mean, Ethel?", 1);
  wait(250);
  say_stop("`3Oh.. nothing...", &person1);
  }


  wait(250);

  say_stop("`4There was nothing you could do..", &person2);
  wait(250);
  say_stop("`6Don't blame yourself kid.", &person3);
  wait(750);
  fade_down();
  wait(250);
  &story = 5;
  force_vision(2);
  fade_up();
  unfreeze(1);
//force vision keep this task alive, now we need to kill it manually
  kill_this_task();
  return;
  }

if (&story > 4)
{
&vision = 2;
}



 if (&story == 3)
 {
 &vision = 1;
 freeze(1);
 move_stop(1, 4, 570, 1);
 playmidi("insper.mid");
 say_stop("What, the house, mother nooooo!!!", 1);
 wait(500);
 say_stop("She's still in there!!", 1);
 unfreeze(1);
 kill_this_task();
 }

}
