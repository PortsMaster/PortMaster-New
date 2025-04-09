void main( void )
{

//playsound(43, 22050,0,0,0);

&s4-duck = 2;
&story = 11;
freeze(1);
//cutscene

//create man
int &man = create_sprite(290, 460, 0, 0, 0);
sp_base_walk(&man, 380);
sp_speed(&man, 1);
sp_timing(&man, 33);
preload_seq(381);
preload_seq(383);
preload_seq(387);
preload_seq(389);

//create little girl
int &girl = create_sprite(290, 460, 0, 0, 0);
sp_base_walk(&girl, 250);
sp_speed(&girl, 1);
sp_timing(&girl, 33);
preload_seq(251);
preload_seq(253);
preload_seq(257);
preload_seq(259);

int &junk = sp_y(1, -1);
if (&junk < 220)
   sp_dir(1, 2);

say("`0Hurry up, Kelly!", &man);
move_stop(&man, 8, 430, 1);
move_stop(&man, 9, 380, 1);
say_stop("`0This is gonna be so great and...", &man);
wait(250);
say_stop("`0WHAT THE!?!?!", &man);
sp_pseq(&man,387);
sp_pframe(&man,1);
sp_seq(&man,0);
wait(250);
sp_pseq(&man,381);
sp_pframe(&man,1);
sp_seq(&man,0);
say_stop("Uh oh.", 1);
wait(250);
sp_pseq(&man,383);
sp_pframe(&man,1);
sp_seq(&man,0);

wait(250);
sp_pseq(&man,389);
sp_pframe(&man,1);
sp_seq(&man,0);
say_stop("`0NO!!!!!", &man);
move_stop(&girl, 9, 350, 1);
move_stop(&girl, 7, 280, 1);
say_stop("`#Daddy, what happened?", &girl);
wait(250);
say_stop("`0GUARDS!!!!!!!", &man);
wait(250);
say_stop("`0HELP!", &man);
wait(250);
say_stop("`0THIS GUY KILLED THE BLESSED FOWL!", &man);
wait(250);


int &guard = create_sprite(290, 460, 0, 0, 0);
sp_base_walk(&guard, 290);
sp_speed(&guard, 1);
sp_timing(&guard, 33);
preload_seq(291);
preload_seq(293);
preload_seq(297);
preload_seq(299);

move_stop(&guard, 8, 380, 1);
say_stop("`5I MUST AVENGE THE WINGED GODDESS!", &guard);
wait(300);
say_stop("`0Kelly, what are you doing?", &man);
wait(300);
say_stop("`#I'm eating.", &girl);
wait(300);
move_stop(&guard, 9, 330, 1);
say_stop("`5Sir, your daughter is eating our god.", &guard);
wait(300);
say_stop("`5I guess we have to kill her too.", &guard);
wait(300);
say_stop("`#This meat.. tastes good!", &girl);
wait(300);
say_stop("`0Wait..isn't it all raw and such?", &man);
wait(300);
say_stop("`5I guess one piece won't hurt...", &guard);
wait(1000);
say_stop("`5IT TASTES GREAT!", &guard);
say_stop("`0LESS FILLING TOO!", &man);
wait(300);
say_stop("`5Dink, you magically changed our supreme beings into food!", &guard);
wait(300);
say_stop("No.. there is a perfect explanation, you see, the friction seemed to cook and...", 1);

wait(300);
say_stop("`0Who cares about that!", &man);
wait(300);
say_stop("`5Dink is a hero!  WE MUST GO TELL THE OTHERS!", &guard);
unfreeze(1);
move(&guard, 1, 300, 1);
move_stop(&man, 4, 300, 1);
move(&guard, 2, 480, 1);
move_stop(&man, 2, 480, 1);
move_stop(&girl, 3, 310, 1);
say_stop("`#Bye, Dink.", &girl);
move_stop(&girl, 2, 470, 1);

}






