void main( void )
{
int &mcounter;
sp_distance(&current_sprite, 62);
sp_range(&current_sprite, 50);
sp_defense(&current_sprite, 6);
sp_strength(&current_sprite, 12);
sp_touch_damage(&current_sprite, 5);
sp_hitpoints(&current_sprite, 100);
sp_target(&current_sprite, 1);
sp_exp(&current_sprite, 150);

preload_seq(742);
preload_seq(744);
preload_seq(746);
preload_seq(748);
preload_seq(301);
preload_seq(303);
preload_seq(305);
preload_seq(307);
preload_seq(309);


}

void hit( void )
{
//playsound(29, 22050,0,&current_sprite, 0);

sp_target(&current_sprite, 1);
}


void die( void )
{
if (get_sprite_with_this_brain(9, &current_sprite) == 0)
 {
  //no more brain 9 monsters here, lets unlock the screen
  screenlock(0);
  playsound(43, 22050,0,0,0);
 }

&save_x = sp_x(&current_sprite, -1);
&save_y = sp_y(&current_sprite, -1);
external("emake","large");

void attack( void )
{
playsound(8, 5050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
}



}
