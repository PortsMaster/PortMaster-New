void talk( void )
{

if (&story > 14)
  {
 say("`9Look Tom, Dink is back!", &current_sprite);
  return;
  }
 //guard 1
 say("`9This is the way Dink.  I wish you luck.", &current_sprite);
}

void hit( void )
{
int &dinky = sp_y(1, -1);
//get dinks y cord

if (&dinky < 280)
  {
   //dink is above them
   say_stop("`9Ouch,  that smarted.", &current_sprite);
   wait(300);
   say_stop("`9I wonder where that came from?", &current_sprite);
   return;
  }
   say_stop("`9Testing out your weapons?  They work a-ok, trust me.", &current_sprite);


}
