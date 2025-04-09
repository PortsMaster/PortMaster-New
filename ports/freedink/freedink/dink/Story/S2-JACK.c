//script for jack

void main( void )
{
preload_seq(341);
preload_seq(343);
preload_seq(347);
preload_seq(349);
if (&s2-aunt > 2)
{
 sp_hitpoints(&current_sprite, 50);
}
int &myrand;
sp_base_walk(&current_sprite, 340);
sp_speed(&current_sprite, 1);
sp_pseq(&current_sprite, 341);
sp_pframe(&current_sprite, 1);
sp_brain(&current_sprite, 16);
}

void talk( void )
{

 freeze(1);
 freeze(&current_sprite);
         choice_start()
(&s2-aunt == 1)         "Say hi to Jack"
(&s2-aunt == 1)         "Thank Jack for his hospitality"
(&s2-aunt == 1)         "Say something rude to Jack"
(&s2-aunt == 3)         "Tell Jack to lay off Maria"
(&s2-aunt == 3)         "Coerce Jack into hitting Maria again"
         "Leave"
         choice_end()

        if (&result == 1)
        {
        wait(400);
         say_stop("Hi Jack! Whacha doing?", 1);
        wait(400);
         say_stop("`6Get lost.", &current_sprite);
        }

        if (&result == 2)
        {
        wait(400);
         say_stop("It's real nice of you letting me stay here and all.", 1);
        wait(400);
         say_stop("`6<grumble>  You find a new place tomorrow.", &current_sprite);
        }
        if (&result == 3)
        {
        wait(400);
         say_stop("Hey Jack!", 1);
        wait(400);
         say_stop("`6Yeah?", &current_sprite);
        wait(400);
         say_stop("Eat me!", 1);
        wait(400);
         say_stop("`6Why you little!!  Take this!", &current_sprite);
sp_touch_damage(&current_sprite, 10);
sp_speed(&current_sprite, 2);
sp_brain(&current_sprite, 9);
sp_target(&current_sprite, 1):
        }

        if (&result == 4)
        {
        wait(400);
         say_stop("Jack.  I know I'm your guest and all but...", 1);
        wait(400);
         say_stop("`6Yeah?", &current_sprite);
        wait(400);
        say_stop("If you touch Maria again, you won't live to see tomorrow.", 1);
        wait(400);
         say_stop("`6How about I touch you right now?", &current_sprite);
        wait(400);
        say_stop("Sorry, not into that.  But I know this guy named Milder...", 1);
        }

        if (&result == 5)
        {
        wait(400);
         say_stop("Jack.  Guess who was badmouthing you a second ago...", 1);
        wait(400);
         say_stop("`6My bitch wife?", &current_sprite);
        wait(400);
        say_stop("Yup.  Better lay a bit o law into her, if you know what I mean.", 1);
        wait(400);
         say_stop("`6Ok.", &current_sprite);
        wait(400);

       move_stop(&current_sprite, 8, 140, 1);
       move_stop(&current_sprite, 2, 140, 1);
       move_stop(&current_sprite, 4, 255, 1);
       move_stop(&current_sprite, 6, 256, 1);
       say_stop("`6Oh honey.. could you come here a sec?", &current_sprite);
        wait(400);
 freeze(&temp2hold);

       say_stop("`#Yes, Jack.",&temp2hold);
       move_stop(&temp2hold, 8, 140, 1);
       move_stop(&temp2hold, 2, 140, 1);
       move_stop(&temp2hold, 6, 310, 1);
       move_stop(&temp2hold, 4, 309, 1);
wait(500);
       say_stop("`#What is it?",&temp2hold);
wait(500);
       say_stop("`6Just this", &current_sprite);

wait(500);

   playsound(9, 17050,0,0,0);
&save_x = sp_x(&temp2hold, -1);
&save_y = sp_y(&temp2hold, -1);
&save_y -= 40; 
 int &mcrap = create_sprite(&save_x, &save_y, 5, 188, 1);
 sp_seq(&mcrap, 188);
wait(100);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 189, 1);
 sp_seq(&mcrap, 189);
wait(100);
   playsound(9, 17050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 188, 1);
 sp_seq(&mcrap, 188);
wait(100);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 189, 1);
 sp_seq(&mcrap, 189);
wait(100);
 wait(500);
       say_stop("Haw!  Good one Jack!",1);
       
 wait(500);

       say_stop("`6Now go clean up.", &current_sprite);
 wait(500);

   say_stop("`#<sob>  Dink... I..thought you were different.",&temp2hold);
 wait(500);
       say_stop("Get a clue, honey.  How do you think I kept my mom in line?  Haw!",1);

       unfreeze(&temp2hold);

        }


   unfreeze(1);
   unfreeze(&current_sprite);
   return;

}

void hit(void)
{
Say("`6Oh, NOW YOU'VE DONE IT!", &current_sprite);
sp_touch_damage(&current_sprite, 10);
sp_speed(&current_sprite, 2);
sp_brain(&current_sprite, 9);
sp_target(&current_sprite, 1):
}

void die(void)
{
script_attach(1000);
freeze(1);
freeze(&temp2hold);
wait(500);
say_stop("`#Dink!  What have you done!", &temp2hold);
wait(500);
say_stop('I guess I just killed your husband.", 1);
wait(500);
say_stop("`#Jack wasn't always like that.  He used to be.. <bursts into tears>", &temp2hold);
wait(500);
say_stop("I know.  It's ok, I'm here now.", 1);
&exp += 100;
&s2-aunt = 4;
unfreeze(1);
unfreeze(&temp2hold);
}
