void main( void )
{
 //The furers ..
 say_stop("`4Good day sir.", &current_sprite);
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
(&story < 11)"Ask about the store"
(&story > 10)"See what's up"
 "See what's for sale"
 "Leave"
 choice_end()
  if (&result == 1)
  {        
   say_stop("How's the fur trading industry going?", 1);
   wait(250);
   say_stop("`4Well, but not too many here buy the furs.", &current_sprite);
   wait(250);
   say_stop("`4Mainly just those traveling to the northlands.", &current_sprite);
   wait(250);
   say_stop("Do you worship the ducks here?", 1);
   wait(250);
   say_stop("`4Yes, but only because of the community.", &current_sprite);
   wait(250);
   say_stop("`4It is quite a strange ritual they have, I wonder", &current_sprite);
   wait(250);
   say_stop("`4how some of them can handle the stress of not eating", &current_sprite);
   wait(250);
   say_stop("`4for so long.", &current_sprite);
   wait(250);
   say_stop("Yeah, it's pretty weird.", 1);
   wait(250);
   say_stop("What do you do for food?", 1);
   wait(250);
   say_stop("`4Oh me?  Well I'm not from these parts, and know how to", &current_sprite);
   wait(250);
   say_stop("`4make foods from other things.  I live on soups and herbs,", &current_sprite);
   wait(250);
   say_stop("`4not the meat and eggs they're used to here.", &current_sprite);
  }
  if (&result == 2)
  {
   say_stop("Hi man, how's the store doing?", 1);
   wait(250);
   say_stop("`4Oh goodness, it's been going quite well sir Dink.", &current_sprite);
   wait(250);
   say_stop("`4I owe you a debt for saving my humble store.", &current_sprite);
   wait(250);
   say_stop("Aww come on, I didn't do that much.", 1);
   wait(250);
   say_stop("Just showed the people here what to eat.", 1);
   wait(250);
   say_stop("`4Perhaps sir Dink, but either way my business has benefited.", &current_sprite);
   wait(250);
   say_stop("`4I think the travelers have finally heard that there's", &current_sprite);
   wait(250);
   say_stop("`4no longer a famine here.", &current_sprite);
   wait(250);
   say_stop("`4Thank you Dink, and if there's anything you need, just ask.", &current_sprite);
  }
  if (&result == 3)
  {
   say_stop("What exactly do you have for sale?", 1);
   wait(250);
   say_stop("`4Hides from dead things.", &current_sprite);
   wait(250);
   say_stop("Ah.  Thanks.", 1);
   //Let Dink buy stuff ...
  }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 if (&story > 10)
 {
  say_stop("`3So that's your game, first save us, then kill us!", &current_sprite);
  return;
 }
 say_stop("`3Please no sir, I'm but a humble trader.", &current_sprite);
}
