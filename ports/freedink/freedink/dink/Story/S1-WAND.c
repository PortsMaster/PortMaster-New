void main ( void )
{
 int &maybe;
 &maybe = random(3,1);
 if (&maybe == 1)
  {
   say_stop("`6Hello fellow traveller.", &current_sprite);
  }
}

//playmidi("xfiles.mid");

void talk ( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Inquire about his travels"
 "Ask about news"
(&story == 2)"Ask about AlkTree nuts"
 "Leave"
 choice_end()
 wait(300);
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
    say_stop("`6AlkTree nuts??  Those make for a hearty meal.  Let's see..", &current_sprite);
    say_stop("`6I think there's a tree to the south east of the small village", &current_sprite);
    say_stop("`6near here.", &current_sprite);
   }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit ( void )
{
 int &dir;
 say("`6Ow, crazy bastard!!", &current_sprite);
 sp_speed(&current_sprite, 4);
 sp_timing(&current_sprite, 0);
 //Disappear off screen
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
 say("I'm afraid he wont be making it to his destination.", 1);
}

void story( void )
{
 int &maybe = random(3,1);
 if (&maybe == 1)
  {
   say_stop("`6Be careful in the West.  The Goblin castle has extreme", &current_sprite);
   say_stop("`6defenses to say the least.", &current_sprite);
   wait(250);
   say_stop("`6I've seen many a traveler lose his head if you know what I mean.", &current_sprite);
  }
 if (&maybe == 2)
  {
   say_stop("`6I've heard of an old man who lives just north of SunCool pond.", &current_sprite);
   say_stop("`6Although I've never seen him I have heard noises when I've", &current_sprite);
   say_stop("`6gone by there.", &current_sprite);
  }
 if (&maybe == 3)
  {
   say_stop("`6Travel by sea is quite spendy these days. I suggest if", &current_sprite);
   say_stop("`6you aren't a person of wealth you look towards perhaps", &current_sprite);
   say_stop("`6working for your voyage or find a friend who will pay", &current_sprite);
   say_stop("`6for you.  Otherwise you could be saving for a long time.", &current_sprite);
  }
}

void news( void )
{
int &maybe = random(3,1);
  if (&maybe == 1)
   {
    makefun();
    return;
   }
 &maybe = random(3,1); 
 if (&maybe == 1)
  {
   say_stop("`6There's some talk of an old evil awakening to", &current_sprite);
   say_stop("`6the west.  I don't know though, I think it's all", &current_sprite);
   say_stop("`6just silly superstition.", &current_sprite);
   wait(500);
   say_stop("Yes.. I'm sure it's super ... stition ...", 1);
  }
 if (&maybe == 2)
  {
   say_stop("`6In the city of PortTown, the populous can seem quite", &current_sprite);
   say_stop("`6rowdy at times.  Some say it's because of the frequenting", &current_sprite);
   say_stop("`6of pirates in the town.  Either way, be careful if you", &current_sprite);
   say_stop("`6ever travel there.", &current_sprite);
  }
 if (&maybe == 3)
  {
   say_stop("`6If you ever run into goblins, be careful.", &current_sprite);
   say_stop("`6They're pretty prone to violence, so just don't", &current_sprite);
   say_stop("`6upset them.  However they're quite stupid.", &current_sprite);
   say_stop("`6You could probably tell them just about anything,", &current_sprite);
   say_stop("`6they'll believe it.", &current_sprite);
  }
}

void makefun( void )
{
 //I think story = 5 ???
 if (&story == 6)
  {
   int &maybe = random(3,1);
   if(&maybe == 1)
   {
    say_stop("`6I heard there was a bad fire in a nearby village,", &current_sprite);
    say_stop("`6hope no one was hurt too bad.", &current_sprite);
    wait(500);
    say_stop("Yes.. I'm sure no one was ... hurt ...", 1);
   }
  }
 if (&old_womans_duck == 3)
  {
   say_stop("`6In the small village nearby, I've heard there's", &current_sprite);
   say_stop("`6a madman.  A murderer who stalks and kills the pets of the people!", &current_sprite);
   wait(250);
   say_stop("`6Horrible isn't it?", &current_sprite);
   wait(250);
   say_stop("Yes.. very .. horrible ..", 1);
  }
 if (&old_womans_duck == 5)
  {
   say_stop("`6In the small village nearby, I've heard there's", &current_sprite);
   say_stop("`6a madman.  A murderer who stalks and kills the pets of the people!", &current_sprite);
   wait(250);
   say_stop("`6Horrible isn't it?", &current_sprite);
   wait(250);
   say_stop("Yes.. very uh .. horrible ..", 1);
  }
 else
 {
  say_stop("`6So young man, what's your name?", &current_sprite);
  say_stop("Smallwood, Dink Smallwood.", 1);
  wait(250);
  say_stop("`6Greetings Mr. Smallwood.", &current_sprite);
 }
}
