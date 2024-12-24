void main( void )
{
 preload_seq(514);
 preload_seq(70);
 int &talker;
 int &junk;
 &talker = 0;
 move(1, 6, 157, 1);
 freeze(&current_sprite);
 freeze(1);
 if (&story > 10)
 {
  unfreeze(&current_sprite);
  unfreeze(1);
  return;
 }
 say("`7AHHHHH!!!!!!", &current_sprite);
 wait(250);
 //Fire here
 playsound(42,22050,0,0,0);
 &junk = create_sprite(385, 151, 11, 506, 1);
 sp_seq(&junk, 514); 
 sp_dir(&junk, 4);
 sp_speed(&junk, 4);
 sp_flying(&junk, 1);
 say("AHHHHH!!!!!", 1);
 wait(290);
 move(1, 2, 240, 1);
 wait(560);
 sp_active(&junk, 0);
 &junk = create_sprite(157, 131, 7, 168, 1);
 sp_seq(&junk, 70);
 playsound(37,22050,0,0,0);
 wait(1200);
 sp_dir(1, 6);
 wait(500);
 say_stop("What the hell?!?", 1);
 wait(250);
 say_stop("`7Sorry.", &current_sprite);
 unfreeze(1);
 unfreeze(&current_sprite);
 //end
}

void talk( void )
{
 if (&story > 10)
 {
  freeze(&current_sprite);
  freeze(1);
  say_stop("`7Ah, Dink.  How are you my boy, how are you.", &current_sprite);
  say_stop("`7Thank you so much for saving our town.", &current_sprite);
  wait(250);
  say_stop("Hey, no problem.", 1);
  wait(250);
  unfreeze(1);
  unfreeze(&current_sprite);
  return;
 }
 if (&talker == 2)
 {
  freeze(1);
  say_stop("`7I'm done talking to you, I have more important things to worry about.", &current_sprite);
  wait(250);
  say_stop("Hmmm.", 1);
  unfreeze(1);
  return;
 }
 freeze(1);
 freeze(&current_sprite);
 choice_start()
"Ask what's up"
"Ask about the town"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   say_stop("Hey, uh thanks for that fireball!", 1);
   say_stop("What the hell's wrong with you?", 1);
   wait(250);
   say_stop("`7I .. I'm sorry, I thought you were someone else.", &current_sprite);
   wait(250);
   say_stop("Like who?!?", 1);
   wait(250);
   say_stop("`7Like maybe another raider coming for my food.", &current_sprite);
   say_stop("`7I have to defend myself.", &current_sprite);
   wait(250);
   say_stop("This town is messed up.", 1);
   &talker = 1;
  }
  if (&result == 2)
  {
   &junk = sp_dir(1, -1);
   say_stop("So, what's with the town here?", 1);
   wait(250);
   say_stop("`7We, we all worship the duck here.", &current_sprite);
   sp_dir(1, 2);
   wait(1000);
   say_stop("Ok, I'm gonna turn back towards you ...", 1);
   say_stop("and you're gonna give a normal answer this time.", 1);
   wait(250);
   say_stop("Ready ....", 1);
   sp_dir(1, &junk);
   wait(750);
   say_stop("`7We all worship the duck here.", &current_sprite);
   wait(1000);
   say_stop("Yeah ...", 1);
   say_stop("Is this some kind of religion?", 1);
   wait(250);
   say_stop("`7Yes, we give all and owe all to the duck.", &current_sprite);
   wait(250);
   say_stop("Well okay then, I'll ... I'll get back to you on that.", 1);
   &talker = 2;
  }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 if (&story > 10)
 {
  freeze(&current_sprite);
  say_stop("`7Ah, some hero you are!", &current_sprite);
  unfreeze(&current_sprite);
  return;
 }
 freeze(&current_sprite);
 say_stop("`7Ahhh, knock it off you!", &current_sprite);
 unfreeze(&current_sprite);
}
 