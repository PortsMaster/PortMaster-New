void main( void )
{
}


void talk( void )
{
   if (&wizard_see > 3)
   {
    return;
   }
 freeze(1);
 say_stop("Hey, it's a scroll from Martridge!", 1);
 say_stop("Let's see ...", 1);
 wait(200);
 say_stop("`0Dear Dink,", &current_sprite);
 say_stop("`0If you're able to see this then it means you", &current_sprite);
 say_stop("`0truly do possess the ability for magic.", &current_sprite);
 wait(200);
 say_stop("`0I unfortunately have been called away and cannot", &current_sprite);
 say_stop("`0instruct you any further.  But there are many", &current_sprite);
 say_stop("`0teachers out there, you will find one and further", &current_sprite);
 say_stop("`0your training.", &current_sprite);
 wait(200);
 say_stop("`0There are 200 gold pieces enclosed, spend them wisely.", &current_sprite);
 &gold += 200;
 wait(200);
 say_stop("`0For now I leave you with this, your first spell.", &current_sprite);
 say_stop("`0Enjoy it Dink, you've earned it.", &current_sprite);
 wait(200);
 say_stop("All right, my first spell! Maybe I can burn down some trees...", 1);
 wait(200);
   script_attach(1000);
 
 Playsound(22,22050,0,0,0);
 &wizard_see = 4;
 sp_brain_parm(&current_sprite, 5);
 sp_brain(&current_sprite, 12); 
 sp_touch_damage(&current_sprite, 0);
 sp_timing(&current_sprite, 0);
 &magic += 1;
 add_magic("item-fb",437, 1);
 say_stop("I now have fireball magic!", 1);

 unfreeze(1);
kill_this_task();
}
