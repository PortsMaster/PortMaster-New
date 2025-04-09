void main( void )
{
 int &talker;
 &talker = 0;
}

void hit( void )
{
   say("`5Please stop hitting me now.", &current_sprite);

}

void talk( void )
{
 freeze(1);
 choice_start()
 "Ask what he's guarding"
 "Ask about getting in"
 "Leave"
 choice_end()

  if (&result == 1)
  {
   say_stop("What are you guarding here?", 1);
   wait(250);
   say_stop("`5This is the town's duck altar.", &current_sprite);
   wait(250);
   say_stop("`5We worship them here.", &current_sprite);
   wait(250);
   say_stop("Oh, I thought it might be a ranch or something.", 1);
   wait(250);
   say_stop("`5On some occasions we do offer food here to the ducks.", &current_sprite);
   wait(250);
   say_stop("You give the DUCKS your food?", 1);
   wait(250);
   say_stop("`5Yes, of course.", &current_sprite);
   &talker = 1;
  }

  if (&result == 2)
  {
   say_stop("So how does one get in to see the altar?", 1);
   wait(250);
   say_stop("`5It is a great honor to worship inside.. one you have not earned.", &current_sprite);
   wait(250);
   say_stop("`5You can pray to the duck from here.", &current_sprite);
  }
 unfreeze(1);
}
