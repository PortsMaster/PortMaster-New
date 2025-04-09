//bow lore man

void main( void )
{
 if (&bowlore > 0)
 {
  sp_active(&current_sprite, 0);
  return;
}
 preload_seq(381);
 preload_seq(383);
 preload_seq(385);
 preload_seq(387);
 preload_seq(389);
 sp_base_walk(&current_sprite, 380);
 sp_hitpoints(&current_sprite, 5);
 sp_brain(&current_sprite, 16);
 sp_speed(&current_sprite, 1);
 sp_timing(&current_sprite, 33);
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start();
        set_y 240
        set_title_color 4
        title_start();
"Hello, friend.  I will teach you bow lore for $1500 gold."
        title_end();
(&bowlore == 0) "Learn bow lore"
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
        say("`4* YOU LEARN BOW LORE *", 1);
         playsound(43, 22050,0,0,0);
         &bowlore = 1;
         &gold -= 1500;
       }
    }

unfreeze(1);
unfreeze(&current_sprite);


}

