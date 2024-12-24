//for continue button

void main( void )
{
int &crap;
}

void buttonon( void )
{
sp_pframe(&current_sprite, 2);
Playsound(20,22050,0,0,0);
&crap = create_sprite(358, 93, 0, 200, 1);
sp_noclip(&crap, 1);
sp_seq(&crap, 200);
sp_reverse(&crap, 0);

}

void buttonoff( void )
{
sp_pframe(&current_sprite, 1);
Playsound(21,22050,0,0,0);
sp_brain(&crap, 7);
sp_reverse(&crap, 1);
sp_seq(&crap, 200);
}

void load( void )
{
Playsound(18,22050,0,0,0);
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

if (&result == 11)
   return;

if (game_exist(&result) == 0)
    return;



    stopmidi();
    stopcd();
     sp_active(1, 1);
   sp_x(1, 334);
   sp_y(1, 161);
   sp_base_walk(1, 70);
   sp_base_attack(1, 100);
    sp_dir(1, 4);
    sp_brain(1, 1);
    sp_que(1, 0);
    sp_noclip(1, 0);
    set_mode(2);
   //script now can't die when the load is preformed..

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

   load_game(&result);
  kill_this_task();
}

void click ( void )
{
sp_brain(1, 0);
load();
sp_brain(1, 13);
if (&result != 11)
Say_xy("`%Try loading a saved game that exists, friend.", 0, 390);

}
