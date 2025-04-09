void talk( void )
{
if (&story > 14)
  {
  say("`9Dink is alive!  Alive!", &current_sprite);
  return;
  }

 //guard 1
 say("`9You are a very brave man Sir Smallwood.", &current_sprite);
}

void hit( void )
{
int &dinky = sp_y(1, -1);
//get dinks y cord

if (&dinky < 280)
  {
   //dink is above them
   say_stop("`9Is that you up there Dink?", &current_sprite);

     wait(300);
   say_stop("`9Why are you trying to kill us?", &current_sprite);
   return;
  }
   say_stop("`9Don't kill us, we're on your side.", &current_sprite);


}

