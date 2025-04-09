void main ( void )
{
//this script needs to survive a screen load, lets unattach it from the
//letter

int &mycur = &current_sprite;

  script_attach(1000);

 //1000 means can't be killed unless we do it, but now &current_sprite
 //won't work..

 freeze(1);
 &letter = 2;
 &story = 6;
 wait(2000);
 say_stop("`2Dear Dink,", &mycur);
 wait(250);
 say_stop("`2We've just gotten word of the tragic accident that happened at...", &mycur);
 say_stop("`2your home a short while ago.  Needless to say we are shocked.", &mycur);
 say_stop("`2This must be a hard time for you, being so young and suffering...", &mycur);
 say_stop("`2such a great loss.  You are completely welcome to come and stay...", &mycur);
 say_stop("`2with us in Terris for a while, I don't think Jack will mind.", &mycur);

 say_stop("`2Sincerely, Aunt Maria Kneedlewood", &mycur);
 wait(500);
 say_stop("Hmm... Terris.  I think that is west of here.", 1);
 wait(500);
 say_stop("Hey!  A map was enclosed!", 1);
 wait(500);
 &s2-map = 1;
 say_stop_xy("`%(Press M or button 6 for map toggle)", 20,380);
 fade_down();
 fill_screen(0);
 //move Dink
 &player_map = 439;
 sp_x(1, 362);
 sp_y(1, 303);
 load_screen();
 draw_screen();
 draw_status();
 fade_up();
 unfreeze(1);

 kill_this_task();
}
