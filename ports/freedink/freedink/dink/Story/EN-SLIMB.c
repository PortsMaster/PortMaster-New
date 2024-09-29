//slime/puddle blue, medium

void main( void )
{
sp_brain(&current_sprite, 9);
sp_speed(&current_sprite, 1);
sp_timing(&current_sprite, 10);
sp_hitpoints(&current_sprite, 25);
sp_exp(&current_sprite, 14);
sp_base_walk(&current_sprite, 650);
sp_base_death(&current_sprite, 660);
sp_touch_damage(&current_sprite, 3);
preload_seq(651);
preload_seq(653);
preload_seq(661);
preload_seq(663);

if (random(2,1) == 1)
 {
 sp_target(&current_sprite, 1);
 }


}


void touch( void )
{
//slurp noise
 playsound(38, 18050, 6000, 1, 0);
}

void hit( void )
{
sp_target(&current_sprite, &enemy_sprite);
//lock on to the guy who just hit us
//playsound
sp_speed(&current_sprite, 1);
 playsound(38, 38050, 6000, 1, 0);

}

void die( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 

&save_x = sp_x(&current_sprite, -1);
&save_y = sp_y(&current_sprite, -1);
external("emake","small");


}
