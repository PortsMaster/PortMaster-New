void main( void )
{
 int &guy;
 int &what;
 &what = random(3,1);
 //Spawn the guy...
 &guy = create_sprite(258, 146, 0, 0, 0);
 sp_brain(&guy, 0);
 sp_base_walk(&guy, 410);
 sp_speed(&guy, 1);
 sp_timing(&guy, 0);
 //set starting pic
 sp_pseq(&guy, 417);
 sp_pframe(&guy, 1);
 //Coversation
 freeze(1);
 freeze(&guy);
 move_stop(1, 8, 222, 1);
 move_stop(&guy, 3, 265, 1);
 wait(250);
 if (&what == 1)
 {
  say_stop("`9Can I HELP you?", &guy);
  wait(250);
  say_stop("Uhh ... maybe.", 1);
  wait(1000);
  say_stop("`9Yeah well, what the hell are you doing??", &guy);
  wait(250);
  say_stop("What do you mean?", 1);
  wait(250);
  say_stop("`9I mean you just barging in here, no knocking, nothing!", &guy);
  say_stop("`9What's with that?", &guy);
  wait(500);
  sp_dir(1, 2);
  wait(500);
  sp_dir(1, 8);
  wait(1000);
  say_stop("And there's like ... something WRONG with that?", 1);
  wait(250);
  say_stop("`9YES, now get the HELL OUT!!", &guy);
 }
 if (&what == 2)
 {
  say_stop("`9Can I HELP you?", &guy);
  wait(250);
  say_stop("Nope, just looking through houses and stuff.", 1);
  wait(750);
  say_stop("`9You know, you've got a lot of nerve.", &guy);
  wait(250);
  say_stop("Yea whatever ...", 1);
  wait(250);
  say_stop("`9Hmmmph.", &guy);
  wait(250);
  say_stop("Hey old man, the funeral house called ...", 1);
  say_stop("they're ready for you now!", 1);
  wait(250);
  say_stop("`9WHAT, now get OUT!!", &guy);
 }
 if (&what == 3)
 {
  say_stop("`9What do you want?", &guy);
  wait(250);
  say_stop("I've come for your daughter.", 1);
  wait(250);
  say_stop("`9Just ... just please leave.", &guy);
 }
 //Leave.
 unfreeze(1);
 move_stop(1, 2, 640, 0);
  unfreeze(&guy);
}
