void main( void )
{
 int &nut;
 int &talker;
 &talker = 0;
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 &nut = sp_dir(1, -1);
 if (&talker == 0)
 {
  say_stop("`3Hi, we are the giant ducks of Koka Isle.", &current_sprite);
  wait(250);
  say_stop("`3Who are you?", &current_sprite);
  wait(500);
  sp_dir(1, 2);
  wait(1000);
  sp_dir(1, &nut);
  wait(250);
  say_stop("Uh, I'm Dink.", 1);
  wait(250);
  say_stop("`3Hello Dink.", &current_sprite);
 }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 freeze(&current_sprite);
 say_stop("`3Quack.  No!!", &current_sprite);
 unfreeze(&current_sprite);
}

void die ( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 

}

