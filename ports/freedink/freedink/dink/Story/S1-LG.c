void main ( void )
{
int &toldall;
int &s1;
int &s2;
int &s3;
int &s4;
 int &talkme;
 &talkme = 0;
 int &tip;
 &tip = random(3,1);
sp_hitpoints(&current_sprite, 30);
 if (&tip == 1)
  {
  say("`5La la laaa La La", &current_sprite);
  }
}

void talk( void )
{

freeze(1);
freeze(&current_sprite);
say_stop("`5Hey Dink, what's up?", &current_sprite);
say_stop("Hello Chealse ...", 1);
wait(250);
choice_start()
"Flirt with her"
"Ask about gossip"
"Ask about Milder FlatStomp"
(&old_womans_duck == 3)"Tell her you killed Ethel's duck"
"Nevermind"
choice_end()
wait(300);
  if (&result == 1)
   {
    say_stop("So baby, you still single and bothered?", 1);
    say_stop("Cause you know I'm a real man for you.", 1);
    wait(250);
    say_stop("`5Whatever, Smallwood!!", &current_sprite);
   }
  if (&result == 2)
   {
    say_stop("So what's the latest word in town Chealse?", 1);
    wait(250);

crapper:

   if (&s1 != 0)
{
   if (&s2 != 0)
   {
   if (&s3 != 0)
     {
   if (&s4 != 0)
       {
        unfreeze(&current_sprite);
        unfreeze(1);
        say_stop("`5I can't think of anymore gossip, sorry Dink.",&current_sprite);
        return;
         }
      }
    }
    }
    if (&old_womans_duck == 3)
     {
      &tip = random(3,1);
      if (&tip == 1)
       {
       duck:
       say_stop("`5Well I hear there's been a horrible murder of Ethel's duck!", &current_sprite);
       say_stop("`5I don't know much now, but I'll tell you when I do.", &current_sprite);
       say_stop("Oh, how tragic .... uh ...", 1);
       wait(250);
       say_stop("... gotta go", 1);
        unfreeze(&current_sprite);
        unfreeze(1);

       return;
       }
     }
    if (&old_womans_duck == 5)
     {
      &tip = random(3,1);
      if (&tip == 1)
      {
      goto duck;
      }
     }


     &tip = random(4,1);
     Debug("Ok, tip is &tip.");
     if (&tip == 1)
      {
      if (&s1 == 1)
      goto crapper;
       say_stop("`5Well, I heard that the SmileSteins have quite an abusive family now.", &current_sprite);
       say_stop("`5Despite their father being a model farmer.", &current_sprite);
       wait(250);
       say_stop("Are you sure, that sounds pretty far fetched.", 1);
       wait(250);
       say_stop("`5Yeah, oh yeah, just the other night when I was coming back", &current_sprite);
       say_stop("`5from picking flowers, I heard Libby up in her room crying.", &current_sprite);
       wait(250);
       say_stop("No ... Libby?  Oh my.", 1);
	   if (&gossip == 0)
	   {
		   &gossip = 1;

	   }
       &s1 = 1;
      }
     if (&tip == 2)
      {
      if (&s2 == 1)
      goto crapper;
       say_stop("`5Libby and her new boyfriend seem really happy together.", &current_sprite);
       wait(250);
       say_stop("That's the guy from PortTown isn't it?", 1);
       say_stop("He seems kinda bossy.", 1);
       wait(250);
       say_stop("`5Yeah, well she says she really likes him and that once", &current_sprite);
       say_stop("`5you get to know him he's a great guy.", &current_sprite);
       &s2 = 1;
      }
     if (&tip == 3)
      {
      if (&s3 == 1)
      goto crapper;
       say_stop("`5I hear that the monsters over in farmer SmileStein's field", &current_sprite);
       say_stop("`5are really driving him crazy.  I've even heard him say he's", &current_sprite);
       say_stop("`5thinking about hiring a hunter to clear them out.", &current_sprite);
       wait(250);
       say_stop("Wow", 1);
       wait(250);
       say_stop("`5Yeah, big stuff..", &current_sprite);
       &s3 = 1;
      }
     if (&tip == 4)
      {
      if (&s4 == 1)
      goto crapper;
       
       say_stop("`5Well when I went to the coast the other day I heard the Pirates", &current_sprite);
       say_stop("`5in PortTown are looking for some more help and that they may be", &current_sprite);
       say_stop("`5waging a war with the Northern Trading Company!", &current_sprite);
       say_stop("Wow Chealse, that's big.", 1);
       wait(250);
       say_stop("How did you hear all THAT stuff??", 1);
       wait(250);
       say_stop("`5Ok ok, my big sister Aby who lives in PortTown told me.", &current_sprite);
       &s4 = 1;
      }
   Debug("result is &result.");
   }
  if (&result == 3)
   {
    say_stop("What's with that big dummy Milder Flatstomp lately?", 1);
    wait(250);
    say_stop("`5Well I hear he applied to the Royal Guard.", &current_sprite);
    say_stop("`5But besides that he's just a big oaf, but I", &current_sprite);
    say_stop("`5also saw him flirting with Libby AND Lyna!", &current_sprite);
    wait(250);
    say_stop("Damn.. they must dig his uniform.  I HAVE to join!", 1);
   }
  if (&result == 4)
   {
    say_stop("Guess what, I got a secret for ya Chealse.", 1);
    wait(250);
    say_stop("`5Really?  What is it Dink?", &current_sprite);
    say_stop("Well....", 1);
    wait(500);
    say_stop("I WAS THE ONE WHO KILLED ETHEL'S DUCK!!!!!!!!!", 1);
    unfreeze(&current_sprite);
    say("`5Noooooooooooo", &current_sprite);
    sp_timing(&current_sprite, 0);
    sp_speed(&current_sprite, 10); 
   }
unfreeze(1);
unfreeze(&current_sprite);
}

void hit ( void )
{
 playsound(12, 22050, 0, 0, 0);
sp_timing(&current_sprite, 0);
sp_speed(&current_sprite, 4);
say("`5Hey, watch it pig farmer!!", &current_sprite);
wait(3000);
sp_timing(&current_sprite, 33);
sp_speed(&current_sprite, 1);
}

void die ( void )
{
&little_girl = 2;
say("She won't be bothering people any more.", 1);
}


