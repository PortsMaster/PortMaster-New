
void main( void )
{
int &mcounter;
sp_brain(&current_sprite, 0);
sp_speed(&current_sprite, 1);
sp_distance(&current_sprite, 50);
sp_range(&current_sprite, 35);
sp_timing(&current_sprite, 0);
sp_frame_delay(&current_sprite, 55);
sp_exp(&current_sprite, 150);
sp_base_walk(&current_sprite, 800);
sp_base_attack(&current_sprite, 790);
sp_defense(&current_sprite, 6);
sp_strength(&current_sprite, 25);
sp_hitpoints(&current_sprite, 80);
preload_seq(792);
preload_seq(794);
preload_seq(796);
preload_seq(798);
preload_seq(805);

preload_seq(801);
preload_seq(803);
preload_seq(807);
preload_seq(809);
}


void hit( void )
{
sp_brain(&current_sprite, 9);
sp_target(&current_sprite, &enemy_sprite);
//lock on to the guy who just hit us
//playsound
playsound(28, 22050,0,&current_sprite, 0);
sp_touch_damage(&current_sprite, 10);

}

void die( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 
}
void attack( void )
{
playsound(27, 22050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
}

void talk ( void )
{

int &temp;
&temp = sp_brain(&current_sprite, -1);
if (&temp == 9)
  {
  say("`6i bey kalling yoo deed!", &current_sprite);
  return; 
  }

freeze(1);
freeze(&current_sprite);
 choice_start()
(&gobpass == 0) "Ask the Goblin guard to let you in"
 "Incite an 'incident'"
 "Leave"
 choice_end()

 if (&result == 1)
 {
  wait(400);
  say_stop("Greetings my good fellow!  May I enter your fine establishment?", 1);
  wait(400);
  say_stop("`6hmm.", &current_sprite);
  wait(400);
  int &dumb = compare_weapon("item-b1");
debug("Dumb is &dumb");
  if (&dumb == 1)
    {
      if (&mayor != 3)
       {
        //if they have not talked to the mayor, let's not let them in.
  say_stop("`6hmm.. are yoo joon?? coom beck lader! too erly", &current_sprite);
  wait(400);
  unfreeze(1);
 unfreeze(&current_sprite);
  return;    

       }
     //they are holding the bow
   say_stop("`6ashee yoo hav bough. GATS OPAN!", &current_sprite);
playsound(43, 22050,0,0,0);

        &gobpass = 1;
        //remove gate
        &dumb = sp(3);
        sp_hard(&dumb, 1);
        draw_hard_sprite(&dumb);
        sp_active(&dumb, 0);
unfreeze(1);
unfreeze(&current_sprite);
  return;    
    }
  say_stop("`6erga hoomans NOT heenter!  leev!", &current_sprite);
  wait(400);
  say_stop("Oh come on, let me in!", 1);
  wait(400);
  say_stop("`6no bow?!!! un not joon! leev!!", &current_sprite);
 }

 if (&result == 2)
 {
  wait(400);
  say_stop("Say.  So how 'bout that war of '23?  You guys got beat back pretty hard.", 1);
  wait(400);
  say_stop("`6yoo ar engerang meee!", &current_sprite);
  wait(400);
  say_stop("I mean, King Daniel basically crushed you all like tiny bugs.", 1);
  wait(400);
  say_stop("`6reechard!?? yoo wheel bey daying now!", &current_sprite);
  sp_brain(&current_sprite, 9);
  sp_target(&current_sprite, 1);
 }

unfreeze(1);
unfreeze(&current_sprite);

}
