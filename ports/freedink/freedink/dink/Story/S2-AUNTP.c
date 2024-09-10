//script for auntie

void main( void )
{
preload_seq(251);
preload_seq(253);
preload_seq(257);
preload_seq(259);

 if (&s2-aunt < 4)
 {
 int &temphold = create_sprite(160,150, 0, 0, 0);
 sp_script(&temphold, "s2-jack");
 wait(5);
 }
int &myrand;
sp_base_walk(&current_sprite, 250);
sp_speed(&current_sprite, 1);
//sp_timing(&current_sprite, 66);

//set starting pic

sp_pseq(&current_sprite, 251);
sp_pframe(&current_sprite, 1);

if (&s2-aunt == 2)
  {
   freeze(1);
   sp_hitpoints(&temphold, 50);
   sp_brain(&current_sprite, 0);
   sp_x(&current_sprite, 113);
   sp_y(&current_sprite, 180);
   sp_brain(&temphold, 0);
   sp_x(&temphold, 154);
   sp_y(&temphold, 160);
   sp_pseq(&current_sprite, 259);
   sp_pseq(&temphold, 341);
&save_x = sp_x(&current_sprite, -1);
&save_y = sp_y(&current_sprite, -1);
&save_y -= 40; 
   wait(500);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 188, 1);
 sp_seq(&mcrap, 188);
  
   say_stop("`6This will learn you to talk back to me!", &temphold);
  sp_dir(&temphold, 1);
   wait(500);
  sp_dir(1, 1);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 189, 1);
 sp_seq(&mcrap, 189);
  wait(300);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 188, 1);
 sp_seq(&mcrap, 188);
 say_stop("`#Please Jack!  Stop...", &current_sprite);
  wait(300);
  say_stop("`6Shut your trap!", &temphold);
  sp_dir(&temphold, 1);

   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 189, 1);
 sp_seq(&mcrap, 189);
  wait(300);
 say_stop("`#I'm leaving you!  We're through!", &current_sprite);
  wait(300);
  say_stop("`6Through are we?", &temphold);

   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 188, 1);
 sp_seq(&mcrap, 188);
wait(50);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 189, 1);
 sp_seq(&mcrap, 189);
wait(50);

   playsound(9, 17050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 188, 1);
 sp_seq(&mcrap, 188);
wait(50);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 189, 1);
 sp_seq(&mcrap, 189);
wait(50);
   playsound(9, 24050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 188, 1);
 sp_seq(&mcrap, 188);
wait(50);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 189, 1);
 sp_seq(&mcrap, 189);
wait(50);

   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 188, 1);
 sp_seq(&mcrap, 188);
wait(50);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 189, 1);
 sp_seq(&mcrap, 189);
wait(50);

   playsound(9, 17050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 188, 1);
 sp_seq(&mcrap, 188);
wait(50);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 189, 1);
 sp_seq(&mcrap, 189);
wait(50);
   playsound(9, 24050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 188, 1);
 sp_seq(&mcrap, 188);
wait(50);
   playsound(9, 22050,0,0,0);
 int &mcrap = create_sprite(&save_x, &save_y, 5, 189, 1);
 sp_seq(&mcrap, 189);
wait(50);




   wait(2000);

  say_stop("`6You ok, baby?", &temphold);
  wait(2000);
 &s2-aunt = 3;

  say_stop("`6You shouldn't make me so mad.", &temphold);
  wait(1000);
 sp_brain(&current_sprite, 16);
  unfreeze(1);

 say_stop("`#<sob>", &current_sprite);
 wait(1000);
 sp_brain(&temphold, 16);
  return;
  }


if (&s2-aunt == 0)
  {
   freeze(1);
  
   sp_x(&current_sprite, 600);
   sp_y(&current_sprite, -50);
   wait(500);
   say_stop("Hello.", 1);
   freeze(&temphold);
   sp_dir(&temphold, 3);
   wait(500);
   say_stop("`6Who the hell are you?", &temphold);
   wait(500);
   say_stop("I'm.. I'm Dink Smallwood.  I got a letter and...", 1);
   wait(500);
   say_stop("`6I ain't sent no letter to nobody nohow.", &temphold);
   wait(500);
   say_stop("But I...", 1);
   wait(300);
   say_stop("`6Git outta my house.", &temphold);

   move_stop(&current_sprite, 1, 430, 1);
   sp_seq(&current_sprite, 0);
   wait(500);
   say_stop("`#Dink!  You made it!", &current_sprite);
   wait(500);
   say_stop("Auntie Maria!", 1);
   wait(500);
   say_stop("`6What the? How do you know my wife?  You two been cheatin' on me?", &temphold);
   wait(500);
   say_stop("`#Jack, this is my nephew from Stonebrook.", &current_sprite);
   wait(500);
   say_stop("`#He's going to be staying with us a while.", &current_sprite);
   wait(500);
   say_stop("`6Huh?  Since when? Gawd dammit!", &temphold);
   wait(500);
   say_stop("`#Dink, I've prepared a room for you upstairs.", &current_sprite);
   wait(500);
   say_stop("Thanks, I'm sure it will be fine.", 1);
   wait(500);
   say_stop("`#Just ask if you need anything.", &current_sprite);
   &s2-aunt = 1;
   unfreeze(&temphold);
    }


   unfreeze(1);
  }

sp_brain(&current_sprite, 16);


}

void talk( void )
{

 freeze(1);
 freeze(&current_sprite);
         choice_start()
(&s2-aunt == 1) "Ask about your mother"
(&s2-aunt == 1) "Ask her about the town"
(&s2-aunt == 3) "Encourage her to dump Jack"
(&s2-aunt == 3) "Encourage her to continue getting beaten by Jack"
(&s2-aunt == 4) "Comfort her"
(&s2-aunt == 4) "Ask for a bigger bed"
(&s2-aunt == 4) (&story == 8) "Tell Maria about your latest adventure"
(&s2-aunt == 5) "Talk about nothing"
(&s2-aunt == 4) (&story > 15) "Brag to Maria about saving the world"
         "Leave"
         choice_end()

        if (&result == 8)
        {
        wait(400);
        say_stop("I just wanted to say, thanks for letting me stay with you.", 1);
        wait(400);
        say_stop("`#It's really no problem, Dink.  Have you been looking for a job at all?", &current_sprite);
        wait(400);
        say_stop("Whups, gotta get going!  See ya!", 1);

        }
        if (&result == 7)
        {
        wait(400);
        say_stop("Guess what I did today!", 1);
        wait(400);
        say_stop("`#Saved Nadine's girl?", &current_sprite);
        wait(400);
        say_stop("Uh, yeah.  How did you know?", 1);
        wait(400);
        say_stop("`#It's in the King's News, there is a copy at the healers.", &current_sprite);
        wait(400);
        say_stop("Ah.  Ok.", 1);
        &s2-aunt = 5;
        }

        if (&result == 1)
        {
        wait(400);
         say_stop("So how do you know my mom?", 1);
        wait(400);
        say_stop("`#Well, she's my sister.", &current_sprite);
        wait(400);
        say_stop("Ah, that explains a few things.", 1);
        }
        if (&result == 2)
        {
        wait(400);
         say_stop("So tell me about Terris.", 1);
        wait(400);
        say_stop("`#It's not a bad town to live in.", &current_sprite);
        wait(400);
        say_stop("You don't sound so enthusiastic.", 1);
        wait(400);
        say_stop("`#Well.. things have been rough lately, that's all.", &current_sprite);
        }

        if (&result == 3)
        {
        wait(400);
         say_stop("I saw Jack hit you.", 1);
        wait(400);
        say_stop("`#You.. you did?", &current_sprite);
        wait(400);
        say_stop("Why don't you leave him?  Now?  Tonight?", 1);
        wait(400);
        say_stop("`#I'm afraid of him.  He would find me.", &current_sprite);
        wait(400);
        say_stop("Well maybe I'll just have to do something about it myself.", 1);
        wait(400);
        say_stop("`#Be careful!  He's very strong,", &current_sprite);
        wait(400);
        say_stop("He ain't nothing, just you watch.", 1);
        }

        if (&result == 4)
        {
        wait(400);
         say_stop("I saw Jack hit you.", 1);
        wait(400);
        say_stop("`#You.. you did?", &current_sprite);
        wait(400);
        say_stop("Yes, he's good at it.  I hope to learn much from him.", 1);
        wait(400);
        say_stop("`#What?!", &current_sprite);
        wait(400);
        say_stop("I just admire his stroke - takes practice you know.", 1);
        }

        if (&result == 5)
        {
        wait(400);
         say_stop("How are you holding up?", 1);
        wait(400);
        say_stop("`#I'm ok.  How do you like our town?  And living here?", &current_sprite);
        wait(400);
        say_stop("I like it.  I think the locals like me too.", 1);
        wait(400);
        say_stop("`#I feel safe with you upstairs.", &current_sprite);
        wait(400);
        say_stop("Me too.", 1);
        }
        if (&result == 6)
        {
        wait(400);
         say_stop("Say.. I like the room and all, but my bed is a little small.", 1);
        wait(400);
        say_stop("`#I would trade, but mine is the exact same size.", &current_sprite);
        wait(400);
        say_stop("What if you traded them in for one big one we could share?", 1);
        wait(400);
        say_stop("`#I'm your aunt, Dink!", &current_sprite);
        wait(400);
        say_stop("And?", 1);
        wait(400);
        say_stop("`#I have some work I have to do.", &current_sprite);
        }


        if (&result == 9)
        {
        wait(400);
         say_stop("Hey guess what, I just got back from a huge adventure.", 1);
        wait(400);
        say_stop("`#That's great.", &current_sprite);
        wait(400);
        say_stop("I pretty much saved the universe.", 1);
        wait(400);
        say_stop("`#Uh huh, fine.", &current_sprite);
        wait(400);
        say_stop("You don't believe any of this.", 1);
        wait(400);
        say_stop("`#Sorry Dink, I know how young men like to tell tales.", &current_sprite);
        wait(400);
        choice_start()
        "Pass off her indifference lightly"
        "Get rude about it"
        choice_end();
         if (&result == 1)
         {
        say_stop("Heh - that's what I like about you auntie!", 1);

         }
         if (&result == 2)
         {
        say_stop("You stupid whore.", 1);
        wait(400);
        say_stop("`#Excuse me?", &current_sprite);
        wait(400);
        say_stop("I see now I shouldn't have killed Jack.", 1);
        wait(400);
        say_stop("I should have joined forces with him.", 1);       
         }


        }



   unfreeze(1);
   unfreeze(&current_sprite);
   return;

}

void hit(void)
{
 int &mcrap = random(4, 1);

  if (&mcrap == 1)
    Say("Take your beatin' like a man, woman!", 1);
  if (&mcrap == 2)
    Say("`#Please.. please don't hit me!", &current_sprite);
  if (&mcrap == 3)
    Say("I hope you like it rough!", 1);
  if (&mcrap == 4)
    Say("I hate relatives!", 1);


}
