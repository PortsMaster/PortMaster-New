void talk( void )
{
freeze(1);

 if (&story == 15)
 {
 playmidi("1011");
 say_stop("`%SMALLWOOD HAS RETURNED!", &current_sprite);
 wait(300);
 say_stop("I have sad news, my King.",1);
 wait(300);
 say_stop("Sir Flatstomp is dead.  He died in my arms, bravely.", 1);
 wait(300);
 say_stop("`%I will inform Lyna.  I was afraid this was so.", &current_sprite);
 wait(300);
 say_stop("Also - the evil ancient Seth has been vanquished.", 1);
 wait(300);
 say_stop("`%Hooray!  The world is safe!", &current_sprite);

  say_stop_xy("CONGRATULATIONS!", 20, 380);
 wait(300);
  say_stop_xy("YOU HAVE FINISHED THE GAME.", 20, 380);
 wait(300);
  say_stop_xy("You took a boy and turned him into a hero.", 20, 380);
 wait(300);
  say_stop_xy("Is this the end?", 20, 380);
 wait(300);
  say_stop_xy("Not by a long shot.", 20, 380);
 wait(300);
  say_stop_xy("There are hundreds more adventures awaiting you.", 20, 380);
 wait(300);
  say_stop_xy("Get them (and other great games!) at www.rtsoft.com", 20, 380);
 wait(300);
  say_stop_xy("Or make your own, download the free development kit.", 20, 380);
 wait(300);
  say_stop_xy("Special thanks to the following:", 20, 380);
 wait(300);
  say_stop_xy("Justin - sorry I made you draw blood ;)", 20, 380);
 wait(300);
  say_stop_xy("Pap - Great level design and story (when you were here...)", 20, 380);
 wait(300);
  say_stop_xy("Shawn - corndogs are NOT the food of the God's", 20, 380);
 wait(300);
  say_stop_xy("(for other unwise sayings, check out the QUOTES.TXT file)", 20, 380);
 wait(300);
  say_stop_xy("Thanks for playing - Seth", 20, 380);

 wait(300);
 say_stop("`%And now, food for my hungry hero!", &current_sprite);

playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(273, 264, 7, 167, 1);
sp_seq(&mcrap, 167);
wait(200);
 &temp1hold = create_sprite(273, 264, 0,0,0);
 sp_script(&temp1hold, "rpotion");
wait(300);

playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(336, 264, 7, 167, 1);
sp_seq(&mcrap, 167);
wait(200);
 &temp1hold = create_sprite(336, 264, 0,0,0);
 sp_script(&temp1hold, "rpotion");
wait(300);

playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(401, 264, 7, 167, 1);
sp_seq(&mcrap, 167);
wait(200);
 &temp1hold = create_sprite(401, 264, 0,0,0);
 sp_script(&temp1hold, "rpotion");
wait(300);


playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(273, 302, 7, 167, 1);
sp_seq(&mcrap, 167);
wait(200);
 &temp1hold = create_sprite(273, 302, 0,0,0);
 sp_script(&temp1hold, "ppotion");
wait(300);

playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(336, 302, 7, 167, 1);
sp_seq(&mcrap, 167);
wait(200);
 &temp1hold = create_sprite(336,302, 0,0,0);
 sp_script(&temp1hold, "ppotion");
wait(300);

playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(401, 302, 7, 167, 1);
sp_seq(&mcrap, 167);
wait(200);
 &temp1hold = create_sprite(401,302, 0,0,0);
 sp_script(&temp1hold, "ppotion");
wait(300);



 &story = 16;
 unfreeze(1);
 return;
 }


 if (&story == 16)
 {
 say("`%Ahh, my favorite subject!", &current_sprite);
 unfreeze(1);
 return;
 }



 if (&story == 14)
 {
  say_stop("`%You must hurry, Dink.", &current_sprite);
 unfreeze(1);
 return;
 }

 if (&story == 12)
 {
  say_stop("`%Hello, Dink.", &current_sprite);
  wait(300);
  say_stop("`%I've heard much about you - it is good to finally meet you.", &current_sprite);
  wait(300);
  say_stop("Greetings, M'lord.", 1);
  wait(300);
  say_stop("`%Now what is it I can help you with?", &current_sprite);
  wait(300);
  &story = 13;
  }

  choice_start();
(&story == 13)  "Complain about your taxes"
(&story == 13)  "Offer to help Milder"
  "Leave"
  choice_end();

if (&result == 1)
   {
    //whine about taxes
  wait(300);
  say_stop("Well... I think you should lower the pig tax, sir.", 1);
  wait(300);
  say_stop("`%Oh really?", &current_sprite);
  wait(300);
  say_stop("Yes - my family got royally screwed by the crown each year.", 1);
  wait(300);
  say_stop("`%I will take that into consideration Dink, I really will.", &current_sprite);
   }

if (&result == 2)
   {
    //help Milder
  wait(300);
  say_stop("I heard about Milder.", 1);
  wait(300);
  say_stop("`%Yes.. he was a very brave knight - he entered the darklands knowing...", &current_sprite);
  wait(300);
  say_stop("`%full well that very few return.  And now he is lost too.", &current_sprite);
  wait(300);
  say_stop("I would like permission to go after him, my King.", 1);
  wait(300);
  say_stop("`%You Dink?  It is suicide.", &current_sprite);
  wait(300);
  say_stop("He grew up in my village - I cannot turn my back on him.", 1);
  wait(300);
  say_stop("`%And I cannot refuse you.", &current_sprite);
  wait(300);
  say_stop("`%But... just getting to the darklands is quite a challenge...", &current_sprite);
  wait(300);
  say_stop("Please - just tell me the way.", 1);
  wait(300);
  say_stop("`%Go north from this castle until you hit the cliffs.", &current_sprite);
  wait(300);
  say_stop("`%I will have men there to guide you through the passage.", &current_sprite);
  wait(300);
  say_stop("`%And Dink...", &current_sprite);
  wait(300);
  say_stop("`%Something very strange is happening to the world...", &current_sprite);
  wait(300);
  say_stop("`%The darklands seem to be the origin.  Please be careful.", &current_sprite);
  wait(300);
  say_stop("Thank you.  I'll be back, and I won't be alone.", 1);
  &story = 14;
   }

   

 
unfreeze(1);

}


 void hit ( void )
 {
  //they try to damage the king

  say_stop("`%You have just attacked me, the King?", &current_sprite);
  wait(300);
  say_stop("`%Ahh, the famous Dink Smallwood sense of humor I heard so much about!", &current_sprite);
 }
