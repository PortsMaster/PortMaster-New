//main.c run when dink is started

void main()
{
//let's init all our globals
// These globals are REQUIRED by dink.exe (it directly uses them, removing
// any of these could result in a game crash.

  make_global_int("&exp",0);
  make_global_int("&strength", 3);
  make_global_int("&defense", 0);
  make_global_int("&cur_weapon", 0);
  make_global_int("&cur_magic", 0);
  make_global_int("&gold", 0);
  make_global_int("&magic", 0);
  make_global_int("&magic_level", 0);
  make_global_int("&vision", 0);
  make_global_int("&result", 0);
  make_global_int("&speed", 1);
  make_global_int("&timing", 0);
  make_global_int("&lifemax", 10); 
  make_global_int("&life", 10);
  make_global_int("&level", 1);
  make_global_int("&player_map", 1);
  make_global_int("&last_text", 0);
  make_global_int("&update_status", 0);
  make_global_int("&missile_target", 0);
  make_global_int("&enemy_sprite", 0);
  make_global_int("&magic_cost", 0);
  make_global_int("&missle_source", 0);

  // These globals are stuff we added, which will all be saved with the player
  // file

  make_global_int("&story", 0);
  make_global_int("&old_womans_duck", 0);
  make_global_int("&nuttree", 0);
  make_global_int("&letter", 0);
  make_global_int("&little_girl", 0);
  make_global_int("&farmer_quest", 0);
  make_global_int("&save_x", 0);
  make_global_int("&save_y", 0);
  make_global_int("&safe", 0);
  make_global_int("&pig_story", 0);
  make_global_int("&wizard_see", 0);
  make_global_int("&mlibby", 0);
  make_global_int("&wizard_again", 0);
  make_global_int("&snowc", 0);
  make_global_int("&duckgame", 0);

  make_global_int("&gossip", 0);
  make_global_int("&robbed", 0);
  make_global_int("&dinklogo", 0);
  make_global_int("&rock_placement", 0);
  make_global_int("&temphold", 0);
  make_global_int("&temp1hold", 0);
  make_global_int("&temp2hold", 0);
  make_global_int("&temp3hold", 0);
  make_global_int("&temp4hold", 0);
  make_global_int("&temp5hold", 0);
  make_global_int("&temp6hold", 0);
  make_global_int("&town1", 0);
  make_global_int("&s2-milder", 0);
  make_global_int("&thief", 0);
  make_global_int("&caveguy", 0);
  make_global_int("&s2-aunt", 0);
  make_global_int("&tombob", 0);
  make_global_int("&mayor", 0);
  make_global_int("&hero", 0);
  make_global_int("&s2-nad", 0);
  make_global_int("&gobpass", 0);
  make_global_int("&bowlore", 0);
  make_global_int("&s4-duck", 0);
  make_global_int("&s5-jop", 0);
  make_global_int("&s7-boat", 0);
  make_global_int("&s2-map", 0);

  //crap needed for misc
  set_dink_speed(3);
  sp_frame_delay(1,0);

//Let's preload that sprite that's been bugging the hell out of Pap
  preload_seq(373);

//if run with -debug option this will be written to debug.txt.

 debug("Dink started. Time to fight for your right to party.");
//playmidi("story.mid");
 kill_this_task();
}
