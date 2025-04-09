void main( void )
{
}

void talk( void )
{
 freeze(1);
 say_stop("`0To get passage on the boat with Death", &current_sprite);
 say_stop("`0please order the full version.", &current_sprite);
 wait(200);
 say_stop("`0You'll be glad you did!", &current_sprite);
 move_stop(1, 2, 147, 1);
 wait(200);
 say_stop("Buy me please!", 1);
 if(&story > 4)
 {
 say_stop("My Mom's dead and I need a home.", 1);
 }
 unfreeze(1);
}
