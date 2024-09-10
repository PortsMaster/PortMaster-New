//slayer

void main( void )
{
Debug("Running cslay.c");
freeze(1);
freeze(&current_sprite);
wait(500);
say_stop("`4Not bad.. not bad at all.", &current_sprite);
preload_seq(632);
preload_seq(634);
preload_seq(636);
preload_seq(638);

preload_seq(641);
preload_seq(643);
preload_seq(647);
preload_seq(649);
say_stop("It's all over, Nelson.", 1);
wait(500);
say_stop("`4Is it?", &current_sprite);
wait(500);
say_stop("`4I think you are about to be an important part of my new religion.", &current_sprite);
wait(500);
say_stop("And just what part is that?", 1);
wait(500);
say_stop("`4The martyr.", &current_sprite);
wait(500);
unfreeze(&current_sprite);

playsound(24, 22052, 0, 0, 0);

&temp1hold = sp_x(&current_sprite, -1);
&temp2hold = sp_y(&current_sprite, -1);
int &mcrap = create_sprite(&temp1hold,&temp2hold, 7, 167, 1);
sp_seq(&mcrap, 167);
int &mcounter;
sp_brain(&current_sprite, 9);
sp_speed(&current_sprite, 1);
sp_distance(&current_sprite, 70);
sp_range(&current_sprite, 60);
sp_timing(&current_sprite, 66);
sp_exp(&current_sprite, 200);
sp_base_walk(&current_sprite, 640);
//sp_base_death(&current_sprite, 680);
sp_target(&current_sprite, 1);
sp_base_attack(&current_sprite, 630);
sp_defense(&current_sprite, 5);
sp_strength(&current_sprite, 15);
sp_touch_damage(&current_sprite, 5);
sp_hitpoints(&current_sprite, 40);
sp_dir(&current_sprite, 9);
unfreeze(1);

say("`#He's a slayer shapeshifter!  No!!!!", &temp6hold);
}


void hit( void )
{
        sp_target(&current_sprite, 1);
        //lock on to the guy who just hit us
        //playsound
        playsound(28, 22050,0,&current_sprite, 0);

}

void die( void )
        {
          int &hold = sp_editor_num(&current_sprite);
          if (&hold != 0)
          editor_type(&hold, 6); 
         screenlock(0);
        }

void attack( void )
        {
        playsound(27, 22050,0,&current_sprite, 0);
        &mcounter = random(4000,0);
        sp_attack_wait(&current_sprite, &mcounter);
        }


