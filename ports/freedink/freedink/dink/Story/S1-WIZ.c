//wizard cut scene

void main( void )
{
freeze(1);
playmidi("wanderer.mid");
int &mcrap = create_sprite(78, 319, 7, 167, 1);
sp_seq(&mcrap, 167);
sp_speed(&current_sprite, 1);
playsound(24, 22052, 0, 0, 0);
move_stop(&current_sprite, 6, 120, 1)
wait(300);
say_stop("What the...", 1);
wait(300);
move_stop(1, 8, 377, 1)
move_stop(1, 6, 341, 1)
move_stop(1, 8, 319, 1)
move_stop(1, 2, 319, 1)
move_stop(1, 4, 280, 1)
wait(300);
say_stop("Who are you?", 1);
wait(200);
sp_pseq(&current_sprite, 561);
wait(200);
sp_pseq(&current_sprite, 563);
wait(200);
say_stop("`0I am a great magician.", &current_sprite);
wait(200);
say_stop("No way! You're so cute and tiny!", 1);
wait(200);
move_stop(&current_sprite, 6, 161, 1)
wait(200);
say_stop("`0I am nothing of the sort!", &current_sprite);
wait(200);
move_stop(&current_sprite, 6, 192, 1)
wait(200);
say_stop("`0You cannot measure magic by size!", &current_sprite);
wait(200);
say_stop("I just have to pet you!", 1);
wait(200);
move_stop(1, 4, 145, 1)
wait(200);
say_stop("Huh?  I just walked right through you.", 1);
wait(200);
move_stop(1, 6, 304, 1)
wait(50);
move_stop(1, 4, 289, 1)
wait(200);
say_stop("You are not really here, are you!", 1);
wait(200);
say_stop("`0Of course I am.. just not physically.", &current_sprite);
wait(200);
sp_pseq(&current_sprite, 561);
wait(200);
sp_pseq(&current_sprite, 563);
wait(200);
say_stop("`0If you would like to learn more.. Come to my hidden cabin.", &current_sprite);
wait(200);
say_stop("How am I supposed to find it if it's hidden?",1);
wait(200);
say_stop("`0Good point.  It lies behind some trees north-east of here.", &current_sprite);
wait(200);
say_stop("Ok, I may drop by later.. are you in a circus?", 1);
wait(200);
say_stop("`0DON'T ANGER ME, HUMAN!", &current_sprite);
sp_speed(&current_sprite, 10);
sp_timing(&current_sprite, 0);
unfreeze(1);
move_stop(&current_sprite, 4, 71, 1)
move_stop(&current_sprite, 8, 213, 1)
move_stop(&current_sprite, 6, 323, 1)
move_stop(&current_sprite, 2, 295, 1)
move_stop(&current_sprite, 4, 145, 1)
move_stop(&current_sprite, 8, 217, 1)
move_stop(&current_sprite, 6, 316, 1)
move_stop(&current_sprite, 2, 336, 1)
move_stop(&current_sprite, 6, 545, 1)
move_stop(&current_sprite, 8, 241, 1)
move_stop(&current_sprite, 4, 359, 1)
&mcrap = create_sprite(359, 241, 7, 167, 1);
sp_seq(&mcrap, 167);
playsound(24, 22052, 0, 0, 0);
sp_active(&current_sprite, 0);
return;
}

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

