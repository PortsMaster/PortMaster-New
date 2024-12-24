void main( void )
{
 int &talker;
 &talker = 0;
}

void touch( void )
{
 if (&story > 10)
 {
  move_stop(1, 2, 318, 1);
  say_stop("`9Thank you for feeding us Dink,", &current_sprite);
  say_stop("`9We all are in your debt.", &current_sprite);
  return;
 }
 if (&talker == 1)
 {
  move_stop(1, 2, 318, 1);
  say_stop("`9Please, go away.", &current_sprite);
  return;
 }
 freeze(1);
 move_stop(1, 2, 318, 1);
 sp_dir(1, 8);
 say_stop("`9What do you want?", &current_sprite);
 choice_start()
(&talker == 0)"Ask to come in"
 "Never Mind"
 choice_end()
  if (&result == 1)
  {
   say_stop("May I come in?", 1);
   wait(250);
   say_stop("`9Have you come with food?  My children are starving!", &current_sprite);
   wait(250);
   say_stop("I ... I don't have any food, I'm sorry.", 1);
   say_stop("Why are you starving?", 1);
   wait(250);
   say_stop("`9I shouldn't talk to you anymore,", &current_sprite);
   say_stop("`9please, just go.", &current_sprite);
   &talker = 1;
  }
 wait(250);
 unfreeze(1); 
}
                   
