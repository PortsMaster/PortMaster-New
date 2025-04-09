//House 2 script for the DAD person
void main( void )
{
 int &neat;
}

void talk( void )
{
 if (&story > 10)
 {
  freeze(1);
  say_stop("`2Thank you, small one.", &current_sprite);
  wait(250);
  say_stop("Smallwood sir.", 1);
  wait(250);
  say_stop("`2Yes.", &current_sprite);
  unfreeze(1);
  return;
 }
 freeze(1);
 &neat = random(3, 1);
 if (&neat == 1)
 {
  say_stop("`2I'm too hungry to talk.", &current_sprite);
 }
 if (&neat == 2)
 {
  say_stop("`2Hello there.", &current_sprite);
 }
 if (&neat == 3)
 {
  say_stop("`2Welcome to our town.", &current_sprite);
 }
 unfreeze(1);
 //unfreeze(&current_sprite);
}

void hit( void )
{
 if (&story > 10)
 {
  say_stop("`2First feed us, then beat us, is that how it is with you?", &current_sprite);
  reutrn;
 }
 say_stop("`2Strange customs you have.", &current_sprite);
}
