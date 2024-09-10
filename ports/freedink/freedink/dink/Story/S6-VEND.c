//hellfire man

void main( void )
{
 preload_seq(381);
 preload_seq(383);
 preload_seq(385);
 preload_seq(387);
 preload_seq(389);
 sp_base_walk(&current_sprite, 380);
 sp_hitpoints(&current_sprite, 50);
 sp_brain(&current_sprite, 16);
 sp_speed(&current_sprite, 1);
 sp_timing(&current_sprite, 33);

}

void hit( void )
{
 say("`5I suppose I'll be dead soon.  I'm not particularly worried.",&current_sprite);

}

void talk( void )
{

int &mcrap = count_magic("item-sfb");

 freeze(1);
 freeze(&current_sprite);


if (&mcrap > 0)
  {

  say_stop("`0Please sir, I have nothing else to sell.", &current_sprite);
  wait(400);
  say_stop("Sell me something else you bastard!", 1);
  wait(400);
  say_stop("`0Nope.", &current_sprite);
  wait(400);
  say_stop("What on earth are you doing in this cave anyway?",1);
  wait(400);
  say_stop("`0I was waiting for you.", &current_sprite);
  wait(400);
  say_stop("Do you have a family?", 1);
  wait(400);
  say_stop("`0No.", &current_sprite);
  wait(400);
  say_stop("Do you have a home?", 1);
  wait(400);
  say_stop("`0I do not.", &current_sprite);
  wait(400);
  say_stop("Your life just doesn't make sense to me.", 1);
  wait(400);
  say_stop("`0Life isn't supposed to make sense.", &current_sprite);
  wait(400);
  say_stop("And I suppose you know everything.", 1);
  wait(400);
  say_stop("`0Nope.  If I did, I doubt I would want to live it.", &current_sprite);
  wait(400);
  say_stop("I'll just be leaving now.", 1);
  unfreeze(1);
  unfreeze(&current_sprite);

  return;
  }

 choice_start();
        set_y 240
        set_title_color 0
        title_start();
"Hello, friend.  I will teach Hellfire magic for $1500 gold."
        title_end();
"Learn Hellfire"
"Leave"
 choice_end();

  if (&result == 1)
    {
     if (&gold < 1500)
       {
        say("I don't have enough money!", 1);
       }
       else
       {

int &junk = free_magic();


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


        say("`0* YOU LEARN HELLFIRE *", 1);
         playsound(43, 22050,0,0,0);
         &gold -= 1500;
 add_magic("item-sfb",437, 2);
       
       }
    }

unfreeze(1);
unfreeze(&current_sprite);


}
