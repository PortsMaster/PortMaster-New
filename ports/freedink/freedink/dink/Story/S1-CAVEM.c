void main( void )
{
debug("Wizard see is &wizard_see..");

 if(&wizard_see < 2)
 {
  sp_active(&current_sprite, 0);
  return;
 }
 //fixed Pap's error here!!!

 if(&wizard_see > 2)
 {

  sp_active(&current_sprite, 0);
  return;
 }
 int &mcounter;
 int &bot;
 preload_seq(541);
 preload_seq(543);
 preload_seq(547);
 preload_seq(549);
 preload_seq(531);
 preload_seq(533);
 preload_seq(537);
 preload_seq(539);
 sp_distance(&current_sprite, 50);
 sp_base_attack(&current_sprite, 540);
 sp_base_walk(&current_sprite, 530);
 sp_strength(&current_sprite, 5);
 sp_touch_damage(&current_sprite, 2);
 sp_hitpoints(&current_sprite, 35);
 sp_exp(&current_sprite, 100);
 int &mcrap = sp(36);
 if (&mcrap > 0)
         {
         //duck is still alive, lets have the monster target it for fun     
         sp_target(&current_sprite, &mcrap);
         } else
         {
         //if no duck, Dink becomes the new target!
          sp_target(&current_sprite, 1);
         }

 playmidi("battle.mid");
 &bot = random(2,1);
 if (&bot == 1)
 {
  &bot = random(3,1);
  if (&bot == 1)
  {
   say_stop("`3Who dares enter my cave?", &current_sprite);
  }
  if (&bot == 2)
  {
   say_stop("`3I sense someone in my domain.", &current_sprite);
  }
  if (&bot == 3)
  {
   say_stop("`3I feel I'm threatened ...", &current_sprite);
  }
 }
}

void die( void )
{
freeze(&current_sprite);
sp_seq(&current_sprite, 0);
&wizard_see = 3;
playsound(29, 17050,0,0, 0);
//make mini explosions?
playmidi("wanderer.mid");

wait(2000);
//draw dead body
//kill_this_task();
}

void hit( void )
{
playsound(29, 22050,0,&current_sprite, 0);
}

void attack( void )
{
playsound(31, 22050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
}

