void main( void )
{
int &hi;

 //people watching parade
 sp_hitpoints(&current_sprite, 20);
sp_brain(&current_sprite, 16);
}


void talk(void )

{
&hi = random(4, 1);

if (&hi == 1)
say("`3Isn't this wonderful?", &current_sprite);

if (&hi == 2)
say("`3Not a very long parade was it...", &current_sprite);
if (&hi == 3)
say("`3This was even better than last year!", &current_sprite);

if (&hi == 4)
 say("`3What a great parade!", &current_sprite);


}


void hit(void )

{

&hi = random(4, 1);

if (&hi == 1)
say("`3Help!  This man is going crazy!", &current_sprite);

if (&hi == 2)
say("`3Guards!!! Over here!!!", &current_sprite);
if (&hi == 3)
say("`3Help!! This Dink guy is no hero, he was behind the attack!", &current_sprite);

if (&hi == 4)
say("`3Please sir... please...no!!!  Come on, help me fight this guy!", &current_sprite);
sp_frame_delay(&current_sprite, 50);
sp_brain(&current_sprite, 9);
sp_touch_damage(&current_sprite, 5);
sp_speed(&current_sprite, 2);
sp_target(&current_sprite, 1);
}

void die( void )
{
if (get_sprite_with_this_brain(16, &current_sprite) == 0)
 {

if (get_sprite_with_this_brain(9, &current_sprite) == 0)
  {
  //no more brain 9 monsters here, lets unlock the screen
wait(1000);
 say("Now, THAT'S entertainment!", 1);
  }
 }

&save_x = sp_x(&current_sprite, -1);
&save_y = sp_y(&current_sprite, -1);
external("emake","medium");


}

