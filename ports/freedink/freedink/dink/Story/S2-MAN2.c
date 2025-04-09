//script for old guys in the bar

void main( void )
{

preload_seq(411);
preload_seq(413);
int &myrand;
sp_brain(&current_sprite, 0);
sp_base_walk(&current_sprite, 410);
sp_speed(&current_sprite, 0);

//set starting pic

sp_pseq(&current_sprite, 411);
sp_pframe(&current_sprite, 1);

mainloop:
wait(2000);
if (&temp4hold == 1)
  {
&myrand = random(5, 1);
  if (&myrand == 1)
  {
  say_stop_npc("`0Fight!!!", current_sprite);
  }
   goto mainloop;
  }
&myrand = random(8, 1);

  if (&myrand == 1)
  {
  sp_pseq(&current_sprite, 411);
  }

  if (&myrand == 2)
  {
  sp_pseq(&current_sprite, 413);
  }

&myrand = random(28, 1);

  if (&myrand == 1)
  {
  say_stop_npc("`3Nathan, how about another story?", &temp3hold);
  say_stop_npc("`0Alright.", &current_sprite);
  say_stop_npc("`0One time I was fighting this dragon...", &current_sprite);
  say_stop_npc("`0As I was about to deliver the death blow....", &current_sprite);
  say_stop_npc("`0He begged me for his life.  Have you ever seen a dragon cry?", &current_sprite);
  wait(400);
  say_stop_npc("`3Nope.", &temp3hold);
  wait(400);
if (&temp4hold == 1)
  {
   goto mainloop;
  }

  say_stop_npc("`4Haw, those old codgers are so full of it...", &temphold);
  say_stop_npc("`0Anyway, it wasn't pretty so I killed him.", &current_sprite);
  say_stop_npc("`3And just where did you see a Dragon?", &temp3hold);
  say_stop_npc("`0Uh.. Joppa Isle!", &current_sprite);
  say_stop_npc("`3Liar.. Joppa Isle doesn't exist, it's a story for kids.", &temp3hold);

  }

  if (&myrand == 2)
  {
  say_stop_npc("`0Did I ever tell you about the time I trained a slayer?", &current_sprite);
  say_stop_npc("`3You trained a slayer!?!", &temp3hold);
  say_stop_npc("`0Yup.  I raised him from when he was a pup.  He would do anything I told him to.", &current_sprite);
  say_stop_npc("`3Where is he now??!", &temp3hold);
  say_stop_npc("`0Had to kill 'em.  Ever had slayer meat?", &current_sprite);
if (&temp4hold == 1)
  {
   goto mainloop;
  }

  say_stop_npc("`4Give me a break...", &temphold);
  say_stop_npc("`0It tastes better than what you serve here, barkeep!", &current_sprite);
  say_stop_npc("`4I'll make a note of that...", &temphold);

  }

  if (&myrand == 3)
  {
  say_stop_npc("`0Then there was the time I found a magic scroll", &current_sprite);
  say_stop_npc("`3Oh yeah?", &temp3hold);
  say_stop_npc("`0Sure did, some strange fire spell it was.", &current_sprite);
  say_stop_npc("`0I may have helped that big fire back a few seasons ago.", &current_sprite);
  say_stop_npc("`0Quite toasty things got!", &current_sprite);
  say_stop_npc("`3Whatever, you've had too much to drink.", &temp3hold);
  }
  if (&myrand == 4)
  {
  say_stop_npc("`0You wanna go hunting?", &current_sprite);
  say_stop_npc("`3Sure I guess, why you wanna go hunting?", &temp3hold);
  say_stop_npc("`0I hear there's a cave to the northeast with quite a catch inside it.", &current_sprite);
  say_stop_npc("`3I don't know...", &temp3hold);
  }


goto mainloop;
}


void hit( void )
{
sp_speed(&current_sprite, 0);
wait(400);
say_stop_npc("`0You'd best learn some manners quickly, boy.", &current_sprite);
wait(800);
goto mainloop;
}

void talk( void )
{

 freeze(1);
         choice_start()
(&s2-milder == 0) "Impress the men with your tales of valour"
(&s2-milder == 1) "Convince the men that you ARE a warrior"
(&s2-milder == 2) (&story < 8) "Argue with the men even more"
(&s2-milder == 2) (&story > 7) "Chat with the men"
         "Leave"
         choice_end()

    if (&result == 1)
    {
wait(500);
 say_stop("Greetings men.  I bring stories of my adventures from the East.", 1);
     //scene with Milder
  preload_seq(401);
  preload_seq(403);
  preload_seq(407);
  preload_seq(409);
  sp_pseq(&temp3hold, 349);
  say_stop("`0Oh really?  And who might you be?", &current_sprite);
  wait(500);
  say_stop("My name is Dink Smallwood.  I am a warrior!", 1);
  wait(500);
  sp_pseq(&current_sprite, 413);
  say_stop("`3You've had adventures, eh?", &temp3hold);
  wait(500);
  say_stop("Oh yes.  Once, I was in this really scary cave...", 1);
  wait(500);
  say_stop("`0Yes, go on!", &current_sprite);
  wait(500);
  say_stop("Next thing I knew I was face to face with a huge monster...", 1);
  playmidi("bullythe.mid");
  int &milder = create_sprite(261, 440, 0, 0,0);
  sp_base_walk(&milder, 400);
  sp_speed(&milder, 1);
  sp_timing(&milder, 0);
move_stop(&milder, 9, 420, 1)
move_stop(&milder, 7, 386, 1)
sp_dir(1, 6);
say_stop("`6What nonsense is this pig farmer filling your heads with?", &milder);
wait(300);
  say_stop("`0He's a PIG FARMER?!", &current_sprite);
  wait(300);
  say_stop("Damn you, Milder!  What are you doing here?", 1);
move_stop(&milder, 4, 300, 1)
  wait(300);

say_stop("`6Just passing through... what are you doing away from the farm?", &milder);
  wait(300);
  say_stop("`3Farm?!  What a loser!", &temp3hold);
  wait(300);
  sp_dir(1, 4);
  say_stop("I don't tend pigs anymore, I'm a mighty warrior.", 1);
  wait(500);
  say_stop("`0Oh hogwash!", &current_sprite);
  wait(500);
  say("`3Hahahah!", &temp3hold);
  say_stop("`6Hahaha!  Good one, peasant!", &milder);
 wait(400);
 say_stop("That IS NOT funny.",1);
 wait(400);
  say_stop("`0I'm sorry Dink.. I'll make it up by buying you a drink.", &current_sprite);
 wait(400);
 say_stop("Great, what kind?",1);
 wait(400);
  say_stop("`0Is a bottle of SWINE ok? Bawahahah!", &current_sprite);
 wait(400);
  say("`3Hahahah!", &temp3hold);
  say_stop("`6Hahaha!", &milder);
 wait(200);
 say_stop("You stupid rubes!  I hate you both!", 1);
 wait(200);
 say_stop("`6This has been fun, pig boy, but I have REAL adventuring to do.  See ya.", &milder);
 move_stop(&milder, 3, 370, 1)
 move_stop(&milder, 1, 210, 1)
  playmidi("");

 say_stop("`0He said pig boy...", &current_sprite);
 wait(400);
  say("`3Hahahah!", &temp3hold);
  say("`0Hahaha!", &current_sprite);
  wait(400);
  &s2-milder = 1;  
    }

if (&result == 2)
  {
   wait(500);
   say_stop("Look... My farming days are over, ok?", 1);
   wait(500);
   say_stop("`0Ok, you really want some adventure?", &current_sprite);
   wait(500);
   say_stop("Oh yes!",1);
   wait(500);
   say_stop("`0Go plow Harper's field, farmer boy.", &current_sprite);
   wait(500);
  say("`3Hahahah!", &temp3hold);
  say_stop("`0Hahahah!", &current_sprite);
   wait(500);
   say_stop("How 'bout I plow your momma?",1);
  &s2-milder = 2;
  }

 if (&result == 3)
  {
   wait(500);
   say_stop("Look...",1);
   wait(500);
  say_stop("`0Save it boy, come back when you've done something important.", &current_sprite);
  }


 if (&result == 4)
  {
   wait(500);
  say_stop("`0Hey, it's Dink!  Great job on saving that girl!", &current_sprite);
   wait(500);
  say_stop("`3I told you he had the makings of a hero!", &temp3hold);
   wait(500);
   say_stop("Actually, didn't you both laugh at me and such?",1);
   wait(500);
  say_stop("`0No.  That was uh, two other guys...", &current_sprite);
   wait(500);
  }



   unfreeze(1);
   goto mainloop;
   return;
goto mainloop;

}

