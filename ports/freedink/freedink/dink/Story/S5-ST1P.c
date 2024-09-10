void main( void )
{
 int &play;
}


void hit( void )
{
 &play = random(3, 1);
 if (&play == 1)
 {
  say_stop("`2Must you hit me?", &current_sprite);
 }
 if (&play == 2)
 {
  say_stop("`2You're a murderer aren't you?", &current_sprite);
 }
 if (&play == 3)
 {
  say_stop("`2So, hitting the owner of a weapons store huh?", &current_sprite);
  say_stop("`2Some people.", &current_sprite);
 }
}


void buyaxe( void)
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
 return;
 }


if (&gold < 3000)
 {
         choice_start()
        set_y 240
        title_start();
You don't have enough gold to buy this.
        title_end();
         "Ok"
         choice_end()
 return;
 }

&gold -= 3000;
add_item("item-axe",438, 6);

}




void talk( void )
{
         choice_start()
        set_y 240
        set_title_color 2
        title_start();
"What will it be, hero?"
        title_end();
         "Throwing Axe - $3000"
         "Leave"
         choice_end()

          if (&result == 1)
          {
           buyaxe();
           unfreeze(1);
           return;

          }

   unfreeze(1);
   return;

}
