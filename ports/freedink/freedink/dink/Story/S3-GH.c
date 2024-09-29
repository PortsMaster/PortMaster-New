//slayer.. we don't have the death graphics yet, oh well

void main( void )
{
int &mcounter;
sp_brain(&current_sprite, 16);
sp_speed(&current_sprite, 1);
sp_distance(&current_sprite, 50);
sp_timing(&current_sprite, 66);
sp_exp(&current_sprite, 150);
sp_base_walk(&current_sprite, 760);
//sp_base_death(&current_sprite, 780);
sp_base_attack(&current_sprite, 750);
sp_defense(&current_sprite, 1);
sp_strength(&current_sprite, 15);
sp_touch_damage(&current_sprite, 10);
sp_hitpoints(&current_sprite, 40);
preload_seq(752);
preload_seq(754);
preload_seq(756);
preload_seq(758);
preload_seq(765);

preload_seq(761);
preload_seq(763);
preload_seq(767);
preload_seq(769);

}


void hit( void )
{
sp_brain(&current_sprite, 9);
sp_target(&current_sprite, &enemy_sprite);
//lock on to the guy who just hit us
//playsound
playsound(28, 22050,0,&current_sprite, 0);

}


void talk( void )
{
 int &randy = random(4, 1);
 if (&randy == 1)
 say("`4Gro'k ki owab dakis gedi!", &current_sprite);
 if (&randy == 2)
 say("`4Tig glock sigre!", &current_sprite);
 if (&randy == 3)  
 say("`4Oston tewers inat'l meen o mistary!", &current_sprite);
 if (&randy == 4)
 say("`4Hoglim dack byork!", &current_sprite);

}
void die( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 

if (&gobpass == 1)
{
if (get_sprite_with_this_brain(9, &current_sprite) == 0)
 {
 if (get_sprite_with_this_brain(16, &current_sprite) == 0)
  {

  //no more brain 9 or 16 monsters here, lets introduce 'mog'
  spawn("s3-mog");
 }

 }

}
void attack( void )
{
playsound(27, 22050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);
}


