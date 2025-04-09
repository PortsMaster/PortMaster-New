void main( void )
{
}

void touch( void )
{
 if (&story > 10)
 {
  move_stop(1, 4, 397,1 );
  sp_dir(1, 6);
  say_stop("`6Ahh Dink, thank you, thank you!", &current_sprite);
  return;
 }
 freeze(1);
 move_stop(1, 4, 397,1 );
 sp_dir(1, 6);
 say_stop("`6Who's there?", &current_sprite);
 wait(250);
 say_stop("My name's Dink.", 1);
 wait(250);
 say_stop("`6Never mind that.", &current_sprite);
 say_stop("`6Do you have food?", &current_sprite);
 wait(250);
 say_stop("Nope ...", 1);
 wait(250);
 say_stop("`6I need food!", &current_sprite);
 wait(250);
 say_stop("Sorry ...", 1);
 wait(250);
 say_stop("`6Then go away!!", &current_sprite);
 unfreeze(1); 
}
