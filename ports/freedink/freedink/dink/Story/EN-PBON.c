//Bonca..medium strength

void main( void )
{
int &mcounter;
screenlock(1);
sp_brain(&current_sprite, 9);
sp_speed(&current_sprite, 1);
sp_nohit(&current_sprite, 0);
sp_distance(&current_sprite, 50);
sp_timing(&current_sprite, 0);
sp_exp(&current_sprite, 25);
sp_base_walk(&current_sprite, 610);
sp_base_death(&current_sprite, 550);
sp_base_attack(&current_sprite, 620);
sp_defense(&current_sprite, 3);
sp_strength(&current_sprite, 8);
sp_touch_damage(&current_sprite, 5);
sp_hitpoints(&current_sprite, 30);
preload_seq(611);
preload_seq(613);
preload_seq(617);
preload_seq(619);
preload_seq(621);
preload_seq(623);
preload_seq(627);
preload_seq(629);


preload_seq(542);
preload_seq(544);
preload_seq(546);
preload_seq(548);

}


void hit( void )
{
playsound(29, 22050,0,&current_sprite, 0);

sp_target(&current_sprite, &enemy_sprite);
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
external("emake","medium");
}

void attack( void )
{
playsound(31, 22050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
}


