//slayer

void main( void )
{
int &mcounter;
sp_brain(&current_sprite, 9);
sp_speed(&current_sprite, 1);
sp_distance(&current_sprite, 60);
sp_range(&current_sprite, 45);
sp_frame_delay(&current_sprite, 45);
sp_timing(&current_sprite, 0);
sp_exp(&current_sprite, 200);
sp_base_walk(&current_sprite, 640);
//sp_base_death(&current_sprite, 680);
sp_base_attack(&current_sprite, 630);
sp_defense(&current_sprite, 5);
sp_strength(&current_sprite, 20);
sp_touch_damage(&current_sprite, 10);
sp_hitpoints(&current_sprite, 100);
preload_seq(632);
preload_seq(634);
preload_seq(636);
preload_seq(638);

preload_seq(641);
preload_seq(643);
preload_seq(647);
preload_seq(649);

}


void hit( void )
{
sp_target(&current_sprite, &enemy_sprite);
//lock on to the guy who just hit us
//playsound
playsound(28, 22050,0,&current_sprite, 0);

}

void die( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 
&save_x = sp_x(&current_sprite, -1);
&save_y = sp_y(&current_sprite, -1);
external("emake","xlarge");

}
void attack( void )
{
playsound(27, 22050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
}


