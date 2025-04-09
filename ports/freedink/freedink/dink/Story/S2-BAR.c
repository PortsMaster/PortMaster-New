//script for bar and stuff, actually attached to the bench

void main( void )
{
 &temp4hold = 0;

 int &crap = create_sprite(390,120, 0, 0, 0);
 &temphold = &crap;
 int &jcrap;

preload_seq(391);
preload_seq(393);

 //build server girl
 &crap = create_sprite(290,250, 0, 0, 0);
 &temp2hold = &crap;
 sp_script(&crap, "s2-wench");

//build old fart 1
 &crap = create_sprite(90,280, 0, 0, 0);
 &temp3hold = &crap;

 sp_script(&crap, "s2-man1");


//build old fart 2
 int &crap = create_sprite(90,220, 0, 0, 0);
 sp_script(&crap, "s2-man2");

//Maybe build Thief
 &crap = random(2,1)
 if (&thief < 1)
 {
  if (&crap == 1)       
  {
  &crap = create_sprite(560, 248, 0, 0, 0);
  sp_script(&crap, "s2-ryant");
  }
 }

int &myrand;
sp_brain(&temphold, 0);
sp_base_walk(&temphold, 390);
sp_speed(&temphold, 0);

//set starting pic

sp_pseq(&temphold, 393);
sp_pframe(&temphold, 1);

//Maybe do cave sequence...
 if (&caveguy == 1)
 {
 &temp4hold = 1;

  script_attach(1000);
  &crap = create_sprite(470, 360, 0, 0, 0);
  sp_brain(&crap, 0);
  sp_base_walk(&crap, 300);
  sp_speed(&crap, 1);
  sp_timing(&crap, 0);
  //set starting pic
  sp_pseq(&crap, 303);
  sp_pframe(&crap, 1);
  freeze(1);
  say_stop("Hey everybody!", 1);
  move_stop(1, 8, 200, 1);
  say_stop("There's some guy trapped in a dungeon nearby.", 1);
  move_stop(1, 6, 420, 1);
  say_stop("I gotta help him!", 1);
  wait(500);
  say_stop("He's trapped with some sort of magic.", 1);
  sp_dir(1, 2);
  wait(250);
  say_stop("Can anyone help?", 1);
  wait(250);
  sp_dir(1, 4);
  wait(250);
  sp_dir(1, 6);
  wait(250);
  sp_dir(1, 8);
  say_stop("`4There's an old guy in the house south of here.", &temphold);
  wait(500);
  say_stop("`4I've heard he knows some magic.", &temphold);
  wait(500);
  say_stop("`4Why don't you try asking him?", &temphold);
  wait(250);
  say_stop("Ok, thanks.", 1);
  move_stop(1, 4, 325, 1);
  move_stop(1, 2, 385, 1);
  sp_disabled(1, 1);
  Playmidi("battle.mid");
  move_stop(&crap, 8, 200, 1);
  move_stop(&crap, 4, 325, 1);
  say_stop("`4Someone knows.", &crap);
  say_stop("`4He must die!", &crap);
  move_stop(&crap, 2, 420, 1);
  sp_active(&crap, 0);
  &caveguy = 2;
  unfreeze(1);
  fade_down();
  fill_screen(0);
  //move Dink
  &player_map = 498;
  sp_x(1, 320);
  sp_y(1, 373);
  sp_disabled(1, 0);
  load_screen();
  draw_screen();
  draw_status();
  fade_up();
  kill_this_task();
 }


mainloop:
wait(3540);
&myrand = random(8, 1);

  if (&myrand == 1)
  {
  sp_pseq(&temphold, 393);
  }

  if (&myrand == 2)
  {
  sp_pseq(&temphold, 391);
  }

&myrand = random(37, 1);

  if (&myrand == 1)
  {
  say_stop_npc("`4Woman, serve those men!", &temphold);
  }

  if (&myrand == 2)
  {
  say_stop_npc("`4Get to work you stupid wench!", &temphold);
  }


goto mainloop;
}


void hit( void )
{

wait(400);
say_stop_npc("`4Trying to break up the place, are ya?", &temphold);
wait(800);
goto mainloop;
}

void talk( void )
{
 &temp4hold = 1;

 freeze(1);
         choice_start()
         "Gossip"
         "Threaten"
         "Leave"
         choice_end()

 if (&result == 2)
 {

  wait(400);
   say_stop("I don't much like you.",1);
  wait(400);
  say_stop("`4And?",&temphold);
  wait(400);
   say_stop("I might kill you.",1);
  wait(400);
  say("`4<presses button under the counter>",&temphold);
  wait(400);

preload_seq(291);
preload_seq(293);
preload_seq(297);
preload_seq(299);

preload_seq(722);
preload_seq(724);
preload_seq(725);
preload_seq(726);

 playmidi("battle.mid");
 //build guards
 &crap = create_sprite(380,450, 9, 0, 0);
 freeze(&crap);
 sp_base_walk(&crap, 290);
 sp_base_attack(&crap, 720); 
 sp_speed(&crap, 1);
 sp_strength(&crap, 10);
 sp_touch_damage(&crap, 2);
 sp_timing(&crap, 0);
 move_stop(&crap, 7,250, 1);
 sp_target(&crap, 1);
 sp_hitpoints(&crap, 40);
 &jcrap = create_sprite(280,450, 9, 0, 0);
 freeze(&jcrap);
 sp_base_walk(&jcrap, 290);
 sp_base_attack(&jcrap, 720); 
 sp_strength(&jcrap, 10);
 sp_distance(&crap, 50);

 sp_touch_damage(&jcrap, 2);

 sp_speed(&jcrap, 1);
 sp_timing(&jcrap, 0);
 move_stop(&jcrap, 9,400, 1);
 sp_distance(&jcrap, 50);
 sp_target(&jcrap, 1);
 sp_hitpoints(&jcrap, 40);

 say_stop("`4Guards!! Help me, destroy this madman!", &temphold);
 wait(500);
 sp_dir(1, 2);
 say_stop("Let's play.", 1);
 
 say("Attack him!", &crap);
 unfreeze(&jcrap);
 unfreeze(&crap);

 sp_script(&crap, "s2-fight");
 sp_script(&jcrap, "s2-fight");
 unfreeze(1);
 &temp4hold = 0;

 }

if (&result  == 1)
  {


  wait(400);
   say_stop("Any news, Barkeep?",1);
  wait(400);

  if (&story < 8)
  {
  say_stop("`4Well.. Nadine's little girl is missing.  That's about it.",&temphold);
  wait(400);
   say_stop("Really?",1);
  wait(400);
  say_stop("`4Yep.",&temphold);
   unfreeze(1);
 &temp4hold = 0;
   goto mainloop;
  
  }
  say_stop("`4Nice job on saving Nadine's little girl.  You are something of a...",&temphold);
  wait(400);

   say_stop("`4hero around here.  Oh, and my employees are lazy, that's about it.",&temphold);
  }


   unfreeze(1);
   &temp4hold = 0;
   goto mainloop;
   return;

}

