void main( void )
{
preload_seq(371);
preload_seq(373);
int &myrand;
sp_brain(&current_sprite, 0);
sp_base_walk(&current_sprite, 370);
sp_speed(&current_sprite, 2);
sp_timing(&current_sprite, 0);
//set starting pic

sp_pseq(&current_sprite, 371);
sp_pframe(&current_sprite, 1);
}

void talk( void )
{
 freeze(1);
 choice_start()
 "Say hi"
(&thief == 0) "Ask what he does"
(&thief == 1) "Offer to help him out"
 "Leave"
 choice_end()

 if (&result == 1)
 {
  wait(400);
  say_stop("Hey, how's it going?", 1);
  wait(400);
  say_stop("`2Are you the guy for the job?", &current_sprite);
  wait(400);
  say_stop("Uh, what job?", 1);
  wait(400);
  say_stop("`2Oh, never mind.", &current_sprite);
  say("`2Ahh, where is that guy?!", &current_sprite);
  unfreeze(1);
 }
 if (&result == 2)
 {
  wait(400);
  say_stop("So what do you do pal?", 1);
  wait(400);
  say_stop("`2Who me?", &current_sprite);
  wait(400);
  say_stop("Yup, myself, why if you couldn't tell I'm an adventurer.", 1);
  wait(400);
  say_stop("`2Hehe, yes well, I'm a ... a .. specialist.", &current_sprite);
  wait(400);
  say_stop("Oh, what do you specialize in?", 1);
  wait(400);
  say_stop("`2Let's just say I help acquire things..", &current_sprite);
  wait(400);
  say_stop("Ahh, I see, just what are you acquiring now?", 1);
  wait(400);
  say_stop("`2Nothing that should interest you.", &current_sprite);
  wait(400);
  say_stop("`2Now be on your way.", &current_sprite);
  //Set it up
  &thief = 1;
 }
 if (&result == 3)
 //Helping the guy out!!
 {
  wait(400);
  say_stop("`2You again?", &current_sprite);
  wait(400);
  say_stop("Whatever you're doing .. I can help you out.", 1);
  wait(400);
  say_stop("`2YOU?!?", &current_sprite);
  wait(400);
  say_stop("`2Are you sure?", &current_sprite);
  wait(400);
  say_stop("Yeah, I know how to do all sorts of things.", 1);
  wait(400);
  say_stop("`2Hmmmmm", &current_sprite);
  wait(400);
  say_stop("`2Well I guess my other guy's not showing up.", &current_sprite);
  wait(400);
  say_stop("`2So you're in.", &current_sprite);
  wait(400);
  say_stop("`2Meet me west of here when you're ready", &current_sprite);
  move_stop(&current_sprite, 4, 317, 1);
  move_stop(&current_sprite, 2, 430, 1);
  unfreeze(1);                                         
  &thief = 2;
  sp_active(&current_sprite, 0);
 }
unfreeze(1);                                         
}
