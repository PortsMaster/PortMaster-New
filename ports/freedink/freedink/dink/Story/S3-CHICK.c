void main( void )
{
 int &wherex;
 int &wherey;
}

void talk( void )
{


if (&gobpass == 5)
  {
   if (&mayor == 0)
   {
    say_stop("** FIXING BUG.. RESETTING GOBLIN VILLAGE **",&current_sprite);
   &gobpass = 0;
    return;

   }
  }


 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Say hi"
 "Ask what she does"
(&mayor == 0)"Tell her about the planned assault"
(&mayor == 3)"See what's happened since"
(&mayor == 4)"Show her the Scroll"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   wait(400);
   say_stop("Hey, how's it going?", 1);
   wait(250);
   say_stop("`9Oh hi, pretty good.", &current_sprite);
   wait(1000);
   say_stop("My name's Dink, pleasure to meet you.", 1);
   wait(250);
   say_stop("`9Hello Dink, I'm Christina." &current_sprite);
   wait(250);
   say_stop("Just having a stroll around town?", 1);
   wait(250);
   say_stop("`9I was just taking a look at the town square.", &current_sprite);
   wait(250);
   say_stop("What for?", 1);
   wait(250);
   say_stop("`9For the big parade happening soon, what else silly?", &current_sprite);
   wait(250);
   say_stop("Ahh, yes.. I've ... heard of that parade.", 1);
  }
  if (&result == 2)
  {
   wait(400);
   say_stop("So what do you do?", 1);
   wait(250);
   say_stop("`9Oh, I'm a painter.", &current_sprite);
   wait(250);
   say_stop("Ahh, I see.  What are you painting here?", 1);
   wait(250);
   say_stop("`9I hope to make a portrait of the parade happening soon.", &current_sprite);
   wait(250);
   say_stop("Hmm", 1);
  }
  if (&result == 3)
  {
   &wherex = sp_x(&current_sprite, -1);
   &wherey = sp_y(&current_sprite, -1);
   wait(400);
   say_stop("You know, I've heard some things about this parade.", 1);
   wait(250);
   say_stop("`9Yeah me too, everyone's happy as can be.", &current_sprite);
   wait(250);
   say_stop("`9The music can be heard all around the land.", &current_sprite);
   wait(250);
   say_stop("Yeah well ...", 1);
   wait(250);
   say_stop("I've heard different things...", 1);
   wait(250);
   say_stop("Like that Cast Knights are planning to come and kill everyone here.", 1);
   wait(250);
   say_stop("`9What...?", &current_sprite);
   wait(250);
   say_stop("`9You're kidding right?", &current_sprite);
   wait(250);
   say_stop("Wish I was, but I heard it myself just outside of town.", 1);
   wait(250);
   say_stop("`9We're all gonna die!", &current_sprite);
   wait(250);
   say_stop("We've gotta call off the parade.", 1);
   wait(250);
   say_stop("`9Wait no .. there's another answer.", &current_sprite);
   wait(250);
   say_stop("`9The Mayor, he knows some of the Royal guard of the land.", &current_sprite);
   wait(250);
   say_stop("`9If we can convince him, maybe we can save the parade.", &current_sprite);
   wait(250);
   say_stop("`9Follow me.", &current_sprite);
   &mayor = 1;
   //Move off screen
   if (&wherey < 200)
   {
    move_stop(&current_sprite, 2, 210, 1);
   }
   if (&wherey > 322)
   {
    move_stop(&current_sprite, 6, 660, 1);
   }
   if (&wherex < 500)
   {
   move_stop(&current_sprite, 6, 440, 1);
   }
   if (&wherex > 500)
   {
    move_stop(&current_sprite, 2, 250, 1);
   }
   move_stop(&current_sprite, 6, 660, 1);
   sp_active(&current_sprite, 0);
  }

  if (&result == 4)
  {
   int &woman;
   &woman = &current_sprite;
   //Playmidi("planning.mid");
   wait(400);
   say_stop("Had any luck talking to people?", 1);
   wait(250);
   say_stop("`9Not really, no one's been here.", &woman);
   wait(250);
   say_stop("`9It's a yearly event and everyone knows when it is,", &woman);
   wait(250);
   say_stop("`9they don't come beforehand, they just show up.", &woman);
   wait(250);
   say_stop("That could be bad.", 1);
   wait(250);
   say_stop("`9I did hear one rumor though.", &woman);
   wait(250);
   say_stop("`9A man said he was traveling near the Goblin Sanctuary and one", &woman);
   wait(250);
   say_stop("`9attacked him.  Very rare these days.", &woman);
   wait(250);
   say_stop("That could be something, I'll check it out.", 1);
   wait(250);
  }


  if (&result == 5)
  {
   wait(400);
   say_stop("Take a look at this!", 1);
   say_stop("The Cast's battle plan for the city.", 1);
   wait(250);
   say_stop("`9My god, look at this plan.", &current_sprite);
   wait(250);
   say_stop("`9They aren't even focusing their attack at the military", &current_sprite);
   wait(250);
   say_stop("`9they're attacking the whole populace here.", &current_sprite);
   wait(250);
   say_stop("We've got to stop them!", 1);
   wait(250);
   say_stop("`9Quick, get this information to my father ... hurry!", &current_sprite);
  }
 unfreeze(1);
 wait(500);
 unfreeze(&current_sprite);
}

void hit( void )
{
 int &say;
 playsound(12, 22050, 0, 0, 0);

 &say = random(3,1);
 freeze(&current_sprite);
 if (&say == 1)
 {
  say_stop("`9Hey watch it sucka!", &current_sprite);
 }
 if (&say == 2)
 {
  say_stop("`9Help me, someone help me!", &current_sprite);
 }
 if (&say == 3)
 {
  say_stop("`9Guards, guards, tis a bloodbath!", &current_sprite);
 }
 unfreeze(&current_sprite);
}
