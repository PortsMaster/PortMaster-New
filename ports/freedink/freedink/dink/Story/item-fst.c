//item fists

void use( void )
{
//disallow diagonal punches

if (sp_dir(1, -1) == 1)
    sp_dir(1, 2);
if (sp_dir(1, -1) == 3)
    sp_dir(1, 2);
if (sp_dir(1, -1) == 7)
    sp_dir(1, 8);
if (sp_dir(1, -1) == 9)
    sp_dir(1, 8);

&basehit = sp_dir(1, -1);
&basehit += 100; //100 is the 'base' for the hit animations, we just add
//the direction
sp_seq(1, &basehit);
sp_frame(1, 1); //reset seq to 1st frame
sp_kill_wait(1); //make sure dink will punch right away
sp_nocontrol(1, 1); //dink can't move until anim is done!
wait(1);
playsound(8, 8000,0,0,0);

}

void disarm(void)
{
debug("Killed fists");

kill_this_task();
}

void arm(void)
{
sp_attack_hit_sound(1, 0);
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
debug("fists armed");


int &basehit;
}

void pickup(void)
{
Debug("Player now owns this item.");
kill_this_task();
}

void drop(void)
{
Debug("Item dropped.");
kill_this_task();
}


