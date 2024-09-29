//slayer.. we don't have the death graphics yet, oh well

void main( void )
{
int &mcounter;
sp_brain(&current_sprite, 9);
sp_target(&current_sprite, 1);
sp_speed(&current_sprite, 1);
sp_range(&current_sprite, 60);
sp_distance(&current_sprite, 60);
sp_timing(&current_sprite, 33);
sp_exp(&current_sprite, 400);
sp_base_walk(&current_sprite, 820);
sp_base_attack(&current_sprite, 810);
sp_defense(&current_sprite, 18);
sp_strength(&current_sprite, 35);
sp_touch_damage(&current_sprite, 25);
sp_hitpoints(&current_sprite, 40);
preload_seq(812);
preload_seq(814);
preload_seq(816);
preload_seq(818);
preload_seq(825);

preload_seq(821);
preload_seq(823);
preload_seq(827);
preload_seq(829);

}


void hit( void )
{
sp_brain(&current_sprite, 9);
sp_target(&current_sprite, &enemy_sprite);
//lock on to the guy who just hit us
//playsound
playsound(28, 28050,0,&current_sprite, 0);

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
playsound(27, 28050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
}


