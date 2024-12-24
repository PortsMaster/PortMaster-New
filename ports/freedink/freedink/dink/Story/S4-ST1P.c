void main( void )
{
 int &talker;
 &talker = 0;
 int &bsword;
 int &b2sword;
 int &bclaw;
 int &bnut; 
 int &bad;
 if (&story > 10)
 {
  &talker = 2;
  return;
 }
 &bad = random(3, 1);
 if (&bad == 1)
 {
  &bad = random(3, 1);
  if (&bad == 1)
  {
  say_stop("`2Welcome to Jill's pawn shop.", &current_sprite);
  }
  if (&bad == 2)
  {
  say_stop("`2Oh, too have some food ...", &current_sprite);
  }
  if (&bad == 3)
  {
  say_stop("`2The ducks ... the ducks ...", &current_sprite);
  }
 }
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
(&talker == 0)"See what's news"
(&talker == 1)"See what's for sale"
(&talker == 2)"Say hi"
 "Sell an item"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   say_stop("How's things been here lately?", 1);
   wait(250);
   say_stop("`2Oh just fine sir, thanks for asking.", &current_sprite);
   wait(250);
   say_stop("What's with all the ducks?", 1);
   wait(250);
   say_stop("`2Those ducks are our friends and keepers", &current_sprite);
   say_stop("`2they've given us all we have today.", &current_sprite);
   wait(1000);
   say_stop("Okay, that's the weirdest statement I think I've heard today.", 1);
   wait(250);
   say_stop("`2Be kind to the ducks in this town.", &current_sprite);
   wait(250);
   say_stop("Sure, no problem.", 1);
   &talker = 1;
  }
  if (&result == 2)
  {
   say_stop("Uh, do you have anything for sale?", 1);
   wait(250);
   say_stop("`2Well, I ... I'm afraid not right now sir.", &current_sprite);
   wait(250);
   say_stop("Why not?", 1);
   wait(250);
   say_stop("`2With the taxes being raised for the ducks,", &current_sprite);
   wait(250);
   say_stop("`2I've been forced to sell much of what I own to pay it.", &current_sprite);
   wait(250);
   say_stop("I see.", 1);
   wait(250);
   say_stop("`2Perhaps if you were to find me at a later date.", &current_sprite);
   wait(250);
   say_stop("`2Just, not right now.", &current_sprite);
  }
  if (&result == 3)
  {
   say_stop("Hi Jill, how are you doing?", 1);
   wait(250);
   say_stop("`2Oh Dink, thank you, thank you for saving us.", &current_sprite);
   wait(250);
   say_stop("`2I didn't know what was going to happen to the town.", &current_sprite);
   wait(250);
   say_stop("`2I've been doing fine, things are definitely doing better.", &current_sprite);
   wait(250);
   say_stop("`2Thank you.", &current_sprite);
  }
  if (&result == 4)
  {
   goto sell;
  }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 if (&story > 10)
 {
  say_stop("`2What kind of sick traitor are you?!?", &current_sprite);
  return;
 }
 say_stop("`2Please, don't beat me sir.", &current_sprite);
 wait(250);
}

void sell(void )
{
//let's sell some stuff back

sell:

//how many items do they have?

&bsword = count_item("item-sw1");
&b2sword = count_item("item-sw2");
&bclaw = count_item("item-cl");
&bnut = count_item("item-nut");

         choice_start()
        set_y 240
        set_title_color 6
        title_start();
"We'll buy a few things.  What have you got?"
        title_end();
       (&bsword > 0)  "Sell a Longsword - $200"
       (&bnut > 0)  "Sell a nut - $2"
       (&b2sword > 0)  "Sell a Clawsword - $1000"
       (&bclaw > 0)  "Sell a slayer claw - $150"
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

if (&result == 3)
    {
     kill_this_item("item-sw2");
     &gold += 1000;
    goto sell;
    }
if (&result == 4)
    {
     kill_this_item("item-cl");
     &gold += 150;
    goto sell;
    }

   unfreeze(1);
   goto mainloop;
   return;
}
