//Bonca..strong 

void main( void )
{
//can't get out of screen until this dude is DEAD
int &mcounter;

sp_brain(&current_sprite, 9);
sp_speed(&current_sprite, 2);
sp_nohit(&current_sprite, 0);
sp_distance(&current_sprite, 50);
sp_frame_delay(&current_sprite, 30);
sp_range(&current_sprite, 30);
sp_timing(&current_sprite, 0);
sp_exp(&current_sprite, 120);
sp_base_walk(&current_sprite, 600);
sp_base_death(&current_sprite, 550);
sp_base_attack(&current_sprite, 590);
sp_defense(&current_sprite, 0);
sp_strength(&current_sprite, 10);
sp_touch_damage(&current_sprite, 5);
sp_hitpoints(&current_sprite, 40);
preload_seq(601);
preload_seq(603);
preload_seq(607);
preload_seq(609);

preload_seq(551);
preload_seq(553);
preload_seq(557);
preload_seq(559);


preload_seq(592);
preload_seq(594);
preload_seq(596);
preload_seq(598);

wait(500);
int &mtarget = get_sprite_with_this_brain(9, &current_sprite);
if (&mtarget > 0)
  {
   sp_target(&current_sprite, &mtarget);
  }

set_callback_random("target",2000,0);

}


void target( void )
{
&mtarget = sp_target(&current_sprite, -1);

if (&mtarget == 0)
   {
    //get new target

        &mtarget = get_sprite_with_this_brain(9, &current_sprite);
        if (&mtarget > 0)
          {
           sp_target(&current_sprite, &mtarget);
          }

   }

}

void hit( void )
{
playsound(29, 18050,0,&current_sprite, 0);

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
external("emake","large");
}

void attack( void )
{
playsound(31, 18050,0,&current_sprite, 0);
&mcounter = random(2000,0);
sp_attack_wait(&current_sprite, &mcounter);

}


