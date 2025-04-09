//crazy girl brain

void main( void )
{
screenlock(1);
sp_brain(&current_sprite, 9);
sp_speed(&current_sprite, 3);
sp_timing(&current_sprite, 0);
sp_exp(&current_sprite, 300);
sp_base_walk(&current_sprite, 330);
sp_touch_damage(&current_sprite, 20);
sp_hitpoints(&current_sprite, 100);
preload_seq(331);
preload_seq(333);
preload_seq(335);
preload_seq(337);
preload_seq(339);
sp_target(&current_sprite, 1);
say("`#FOOD!",&current_sprite);
}


void hit( void )
{
sp_target(&current_sprite, &enemy_sprite);
playsound(12, 12050, 10000, &current_sprite, 0);
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
