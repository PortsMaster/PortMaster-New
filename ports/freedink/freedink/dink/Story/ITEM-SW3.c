//item sword 3

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
wait(200);
playsound(8, 8000,0,0,0);

}

void disarm(void)
{
sp_attack_hit_sound(1, 0);

&strength -= 25;
sp_distance(1, 0);
sp_range(1, 0);
kill_this_task();
}

void arm(void)
{
//sword range
sp_distance(1, 50);
sp_range(1, 40);
//sword strength added
&strength += 25;

sp_attack_hit_sound(1, 10);
sp_attack_hit_sound_speed(1, 8000);
init("load_sequence_now graphics\dink\sword\walk\d-sw1- 71 43 64 69 -14 -10 14 10");
init("load_sequence_now graphics\dink\sword\walk\d-sw2- 72 43 35 70 -21 -10 19 10");
init("load_sequence_now graphics\dink\sword\walk\d-sw3- 73 43 28 69 -13 -9 13 9");
init("load_sequence_now graphics\dink\sword\walk\d-sw4- 74 43 66 75 -14 -12 20 12");

init("load_sequence_now graphics\dink\sword\walk\d-sw6- 76 43 27 69 -23 -10 23 10");
init("load_sequence_now graphics\dink\sword\walk\d-sw7- 77 43 38 94 -20 -10 20 10");
init("load_sequence_now graphics\dink\sword\walk\d-sw8- 78 43 30 96 -15 -12 15 12");
init("load_sequence_now graphics\dink\sword\walk\d-sw9- 79 43 31 80 -13 -9 13 9");

init("load_sequence_now graphics\dink\sword\idle\d-si2- 12 250 74 73 -17 -12 16 9");
init("load_sequence_now graphics\dink\sword\idle\d-si4- 14 250 57 103 -11 -12 16 10");
init("load_sequence_now graphics\dink\sword\idle\d-si6- 16 250 30 92 -15 -9 11 9");
init("load_sequence_now graphics\dink\sword\idle\d-si8- 18 250 35 106 -15 -12 15 9");

init("load_sequence_now graphics\dink\sword\hit\d-sa2- 102 75 52 92 -23 -12 24 11");
init("load_sequence_now graphics\dink\sword\hit\d-sa4- 104 75 74 90 -23 -13 23 14");
init("load_sequence_now graphics\dink\sword\hit\d-sa6- 106 75 33 92 -18 -14 18 10");
init("load_sequence_now graphics\dink\sword\hit\d-sa8- 108 75 46 109 -17 -16 17 10");
int &basehit;
}

void pickup(void)
{
Debug("Player now owns this item.");
kill_this_task();
}

void holdingdrop( void )
{
 //this is run if the item is dropped while it is armed
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

}

void drop(void)
{
Debug("Item dropped.");
kill_this_task();
}


