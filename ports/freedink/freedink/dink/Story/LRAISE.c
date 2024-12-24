//raise their level

void raise( void )
{
playsound(33, 22000, 0, 0,0);
script_attach(1000);


   Playsound(10,22050,0,0,0);
wait(1000);
if (&level < 32)
  {
stop_entire_game(1);
   &level += 1;
        choice_start();
        set_y 240
        title_start();
YOU ARE NOW LEVEL &level

You may increase one of your attributes.
        title_end();
        "Increase Attack"
        "Increase Defense"
        "Increase Magic"
        choice_end();
    
  if (&result == 1)
  {
   &strength += 1;
  }
  if (&result == 2)
  {
   &defense += 1;
  }
  if (&result == 3)
  {
   &magic += 1;
  }

   &lifemax += 3;
	}
else
{
	&exp = 0;
	say("What a gyp!", 1);
}
draw_status();
kill_this_task();
}

