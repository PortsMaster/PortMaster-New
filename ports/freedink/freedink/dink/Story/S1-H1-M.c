
void main(void)
{
int &whob = sp(26);
sp_hitpoints(&current_sprite, 0);


 if (&story > 2)
 {
 sp_active(&whob,0);
// draw_hard_map();
 return;
 }

 if (&old_womans_duck > 2)
 {
 if (&pig_story == 0)
 {
move_stop(&current_sprite, 2, 160, 1);
freeze(&current_sprite);
wait(200);
say_stop("`#Dink, it's getting late!  No food until you feed the pigs!", &current_sprite);
wait(200);
unfreeze(&current_sprite);
return;
 }
 &story = 2;
 move_stop(1, 8, 370, 1);
freeze(1);
move_stop(&current_sprite, 2, 200, 1);
freeze(&current_sprite);
wait(1000);
 say_stop("`#Dink, can you do something for me?", &current_sprite);
 wait(500);
 say_stop("Yes, what is it?", 1);
 wait(500);
 say_stop("`#Can you go out to the woods and see if you can get,", &current_sprite);
 wait(500);
 say_stop("`#some AlkTree nuts, I think they're in season.", &current_sprite);
 wait(500);
 say_stop("No problem, I'll be right back.", 1);
 wait(250);
 say_stop("`#You're a dear.", &current_sprite);
 unfreeze(1);
 unfreeze(&current_sprite);
 return;
 }



 if (&story == 0)
 {
 //new game was just started.
 //make script live on
 int &cur_sprite = &current_sprite;
 playmidi("dance.mid");
 freeze(1);
 freeze(&cur_sprite);
 wait(1000);
 say_stop("`#Dink, would you go feed the pigs?", &cur_sprite);
 wait(200);
 say_stop("What, now?", 1);
 wait(200);
 say_stop("`#YES, NOW.", &cur_sprite);
 unfreeze(1);
 unfreeze(&cur_sprite);
 playsound(22, 22050, 0,0,0);
 &update_status = 1;
 draw_status();
 &story = 1;
 return;
 }

}

void talk(void)
{
 freeze(1);
 freeze(&current_sprite);
 choice_start();
   "Ask about pig feeding"
   "Ask about your father" 
   "Get info about the village"
   "Get angry for no reason"
(&pig_story == 1) "Tell her you fed the pigs"
   "Leave"
 choice_end();

 wait(200);

 if (&result == 1)
  {
  say_stop("Mother, how do I feed the pigs?  I forgot!",1);
  wait(200);
  say_stop("`#That's very amusing, Dink.  You get the sack of feed, and you", &current_sprite);
  say_stop("`#sprinkle it in the pig pen.  And don't tease them!", &current_sprite);
  wait(100);
  }

 if (&result == 2)
  {
  say_stop("What kind of a man was father?",1);
  wait(200);
  say_stop("`#He was a peasant like us.", &current_sprite);
  wait(200);
  say_stop("Was he good with the sword?",1);
  wait(200);
  say_stop("`#Of course not.  He was a wonderful farmer and husband.", &current_sprite);

  }
 if (&result == 3)
  {
  say_stop("Tell me about this village.",1);
  wait(200);
  say_stop("`#The villagers are very friendly.  Oh, Ethel wants to see you.", &current_sprite);
  wait(200);
  say_stop("Ethel?  She's old, isn't she?",1);
  wait(200);
  say_stop("`#Yes Dink, she is. <laugh>", &current_sprite);
  }

 if (&result == 4)
  {
  say_stop("I HATE YOU!",1);
  wait(200);
  say_stop("`#You'll get over it.",&current_sprite);
  }

 if (&result == 5)
  {
  say_stop("I'm finished with my chores, mother.",1);
  wait(200);
  say_stop("`#Good boy.  Go visit our neighbors while I prepare dinner.", &current_sprite);
  }


 unfreeze(1);
 unfreeze(&current_sprite);

  }

}

void hit(void)
{
 say_stop("`#Ouch!  Stop it!", &current_sprite);

}

