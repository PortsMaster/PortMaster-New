void main( void )
{
 int &dude;


 if (&caveguy == 0)
 {
  freeze(1);
  &dude = create_sprite(464, 116, 0, 0, 0);

 &temp1hold = &dude;
  sp_brain(&dude, 0);
  sp_base_walk(&dude, 370);
  sp_speed(&dude, 2);
  sp_timing(&dude, 0);
 //set starting pic
  sp_pseq(&dude, 373);
  sp_pframe(&dude, 1);
  sp_dir(&dude, 2);
  //Playmidi("Mystery.mid", 1);
  say_stop("`5Help me!", &dude);
  wait(300);
  say_stop("The hell!?!", 1);
  move_stop(1, 6, 130, 1);
  move_stop(1, 3, 190, 1);
  move_stop(1, 6, 300, 1);
  say_stop("What's your problem?", 1);
  move(&dude, 1, 400, 1);
  say_stop("`5They threw me in here", &dude);
  wait(300);
  say_stop("Huh?", 1);
  wait(200);
  say_stop("Who threw you in here?", 1);
  wait(300);

  say_stop("`5They did, agents of the Cast.", &dude);
  sp_dir(1, 2);
  wait(750);
  say_stop("Is he telling the truth?", 1);
  sp_dir(1, 6);
  wait(500);
  say_stop("You probably deserved it...", 1);
  wait(300);
  say_stop("`5No, actually I didn't.", &dude);
  wait(300);
  say_stop("Oh.", 1);
  wait(300);
  say_stop("`5Now will you help me get outta here!", &dude);
  wait(300);
  say_stop("`5They'll be back here soon, they'll kill us both!", &dude);
  wait(300);
  say_stop("Ok ok, how do I get you out?", 1);
  wait(300);
  say_stop("`5I'm not sure.  That statue seems to keep me in.", &dude);
  wait(200);
  say_stop("`5I think it's protected with magic.", &dude);
  wait(250);
  say_stop("`5You know any, kid?", &dude);
  wait(300);
  say_stop("Hmm, just my fireball spell.", 1);
  wait(300);
  say_stop("`5I don't think that'll cut it.", &dude);
  wait(300);
  say_stop("`5Try in town, someone there's gotta know something.", &dude);
  wait(300);
  say_stop("Ok... by the way, my name is Dink.  Goodbye for now.", 1);
  &caveguy = 1;
  unfreeze(1);
  return;
 }
 if (&caveguy == 1)
 {
  freeze(1);
  &dude = create_sprite(464, 116, 0, 0, 0);
 &temp1hold = &dude;

  sp_brain(&dude, 0);
  sp_base_walk(&dude, 370);
  sp_speed(&dude, 2);
  sp_timing(&dude, 0);
 //set starting pic
  sp_pseq(&dude, 371);
  sp_pframe(&dude, 1);
  sp_dir(&dude, 2);
  //Playmidi("Mystery.mid", 1);
  say_stop("`5Any luck?", &dude);
  move_stop(1, 6, 130, 1);
  say_stop("Uh, working on that.", 1);
  wait(500);
  say_stop("`5Hurry!!", &dude);
  sp_dir(1, 2);
  wait(750);
  sp_dir(1, 6);
  wait(500);
  say_stop("Noted.", 1);
  unfreeze(1);
 }
 if (&caveguy == 2)
 {
  freeze(1);
  &dude = create_sprite(464, 116, 0, 0, 0);
 &temp1hold = &dude;

  sp_brain(&dude, 0);
  sp_base_walk(&dude, 370);
  sp_speed(&dude, 2);
  sp_timing(&dude, 0);
 //set starting pic
  sp_pseq(&dude, 371);
  sp_pframe(&dude, 1);
  sp_dir(&dude, 2);
  //Playmidi("Mystery.mid");
  wait(500);
  say_stop("`5Any luck yet?", &dude);
  move_stop(1, 6, 130, 1);
  say_stop("There's some old man in town who knows some magic.", 1);
   wait(200:
  say_stop("He might have a spell that could help us.", 1);
  wait(500);
  sp_dir(&dude, 2);
  wait(750);
  sp_dir(&dude, 4);
  wait(500);
  say_stop("`5THEN WHAT THE HELL ARE YOU DOING HERE?", &dude);
  wait(250);
  say_stop("Oh yeah, sorry.", 1);
  unfreeze(1);
 }
 if (&caveguy == 3)
 {
  freeze(1);
 &temp1hold = &dude;

  &dude = create_sprite(464, 116, 0, 0, 0);
  sp_brain(&dude, 0);
  sp_base_walk(&dude, 370);
  sp_speed(&dude, 2);
  sp_timing(&dude, 0);
 //set starting pic
  sp_pseq(&dude, 371);
  sp_pframe(&dude, 1);
  sp_dir(&dude, 2);
  //Playmidi("Mystery.mid");
  wait(500);
  say_stop("`5Any luck YET!?", &dude);
  wait(250);
  move_stop(1, 6, 130, 1);
  say_stop("The damn old man says I'm not powerful enough yet", 1);
  wait(200);
  say_stop("so I'm trying to raise my skills now.", 1);
  wait(750);
  sp_dir(&dude, 2);
  wait(500);
  sp_dir(&dude, 4);
  wait(500);
  say_stop("`5Well hey that's great.", &dude);
  wait(200);
  say_stop("`5I'll just be DYING here and hope those agents don't come back!!", &dude);
  wait(250);
  say_stop("Ok, ok I'm on it..", 1);
  unfreeze(1);
 }
 if (&caveguy == 4)
 {
  freeze(1);
  &dude = create_sprite(464, 116, 0, 0, 0);
 &temp1hold = &dude;

  sp_brain(&dude, 0);
  sp_base_walk(&dude, 370);
  sp_speed(&dude, 2);
  sp_timing(&dude, 0);
 //set starting pic
  sp_pseq(&dude, 371);
  sp_pframe(&dude, 1);
  sp_dir(&dude, 2);
  //Playmidi("Mystery.mid");
  wait(500);
  say_stop("`5I'm going to die soon, I just know it.", &dude);
  wait(300);
  say_stop("`5Any luck!?!", &dude);
  wait(250);
  move_stop(1, 6, 130, 1);
  say_stop("I got the spell, so let's see if it works.", 1);
  wait(250);
  say_stop("`5All right!!", &dude);
  wait(250);
  say_stop("`5Hurry though, I could've sworn I heard something just before you came.", &dude);
  wait(250);
  say_stop("Ok.", 1);
  unfreeze(1);
 }
}


