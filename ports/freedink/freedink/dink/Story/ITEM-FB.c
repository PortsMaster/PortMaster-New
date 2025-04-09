//item fireball

void use( void )
{

&mydir = sp_dir(1, -1);

//disallow diagonal fireballs for now

if (sp_dir(1, -1) == 1)
    sp_dir(1, 4);
if (sp_dir(1, -1) == 3)
    sp_dir(1, 6);
if (sp_dir(1, -1) == 7)
    sp_dir(1, 4);
if (sp_dir(1, -1) == 9)
    sp_dir(1, 6);


&basehit = sp_dir(1, -1);
&basehit += 320;

sp_seq(1, &basehit);
sp_frame(1, 1); //reset seq to 1st frame
sp_kill_wait(1); //make sure dink will punch right away
sp_nocontrol(1, 1); //dink can't move until anim is done!
 &magic_level = 0;
 draw_status();
 &mholdx = sp_x(1, -1);
 &mholdy = sp_y(1, -1);
//freeze(1);

 wait(100);

if (&mydir == 1)
  {
  &mholdx -= 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 504, 1);
  sp_seq(&junk, 504); 
  sp_mx(&junk, -6);
  sp_my(&junk, +2);

  }




if (&mydir == 4)
  {
  &mholdx -= 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 504, 1);
  sp_seq(&junk, 504); 
  sp_dir(&junk, 4);
  }

if (&mydir == 6)
  {
//  &mholdy -= 10; 
  &mholdx += 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 506, 1);
  sp_seq(&junk, 506); 
  sp_dir(&junk, 6);
  }

if (&mydir == 3)
  {
  &mholdx += 30;

  &junk = create_sprite(&mholdx, &mholdy, 11, 506, 1);
  sp_seq(&junk, 506); 
  sp_mx(&junk, +6);
  sp_my(&junk, +2);

  }




if (&mydir == 2)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 502, 1);
  sp_seq(&junk, 502); 
  sp_dir(&junk, 2);
  }

if (&mydir == 7)
  {
  &mholdx -= 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 504, 1);
  sp_seq(&junk, 504); 
  sp_mx(&junk, -6);
  sp_my(&junk, -2);

  }


if (&mydir == 8)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 508, 1);
  sp_seq(&junk, 508); 
  sp_dir(&junk, 8);
  }

if (&mydir == 9)
  {
  &mholdx += 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 506, 1);
  sp_seq(&junk, 506); 
  sp_mx(&junk, +6);
  sp_my(&junk, -2);

  }



//create fake shadow effect
playsound(17, 8000,0,&junk,0);

  sp_timing(&junk, 0);
  sp_speed(&junk, 6);
  sp_strength(&junk, 10);
  sp_range(&junk, 10);
  //this makes it easier to hit stuff
  sp_flying(&junk, 1);
  sp_script(&junk, "dam-fire");
  //when the fireball hits something, it will look to this script, this way
  //we can burn trees when appropriate
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
&magic_cost = 0;
kill_this_task();
}

void arm(void)
{
Debug("Preloading fireball");

int &basehit;
int &mholdx;
int &mholdy;
int &junk;
int &mshadow;
int &mydir;
&magic_cost = 100;
preload_seq(322);
preload_seq(324);
preload_seq(326);
preload_seq(328);
preload_seq(502);
preload_seq(504);
preload_seq(506);
preload_seq(508);

//tree burn
preload_seq(20);

//explosion
preload_seq(70);
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


