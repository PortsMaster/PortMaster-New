void main( void )
{
 int &crap;
}

void hit( void )
{
  &crap = random(5, 1); 
if (&crap == 1)
 say_stop("`4OUCH!", &current_sprite);
if (&crap == 2)
 say_stop("`4There is a rock near the Duck Idol with a crack in it...", &current_sprite);
if (&crap == 3)
 say_stop("`4Please sir, don't hurt me, the talking tree of the east!", &current_sprite);
if (&crap == 4)
 say_stop("`4That one smarted!", &current_sprite);
if (&crap == 5)
 say_stop("`4That's gonna leave a mark!", &current_sprite);

}

void talk( void )
{
 say("It's an apple tree.", 1);

}
