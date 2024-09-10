void main( void )
{
 int &pap;
 int &beat;
 &beat = 0;
 &pap = random(15, 1)
 if (&pap == 1)
 {
  say_stop("`4Hello there sir.", &current_sprite);
 }
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Say Hi"
 "Ask about his tales"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   say_stop("So what do you do?", 1);
   wait(250);
   say_stop("`4Well, I'm a hunter.", &current_sprite);
   wait(250);
   say_stop("`4Hope to find some good furs in these parts.", &current_sprite);
   wait(250);
   say_stop("That's a good job", 1);
   wait(250);
   say_stop("Any luck lately?", 1);
   wait(250);
   say_stop("`4No, not really.  It's been kinda weird.", &current_sprite);
   wait(250);
   say_stop("`4I've seen a lot of monsters around lately though,", &current_sprite);
   wait(250);
   say_stop("`4it's like maybe they scared off all the animals.", &current_sprite);
  }
  if (&result == 2)
  {
   &pap = random(2, 1);
   if (&pap == 1)
   {
    goto story1;
   }
   if (&pap == 2)
   {
    goto story2;
   }
  }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 if (&beat == 0)
 {
  &beat = 1;
  say_stop("`4Sir, nooo.  I don't take kindly to bruising.", &current_sprite);
  return;
 }
 if (&beat == 1)
 {
  &beat = 2;
  say_stop("`4I'm warning you sir, please stop that.", &current_sprite);
  return;
 }
 if (&beat == 2)
 {
  say_stop("`4That's it, I'm outta here!", &current_sprite);
  sp_speed(&current_sprite, 4);
  move_stop(&current_sprite, 3, 700, 1);
  freeze(&current_sprite);
  wait(500);
  say_stop("See ya.", 1);
  sp_active(&current_sprite, 0);
 }
}

void story1( void )
{
 story1:
 say_stop("`4I've heard many strange tales in my day.", &current_sprite);
 wait(250);
 say_stop("`4One particular tale spoke of an island in the sea.", &current_sprite);
 wait(250);
 say_stop("`4Where both humans and dragons lived.", &current_sprite);
 wait(250);
 say_stop("`4And in peace, no wars, no fighting.", &current_sprite);
 wait(250);
 say_stop("`4I even heard there was an underground tunnel to it.", &current_sprite);
 wait(250);
 say_stop("`4They say it was a beautiful island to visit.", &current_sprite);
 wait(250);
 say_stop("`4But I don't think it exists, just an old tale.", &current_sprite);
 unfreeze(1);
 unfreeze(&current_sprite);
}

void story2( void )
{
 story2:
 say_stop("`4A long time ago there used to be an entire goblin castle", &current_sprite);
 wait(250);
 say_stop("`4in this land.", &current_sprite);
 wait(250);
 say_stop("`4It's said they launched attack and attack from it,", &current_sprite);
 wait(250);
 say_stop("`4terrorizing the land.", &current_sprite);
 wait(250);
 say_stop("`4But they say a magic user came and cast a mighty spell on the castle.", &current_sprite);
 wait(250);
 say_stop("`4So strong that it teleported the castle to the icelands in the north.", &current_sprite);
 wait(250);
 say_stop("`4Presumably the goblins died in the harsh weather.", &current_sprite);
 wait(250);
 say_stop("`4Otherwise, no one has heard of the castle since.", &current_sprite);
 unfreeze(1);
 unfreeze(&current_sprite);
}
