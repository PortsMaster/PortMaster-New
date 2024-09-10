//pillbug brain

void main( void )
{
int &fsave_x;
int &kcrap;
int &fsave_y;
int &resist;
int &mcounter;
int &mtarget;
sp_brain(&current_sprite, 10);
sp_timing(&current_sprite, 66);
sp_speed(&current_sprite, 1);
sp_nohit(&current_sprite, 0);
sp_exp(&current_sprite, 400);
sp_base_walk(&current_sprite, 200);
sp_base_death(&current_sprite, 210);
sp_touch_damage(&current_sprite, 10);
sp_hitpoints(&current_sprite, 80);
sp_defense(&current_sprite, 8);
preload_seq(202);
preload_seq(204);
preload_seq(206);
preload_seq(208);
preload_Seq(70);
preload_Seq(166);

set_callback_random("target",500,2000);

}

void target( void )
{
    //get new target
&kcrap = random(2, 1);
if (&life < 1)
  &kcrap = 2;

if (&kcrap == 1)
 {
 sp_target(&current_sprite, 1);
 return;
 }

        &mtarget = get_sprite_with_this_brain(9, &current_sprite);
        if (&mtarget > 0)
          {

           &mtarget = get_rand_sprite_with_this_brain(9, &current_sprite);
           sp_target(&current_sprite, &mtarget);
          }

}




void attack( void )
{

  playsound(47, 22050,0,0,0);

        &kcrap = sp_target(&current_sprite, -1);
&fsave_x = sp_x(&kcrap, -1);
&fsave_y = sp_y(&kcrap, -1);
        &mcounter = random(5000,3000);
        sp_attack_wait(&current_sprite, &mcounter);

&resist = random(40, 1);

//if NPC, turn off resist option
if (&kcrap != 1)
&resist = 100000;

if (&resist > &magic)
        {
        say("`4<Casts harm>", &current_sprite);

        playsound(31, 12050,0,0, 0);
        hurt(&kcrap, 20);

        &fsave_y -= 29;
        int &spark = create_sprite(&fsave_x, &fsave_y, 7, 70, 1);
        sp_seq(&spark, 70);
        sp_que(&spark, -70);
        sp_speed(&spark, 5);
        return;
        }

        playsound(31, 44050,0,0, 0);
        &fsave_y -= 29;
        int &spark = create_sprite(&fsave_x, &fsave_y, 7, 166, 1);
        sp_seq(&spark, 166);
        sp_que(&spark, -70);
        say("Magic resisted.", &kcrap);
}

void hit( void )
{
sp_target(&current_sprite, &enemy_sprite);
playsound(46, 17050, 4000, &current_sprite, 0);
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

 external("emake","xlarge");

}
