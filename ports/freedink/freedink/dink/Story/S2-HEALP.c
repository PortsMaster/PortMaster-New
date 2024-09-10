//script for store manager, actually attached to the bench

void main( void )
{

 int &crap = create_sprite(185,150, 0, 0, 0);
 &temphold = &crap;
 int &amount = 0;

preload_seq(241);
preload_seq(243);
int &myrand;
sp_brain(&temphold, 0);
sp_base_walk(&temphold, 240);
sp_speed(&temphold, 0);

//set starting pic

sp_pseq(&temphold, 243);
sp_pframe(&temphold, 1);

mainloop:
wait(500);
&myrand = random(8, 1);

  if (&myrand == 1)
  {
  sp_pseq(&temphold, 243);
  }

  if (&myrand == 2)
  {
  sp_pseq(&temphold, 241);
  }

goto mainloop;
}

void buybottle( void)
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


if (&gold < 25)
 {
         choice_start()
        set_y 240
        title_start();
You don't have enough gold to buy elixer.
        title_end();
         "Ok"
         choice_end()
 return;
 }

&gold -= 25;
add_item("item-eli",438, 9);

}


void hit( void )
{
sp_speed(&current_sprite, 0);
wait(400);
say_stop("`%Please don't wreck the place, thanks.", &temphold);
wait(800);
goto mainloop;
}

void talk( void )
{

 freeze(1);
startok:

if (&life >= &lifemax)
{
 choice_start();
        set_y 240
        set_title_color 15
        title_start();
"You are the perfect picture of health, sir."
        title_end();
         "Buy a bottle of elixer for $25"
         "Leave"
 choice_end();

  if (&result == 1)
  {
  buybottle();
  }
   unfreeze(1);
   goto mainloop;
   return;
}


}
startchoice:
&amount = &lifemax;
&amount -= &life;

         choice_start()
        set_y 240
        set_title_color 15
        title_start();
"You are injured!  It will cost $&amount gold to heal you."
        title_end();
         "Get healed"
         "Buy a bottle of elixer for $25"
         "Leave"
         choice_end()

if (&result == 1)
  {
   if (&gold < &amount)
   {
         choice_start()
        set_y 240
        title_start();
You don't have enough gold.
        title_end();
         "Ok"
         choice_end()
   goto startchoice;    
   }
&life = &lifemax;
&gold -= &amount;
Playsound(22,22050,0,0,0);
say("I am healed.", 1);
 unfreeze(1);
 goto mainloop;
  }

  if (&result == 2)
  {
   buybottle();
  }

   unfreeze(1);
   goto mainloop;
   return;

}

