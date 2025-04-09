//script for store manager, actually attached to the bench

void main( void )
{

preload_seq(347);
preload_seq(349);
int &myrand;
&temp3hold = &current_sprite;
sp_brain(&current_sprite, 0);
sp_base_walk(&current_sprite, 340);
sp_speed(&current_sprite, 0);

//set starting pic

sp_pseq(&current_sprite, 349);
sp_pframe(&current_sprite, 1);
}


void hit( void )
{
wait(400);
say_stop("`3Ouch!", &current_sprite);
}


