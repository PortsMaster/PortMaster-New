//Bonca..medium strength

void main( void )
{
int &mcounter;
sp_brain(&current_sprite, 9);
sp_speed(&current_sprite, 1);
sp_distance(&current_sprite, 50);
sp_timing(&current_sprite, 33);
sp_exp(&current_sprite, 30);
sp_base_walk(&current_sprite, 530);
sp_base_death(&current_sprite, 550);
sp_base_attack(&current_sprite, 540);
sp_defense(&current_sprite, 3);
sp_strength(&current_sprite, 8);
sp_touch_damage(&current_sprite, 4);
sp_hitpoints(&current_sprite, 20);

int &mtarget = get_sprite_with_this_brain(9, &current_sprite);
if (&mtarget > 0)
  {
   sp_target(&current_sprite, &mtarget);
  }
preload_seq(531);
preload_seq(533);
preload_seq(537);
preload_seq(539);
preload_seq(551);
preload_seq(553);
preload_seq(557);
preload_seq(559);


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


