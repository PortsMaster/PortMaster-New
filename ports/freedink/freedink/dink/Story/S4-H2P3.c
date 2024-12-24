void main( void )
{
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 if (&story > 10)
 {
  say_stop("Hi little girl ..", 1);
  wait(250);
  say_stop("`1Hi mister, thanks for letting us all eat.", &current_sprite);
  wait(250);
  say_stop("You're welcome.", 1);
  unfreeze(1);
  unfreeze(&current_sprite);
  return;
 }
 choice_start()
 "Say hi"
 "Ask about food"
 "Never mind"
 choice_end()
  if (&result == 1)
  {
   say_stop("Hi little girl ..", 1);
   wait(250);
   say_stop("`1Hi mister.", &current_sprite);
  }
  if (&result == 2)
  {
   say_stop("Do you get to eat much little girl?", 1);
   wait(250);
   say_stop("`1Not much lately, mommy says we can't eat that much,", &current_sprite);
   say_stop("`1because of the ducks.", &current_sprite);
   wait(250);
   say_stop("`1I don't like the ducks.", &current_sprite);
  }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 say_stop("`2No mister!", &current_sprite);
}
