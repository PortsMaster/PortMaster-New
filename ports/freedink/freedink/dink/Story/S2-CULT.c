//script for slayer-little girl cult

void main( void )
{

if (&s2-nad != 2)
{

wait(1000);

if (&s2-nad < 3)
 say("What a lovely backyard.", 1);

if (&s2-nad > 2)
 say("Ah, the memories.", 1);

 return;
}
preload_seq(531);
preload_seq(533);
preload_seq(537);
preload_seq(539);
preload_seq(551);
preload_seq(553);
preload_seq(557);
preload_seq(559);
preload_seq(542);
preload_seq(544);
preload_seq(546);
preload_seq(548);

 //build little girls
 int &crap = create_sprite(265,176, 0, 0, 0);
 &temphold = &crap;
 sp_script(&crap, "s2-cg1");

 //build little girls
 &crap = create_sprite(383,179, 0, 0, 0);
 &temp2hold = &crap;
 sp_script(&crap, "s2-cg2");

 &crap = create_sprite(229,278, 0, 0, 0);
 &temp3hold = &crap;
 sp_script(&crap, "s2-cg3");

 &crap = create_sprite(393,278, 0, 0, 0);
 &temp4hold = &crap;
 sp_script(&crap, "s2-cg4");
 freeze(1);


move(1, 4, 583, 1);


  wait(500);


  say_stop("`#I love you, Dead Dragon Carcass.", &temphold);
  wait(500);
  say_stop("`#I worship you, Dead Dragon Carcass.", &temp2hold);
   wait(500);
  say_stop("`#I would kill for you, Dead Dragon Carcass", &temp3hold);
   wait(500);
  say_stop("`#I would do anything for you, DDC.", &temp4hold);
   wait(500);
  say_stop("`#Please Cindy, say the whole name each time.", &temphold);
   wait(500);
  say_stop("`#Fine.", &temp4hold);
   wait(500);
  say_stop("`#I would do anything for you, DEAD DRAGON CARCASS.", &temp4hold);

   wait(500);
  say_stop("Interesting little party we've got here...", 1);

start4:

 &crap = create_sprite(329,450, 0, 0, 0);
 &temp5hold = &crap;
preload_seq(341);
preload_seq(343);
preload_seq(347);
preload_seq(349);
sp_base_walk(&temp5hold, 340);
sp_speed(&temp5hold, 1);
//sp_timing(&current_sprite, 66);
sp_pseq(&temp5hold, 349);
sp_pframe(&temp5hold, 1);

move_stop(&temp5hold, 8, 320, 1);
wait(500);
say_stop("`4How goes the Dead Dragon Carcass worshipping, girls?", &temp5hold);
wait(500);
say_stop("`#Wonderful - thank you for showing us the light, Bishop Nelson!", &temphold);
wait(500);
say_stop("`4Guess what, I have a little surprise for you today.", &temp5hold);
wait(500);
   wait(500);
  say_stop("`#More goat blood?", &temp4hold);
wait(500);
say_stop("`4No, Cindy.", &temp5hold);
wait(500);
say_stop("`4We have a new member.  Come on out, Mary!", &temp5hold);

 &crap = create_sprite(300,450, 0, 0, 0);
 &temp6hold = &crap;
 sp_script(&crap, "s2-cg5");
move_stop(&temp6hold, 8, 360, 1);
wait(500);
say_stop("`#Please!  I don't want to join your cult!", &temp6hold);
wait(500);
say_stop("`4You WILL learn to love the Dead Dragon Carcass, Mary.", &temp5hold);
wait(500);
say_stop("`#How can you worship a rotting corpse?!", &temp6hold);
wait(500);
  say_stop("`#I think the Carcass would appreciate another sacrifice, Bishop Nelson.", &temphold);
  wait(500);
say_stop("`4Excellent point, Jennifer.", &temp5hold);
wait(500);

start:

choice_start();
        set_y 240
        set_title_color 10
        title_start();
A girl is about to die in a cult ritual.  What do you do?
        title_end();
"Say something to the effect that you are going to save her"
"Agree that Mary should be sacrificed"
"Use brains and stay hidden"
choice_end()
wait(500);
if (&result == 3)
   {
     wait(200);
   sp_dir(1, 2);
     wait(200);
    say_stop("Nah, I think I'd rather shout something.", 1);
     wait(300);
   sp_dir(1, 4);
  wait(200);
   goto start;
   }

if (&result == 1)
  {
    Say_stop("Excuse me?", 1);
    wait(500);
          say_stop("`#There is a man hiding in the bushes!", &temphold);
          wait(500);
    Say_stop("Get your hands off her, Nelson!  She's coming with me!", 1);
    wait(500);
    say_stop("`4I don't think so, Smallwood.", &temp5hold);
wait(500);
move_stop(1, 4, 470, 1);
    wait(500);
    Say_stop("Girls!  This man is a lunatic - turn on him and destroy him!", 1);

  }


if (&result == 2)
  {
    Say_stop("I agree, crucify the new girl!", 1);
    wait(500);
          say_stop("`#There is a man hiding in the bushes!", &temphold);
          wait(500);
    Say_stop("I just adore your sadistic rituals.  May I continue to watch?", 1);
    wait(500);
    say_stop("`4Come here, child.", &temp5hold);
wait(500);
move_stop(1, 4, 470, 1);
    wait(500);
    Say_stop("Ahh, this is a much better view.", 1);

  }


    wait(500);
    say_stop("`4The Dead Dragon Carcass is calling for a sacrifice...", &temp5hold);
    wait(500);
    say_stop("`4HIM!", &temp5hold);
preload_seq(167);

  say_stop("`#Girls, TRANSFORM!", &temphold);
  wait(500);
screenlock(1);
unfreeze(1);

sp_brain(&temp5hold, 16);
sp_script(&temp5hold, "s2-cman");

sp_brain(&temp6hold, 16);
sp_script(&temp6hold, "s2-culg");


playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(265, 176, 7, 167, 1);
sp_seq(&mcrap, 167);
sp_script(&temphold, "s2-cbon");
wait(800);



playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(383, 179, 7, 167, 1);
sp_seq(&mcrap, 167);
sp_script(&temp2hold, "s2-cbon");
wait(800);

playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(229, 278, 7, 167, 1);
sp_seq(&mcrap, 167);
sp_script(&temp3hold, "s2-cbon");
wait(800);

playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(393, 278, 7, 167, 1);
sp_seq(&mcrap, 167);
sp_script(&temp4hold, "s2-cbon");
wait(800);

say_stop("`4You see, my girls are more than meets the eye.", &temp5hold);
//haha, transformers reference

playmidi("denube.mid");
}


