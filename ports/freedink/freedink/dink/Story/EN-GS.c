//slayer.. we don't have the death graphics yet, oh well

void main( void )
{
int &mcounter;
sp_brain(&current_sprite, 16);
sp_speed(&current_sprite, 1);
sp_distance(&current_sprite, 50);
sp_range(&current_sprite, 35);
sp_timing(&current_sprite, 0);
sp_frame_delay(&current_sprite, 55);
sp_exp(&current_sprite, 150);
sp_base_walk(&current_sprite, 800);
sp_base_attack(&current_sprite, 790);
sp_defense(&current_sprite, 2);
sp_strength(&current_sprite, 20);
sp_touch_damage(&current_sprite, 8);
sp_hitpoints(&current_sprite, 60);
preload_seq(792);
preload_seq(794);
preload_seq(796);
preload_seq(798);
preload_seq(805);

preload_seq(801);
preload_seq(803);
preload_seq(807);
preload_seq(809);
}


void hit( void )
{
sp_brain(&current_sprite, 9);
sp_target(&current_sprite, &enemy_sprite);
//lock on to the guy who just hit us
//playsound
playsound(28, 22050,0,&current_sprite, 0);

}

void talk( void )
{
 int &randy = random(4, 1);
 if (&randy == 1)
 say("`4Gro'k ki owab dakis gedi!", &current_sprite);
 if (&randy == 2)
 say("`4Tig glock sigre!", &current_sprite);
 if (&randy == 3)  
 say("`4Oston tewers inat'l meen o mistary!", &current_sprite);
 if (&randy == 4)
 say("`4Hoglim dack byork!", &current_sprite);

}


void die( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 
}
void attack( void )
{
playsound(27, 22050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
}


