void main( void )
{
}

void hit( void )
{
 say("Let me show you MY version of politics, friend!", 1);
}

void talk( void )
{
 if (&mayor == 2)
 {
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Say hi"
 "Tell him about the planned assault"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   wait(400);
   say_stop("Hello Mayor, nice town you have here.", 1);
   wait(250);
   say_stop("`5Thank you fair citizen.", &current_sprite);
   wait(250);
   say_stop("Yeah, noted.", 1);
  }
  if (&result == 2)
  {
   //Playmidi("Urgent.mid");
   wait(400);
   say_stop("Mayor, I have urgent news, your town is going to be attacked!", 1);
   wait(250);
   say_stop("`5What?!?  That's preposterous, you've got to be joking!", &current_sprite);
   wait(250);
   say_stop("No, I'm dead serious!  It's the Cast Knights.", 1);
   wait(250);
   say_stop("They're planning to attack during the parade.", 1);
   wait(250);
   say_stop("`5That's crazy!!  ... so many people would be hurt.", &current_sprite);
   wait(250);
   say_stop("All the more reason for you to believe me.", 1);
   wait(250);
   say_stop("Now the girl by the fountain said you knew some Royal guards.", 1);
   wait(250);
   say_stop("`5You talked with my daughter?", &current_sprite);
   wait(250);
   say_stop("She's your daughter??  Is she single?",1);
   wait(250);
   say_stop("`5What?", &current_sprite);
   wait(250);
   say_stop("Never mind, so you have some connections right?", 1);
   wait(250);
   say_stop("`5Yes they could help.", &current_sprite);
   wait(250);
   say_stop("`5But I need proof before I can go calling them in.", &current_sprite);
   wait(250);
   say_stop("Ok, so if I get proof you'll help?", 1);
   wait(250);
   say_stop("`5Yes, without it my hands are tied.", &current_sprite);
   wait(250);
   &mayor = 3;
   say_stop("Allright, then I'm off.", 1);
  }
 unfreeze(1);
 unfreeze(&current_sprite);
 return;
 }
 if (&mayor == 3)
 {
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Say hi"
 "Show him the proof"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   wait(400);
   say_stop("Hello Mayor, nice town you have here.", 1);
   wait(250);
   say_stop("`5Thank you fair citizen.", &current_sprite);
   wait(250);
   say_stop("Yeah, noted.", 1);
  }
  if (&result == 2)
  {
   wait(400);
   say_stop("I finally got the proof we need.", 1);
   wait(250);
   //Check to see if he did
   say_stop("`5No you didn't you liar!", &current_sprite);
   wait(250);
   say_stop("Oops, my bad.", 1);
  }
 unfreeze(1);
 unfreeze(&current_sprite);
 }
 if (&mayor == 4)
 {
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Say hello"
 "Show him the scroll with the plans"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   wait(400);
   say_stop("Hello Mayor, how's it going?", 1);
   wait(250);
   say_stop("`5Pretty good fair citizen.", &current_sprite);
   wait(250);
   say_stop("Hey, that's just great.", 1);
  }
  if (&result == 2)
  {
   wait(400);
   say_stop("I've got your proof mayor.", 1);
   wait(250);
   say_stop("They plan to slaughter the entire city.", 1);
   wait(250);
   say_stop("`5Oh my god, this attack would destroy our defenses!", &current_sprite);
   wait(250);
   say_stop("`5I can't believe they would attack us like this.", &current_sprite);
   wait(250);
   say_stop("Now will you call the Guard?", 1);
   wait(250);
   say_stop("`5Yes, I just hope they can get here in time...", &current_sprite);
   &mayor = 5;
   wait(500);
   script_attach(1000);
   //fadeout & cutscene?
   fade_down();
   //change maps and stuff ...
   &player_map = 586;
   sp_x(1, 266);
   sp_y(1, 80);
   load_screen();
   draw_screen();
   draw_status();
   fade_up();
   kill_this_task();
   //Done
  }
 unfreeze(1);
 unfreeze(&current_sprite);
 }
}
