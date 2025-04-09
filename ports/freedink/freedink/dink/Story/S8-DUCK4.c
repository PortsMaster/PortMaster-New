void main( void )
{
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 say_stop("Hey duck, thanks for the game.", 1);
 wait(250);
 say_stop("`3Hey, no problem.", &current_sprite);
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 freeze(&current_sprite);
 say_stop("`3Hey man, don't make me put you in the arena!", &current_sprite);
 unfreeze(&current_sprite);
}
