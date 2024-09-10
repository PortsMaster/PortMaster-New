void main( void )
{
sp_hitpoints(&current_sprite, 40);

}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 if (&mayor == 6)
 {
  say_stop("Hey, uhh ... where did everyone go?", 1);
  wait(250);
  say_stop("`6The parade's over already man.", &current_sprite);
  wait(250);
  say_stop("`6Everyone took off.", &current_sprite);
  wait(250);
  say_stop("That quick?!?", 1);
  wait(250);
  say_stop("`6I don't know man, I just work here.", &current_sprite);
  &mayor = 7;
  unfreeze(1);
  wait(500)
  unfreeze(&current_sprite);
  return;
 }
 if (&mayor == 7)
 {
  say_stop("Hey, uhh ... where did everyone go?", 1);
  wait(250);
  say_stop("`6I already told you buddy, they left.", &current_sprite);
  wait(250);
  say_stop("`6What are you, some kind of freak?", &current_sprite);
  wait(250);
  say_stop("I see ...", 1);
 }
 unfreeze(1);
 wait(500)
 unfreeze(&current_sprite);
}

void hit( void )
{
 freeze(&current_sprite);
 say_stop("`6Like oowwww man.", &current_sprite);
 wait(500);
 unfreeze(&current_sprite);
}
