void main( void )
{
int &mrandom;
}

void hit( void )
{

&mrandom = random(3, 1);

 if (&mrandom == 1)
 say_stop("`4Watch it boy, even my temper may wear eventually.", &current_sprite);
 if (&mrandom == 2)
 say_stop("`4Oh, a warrior are you? <chuckle>", &current_sprite);
 if (&mrandom == 3)
 say_stop("`4Nice... Have you been practicing that on your pigs?", &current_sprite);


}


void talk( void)
{
move_stop(1, 2, 193, 1);
move_stop(1, 8, 190, 1);
 if (&story == 5)
 {
 freeze(1);
 &letter = 1;
 say_stop("`4Sorry about what happened Dink, I hope you're ok.", &current_sprite);
 say_stop("Thanks, I'll be ok.", 1);
 wait(250);
 say_stop("`4By the way, a letter came for you.  It's at your house,", &current_sprite);
 say_stop("`4you should go take a look at it.", &current_sprite);
 wait(250);
 say_stop("Thanks.", 1);
 unfreeze(1);
 return;
 }
freeze(1);


choice_start();
"Ask the guard to let you out."
"Forget it"
choice_end();
wait(200);
if (&result == 1)
  {
  say_stop("Hey, guard Renton.  I need to go do something, please let me out.", 1);
  wait(200);
  say_stop("`4It's much too dangerous for a boy out there, Dink.", &current_sprite);
  wait(200);
  say_stop("Boy?  Please refer to me as warrior from now on.", 1);
  wait(200);
  say_stop("`4Hardly... go tend your livestock. <chuckle>", &current_sprite);

  }
unfreeze(1);



}
