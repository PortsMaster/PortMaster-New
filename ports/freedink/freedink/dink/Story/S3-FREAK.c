void main( void )
{
 int &force;
 &temp1hold = sp(33);
 &temp2hold = sp(34);
 &temp3hold = sp(35);
 &temp4hold = sp(36);

if (get_sprite_with_this_brain(3, &current_sprite) == 0)
 {
  //no more brain 3 (ducks) on the screen.
    say("`9Murderer!", &current_sprite);

 }



sp_frame_delay(&current_sprite, 30);
 start:

if (get_sprite_with_this_brain(3, &current_sprite) == 0)
 {
  //no more brain 3 (ducks) on the screen.
  &force = random(4, 1);
  if (&force == 1)
  {
   &force = random(4, 1);
   if (&force == 1)
   {
    say("`9Where are you, little guys?", &current_sprite);
   }
   if (&force == 2)
   {
    say("`9My ducks!!!!!!!! ALL DEAD!!!!!!! DAMN YOU!", &current_sprite);
   }
   if (&force == 3)
   {
    say("`9GET OUT OF HERE!!!!!", &current_sprite);
   }
   if (&force == 4)
   {
    say("`9There go my chances of impressing the Mayor's daughter!!!!", &current_sprite);
   }
  }
 goto loser;
 }


  &force = random(4, 1);
  if (&force == 1)
  {
   &force = random(4, 1);
   if (&force == 1)
   {
    say("`9This parade is gonna rule!!!", &current_sprite);
   }
   if (&force == 2)
   {
    say("`9I love my ducks.", &current_sprite);
   }
   if (&force == 3)
   {
    say("`9Ready for our act little pals?", &current_sprite);
   }
   if (&force == 4)
   {
    say("`9Gettin' ready to rock!!", &current_sprite);
   }
  }
loser:
  move_stop(&current_sprite, 6, 530, 1);
  move_stop(&current_sprite, 4, 100, 1);
//wait(800);
  goto start;
}

void talk( void )
{

if (get_sprite_with_this_brain(3, &current_sprite) == 0)
 {
    say("`9Get lost!! You have completely destroyed my act!", &current_sprite);
    goto start;
 }



 freeze(1);
 freeze(&current_sprite);
 say_stop("`9What do you want man?  I gotta keep moving!", &current_sprite);
 choice_start()
(&mayor < 6)"Ask why he's running"
(&mayor < 6)"Ask about the ducks"
(&mayor > 5)"Ask about the parade"
 "Leave"
 choice_end()

  if (&result == 1)
  {
  say_stop("Why are you running around so fast?", 1);
  wait(250);
  say_stop("`9Cause I'm excited!!", &current_sprite);
  wait(250);
  say_stop("About what?", 1);
  wait(250);
  say_stop("`9The big parade happening soon man!!", &current_sprite);
  wait(250);
  say_stop("`9It's gonna rock!!!!!!", &current_sprite);
  }
  if (&result == 2)
  {
  say_stop("What's with all the ducks?", 1);
  wait(250);
  say_stop("`9Oh, they're my pets.  We're gonna be in the parade together.", &current_sprite);
  wait(250);
  say_stop("I see ...", 1);
  wait(250);
  say_stop("`9Wanna see what we do?", &current_sprite);
  wait(250);
  say_stop("Not really.", 1);
  wait(250);
  say_stop("`9Okay, here it goes ...", &current_sprite);
  wait(250);
  say_stop("`9Ready guys?  Follow me!", &current_sprite);
  sp_follow(&temp1hold, &current_sprite);
  sp_follow(&temp2hold, &current_sprite);
  sp_follow(&temp3hold, &current_sprite);
  move_stop(&current_sprite, 4, 100, 1);
  move_stop(&current_sprite, 6, 530, 1);
  say("Hey..", 1);
  move_stop(&current_sprite, 4, 100, 1);
  move_stop(&current_sprite, 6, 300, 1);
  say_stop("`9Yeah?", &current_sprite);
  wait(250);
  say_stop("What's with that other one?", 1);
  wait(250);
  say_stop("`9Oh ...", &current_sprite);
  wait(250);
  say_stop("`9he has issues.", &current_sprite);
  unfreeze(&current_sprite);
  wait(1000);
  sp_dir(1, 2);
  say_stop("Oh boy ...", 1);
  }
  if (&result == 3)
  {
  say_stop("Soooo ... didn't see you at the parade.", 1);
  wait(250);
  say_stop("`9Oh .. hehe .. yeah, I uhh ... I ...", &current_sprite);
  wait(250);
  say_stop("`9one of the ducks got sick, and well .. we couldn't perform.", &current_sprite);
  wait(250);
  sp_dir(1, 2);
  wait(1000);
  sp_dir(1, 4);
  say_stop("I'm sure.  That's too bad, after all that practice.", 1);
  wait(250);
  say_stop("`9Well hey, don't worry ...", &current_sprite);
  wait(250);
  say_stop("`9we're practicing for next year.", &current_sprite);
  wait(250);
  say_stop("Aww man...", 1);
  unfreeze(&current_sprite);
  wait(500);
  sp_dir(1, 2);
  say_stop("Note to self:  Don't come here next year.", 1);
  }
 unfreeze(1);
 unfreeze(&current_sprite);
 goto start;
}
