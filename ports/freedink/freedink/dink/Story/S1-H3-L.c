void main( void )
{
 int &say;
 //playsound("cry.wav");
 &say = random(4,1);
 if (&say == 1)
 {
 say_stop("`3Oh Dink, it's you..", &current_sprite);
 wait(250);
 }
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 (&mlibby == 0) "Coax her into telling you why she's upset"
 "Try to comfort her"
(&farmer_quest == 2)"Brag about how you cleared their farm"
 "Never mind"
 choice_end()
 wait(300);
  if (&result == 1)
  {
	  say_stop("Libby, what's wrong?  Why are you so upset?", 1);
	  say_stop("`3Nothing Dink, you wouldn't understand.", &current_sprite);
	  wait(250);
	  if (&gossip == 0)
	  {
		  unfreeze(1);
		  unfreeze(&current_sprite);
		  return;
	  }
         &mlibby = 1;
	  say_stop("It's your father isn't it?  Does he do anything to you?", 1);
	  wait(250);
	  say_stop("`3What?  What are you talking about?", &current_sprite);
	  say_stop("I've heard .. rumors Libby, it's okay to admit it you know.", 1);
	  wait(250);
	  say_stop("`3Admit?  Admit what?", &current_sprite);
	  say_stop("That your father hits you.", 1);
	  say_stop("`3You fool, of course not!!  He doesn't do that!!", &current_sprite);
	  say_stop("`3I'm crying because my father's so upset.", &current_sprite);
	  wait(250);
	  say_stop("Oh ... I .... see.", 1);
          say_stop("`3<sniff>", &current_sprite);
	  say_stop("Is your father upset because you won't satisfy him?", 1);
	  wait(250);
	  say_stop("`3DINK!!  What the hell's wrong with you??", &current_sprite);
	  say_stop("`3It's been exactly one year since Mother died, that's why.", &current_sprite);
	  wait(200);
	  say_stop("Uhhh.  I ... uhm ...", 1);
	  wait(250);
	  say_stop("Oh", 1);
	  wait(200);
	  choice_start()
 "Try to comfort her about her family"
 "Apologize for being an ass"
      choice_end()
      wait(300);
	  if (&result == 1)
	  {
		  say_stop("I'm sorry about your mother.  But I know how you feel", 1);
		  say_stop("I'm pretty upset myself you know.", 1);
		  say_stop("`3Thank you Dink, you've made me happy.", &current_sprite);
                  unfreeze(1);
                  unfreeze(&current_sprite);
		  return;

	  }
	  if (&result == 2)
	  {
                  say_stop("Uhh, hehe, sorry for being so insensitive and saying those things.", 1);
		  say_stop("Guess I shouldn't listen to rumors so much.", 1);
		  wait(250);
		  say_stop("Uhh .. hehe ..he ..", 1);
		  say_stop("Uhhhhh...", 1);
		  say_stop("Oh boy.", 1);
                  unfreeze(1);
                  unfreeze(&current_sprite);
		  return;
	  }
  }
  if (&result == 2)
  {
	  say_stop("Don't cry Libby.  It's okay whatever it is.", 1);
	  say_stop("Sometimes bad things just happen to us, we just", 1);
          say_stop("have to learn to persevere through them.", 1);
	  wait(250);
	  say_stop("`3Thanks Dink, that's kind of you.", &current_sprite);
	  wait(250);
  }	  
  if (&result == 3)
  {
          say_stop("So I guess you noticed that your farm is doing better now huh?", 1);
	  wait(250);
	  say_stop("You know that was my handiwork out there.", 1);
          say_stop("`3Pretty good...", &current_sprite);
          say_stop("`3...compared to your usual.", &current_sprite);
	  wait(250);
          say_stop("Dohh!", 1);
          
  }
  if (&result == 4)
  {
          say_stop("Uh, never mind.  I have to get going now.", 1);
  }
  unfreeze(1);
  unfreeze(&current_sprite);
}

void hit( void )
{
 &say = random(6,1)
  if (&say == 1)
  {
   say_stop("You know I hate to do this to you baby.", 1);
   return;
  }
 say_stop("`3Noo Dink!!  What's your problem...", &current_sprite);
}
