void main( void )
{
}

void talk( void )
{
 freeze(1);
 say_stop("`%House for Sale:  Contact Charlie for information.", &current_sprite);
 wait(250);
 sp_dir(1, 2);
 say_stop("I wonder who Charlie is ...", 1);
 unfreeze(1);
}
