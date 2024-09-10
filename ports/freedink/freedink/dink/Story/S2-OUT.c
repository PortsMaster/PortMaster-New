//script for store manager, actually attached to the bench

void main( void )
{
int &bsword;
int &bnut


 int &crap = create_sprite(180,260, 0, 0, 0);
 &temphold = &crap;


preload_seq(389);
preload_seq(383);
int &myrand;
sp_brain(&temphold, 0);
sp_base_walk(&temphold, 380);
sp_speed(&temphold, 0);

//set starting pic

sp_pseq(&temphold, 383);
sp_pframe(&temphold, 1);

mainloop:
wait(500);
&myrand = random(8, 1);

  if (&myrand == 1)
  {
  sp_pseq(&temphold, 383);
  }

  if (&myrand == 2)
  {
  sp_pseq(&temphold, 389);
  }

&myrand = random(20, 1);

  if (&myrand == 1)
  {
  say_stop_npc("`6Let me know if I can help you find something.", &temphold);
  }


goto mainloop;
}


void hit( void )
{
sp_speed(&current_sprite, 0);
wait(400);
say_stop_npc("`6Please don't wreck the place, thanks.", &temphold);
wait(800);  
goto mainloop;
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
        title_start();
You don't have enough gold to buy this sword.  Awk!
        title_end();
         "Ok"
         choice_end()
 return;
 }

&gold -= 400;
add_item("item-sw1",438, 7);

}

void buyb1( void)
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
        title_start();
You don't have enough gold to buy this bow.  Awk!
        title_end();
         "Ok"
         choice_end()
 return;
 }

&gold -= 400;
add_item("item-b1",438, 8);

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
        title_start();
You don't have enough gold to buy this bomb.  Awk!
        title_end();
         "Ok"
         choice_end()
 return;
 }

&gold -= 20;
add_item("item-bom",438, 3);

}

void sell(void )
{
//let's sell some stuff back

sell:

//how many items do they have?

&bsword = count_item("item-sw1");
&bnut = count_item("item-nut");

         choice_start()
        set_y 240
        set_title_color 6
        title_start();
"We'll buy a few things.  What have you got?"
        title_end();
       (&bsword > 0)  "Sell a Longsword - $200"
       (&bnut > 0)  "Sell a nut - $2"
        "Sell nothing"
        choice_end()

if (&result == 1)
    {
     kill_this_item("item-sw1");
     &gold += 200;
    goto sell;
    }

if (&result == 2)
    {
     kill_this_item("item-nut");
     &gold += 2;
    goto sell;
    }
   unfreeze(1);
   goto mainloop;
   return;


}


void buy( void )
{
buy:
         choice_start()
        set_y 240
        set_title_color 6
        title_start();
"Our wares are the finest quality around.  We'll beat any price!"
        title_end();
         "Longsword - $400"
         "Bomb - $20"
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


   unfreeze(1);
   goto mainloop;
   return;

}


void talk( void )
{

 freeze(1);
         choice_start()
        set_y 240
        set_title_color 6
        title_start();
"What can I do for you today, sir?"
        title_end();
         "Buy"
         "Sell"
         "Leave"
         choice_end()

   if (&result == 1)
           {
            goto buy;
           }

   if (&result == 2)
           {
            goto sell;
           }


   unfreeze(1);
   goto mainloop;
   return;

}

