//slime/puddle green, weak

void main( void )
{
sp_brain(&current_sprite, 9);
sp_speed(&current_sprite, 1);
sp_timing(&current_sprite, 10);
sp_exp(&current_sprite, 3);
sp_base_walk(&current_sprite, 670);
sp_base_death(&current_sprite, 680);
sp_base_attack(&current_sprite, -1);
sp_touch_damage(&current_sprite, 3);
sp_hitpoints(&current_sprite, 13);
preload_seq(671);
preload_seq(673);
preload_seq(681);
preload_seq(683);

if (random(2,1) == 1)
 {
 sp_target(&current_sprite, 1);
 }
}


void hit( void )
{
sp_target(&current_sprite, &enemy_sprite);
//lock on to the guy who just hit us
//playsound
sp_timing(&current_sprite, 0);
}

void die( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 
}
