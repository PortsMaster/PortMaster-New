//slime brain

void main( void )
{
sp_brain(&current_sprite, 9);
sp_speed(&current_sprite, 1);
sp_exp(&current_sprite, 8);
sp_timing(&current_sprite, 20);
sp_hitpoints(&current_sprite, 15);
sp_touch_damage(&current_sprite, 6);
preload_seq(651);
preload_seq(653);
preload_seq(661);
preload_seq(663);
sp_base_attack(&current_sprite, -1);
sp_base_walk(&current_sprite,690);
sp_base_death(&current_sprite, 700);
                              
if (random(2,1) == 1)
 {
 sp_target(&current_sprite, 1);
 }
}


void touch( void )
{
//slurp noise

 playsound(38, 18050, 6000, 0, 0);

}


void hit( void )
{
sp_target(&current_sprite, &enemy_sprite);
//lock on to the guy who just hit us
//playsound
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
