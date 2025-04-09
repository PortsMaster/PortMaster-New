void main (void)
{
 //end sequence for s5
 freeze(1);
 freeze(&temp1hold);
 freeze(&temp2hold);
 freeze(&temp3hold);
wait(500);
screenlock(0);
say_stop("`2You did it!  You did it Smallwood!", &temp1hold);
wait(500);
say_stop("`#Dink, you saved me!  You are a hero!", &temp3hold);
wait(500);
//choice statement just for fun
choice_start();
"Pshaw, twasn't nuthin!"
"I saved all of you, actually."
choice_end();
wait(500);
say_stop("`#In any case, we are very grateful.", &temp2hold);
wait(500);
say_stop("`2Those two dragons have been on the rampage for a month.", &temp1hold);
wait(500);
say_stop("`2It all started when we built this town on their nest.", &temp1hold);
wait(500);
say_stop("So basically, I just killed two innocent Dragons for protecting their own?", 1);
wait(500);
say_stop("`2Um.. gotta get back to the store, see ya later.", &temp1hold);
move_stop(&temp1hold, 6, 670,1);
sp_active(&temp1hold, 0);

 int &door = sp(2);
 sp_prop(&door, 1);


&story = 12;
&s5-jop = 4;
 unfreeze(1);
 unfreeze(&temp1hold);
 unfreeze(&temp2hold);
 unfreeze(&temp3hold);
 kill_this_task();
}
