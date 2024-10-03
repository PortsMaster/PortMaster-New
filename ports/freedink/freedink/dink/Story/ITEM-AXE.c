//item axe

void use( void )
{
  int &stm;
&mydir = sp_dir(1, -1);

if (sp_dir(1, -1) == 1)
    sp_dir(1, 4);
if (sp_dir(1, -1) == 3)
    sp_dir(1, 6);
if (sp_dir(1, -1) == 7)
    sp_dir(1, 4);
if (sp_dir(1, -1) == 9)
    sp_dir(1, 6);

playsound(8, 8000,0,0,0);

&basehit = sp_dir(1, -1);
&basehit += 320;

sp_seq(1, &basehit);
sp_frame(1, 1); //reset seq to 1st frame
sp_kill_wait(1); //make sure dink will punch right away
sp_nocontrol(1, 1); //dink can't move until anim is done!
 &mholdx = sp_x(1, -1);
 &mholdy = sp_y(1, -1);
//freeze(1);

 wait(100);

if (&mydir == 1)
  {
  &mholdx -= 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 85, 1);
  sp_seq(&junk, 85); 
  sp_mx(&junk, -6);
  sp_my(&junk, +2);

  }




if (&mydir == 4)
  {
  &mholdx -= 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 85, 1);
  sp_seq(&junk, 85); 
  sp_dir(&junk, 4);
  }

if (&mydir == 6)
  {
//  &mholdy -= 10; 
  &mholdx += 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 85, 1);
  sp_seq(&junk, 85); 
  sp_dir(&junk, 6);
  }

if (&mydir == 3)
  {
  &mholdx += 30;

  &junk = create_sprite(&mholdx, &mholdy, 11, 85, 1);
  sp_seq(&junk, 85); 
  sp_mx(&junk, +6);
  sp_my(&junk, +2);

  }




if (&mydir == 2)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 85, 1);
  sp_seq(&junk, 85); 
  sp_dir(&junk, 2);
  }

if (&mydir == 7)
  {
  &mholdx -= 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 85, 1);
  sp_seq(&junk, 85); 
  sp_mx(&junk, -6);
  sp_my(&junk, -2);

  }


if (&mydir == 8)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 85, 1);
  sp_seq(&junk, 85); 
  sp_dir(&junk, 8);
  }

if (&mydir == 9)
  {
  &mholdx += 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 85, 1);
  sp_seq(&junk, 85); 
  sp_mx(&junk, +6);
  sp_my(&junk, -2);

  }



//create fake shadow effect

  sp_timing(&junk, 0);
  sp_speed(&junk, 6);
  
  sp_strength(&junk, 15);
  if (&strength > 25)
  {
     &stm = &strength;
     &stm -= 10;
     sp_strength(&junk, &stm);
   }
  sp_range(&junk, 10);
  //this makes it easier to hit stuff
  sp_flying(&junk, 1);
  sp_attack_hit_sound(&junk, 48);
  sp_attack_hit_sound_speed(&junk, 13000);
  &mshadow = create_sprite(&mholdx, &mholdy, 15, 432, 3);
  sp_brain_parm(&mshadow, &junk);
  sp_que(&mshadow, -500);

  //will be drawn under everything

  //set fireball to not be able to damage Dink or the shadow
  sp_brain_parm(&junk, 1);
  sp_brain_parm2(&junk, &mshadow);

unfreeze(1);
}

void disarm(void)
{
kill_this_task();
}

void arm(void)
{
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



Debug("Preloading ice");

int &basehit;
int &mholdx;
int &mholdy;
int &junk;
int &mshadow;
int &mydir;
preload_seq(85);
preload_seq(94);
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


