//item massive bow (+8)

void use( void )
{
        activate_bow();
        &mypower = get_last_bow_power();

         &mholdx = sp_x(1, -1);
         &mholdy = sp_y(1, -1);

        &mydir = sp_dir(1, -1);

if (&mypower < 100)
{
 return;
}


playsound(44, 22050,0,0,0);


  if (&mydir == 6)
  {
  &mholdx += 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 25, 6);
  sp_dir(&junk, 6);
  }

  if (&mydir == 4)
  {
  &mholdx -= 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 25, 4);
  sp_dir(&junk, 4);
  }

  if (&mydir == 2)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 25, 2);
  sp_dir(&junk, 2);
  }

  if (&mydir == 8)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 25, 8);
  sp_dir(&junk, 8);
  }

  if (&mydir == 9)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 25, 5);
  sp_dir(&junk, 9);
  }
  if (&mydir == 1)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 25, 1);
  sp_dir(&junk, 1);
  }
  if (&mydir == 7)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 25, 7);
  sp_dir(&junk, 7);
  }

  if (&mydir == 3)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 25, 3);
  sp_dir(&junk, 3);
  }

  &mypower / 100;
  &temp = &strength;
  &temp / 5;


  if (&temp == 0)
    {
     &temp = 1;
    }
  &mypower * &temp;
  sp_timing(&junk, 0);

  if (&bowlore == 1)
{
  &temp = random(2, 1);

  if (&temp == 1)
    {
     //critical hit
  &mypower * 3;
playsound(44, 14050,0,0,0);

  say("`4* POWER SHOT *", 1);
    }
 }
  sp_speed(&junk, 6);
  
  sp_strength(&junk, &mypower);
  sp_range(&junk, 10);
  //this makes it easier to hit stuff
  sp_flying(&junk, 1);
  sp_script(&junk, "dam-a1");
  //when the fireball hits something, it will look to this script, this way
  //we can burn trees when appropriate
  &mshadow = create_sprite(&mholdx, &mholdy, 15, 432, 3);
  sp_brain_parm(&mshadow, &junk);
  sp_que(&mshadow, -500);
  sp_brain_parm(&junk, 1);
  sp_brain_parm2(&junk, &mshadow);
  sp_nohit(&mshadow, 1);


return;
}

void disarm(void)
{
&strength -= 8;

kill_this_task();
}

void arm(void)
{
&strength += 8;
int &junk;
int &mydir;
int &mholdx;
int &mholdy;
int &mshadow;
int &mypower;
int &temp;
init("load_sequence_now graphics\dink\bow\walk\d-bw1- 71 43 30 84 -14 -10 14 10");
init("load_sequence_now graphics\dink\bow\walk\d-bw2- 72 43 29 86 -21 -10 19 10");
init("load_sequence_now graphics\dink\bow\walk\d-bw3- 73 43 35 79 -13 -9 13 9");
init("load_sequence_now graphics\dink\bow\walk\d-bw4- 74 43 41 79 -18 -12 20 12");

init("load_sequence_now graphics\dink\bow\walk\d-bw6- 76 43 47 78 -23 -10 23 10");
init("load_sequence_now graphics\dink\bow\walk\d-bw7- 77 43 46 71 -20 -10 20 10");
init("load_sequence_now graphics\dink\bow\walk\d-bw8- 78 43 35 76 -15 -12 15 12");
init("load_sequence_now graphics\dink\bow\walk\d-bw9- 79 43 46 78 -13 -9 13 9");

init("load_sequence_now graphics\dink\bow\idle\d-bi2- 12 250 35 87 -17 -12 16 9");
init("load_sequence_now graphics\dink\bow\idle\d-bi4- 14 250 37 77 -11 -12 16 10");
init("load_sequence_now graphics\dink\bow\idle\d-bi6- 16 250 35 83 -15 -9 11 9");
init("load_sequence_now graphics\dink\bow\idle\d-bi8- 18 250 33 70 -15 -12 15 9");

init("load_sequence_now graphics\dink\bow\hit\d-ba2- 102 75 27 89 -23 -12 24 11");
init("load_sequence_now graphics\dink\bow\hit\d-ba4- 104 75 76 79 -23 -13 23 14");
init("load_sequence_now graphics\dink\bow\hit\d-ba6- 106 75 37 81 -14 -10 14 10");
init("load_sequence_now graphics\dink\bow\hit\d-ba8- 108 75 31 89 -17 -16 17 10");

//bow weapon diags

init("load_sequence_now graphics\dink\bow\hit\d-ba1- 101 75 57 84 -20 -12 20 12");
init("load_sequence_now graphics\dink\bow\hit\d-ba3- 103 75 33 86 -19 -13 19 13");
init("load_sequence_now graphics\dink\bow\hit\d-ba7- 107 75 54 82 -19 -11 19 11");
init("load_sequence_now graphics\dink\bow\hit\d-ba9- 109 75 37 78 -21 -10 21 10");
preload_seq(25);
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


