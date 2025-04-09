void main( void )
{
int &crap;
int &randx;
int &randy;
int &fally;

}

void talk( void )
{
say_stop("Hey, that's an AlkTree.", 1);
wait(250);
}

void hit( void )
{
         &crap = scripts_used();
if (&crap > 170)
  {
  //don't make any more nuts, there are 165 already on the screen..)
  return;
  }

//lets make the nut fall down and give it a nut script
&randx = random(200,320);
&randy = random(80,0);
&crap = create_sprite(&randx, &randy, 0, 421, 23);
sp_speed(&crap, 1);
move_stop(&crap, 8, 86, 1)
&fally = random(80,110);
sp_script(&crap, "s1-nut");
move_stop(&crap, 2, &fally, 1)

}
