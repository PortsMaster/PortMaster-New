//script for tree

//fixing bad script for V1.03

void main( void )
{
preload_seq(167);
sp_hard(&current_sprite, 0);
draw_hard_sprite(&current_sprite);

}

void talk(void)
{
 say_stop("`0I'm tree years old.. HAW HAW HAW!", &current_sprite);
 wait(400);
 say_stop("That is also the LAMEST thing I've ever heard.", 1);
}

void die(void)
{
	say("`0Your magic is treely useless against me.. HAW HAW HAW!", &current_sprite);
	sp_hard(&current_sprite, 0);
	draw_hard_sprite(&current_sprite);
}
