void main( void )
{
 preload_seq(542);
 preload_seq(544);
 preload_seq(546);
 preload_seq(548);
 preload_seq(531);
 preload_seq(533);
 preload_seq(537);
 preload_seq(539);

 preload_seq(551);
 preload_seq(553);
 preload_seq(557);
 preload_seq(559);


 int &mcounter;
 sp_distance(&current_sprite, 50);
 sp_brain(&current_sprite, 9);
 sp_base_attack(&current_sprite, 540);
 sp_base_walk(&current_sprite, 530);
 sp_base_death(&current_sprite, 550);
 sp_strength(&current_sprite, 18);
 sp_exp(&current_sprite, 10);
 sp_hitpoints(&current_sprite, 20);
 sp_speed(&current_sprite, 1);
 sp_timing(&current_sprite, 33);
 sp_touch_damage(&current_sprite, 3);
 sp_target(&current_sprite, 1);

}

void die( void )
{
playsound(29, 17050,0,0, 0);
  
  &save_x = sp_x(&current_sprite, -1);
  &save_y = sp_y(&current_sprite, -1);
  external("ranstuff", "small");

  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 
}

void hit( void )
{
playsound(29, 22050,0,&current_sprite, 0);
sp_target(&current_sprite, &enemy_sprite);

}

void attack( void )
{
playsound(31, 22050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
}

