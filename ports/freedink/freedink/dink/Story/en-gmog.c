//Mog Enemy sprite script

void main( void )
{
	int &mcounter;
	sp_brain(&current_sprite, 16);
	sp_speed(&current_sprite, 1);
	sp_distance(&current_sprite, 50);
	sp_range(&current_sprite, 45);
	sp_frame_delay(&current_sprite, 50);
	sp_timing(&current_sprite, 0);
	sp_exp(&current_sprite, 150);
	sp_base_walk(&current_sprite, 780);
	sp_base_attack(&current_sprite, 770);
	sp_defense(&current_sprite, 4);
	sp_strength(&current_sprite, 20);
	sp_touch_damage(&current_sprite, 8);
	sp_hitpoints(&current_sprite, 50);
	preload_seq(772);
	preload_seq(774);
	preload_seq(776);
	preload_seq(778);
	preload_seq(785);
	
	preload_seq(781);
	preload_seq(783);
	preload_seq(787);
	preload_seq(789);
	sp_pframe(&current_sprite, 1);
	sp_pseq(&current_sprite, 789);
}


void hit( void )            
{
	sp_brain(&current_sprite, 9);
	sp_target(&current_sprite, &enemy_sprite);
	//lock on to the guy who just hit us
	//playsound
	playsound(28, 22050,0,&current_sprite, 0);
}

void die( void )
{
	//fix, must make it so that the monster isn't hit again.
	sp_nohit(&current_sprite, 1);
	screenlock(0);
	freeze(1);
	sp_touch_damage(&current_sprite, 0);
	sp_brain(&current_sprite, 0);
	sp_seq(&current_sprite, 0);
	sp_pseq(&current_sprite, 785);
	sp_pframe(&current_sprite, 1);
	//For screen fade & change
	int &wherex = sp_x(1, -1);
	int &wherey = sp_y(1, -1);

	say_stop("`4Please...", &current_sprite);
	wait(500);
	say_stop("`4I will tell you where the secret Cast camp is...", &current_sprite);
	wait(1000);
	fade_down();
	wait(2000);
	&gobpass = 5;
	script_attach(1000);

   //change maps and stuff ...
	&player_map = 489;
	sp_x(1, 226);
	sp_y(1, 386);
	load_screen(489);
	draw_screen();
	draw_status();
	fade_up();
	kill_this_task();
}

void attack( void )
{
	playsound(27, 22050,0,&current_sprite, 0);
	&mcounter = random(4000,0);
	sp_attack_wait(&current_sprite, &mcounter);
}


