void main( void )
{
 int &hi;
 &hi = 0;
}


void buys3( void)
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


if (&gold < 4000)
 {
         choice_start()
        set_y 240
        title_start();
You are a little short of cash right now.
        title_end();
         "Ok"
         choice_end()
 return;
 }

&gold -= 4000;
add_item("item-sw3",438, 21);

}



void buyb2( void)
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


if (&gold < 5000)
 {
         choice_start()
        set_y 240
        title_start();
You are a little short of cash right now.
        title_end();
         "Ok"
         choice_end()
 return;
 }

&gold -= 5000;
add_item("item-b2",438, 12);

}


void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Say hi"
 "See what she has"
 "Leave"
 choice_end()
  if (&result == 1)
  {
  if (&story > 14)
    {
    say_stop("`2I see you are back, adventurer Smallwood.", &current_sprite);
   wait(250);
   say_stop("I killed Seth.", 1);
   wait(250);
   say_stop("`2Praise be!  You are a true hero, Dink!", &current_sprite);
    unfreeze(1);
    unfreeze(&current_sprite);
    return;


    }

   if (&hi == 1)
   {
    say_stop("`2Please Dink, you must hurry to your friend.", &current_sprite);
   wait(250);
   say_stop("But how!  Where is he?", 1);
   wait(250);
   say_stop("`2The portal is very close to here.  You will find it.", &current_sprite);
    unfreeze(1);
    unfreeze(&current_sprite);
    return;
   }
   say_stop("`2Ah, Dink, I've heard of you.", &current_sprite);
   wait(250);
   say_stop("`2I didn't think you'd be to these parts so quickly.", &current_sprite);
   &hi = 1;
   wait(250);
   say_stop("Sometimes I amaze even myself.", 1);
   wait(500);
   say_stop("How've things here been lately?", 1);
   wait(250);
   say_stop("`2Strange, I've seen a lot of movement out of the darklands.", &current_sprite);
   wait(250);
   say_stop("`2Seems they're pushing out into the world.", &current_sprite);
   wait(250);
   say_stop("Well, they can do all they want,", 1);
   wait(250);
   say_stop("but I have to find Milder!", 1);
   wait(250);
   say_stop("`2I'm sure time's running out for your friend Dink.", &current_sprite);
   wait(250);
   say_stop("`2For all we know they could've converted Milder to evil.", &current_sprite);
   wait(500);
   say_stop("`2Dink, if they keep getting stronger I fear my church", &current_sprite);
   wait(250);
   say_stop("`2will no longer be able to hold the evil off.", &current_sprite);
   wait(250);
   say_stop("What is the 'evil' you keep talking about?", 1);
   wait(250);
   say_stop("`2It is an abomination of nature.  I will not speak of it.", &current_sprite);
  }

  if (&result == 2)
  {

         choice_start()
        set_y 240
        set_title_color 2
        title_start();
"I only have a few things... power weapons I found near the 'machine'..."
        title_end();
         "Light Sword - $4000"
         "Massive Bow - $5000"
         "Leave"
         choice_end()

          if (&result == 1)
          {
           buys3();
           unfreeze(&current_sprite);
           unfreeze(1);
           return;
          }

          if (&result == 2)
          {
           buyb2();
           unfreeze(&current_sprite);
           unfreeze(1);
           return;
          }


   }


 unfreeze(1);
 wait(500);
 unfreeze(&current_sprite);
}

void hit( void )
{
 say("Hahaha!!", 1);
}
