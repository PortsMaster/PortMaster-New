//boss brain

void main( void )
{

int &fsave_x;
int &kcrap;
int &dam;
int &fsave_y;
int &spark;
int &speed = 1;
int &resist;
int &mcounter;
int &mtarget;
sp_brain(&current_sprite, 10);
sp_timing(&current_sprite, 33);
sp_speed(&current_sprite, 1);
sp_nohit(&current_sprite, 0);
sp_exp(&current_sprite, 0);
sp_base_walk(&current_sprite, 580);
sp_touch_damage(&current_sprite, 30);
sp_hitpoints(&current_sprite, 300);
sp_defense(&current_sprite, 25);

 sp_target(&current_sprite, 1);

}

void attack( void )
{
    unfreeze(&current_sprite);
        &mcounter = random(4000,2000);
        sp_attack_wait(&current_sprite, &mcounter);



        &kcrap = sp_target(&current_sprite, -1);
&fsave_x = sp_x(&kcrap, -1);
&fsave_y = sp_y(&kcrap, -1);

&resist = random(2, 1);
if (&resist == 1)
  {
   //cast some kind of bomb
    freeze(&current_sprite);
    sp_speed(&current_sprite, 0);
//    sp_dir(&current_sprite, 0);
      sp_seq(&current_sprite, 0);
      sp_frame(&current_sprite, 0);
      sp_pseq(&current_sprite, 580);
      sp_pframe(&current_sprite, 1);
      wait(500);
      &save_x = sp_x(1, -1);
      &save_y = sp_y(1, -1);
      sp_pseq(&current_sprite, 580);
      sp_pframe(&current_sprite, 2);
      wait(200);
      sp_pseq(&current_sprite, 580);
      sp_pframe(&current_sprite, 1);
      wait(200);
      sp_pseq(&current_sprite, 580);
      sp_pframe(&current_sprite, 2);
      wait(200);
      sp_pseq(&current_sprite, 580);
      sp_pframe(&current_sprite, 1);
      wait(200);      
        say("`4<Casts explosion>", &current_sprite);
        playsound(31, 12050,0,0, 0);
        spawn("dam-bom2");
    sp_brain(&current_sprite, 10);
    sp_speed(&current_sprite, &speed);
    unfreeze(&current_sprite);

  return;
  }
&resist = random(40, 1);

//if NPC, turn off resist option
if (&kcrap != 1)
&resist = 100000;

if (&resist > &magic)
        {
        say("`4<Casts greater harm>", &current_sprite);

        playsound(31, 12050,0,0, 0);
        hurt(&kcrap, 30);

        &fsave_y -= 29;
        &spark = create_sprite(&fsave_x, &fsave_y, 7, 70, 1);
        sp_seq(&spark, 70);
        sp_que(&spark, -70);
        sp_speed(&spark, 5);
        return;
        }

        playsound(31, 44050,0,0, 0);
        &fsave_y -= 29;
        int &spark = create_sprite(&fsave_x, &fsave_y, 7, 166, 1);
        sp_seq(&spark, 166);
        sp_que(&spark, -70);
        say("Magic resisted.", &kcrap);
}

void hit( void )
{
playsound(46, 3050, 4000, &current_sprite, 0);
    sp_speed(&current_sprite, &speed);

    sp_brain(&current_sprite, 10);
   unfreeze(&current_sprite);


&dam = sp_hitpoints(&current_sprite, -1);

if (&dam < 270)
 {
  sp_timing(&current_sprite, 0);
   sp_speed(&current_sprite, 2);
   &speed = 2;
  sp_frame_delay(&current_sprite, 60);
 }


if (&dam < 200)
 {
   &speed = 3;
   sp_speed(&current_sprite, 3);
  sp_frame_delay(&current_sprite, 50);

  }

if (&dam < 100)
 {
   &speed = 4;
   sp_speed(&current_sprite, 4);
  sp_frame_delay(&current_sprite, 40);

  }

if (&dam < 15)
 {
   &speed = 5;
   sp_speed(&current_sprite, 5);
  sp_frame_delay(&current_sprite, 30);
 
  }

&dam = random(2,1);

        if (&dam == 1)
        return;

&dam = sp_hitpoints(&current_sprite, -1);

if (&dam < 6)
  {
   say("`%Watch Conan O'brien!", &CURRENT_SPRITE);
   return;
  }

if (&dam < 15)
  {
   say("`%MOTHER!!!!!!!!!!", &CURRENT_SPRITE);
   return;
  }


if (&dam < 50)
  {
   say("`%FEEL MY WRATH, SMALLWOOD!", &CURRENT_SPRITE);
   return;
  }

if (&dam < 100)
  {
   say("`%I felt that.", &CURRENT_SPRITE);
  return;
  }



if (&dam < 140)
  {
   say("`%Listen to the birds.. even they are calling for your heart.", &CURRENT_SPRITE);
  playsound(49, 22050, 0, &current_sprite, 0);
  return;
  }


if (&dam < 160)
  {
   say("`%You'll be dead soon.", &CURRENT_SPRITE);
  return;
  }


if (&dam < 180)
  {
   say("`%Nice shot.  It will be your last.", &CURRENT_SPRITE);
  return;
  }

if (&dam < 200)
  {
   say("`%You are starting to annoy me now.", &CURRENT_SPRITE);
    return;
  }


if (&dam < 240)
  {
   say("`%I could finish you now, but this rather amuses me.", &CURRENT_SPRITE);
  return;
  }


if (&dam < 260)
  {
   say("`%It's kind of sad that you are going to die for nothing.", &CURRENT_SPRITE);
  return;
  }


if (&dam < 280)
  {
   say("`%That kinda tickled.", &CURRENT_SPRITE);
  return;
  }


   say("`%You are just like me you know, Dink.", &CURRENT_SPRITE);

//lock on to the guy who just hit us
//playsound

}

void die( void )
{
	//fix, must make it so that the monster isn't hit again.
        sp_nohit(&current_sprite, 1);
	
	&save_x = sp_x(&current_sprite, -1);
	&save_y = sp_y(&current_sprite, -1);
	say("EAT IT!", 1);
	add_exp(10000, &current_sprite);
	
	freeze(1);
	sp_brain(&current_sprite, 0);
	
	playsound(24, 22052, 0, 0, 0);
	int &mcrap = create_sprite(&save_x, &save_y, 7, 167, 1);
	sp_seq(&mcrap, 167);
	wait(100);
	
	
	playsound(24, 22052, 0, 0, 0);
	int &mcrap = create_sprite(&save_x, &save_y, 7, 167, 1);
	sp_seq(&mcrap, 167);
	wait(100);
	&save_x -= 40;
	&save_y -= 30;
	playsound(24, 22052, 0, 0, 0);
	int &mcrap = create_sprite(&save_x, &save_y, 7, 167, 1);
	sp_seq(&mcrap, 167);
	wait(100);
	
	&save_x += 80;
	&save_y += 60;
	
	playsound(24, 22052, 0, 0, 0);
	int &mcrap = create_sprite(&save_x, &save_y, 7, 167, 1);
	sp_seq(&mcrap, 167);
	wait(100);
	&save_x += 10;
	&save_y += 20;
	
	
	playsound(24, 22052, 0, 0, 0);
	int &mcrap = create_sprite(&save_x, &save_y, 7, 167, 1);
	sp_seq(&mcrap, 167);
	wait(100);
	&save_x -= 30;
	&save_y -= 60;
	
	playsound(24, 22052, 0, 0, 0);
	int &mcrap = create_sprite(&save_x, &save_y, 7, 167, 1);
	sp_seq(&mcrap, 167);
	wait(100);
	sp_brain_parm(&current_sprite, 5);
	sp_brain(&current_sprite, 12);
	script_attach(1000);
	wait(500);
	wait(2000);

	say_stop("Too bad I had to kill him, he seemed likable enough.", 1);
	wait(500);
	say_stop("My body is tingling!", 1);
	&life = &lifemax;
	wait(500);
	say_stop("I must now get back to Goodheart Castle and inform the King.", 1);
	unfreeze(1);
	&story = 15;
	
	//kill spawn from hell
	sp_kill(&current_sprite, 1);
	kill_this_task();
}
