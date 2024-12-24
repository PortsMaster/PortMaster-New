void main( void )
{
int &dumb = create_sprite(360, 300, 0, 64, 1);
sp_hard(&dumb, 0);
draw_hard_sprite(&dumb);
sp_disabled(&dumb, 1);

sp_base_walk(&current_sprite, 370);
sp_speed(&current_sprite, 3);
sp_timing(&current_sprite, 0);
}

void hit( void )
{
  say("`3Did something touch me?  A fly perhaps?", &current_sprite);

}

void talk( void )
{
 freeze(1);
 choice_start();
        set_y 240
        set_title_color 3
        title_start();
"Hello good sir, the bridge toll is 100 gold."
        title_end();
"Pay the toll"
"Argue"
"Leave"
 choice_end();

  if (&result == 1)
  {

 if (&gold < 100)
 {
 wait(500);
 say_stop("`3You don't have enough gold, fool!", &current_sprite);   
 unfreeze(1);
 return;
 }
 wait(500);
 say_stop("`3Thanks.  Have a nice day.", &current_sprite);   
 &gold -= 100;
 move_stop(&current_sprite, 4, -50, 1);
 &story = 7;
 unfreeze(1);
 sp_hard(&dumb, 1);
  force_vision(0);
// sp_active(&current_sprite, 0);

  kill_this_task();
 return;
  }

 if (&result == 2)
  {
 wait(500);
 say_stop("This is ridiculous.  How can you justify charging this much?",1);
 wait(500);
 say_stop("`3My kids need to eat.", &current_sprite);
 wait(500);
 say_stop("Does the king know about your little 'business'?", 1);
 wait(500);
 say_stop("`3Of course not.", &current_sprite);
 wait(500);
 say_stop("Ah, how nice.", 1);
  }


 unfreeze(1);
}
