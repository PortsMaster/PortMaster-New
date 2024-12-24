void main( void )
{
 int &what;
 &temp1hold = sp(7);
}

void touch( void )
{
 if (&story > 10)
 {
  move_stop(1, 2, 175,1 );
  sp_dir(1, 6);
  say("`3Thank you for saving us Dink!", &temp1hold);
  return;
 }
 &what = random(6, 1);
 freeze(1);
 move_stop(1, 2, 175,1 );
 sp_dir(1, 6);
 if (&what == 1)
 {
  say("`3It's locked.", &temp1hold);
 }
 if (&what == 2)
 {
  say("`3Go away.", &temp1hold);
 }
 if (&what == 3)
 {
  say("`3I hate you.", &temp1hold);
 }
 if (&what == 4)
 {
  say("`3Noooooooo!!", &temp1hold);
 }
 if (&what == 5)
 {
  say("`3You can't get in.", &temp1hold);
 }
 if (&what == 6)
 {
  say("`3Leave me alone.", &temp1hold);
 }
 unfreeze(1); 
}
