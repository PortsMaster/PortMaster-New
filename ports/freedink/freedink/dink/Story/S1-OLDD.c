void main( void )
{
}
                
void talk( void )
{
freeze(1);
freeze(&current_sprite);
    choice_start();
   "Tell the duck to go home"
   "Yell at it"
    choice_end();
   if (&result == 1)
   {
 wait(500);
 say_stop("Hey little duck, you gotta get home to Ethel.", 1);
 wait(500);
 say_stop("`0QUACK!!", &current_sprite);
 wait(500);
   }
   if (&result == 2)
   {
 wait(500);
 say_stop("You suck little duck guy, not even I run away from home.", 1);
 wait(250);
 say_stop("You should be ashamed.", 1);
 wait(500);
 say_stop("`0Bite me", &current_sprite);
 wait(250);
 say_stop("`0But fine, I'll go home...", &current_sprite);
 wait(500);
 &old_womans_duck = 2;
 sp_speed(&current_sprite, 2);
 sp_timing(&current_sprite, 0);

 move_stop(&current_sprite, 8, -12, 1);
 sp_active(&current_sprite, 0);

   }
unfreeze(1);
unfreeze(&current_sprite);
}

void die( void )
{
 &old_womans_duck = 3;
 say_stop("Haw haw!", 1);
}


