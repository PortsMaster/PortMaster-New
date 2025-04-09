//pillbug brain

void main( void )
{
screenlock(1);
sp_brain(&current_sprite, 9);
sp_speed(&current_sprite, 2);
sp_timing(&current_sprite, 10);
sp_exp(&current_sprite, 100);
sp_base_walk(&current_sprite, 130);
sp_base_death(&current_sprite, 140);
sp_touch_damage(&current_sprite, 25);
sp_hitpoints(&current_sprite, 50);
preload_seq(131);
preload_seq(133);
preload_seq(141);
preload_seq(143);

if (random(2,1) == 1)
 {
 sp_target(&current_sprite, 1);
 }
}


void hit( void )
{
sp_target(&current_sprite, &enemy_sprite);
playsound(30, 15050, 4000, &current_sprite, 0);
//lock on to the guy who just hit us
//playsound
}
void die( void )
{

if (get_sprite_with_this_brain(9, &current_sprite) == 0)
 {
  //no more brain 9 monsters here, lets unlock the screen

  screenlock(0);
  playsound(43, 22050,0,0,0);

 }




  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 

&save_x = sp_x(&current_sprite, -1);
&save_y = sp_y(&current_sprite, -1);

 external("emake","large");

}
