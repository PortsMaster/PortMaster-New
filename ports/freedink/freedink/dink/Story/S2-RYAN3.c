void main( void )
{
 int &crap;
 int &jcrap;
 sp_brain(&current_sprite, 0);
 sp_base_walk(&current_sprite, 370);
 sp_speed(&current_sprite, 2);
 sp_timing(&current_sprite, 0);
//set starting pic
 sp_pseq(&current_sprite, 377);
 sp_pframe(&current_sprite, 1);
 //Ok Go
 freeze(1);
 move_stop(1, 8, 375, 1);
 move_stop(1, 4, 300, 1);
 move_stop(1, 8, 350, 1);
 move_stop(&current_sprite, 8, 330, 1);
 //playmidi("mystery.mid");
 say_stop("`2Ok, it's up here", &current_sprite);
 move_stop(&current_sprite, 8, 200, 1);
 say_stop("`2Follow me...", &current_sprite);
 move_stop(&current_sprite, 6, 399, 1);
 move_stop(&current_sprite, 8, 165, 1);
 playsound(19, 22052, 0, 0, 0);
 wait(100);
 playsound(19, 44102, 0, 0, 0);
 wait(100);
 playsound(19, 44102, 0, 0, 0);
 say("`2Now if I can just pick this lock...", &current_sprite);
 move_stop(1, 8, 190, 1);
 move_stop(1, 6, 350, 1);
 say_stop("What are we doing?", 1);
 playsound(19, 44102, 0, 0, 0);
 wait(100);
 playsound(19, 44102, 0, 0, 0);
 say_stop("`2Just one more second...", &current_sprite);
 playmidi("battle.mid");
 //build guards
 preload_seq(291);
 preload_seq(293);
 preload_seq(297);
 preload_seq(299);
 preload_seq(722);
 preload_seq(724);
 preload_seq(725);
 preload_seq(726);
 &crap = create_sprite(380,450, 9, 0, 0);
 freeze(&crap);
 sp_base_walk(&crap, 290);
 sp_base_attack(&crap, 720); 
 sp_speed(&crap, 1);
 sp_strength(&crap, 10);
 sp_touch_damage(&crap, 2);
 sp_timing(&crap, 0);
 move(&crap, 7,250, 1);
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
 say_stop("`2Oh no, guards!!  Run for it!", &current_sprite);
 wait(250);
 sp_dir(1, 2);
 &thief = 3;
 say_stop("This ain't good.", 1);
 unfreeze(1);
 unfreeze(&jcrap);
 unfreeze(&crap);
 move_stop(&current_sprite, 6, 700, 1);
 sp_active(&current_sprite, 0);
}
