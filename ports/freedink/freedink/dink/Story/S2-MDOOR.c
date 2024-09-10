void main( void )
{
}

void touch( void )
{

 freeze(1);
 move_stop(1, 6, 300,1 );
 sp_dir(1,4);
 if (&caveguy == 2)
 {
 say_stop("This looks like the place, but it's locked.", 1);
 say_stop("Maybe I should try knocking..", 1);
 unfreeze(1);

 return;
 }

 if (&caveguy == 3)
 {
 say_stop("I hope that damn old man gives me that spell.", 1);
 unfreeze(1);
 return;
 }

 say("It's locked.", 1);
 unfreeze(1);
}

void hit( void )
{
 goto knocked;
}

void talk( void )
{
 knocked:

 if (&caveguy == 2)
 {
 int &me;
 &me = &current_sprite;
 script_attach(1000);
 freeze(1);
 wait(500);
  playsound(45, 12000, 0,0,0);
 wait(500);
 say_stop("Hello, anyone in there?", 1);
 wait(500);
 say_stop("Hello?!?", 1);
 wait(300);
 say_stop("`0Who wants to know?", &me);
 wait(300);
 say_stop("I .. I'm Dink Smallwood, I'm trying to help...", 1);
 wait(200);
 say_stop("a poor guy who is imprisoned in the dungeon south of here.", 1);
 wait(300);
 say_stop("`0Young Maulwood, people get trapped in places they shouldn't go all the time.", &me);
 wait(200);
 say_stop("`0Why should I care what happens to this man?", &me);
 wait(500);
 sp_dir(1, 2);
 wait(500);
 sp_dir(1, 4);
 wait(500);
 say_stop("It's Smallwood sir, and he says...", 1);
 wait(200);
 say_stop("he was imprisoned by agents of the Cast and that the lock can only be broken with magic!", 1);
 wait(300);
 say_stop("`0Are you high?", &me);
 wait(300);
 say_stop("No.", 1);
 say_stop("`0Oh.", &me);
 wait(200);
 say_stop("`0Well, if those Cast members are involved I'd best help.", &me);
 wait(200);
 say_stop("`0Come in.", &me);
 fade_down();
 fill_screen(0);
 //move Dink
 &player_map = 38;
 sp_x(1, 261);
 sp_y(1, 350);
 load_screen();
 draw_screen();
 draw_status();
 fade_up();
 kill_this_task();
 return;
 }
 if (&caveguy == 3)
 {
 int &me;
 &me = &current_sprite;
 script_attach(1000);
 freeze(1);
  playsound(45, 12000, 0,0,0);
  wait(700);
 say_stop("Hey, I'm back!", 1);
 wait(300);
 say_stop("`0Ah, yes Smallwand, come in ..", &me);
 fade_down();
 fill_screen(0);
 //move Dink
 &player_map = 38;
 sp_x(1, 261);
 sp_y(1, 350);
 load_screen();
 draw_screen();
 draw_status();
 fade_up();
 kill_this_task();
  return;
 }

 freeze(1);
 wait(500);
  playsound(45, 12000, 0,0,0);
 wait(500);
 say_stop("Hello, anyone home?", 1);
  unfreeze(1);

}
