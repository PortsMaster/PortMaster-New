void main( void )
{
 int &say;
 &say = random(4,1);
 if (&say == 4)
 {
	 say_stop("`7I'm sorry my dear, I miss you...", &current_sprite);
	 say_stop("`7Oh Dink!!  Sorry, didn't see you there.", &current_sprite);
 }
 if (&story == 5)
 {
	 &say = random(3,1);
	 if (&say == 1)
	 {
		 say_stop("`7Dink!  I hope you're doing okay.", &current_sprite);
		 wait(250);
		 say_stop("`7Tragic, what happened.", &current_sprite);
	 }
 }
 if (&farmer_quest == 1)
 {
	 say("`7Oh Dink, how goes the battle?", &current_sprite);
 }
 if (&farmer_quest == 2)
 {
	 say("`7Ah Dink, savior of my farm!", &current_sprite);
 }
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Ask how the family's doing"
(&farmer_quest == 0)"Inquire about his farm"
 "Ask to see Libby"
(&farmer_quest == 1)"Get info about the farm"
 "Leave"
 choice_end()
 wait(200);
  if (&result == 1)
  {
 say_stop("So how is the family?", 1);
          say_stop("`7We're fine.", &current_sprite);
           wait(200);
          say_stop("Ah.", 1);
	  if (&story == 5)
	  {
		  say_stop("`7Dink, I'm so sorry about your mother.", &current_sprite);
		  say_stop("`7She was a good lady.", &current_sprite);
           wait(200);
		  say_stop("Thanks.", 1);
	  }
  }
  if (&result == 2)
  {
          say_stop("So how is your farm?  Growing much?", 1);

          wait(200);
          say_stop("`7The farm... oh the farm!!  Those damn monsters,", &current_sprite);
	  say_stop("`7they're really starting to bother me.", &current_sprite);
	  say_stop("`7They come in from the forest and tear up the fields!", &current_sprite);
	  say_stop("`7I gotta do something about them soon ..." ,&current_sprite);
      choice_start()
      "Offer to take care of the problem"
      "Ask what he plans to do"
      choice_end()
	  if (&result == 1)
	  {
		  &farmer_quest = 1;
		  say_stop("Don't worry Mr. SmileStein, I'll take care of the problem.", 1);
		  wait(250);
		  say_stop("`7Really Dink??  Oh thank you, thank you.", &current_sprite);
		  say_stop("`7Just come back and tell me when you've defeated them.", &current_sprite);
		  say_stop("No problem sir.", 1);
	  }
	  if (&result == 2)
	  {
		  say_stop("What are you planning?", 1);
		  wait(250);
		  say_stop("`7I'm thinking of hiring a hunter from PortTown to come", &current_sprite);
		  say_stop("`7and take care of them!  That'll help next year's harvest.", &current_sprite);
	  }
  }
  if (&result == 3)
  {
          say_stop("Can I go up and see Libby?", 1);
	  wait(250);

	  if (&farmer_quest == 2)
	  {
		  say_stop("`7For you Dink, yes go right up.", &current_sprite);
		  unfreeze(1);
                  unfreeze(&current_sprite);
		  return;
	  }
	  say_stop("`7No, no you may not right now.", &current_sprite);
	  say_stop("`7She is not to be disturbed.", &current_sprite);
	  say_stop("Oh", 1);
  }
  if (&result == 4)
  {
	  say_stop("`7Well, my farm is off to the west a bit.", &current_sprite);
	  say_stop("`7The monsters seem to be trampling it constantly.", &current_sprite);
	  say_stop("`7Please see what you can do Dink.", &current_sprite);
  }
  unfreeze(1);
  unfreeze(&current_sprite);
}

void hit( void )
{
 say_stop("`7Please, I'm not in the mood.", &current_sprite);
}
