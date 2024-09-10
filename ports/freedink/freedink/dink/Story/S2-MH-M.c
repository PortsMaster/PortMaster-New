void main( void )
{
 freeze(1);
 freeze(&current_sprite);

 say_stop("`0Welcome young BallWood.", &current_sprite);
 wait(250);
 say_stop("It's Smallwood sir.", 1);
 say_stop("`0Yes, now what did you want?", &current_sprite);
 unfreeze(1);
  unfreeze(&current_sprite);
}

void talk( void )
{
 if (&caveguy == 2)
 {
  freeze(1);
 freeze(&current_sprite);
  say_stop("Please.  Teach me some incredibly strong sorcerous enchantment!", 1);
  wait(250);
  say_stop("Er, to help the man trapped in the dungeon I mean.", 1);
  wait(250);
  if (&magic > 4)
  {
   say_stop("`0I sense you are powerful enough now Tallwood.", &current_sprite);
  wait(250);
   say_stop("`0You will now understand the Acid Rain magic.", &current_sprite);
  wait(250);
  say_stop("Rain?  Rain is the big magic you will teach?", 1);
  wait(250);
   say_stop("`0Scoff not child or you shall burn and kill yourself with it!", &current_sprite);
   //Give magic here
   add_magic("item-ice",437, 5);

   //SETH!!!
   //Give magic here
   //This magic will allow Dink to free the guy in the cave ..
   //Even though the guy only walks a few feet to be killed again anyway...
   //Ooops
   playsound(22,22050,0,0,0);
   &caveguy = 4;
   say_stop("I now have Rain Magic.  Yay.", 1);
   unfreeze(1);
  unfreeze(&current_sprite);
     return;
  }
  say_stop("`0I'm sorry Smallweed, but your magic is not powerful enough yet.", &current_sprite);
  wait(250);
  say_stop("`0You must have at least 5 magic for the new spell.", &current_sprite);
  &caveguy = 3;
  unfreeze(1);
  unfreeze(&current_sprite);
  return;
 }
 if (&caveguy == 3)
 {
 freeze(&current_sprite);
  freeze(1);
  //First check him
  if (&magic > 4)
  {
   say_stop("`0I sense you are powerful enough now Tallwood.", &current_sprite);
   wait(250);
   say_stop("`0You will now understand the Acid Rain magic.", &current_sprite);
  wait(250);
  say_stop("Rain?  Rain is the big magic you will teach?", 1);
  wait(250);
   say_stop("`0Scoff not child or you shall burn and kill yourself with it!", &current_sprite);
   //Give magic here
   add_magic("item-ice",437, 5);
   playsound(10,22050,0,0,0);
   &caveguy = 4;
   say_stop("I now have Rain Magic.  Yay.", 1);

   unfreeze(1);
  unfreeze(&current_sprite);
    return;
  }
  //Otherwise
  say_stop("`0You are still not powerful enough Brickwood.", &current_sprite);
  wait(250);
  say_stop("Smallwood sir.", 1);
  wait(250);
  say_stop("`0You need 5 magic for this spell.", &current_sprite);
  wait(500);
  sp_dir(1, 2);
  wait(500);
  say_stop("Aww man.", 1);
  unfreeze(1);
  unfreeze(&current_sprite);
  return;
 }
 freeze(1);
 freeze(&current_sprite);
 say_stop("Hey Mister, you know anymore magic you can teach me?", 1);
 wait(250);
 say_stop("`0No Smallwood, I'm too old and tired anyway.", &current_sprite);
 wait(250);
 say_stop("Ok, no problem... and my name isn't.. oh.", 1);

 unfreeze(1);
  unfreeze(&current_sprite);
}
 