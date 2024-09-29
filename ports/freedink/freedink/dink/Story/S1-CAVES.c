void main( void )
{
playmidi("insper.mid");
 int &mbot;
 &mbot = random(7,1);
 if (&mbot == 1)
 
 {
  say_stop("Smells damp in here.", 1);
 }
 if (&mbot == 2)
 
 {
  say_stop("I don't like this one bit...", 1);
 }
//call it once right now
noise();

set_callback_random("noise", 5000, 10000);

}

void noise( void )
{
if (&wizard_see > 2)
  {
  //killed monster already, why would it roar?
  return;
  }

playsound(32, 11000, 4000, 0, 0);
wait(4000);
int &bot = random(4,1);
if (&bot == 1)
say_stop("Can we leave now? <shiver>", 1);
if (&bot == 2)
say_stop("I'm scared.", 1);
if (&bot == 3)
say_stop("Why, that's a funny noise.", 1);

if (&bot == 4)
say_stop("This cave sucks, let's leave...", 1);

}
