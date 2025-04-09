void main( void )
{

int &mcounter;
}

void die( void )
{
	freeze(&current_sprite);
	say("`1Ahhhhhhh", &current_sprite);
	wait(400);
	sp_active(&current_sprite, 0);
}

void attack( void )
{
playsound(36, 22050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
sp_target(&current_sprite, 1);
}



