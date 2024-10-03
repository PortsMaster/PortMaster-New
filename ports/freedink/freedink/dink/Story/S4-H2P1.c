//House 2 script for the mom person
void main( void )
{
 int &bad;
preload_seq(331);
preload_seq(221);
}

void talk( void )
{
 if (&story > 10)
 {
  freeze(1);
  say_stop("`5Ahh Dink, how can we ever repay you?", &current_sprite);
  say_stop("`5I'm so glad to see my child eat again thanks to you.", &current_sprite);
  wait(250);
	unfreeze(1);
  return;
 }
 freeze(1);
 choice_start()
 "See how the family's doing"
 "Never mind"
 choice_end()
  if (&result == 1)
  {
   say_stop("So how's the store doing?", 1);
   wait(250);
   say_stop("`5We, we don't have a store sir.", &current_sprite);
   wait(250);
   say_stop("How are you doing otherwise?  This town seems to be in a depression.", 1);
   wait(250);
   say_stop("`5Yes well, we give a lot to the ducks.", &current_sprite);
   wait(250);
   say_stop("Yeah, yeah, the ducks I know ...", 1);
   say_stop("what the hell have they given back to you?", 1);
  }
 unfreeze(1);
 //unfreeze(&current_sprite);
}

void hit( void )
{
 &bad = random(3, 1);
 if (&story > 10)
 {
  say_stop("`5But after saving us??  Nooo!", &current_sprite);
  return;
 }
 if (&bad == 1)
 {
  say_stop("`5Ahhh, No!", &current_sprite);
  say_stop("`5We need food, not hate.", &current_sprite);
 }
 if (&bad == 2)
 {
  say_stop("`5Not the fists, not the fists!!", &current_sprite);
 }
 if (&bad == 3)
 {
  say_stop("`5Please, don't beat a starving woman!", &current_sprite);
 }
}
