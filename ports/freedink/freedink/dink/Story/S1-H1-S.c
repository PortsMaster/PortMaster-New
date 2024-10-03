void main ( void )
{
if (&story == 3)
{
 freeze(1);
 &vision = 1;
 wait(1000);
 say_stop("Mother noooooo!", 1);
 move_stop(1, 8, 259, 0);
 move_stop(1, 4, 203, 0);
 move_stop(1, 8, 151, 0);
 wait(200);
 say_stop("Mother, you can't die, nooo I  I ...", 1);
 wait(200);
 say_stop("never knew how much I really cared about you", 1);
 say_stop("until now.", 1);
 wait(250);
 say_stop("Ahh, too much smoke .... gotta get out ...", 1);
 &story = 4;
 move_stop(1, 2, 259, 0);
 move_stop(1, 6, 321, 0);
 move_stop(1, 2, 398, 0);
 return;
}
if (&story > 3)
{
 if (&letter == 1)
  {
  Debug("Why am I here...story is &story and letter is &letter");
  &vision = 2;
  int &thing;
  &thing = create_sprite(404, 220, 0, 422, 5);
  sp_script(&thing,"s1-ltr");
  move_stop(1, 8, 370, 1);
  say("There's that letter.", 1);
  wait(500);
  move_stop(1, 8, 185, 1);
  move_stop(1, 6, 373, 1);
  return;
  }
 &vision = 2;
 say("My old home ...", 1);
  return;
}

}
