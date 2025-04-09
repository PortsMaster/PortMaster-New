//item pig food

void use( void )
{
//disallow diagonal punches
&dir = sp_dir(1, -1);
if (&dir == 1)
{
    &dir = 2;
}
if (&dir == 3)
{
    &dir = 2;
}
if (&dir == 7)
{
    &dir = 8;
}
if (&dir == 9)
{
    &dir = 8;
}
sp_dir(1, &dir);

&basehit = sp_dir(1, -1);
&basehit += 520;
//520 is the 'base' for the hit animations, we just add
//the direction
sp_seq(1, &basehit);
sp_frame(1, 1); //reset seq to 1st frame
sp_kill_wait(1); //make sure dink will punch right away
sp_nocontrol(1, 1); //dink can't move until anim is done!
wait(250);
playsound(13, 8000,0,0,0);

 &mholdx = sp_x(1, -1);
 &mholdy = sp_y(1, -1);
wait(10);

if (&dir == 4)
  {
    &mholdy -= 37; 
      &mholdx -= 50;
   &junk = create_sprite(&mholdx, &mholdy, 5, 430, 1);
sp_seq(&junk, 430);
  }
wait(10);

if (&dir == 6)
  {
    &mholdy -= 20; 
    &mholdx += 50;
   &junk = create_sprite(&mholdx, &mholdy, 5, 431, 1);
  sp_seq(&junk, 431); 
  }

if (&dir == 8)
  {
    &mholdy -= 50; 
    &mholdx += 8;
   &junk = create_sprite(&mholdx, &mholdy, 5, 430, 1);
  sp_seq(&junk, 430); 
  }

if (&dir == 2)
  {
  //  &mholdy += 0; 
    &mholdx -= 2;
   &junk = create_sprite(&mholdx, &mholdy, 5, 431, 1);
  sp_seq(&junk, 431); 
  }


 if (&pig_story != 0) return;

 if (&player_map == 407)
   {
    //they are feeding the pigs.. maybe...

&junk = inside_box(&mholdx,&mholdy, 200, 180, 400, 306);
    if (&junk == 1)
    {
    freeze(1);
     wait(200);
     Say_stop("Come on pigs, eat!", 1);
  //lets create the bully, and run his script
        &junk = create_sprite(680, 200, 0, 341, 1);
        sp_script(&junk, "s1-bul");

    }

   }

}

void disarm(void)
{
kill_this_task();
}

void arm(void)
{
int &basehit;
int &mholdx;
int &mholdy;
int &junk;
int &dir;

init("load_sequence_now graphics\dink\walk\ds-w1- 71 35 38 72");
init("load_sequence_now graphics\dink\walk\ds-w2- 72 35 37 69 -13 -9 13 9");
init("load_sequence_now graphics\dink\walk\ds-w3- 73 35 38 72");
init("load_sequence_now graphics\dink\walk\ds-w4- 74 35 38 72");

init("load_sequence_now graphics\dink\walk\ds-w6- 76 35 38 72");
init("load_sequence_now graphics\dink\walk\ds-w7- 77 35 38 72");
init("load_sequence_now graphics\dink\walk\ds-w8- 78 35 37 69 -13 -9 13 9");
init("load_sequence_now graphics\dink\walk\ds-w9- 79 35 38 72");

init("load_sequence_now graphics\dink\idle\ds-i2- 12 250 33 70 -12 -9 12 9");
init("load_sequence_now graphics\dink\idle\ds-i4- 14 250 30 71 -11 -9 11 9");
init("load_sequence_now graphics\dink\idle\ds-i6- 16 250 36 70 -11 -9 11 9");
init("load_sequence_now graphics\dink\idle\ds-i8- 18 250 32 68 -12 -9 12 9");


preload_seq(522);
preload_seq(524);
preload_seq(526);
preload_seq(528);
preload_seq(430);
preload_seq(431);
}

void pickup(void)
{
kill_this_task();
}

void drop(void)
{
kill_this_task();
}
