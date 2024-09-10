void main( void )
{
sp_hitpoints(&current_sprite, 30);

}



void talk( void )
{

int &mcrap = count_item("item-bt");

 freeze(1);
 freeze(&current_sprite);
 choice_start();
        set_y 240
        set_title_color 5
        title_start();
"I'm a cobbler/pharmacist.  I make
special herb boots.  When the herb
touches your skin, you'll want to
dance and be hyper."
        title_end();
(&mcrap == 0) "Buy his boots ($500)"
(&mcrap == 0) "Complain about the price"
(&mcrap != 0) "Complain about the price"
"Leave"
 choice_end();

if (&result == 2)
  {
  wait(300);
  say_stop("You know, I bought the ones I'm wearing for only 1 piece of gold.", 1);
  wait(300);
  say_stop("`5You get what you pay for.", &current_sprite);
  wait(300);
  say_stop("Do you sell a lot of these?", 1);
  wait(300);
  say_stop("`5I've never sold one.", &current_sprite);
  wait(300);
  say_stop("Nice.", 1);
  }

if (&result == 3)
  {
  wait(300);
  say_stop("You know, the price is too much, could you please lower it?", 1);
  wait(300);
  say_stop("`5Sure, how about 2 gold?", &current_sprite);
  wait(300);
  say_stop("Great!  I'll take.. hey!", 1);
  wait(300);
  say_stop("I already bought them at the rip off price!", 1);
  wait(300);
  say_stop("`5What a pity.", &current_sprite);
  wait(300);
  say_stop("I would like to make a return.", 1);
  wait(300);
  say_stop("`5And I would like to ask you to leave.", &current_sprite);
  }


  if (&result == 1)
    {
     if (&gold < 500)
       {
        say("I don't have enough money!", 1);
       }
       else
       {

int &junk = free_items();


if (&junk < 1)
 {
         choice_start()
        set_y 240
        title_start();
You are carrying too much.
        title_end();
         "Ok"
         choice_end()
unfreeze(1);
unfreeze(&current_sprite);

 return;
 }



        say("`0* HYPER BOOTS BOUGHT *", 1);
         playsound(43, 22050,0,0,0);
         &gold -= 500;
 add_item("item-bt",438, 22);
       
       }
    }

unfreeze(1);
unfreeze(&current_sprite);


}

void hit( void )
{
say("`5Help!!! Murderer!", &current_sprite);

}
