void main ( void )
{
 int &maybe;
 &maybe = random(3,1);
 if (&maybe == 1)
  {
	 &maybe = random(3,1);
	 if (&maybe == 1)
	 {
     sp_speed(&current_sprite, 7);
     sp_timing(&current_sprite, 0);
     move(&current_sprite, 6, 510, 1);
	 sp_speed(&current_sprite, 1);
     sp_timing(&current_sprite, 33);
	 say_stop("`9I hope they didn't follow me ..", &current_sprite);
	 }
	 else
     {
     say_stop("`9Hello friend..", &current_sprite);
	 }
  }
}

void talk ( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Ask about his travels"
 "Ask for news"
(&story == 2)"Ask if he has any AlkTree nuts"
 "Leave"
 choice_end()

  if (&result == 1)
   {
    story();
   }
  if (&result == 2)
   {
    news();
   }
  if (&result == 3)
   {
    say_stop("`9AlkTree nuts??  I haven't had those in a long long time.", &current_sprite);
    say_stop("`9In my old town I might have been able to tell you,", &current_sprite);
    say_stop("`9but I don't know of any around here.", &current_sprite);
   }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit ( void )
{
 int &dir;
 say("`9Ow, the hell's your problem?!", &current_sprite);
 sp_speed(&current_sprite, 4);
 sp_timing(&current_sprite, 0);
 //Dissapear off screen
 &dir = random(4, 1);
 if (&dir == 1)
 {
         move(&current_sprite, 1, -100, 1);
 }
 if (&dir == 2)
 {
         move(&current_sprite, 3, 700, 1);
 }
 if (&dir == 3)
 {
         move(&current_sprite, 7, -100, 1);
 }
 if (&dir == 4)
 {
         move(&current_sprite, 9, 700, 1);
 }
 sp_brain(&current_sprite, 0);
 sp_kill(&current_sprite, 2000);
 script_attach(0);
}

void die ( void )
{
 say_stop("He won't bother anyone anymore...", 1);
}

void story( void )
{
int &maybe = random(3,1);
 if (&maybe == 1)
  {
   say_stop("`9I just escaped from the Goblin Sanctuary.", &current_sprite);
   say_stop("`9It's quite a horrible place and I wouldn't recommend going there.", &current_sprite);
   wait(250);
   say_stop("That place is far to the west, how'd you get out here?", 1);
   say_stop("`9Well I've just been headed away from it ever since I got out.", &current_sprite);
   say_stop("`9I hope I can make it to PortTown and get away for a while.", &current_sprite);
  }
 if (&maybe == 2)
  {
   say_stop("`9I've always wanted to go out into the world and find adventure.", &current_sprite);
   say_stop("`9Whether it be working with the Royal Guard or signing up", &current_sprite);
   say_stop("`9with a band of mercenaries.", &current_sprite);
   wait(250);
   say_stop("`9Unfortunately for me one of my first jobs led me right into", &current_sprite);
   say_stop("`9being captured by the goblins.  Last time I go to the WestLands.", &current_sprite); 
  }
 if (&maybe == 3)
  {
   say_stop("`9After being around those goblins for so long I'm glad to be out.", &current_sprite);
   say_stop("`9Those guy are dumb as bricks man!", &current_sprite);
   say_stop("`9I'm embarrassed that I got captured in the first place.", &current_sprite);
  }
}

void news( void )
{
int &maybe = random(5,1);

  if (&maybe == 1)
   {
    makefun();

   }

 &maybe = random(3,1);
 if (&maybe == 1)
  {
   //playmidi("creepy.mid");
   wait(1000);
   say_stop("`9When I was captured at the Goblin Sanctuary I did notice something.", &current_sprite);
   say_stop("`9All their patrols that came back from the north seemed different.", &current_sprite);
   say_stop("`9Soon they started behaving really weird, not much later a few were", &current_sprite);
   say_stop("`9locked up right next to me and going crazy!", &current_sprite);
   wait(200);
   say_stop("Man, sounds pretty creepy.", 1);
   wait(200);
   say_stop("`9Just another reason I'm headed away for a while.", &current_sprite);
   wait(200);
  }
 if (&maybe == 2)
  {
   say_stop("`9While imprisoned, the goblins said that by the Crag cliffs", &current_sprite);
   say_stop("`9There was a wizard that they were fighting, they thought", &current_sprite);
   say_stop("`9they could actually get his magic if they defeated him.", &current_sprite);
   say_stop("`9Anyway they said this guy could actually turn people to ice!!", &current_sprite);
   say_stop("`9I'd guess they lost about 30 troops before they gave up.", &current_sprite);
  }
 if (&maybe == 3)
  {
   say_stop("`9I hear your Mom's a slut.  But that's just the word on", &current_sprite);
   say_stop("`9the street.  Ha Ha Ha", &current_sprite);
   say_stop("`9Ha Ha .. Ha ..", &current_sprite);
   say_stop("`9 ... Ha ... ", &current_sprite);
   say_stop("Ha Ha Ha ...", 1);
   say_stop("`9 .. Ha Ha ..", &current_sprite);

   if (&story > 4)
   {
   say_stop("Ha Ha ... wait!!!!", 1);
   say_stop("My Mom's dead!!!!!", 1);
   }
  }

}

void makefun( void )
{
 if (&story == 5)
  {
   say_stop("`9Some other guy I meet wandering told me there was a bad fire", &current_sprite);
   say_stop("`9around these parts.  Hope no one was injured.", &current_sprite);
   wait(200);
   say_stop("Yes.. I'm sure no one was ... hurt ...", 1);
   unfreeze(1);
   unfreeze(&current_sprite);
   return;
  }
  say_stop("Greetings friend, any news?", 1);
  wait(200);
  say_stop("`9Not really.  What's your name anyway?", &current_sprite);
  wait(200);
  say_stop("Smallwood,", 1);
  wait(250);
  say_stop("Dink Smallwood.", 1);
  wait(200);
  say_stop("`9Hello, I'm Chance `Zands", &current_sprite);
  wait(200);
  say_stop("`9You have an interesting name there.", &current_sprite);
  wait(200);
  say_stop("Thank you.", 1);    
}
