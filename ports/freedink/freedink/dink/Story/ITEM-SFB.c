//item fireball

void use( void )
{
//disallow diagonal fireballs for now

if (sp_dir(1, -1) == 1)
    sp_dir(1, 2);
if (sp_dir(1, -1) == 3)
    sp_dir(1, 2);
if (sp_dir(1, -1) == 7)
    sp_dir(1, 8);
if (sp_dir(1, -1) == 9)
    sp_dir(1, 8);

&basehit = sp_dir(1, -1);
&basehit += 320;

sp_seq(1, &basehit);
sp_frame(1, 1); //reset seq to 1st frame
sp_kill_wait(1); //make sure dink will punch right away
sp_nocontrol(1, 1); //dink can't move until anim is done!

 &mholdx = sp_x(1, -1);
 &mholdy = sp_y(1, -1);
 wait(40);
 &magic_level = 0;
 draw_status();
if (sp_dir(1, -1) == 4)
  {
  &mholdx -= 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 514, 1);
  sp_seq(&junk, 514); 
  sp_dir(&junk, 4);
  }

if (sp_dir(1, -1) == 6)
  {
//  &mholdy -= 10; 
  &mholdx += 30;
  &junk = create_sprite(&mholdx, &mholdy, 11, 516, 1);
  sp_seq(&junk, 516); 
  sp_dir(&junk, 6);
  }

if (sp_dir(1, -1) == 2)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 512, 1);
  sp_seq(&junk, 512); 
  sp_dir(&junk, 2);
  }

if (sp_dir(1, -1) == 8)
  {
  &junk = create_sprite(&mholdx, &mholdy, 11, 518, 1);
  sp_seq(&junk, 518); 
  sp_dir(&junk, 8);
  }

//create fake shadow effect
playsound(17, 8000,0,&junk,0);

  sp_timing(&junk, 0);
  sp_speed(&junk, 6);
  sp_strength(&junk, 40);
  sp_flying(&junk, 1);
  sp_range(&junk, 20);
  //this makes it easier to hit stuff
  sp_script(&junk, "dam-sfb");
  //when the fireball hits something, it will look to this script, this way
  //we can burn trees when appropriate
  &mshadow = create_sprite(&mholdx, &mholdy, 15, 432, 3);
  sp_brain_parm(&mshadow, &junk);
  sp_que(&mshadow, -500);
  sp_nohit(&mshadow, 1);
  //will be drawn under everything
  //set fireball to not be able to damage Dink or the shadow
  sp_brain_parm(&junk, 1);
  sp_brain_parm2(&junk, &mshadow);
}

void disarm(void)
{
&magic_cost = 0;
kill_this_task();
}

void arm(void)
{
Debug("Preloading fireball");
&magic_cost = 2000;
int &basehit;
int &mholdx;
int &mholdy;
int &junk;
int &mshadow;
preload_seq(322);
preload_seq(324);
preload_seq(326);
preload_seq(328);

preload_seq(512);
preload_seq(514);
preload_seq(516);
preload_seq(518);
//tree burn
preload_seq(20);
//explosion
preload_seq(167);

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


