void main( void )
{
 int &nut;
 int &talker;
 &talker = 1;
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 &nut = sp_dir(1, -1);
 if (&talker == 0)
 {
  say_stop("Hi giant duck.", 1);
  wait(250);
  say_stop("`3Hi there.", &current_sprite);
  wait(250);
  say_stop("`3Welcome to our island.", &current_sprite);
  wait(250);
  say_stop("Thanks.", 1);
  wait(250);
  say_stop("`3Would you like to play with me?", &current_sprite);
  wait(250);
  say_stop("Uhh, not right now, I'm ... busy.", 1);
  wait(250);
  say_stop("`3Okay, maybe later then.", 1);
  unfreeze(1);
  unfreeze(&current_sprite);
  &talker = 1;
  return;
 }
 if (&talker == 1)
 {
  say_stop("Hi giant duck.", 1);
  wait(250);
  say_stop("`3Hi there.", &current_sprite);
  wait(250);
  say_stop("`3Welcome to our island.", &current_sprite);
  wait(250);
  say_stop("Thanks.", 1);
  wait(250);
  say_stop("`3Would you like to play with me?", &current_sprite);
  choice_start()
  "Go ahead and play"
  "Not yet"
  choice_end()
  if (&result == 1)
  {
   &duckgame = 1;
   say_stop("Sure, let's play something.", 1);
   wait(250);
   say_stop("`3Okay, I have just the game, follow me.", &current_sprite);
   wait(250);
   script_attach(1000);
   //fadeout & cutscene?
   fade_down();
   //change maps and stuff ...
   &player_map = 731;
   sp_x(1, 112);
   sp_y(1, 300);
   load_screen();
   draw_screen();
   draw_status();
   fade_up();
   kill_this_task();
  }
  if (&result == 2)
  {
   say_stop("Sorry, not yet.", 1);
  }
 }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 freeze(&current_sprite);
 say_stop("`3This is not a fun game!!!", &current_sprite);
 unfreeze(&current_sprite);
}

void die ( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 

}


