void main( void )
{
 int &talker;
 &talker = 0;
 int &smell;
 &smell = random(3, 1);
 if (&smell == 1)
 {
  say_stop("`6Good day to ye sir.", &current_sprite);
 }
 if (&smell == 2)
 {
  say_stop("`6Arrr, I miss the sea ...", &current_sprite);
 }
}


void buys1( void)
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


if (&gold < 400)
 {
         choice_start()
        set_y 240
        set_title_color 6
        title_start();
You don't have enough gold to buy this sword, landlubber!
        title_end();
         "Ok"
         choice_end()
 return;
 }

&gold -= 400;
add_item("item-sw1",438, 7);

}


void buy( void )
{
buy:
         choice_start()
        set_y 240
        set_title_color 6
        title_start();
"Arrr, feast your eyes on these fine tools..."
        title_end();
         "Longsword - $400"
         "Bomb - $20"
         "Clawsword - $2000"
         "Leave"
         choice_end()

          if (&result == 1)
          {
           buys1();
           unfreeze(1);
           goto mainloop;
           return;

          }
          if (&result == 2)
          {
           buybomb();
           unfreeze(1);
           goto mainloop;
           return;

          }

          if (&result == 3)
          {
           buysw2();
           unfreeze(1);
           goto mainloop;
           return;

          }


   unfreeze(1);
   goto mainloop;
   return;

}

void buybomb( void)
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


if (&gold < 20)
 {
         choice_start()
        set_y 240
        set_title_color 6
        title_start();
You don't have enough gold to buy this bomb, mate!
        title_end();
         "Ok"
         choice_end()
 return;
 }

&gold -= 20;
add_item("item-bom",438, 3);

}

void buysw2( void)
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


if (&gold < 2000)
 {
         choice_start()
        set_y 240
        set_title_color 6
        title_start();
Arr! You don't have enough gold to buy the Clawsword!
        title_end();
         "Ok"
         choice_end()
 return;
 }
&gold -= 2000;
add_item("item-sw2",438, 20);
}


void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
(&talker == 0)"Ask about the store"
(&talker == 1)"Ask about Pete"
 "See what's for sale"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   say_stop("Nice store here, what is it?", 1);
   wait(250);
   say_stop("`6What be this place ye ask?  Can't ya tell?!", &current_sprite);
   wait(250);
   say_stop("`6This be Blistering Pete's weapons shop,", &current_sprite);
   wait(250);
   say_stop("`6Sharpest blades this side of the sea.", &current_sprite);
   &talker = 1;
  }
  if (&result == 2)
  {
   say_stop("Are you a pirate?", 1);
   wait(250);
   say_stop("`6Arr, I used to be ...", &current_sprite);
   wait(250);
   say_stop("`6one of the best I might add.", &current_sprite);
   wait(250);
   say_stop("Well, what are you doing here?", 1);
   wait(250);
   say_stop("Aren't you supposed to be out on the high seas collecting booty?", 1);
   wait(250);
   say_stop("`6I used to live that lifestyle, blood on me blade,", &current_sprite);
   wait(250);
   say_stop("`6rum in me gut, and plunder in the hold.", &current_sprite);
   wait(250);
   say_stop("`6But, a small run in with the Royal navy,", &current_sprite);
   wait(250);
   say_stop("`6has forced me to lay low for a while.", &current_sprite);
   wait(250);
   say_stop("`6But rest assured my treasure awaits me", &current_sprite);
   wait(250);
   say_stop("`6right where I buried it!", &current_sprite);
   wait(500);
   say_stop("`6Why are ye asking?", &current_sprite);
   wait(250);
   say_stop("Just, just wondering sir.", 1);
  }
  if (&result == 3)
  {                                         f
 
  goto buy;
   //Stuff here
  }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 if (&story > 10)
 {
  say_stop("`6I'll kill ye, hero.", &current_sprite); 
 }
 say_stop("`6Don't challenge me boy, I'll give you a wooden leg!!", &current_sprite);
}
