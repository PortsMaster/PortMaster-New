void main( void )
{
sp_hitpoints(&current_sprite, 30);
sp_base_walk(&current_sprite, 370);
preload_seq(371);
preload_seq(373);
preload_seq(375);
preload_seq(377);
preload_seq(379);
sp_speed(&current_sprite, 1);
sp_timing(&current_sprite, 33);
}

void talk( void )
{

if (&story < 14)
 {
 freeze(1);
 freeze(&current_sprite);

  say_stop("`5I am working on the most powerful bow in the world!", &current_sprite);
  wait(300);
  say_stop("Great!  Give it to me now!", 1);
  wait(300);
  say_stop("`5I'm not finished yet.  Come back later.", &current_sprite);
        unfreeze(1);
        unfreeze(&current_sprite);
        return;
 }

int &mcrap = count_item("item-b3");

 freeze(1);
 freeze(&current_sprite);
 choice_start();
        set_y 240
        set_title_color 5
        title_start();
"My masterpiece is finished!"
        title_end();
(&mcrap == 0) "Buy the FlameBow for $25,000"
"Leave"
 choice_end();
  if (&result == 1)
    {
     if (&gold < 25000)
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


        say("`0* FLAMEBOW BOUGHT *", 1);
         playsound(43, 22050,0,0,0);
         &gold -= 25000;
 add_item("item-b3",438, 13);
       }
    }

unfreeze(1);
unfreeze(&current_sprite);


}

void hit( void )
{
say("`5Help!!! Murderer!", &current_sprite);

}

void die ( void )
{

//come back in 5 mins

  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 

}
