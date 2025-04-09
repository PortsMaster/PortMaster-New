//this is run when the escape key is pressed

void main(void)
{
int &old_result;
Playsound(18, 22050, 0,0,0);
freeze(1);
help:

        choice_start();
        "Load a previously saved game"
        "Restart"
        "Quit to system"
        "Help"
        "Continue"
        "View/change gamepad buttons"
        choice_end();


if (&result == 1)
  {
        choice_start();
        "&savegameinfo"
        "&savegameinfo"
        "&savegameinfo"
        "&savegameinfo" 
        "&savegameinfo" 
        "&savegameinfo" 
        "&savegameinfo" 
        "&savegameinfo" 
        "&savegameinfo" 
        "&savegameinfo" 
        "Nevermind"
        choice_end();
if (&result == 11) goto help;

if (game_exist(&result) == 0)
  {

  unfreeze(1);
  wait(2000);  
  Say("Wow, this loaded game looks so familiar.", 1);
  kill_this_task();
    return;
   }

init("load_sequence_now graphics\dink\walk\ds-w1- 71 43 38 72 -14 -9 14 9");
init("load_sequence_now graphics\dink\walk\ds-w2- 72 43 37 69 -13 -9 13 9");
init("load_sequence_now graphics\dink\walk\ds-w3- 73 43 38 72 -14 -9 14 9");
init("load_sequence_now graphics\dink\walk\ds-w4- 74 43 38 72 -12 -9 12 9");

init("load_sequence_now graphics\dink\walk\ds-w6- 76 43 38 72 -13 -9 13 9");
init("load_sequence_now graphics\dink\walk\ds-w7- 77 43 38 72 -12 -10 12 10");
init("load_sequence_now graphics\dink\walk\ds-w8- 78 43 37 69 -13 -9 13 9");
init("load_sequence_now graphics\dink\walk\ds-w9- 79 43 38 72 -14 -9 14 9");

init("load_sequence_now graphics\dink\idle\ds-i2- 12 250 33 70 -12 -9 12 9");
init("load_sequence_now graphics\dink\idle\ds-i4- 14 250 30 71 -11 -9 11 9");
init("load_sequence_now graphics\dink\idle\ds-i6- 16 250 36 70 -11 -9 11 9");
init("load_sequence_now graphics\dink\idle\ds-i8- 18 250 32 68 -12 -9 12 9");

init("load_sequence_now graphics\dink\hit\normal\ds-h2- 102 75 60 72 -19 -9 19 9");
init("load_sequence_now graphics\dink\hit\normal\ds-h4- 104 75 61 73 -19 -10 19 10");
init("load_sequence_now graphics\dink\hit\normal\ds-h6- 106 75 58 71 -18 -10 18 10");
init("load_sequence_now graphics\dink\hit\normal\ds-h8- 108 75 61 71 -19 -10 19 10");


  unfreeze(1);
  load_game(&result);
 &update_status = 1;
 draw_status();

  kill_this_task();
  }




if (&result == 3)
  {
        choice_start();
        "Yes, I really want to quit the game"
        "I was just kidding, back to the action, please"
        choice_end();
   if (&result == 2)
   {
    wait(300);
    say("Phew, that was a close one!",1);
   }
   if (&result == 1)
   {
   kill_game();
   }
  unfreeze(1);
  kill_this_task();
  }

  if (&result == 4)
  {
helpstart:
        choice_start();
        set_y 240
        title_start();




What would you like help on?
        title_end();
        "Keyboard commands"
        "How to save the game"
        "Done"
        choice_end();
Debug("Ok, result is &result");

      if (&result == 1)
     {
        choice_start();
        set_y 240
        title_start();
Ctrl = Attack/choose
Space = Talk/examine/skip text
Shift = Magic
Enter = Item/magic equip screen

Use the arrow keys to move.  Joystick and control pad are also supported.
        title_end();
        "Ok"
        choice_end();
       goto helpstart;
     }

      if (&result == 2)
     {
        choice_start();
        set_y 240
        title_start();
In this quest, saving your game can
only be done at the special 'Save
Machine'. (it hums strangely)

        title_end();
        "Ok"
        choice_end();
       goto helpstart;
     }


      if (&result == 3)
      {
       goto help;
      }


  }


if (&result == 2)
  {
        choice_start();
        "Yes, I really want to restart from scratch"
        "No, go back!"
        choice_end();
   if (&result == 2)
   {
   goto help;
   }
   if (&result == 1)
   {
   unfreeze(1);
   restart_game();
   kill_this_task();
   }
  unfreeze(1);
  kill_this_task();
  }

   if (&result == 6)
   {
   buttonstart:
        choice_start();
        "Button 1 - &buttoninfo"
        "Button 2 - &buttoninfo"
        "Button 3 - &buttoninfo"
        "Button 4 - &buttoninfo"
        "Button 5 - &buttoninfo"
        "Button 6 - &buttoninfo"
        "Button 7 - &buttoninfo"
        "Button 8 - &buttoninfo"
        "Button 9 - &buttoninfo"
        "Button 10 - &buttoninfo"
        "Nevermind"
        choice_end();

if (&result != 11)
  {
  &old_result = &result;
        choice_start();
        set_y 140
        title_start();
What should button &old_result do?
        title_end();
        "Attack"
        "Talk/look"
        "Magic"
        "Item screen"
        "Main menu"
        "View map (if you have one)"
        "Nevermind"
        choice_end();
  if (&result < 7)
   set_button(&old_result, &result);

   goto buttonstart;
  }
    
       goto help;

   }

   if (&result == 7)
   {
        choice_start();
        "&savegameinfo"
        "&savegameinfo"
        "&savegameinfo"
        "&savegameinfo" 
        "&savegameinfo" 
        "&savegameinfo" 
        "&savegameinfo" 
        "&savegameinfo" 
        "&savegameinfo" 
        "&savegameinfo" 
        "Nevermind"
        choice_end();

   save_game(&result);

   }

  unfreeze(1);
  kill_this_task();
}
    
