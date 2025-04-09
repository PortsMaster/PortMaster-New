void main( void )
{
int &randy;
sp_hitpoints(&current_sprite, 20);
int &crap;
}

void talk( void )
{



if (get_sprite_with_this_brain(9, &current_sprite) == 0)
 {
  Playmidi("love.mid");


  //no more brain 9 monsters here, lets unlock the screen
  freeze(1);
  freeze(&current_sprite);

   say_stop("Mary, are you alright?", 1);
   wait(500);
   say_stop("`#Thanks to you.  Who are you?", &current_sprite);
   wait(500);
   choice_start();
   "A friend of the land."
   "A hero, in other words, your magic man."
   "Your worst nightmare."
   "The leader of another and more sadistic cult"
   choice_end();
   wait(500);

   say_stop("`#I see.  You will always be a hero to me.", &current_sprite);
   wait(500);
   say_stop("Time to go home.  Follow me.", 1);
   dink_can_walk_off_screen(1);
   move(1, 2, 700, 1);
   move(&current_sprite, 2, 700, 1);
   script_attach(1000);
   fade_down();
&player_map = 66;
load_screen(66);
freeze(1);
draw_screen();
sp_x(1, 320);
sp_y(1, 480);

 //build little girls
 &temp2hold = create_sprite(320,480, 0, 0, 0);
 
 sp_script(&temp2hold, "s2-qgirl");
 freeze(&temp2hold);
 freeze(&temp1hold);
 Debug("Ok, mother is &temp1hold and chick is &temp2hold");
 fade_up();
 wait(1500);

move_stop(1, 8, 353, 1)
move_stop(1, 9, 391, 1)
move_stop(1, 4, 388, 1)
wait(800);
say_stop("`5Why.. Dink.  What are you doing here?", &temp1hold);

wait(500);
say_stop("I brought someone with me.", 1);
wait(500);
  move_stop(&temp2hold, 8, 292, 1)
  say_stop("`#Mother!", &temp2hold);
  wait(500);
  say_stop("`5Oh Mary!  You are home!",&temp1hold);
  wait(500);
  say_stop("`#This man saved me from some naughty people!", &temp2hold);
  wait(500);
  say_stop("`5Dink, thank you.  If you ever need anything, just ask.",&temp1hold);
  wait(500);
say_stop("I was just doing my job, ma'am.", 1);
&s2-nad = 3;
&story = 8;
wait(500);
  unfreeze(&temp1hold);
  unfreeze(&temp2hold);

  unfreeze(1);
   dink_can_walk_off_screen(0);
    kill_this_task();
 }



&randy = random(3, 1);

 if (&randy == 1)
 say("`#Help me!", &current_sprite);
 if (&randy == 2)
 say("`#Save me!", &current_sprite);
 if (&randy == 3)
 say("`#I wanna go home!", &current_sprite);

}

void hit ( void )
{
 playsound(12, 22050, 0, 0, 0);
}


void die ( void )
{
 &life = 0;
 say("Noooooooooooo!  The girl has died! I HAVE FAILED!!!!", 1);
}
