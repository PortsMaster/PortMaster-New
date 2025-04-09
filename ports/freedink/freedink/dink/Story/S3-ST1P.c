void main( void )
{
 int &call;
 &call = random(3,1);
 if (&call == 1)
 {
  freeze(&current_sprite);
  say_stop("`3Welcome to our book store sir.", &current_sprite);
  unfreeze(&current_sprite);
 }
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 say_stop("`3How may I help you today sir?", &current_sprite);
 choice_start()
 "Ask about the bookstore"
 "Ask about Magic"
 "Find out about the next town"
 "See what's news"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   say_stop("So what do you got here?", 1);
   wait(250);
   say_stop("`3We carry books, what did you think?", &current_sprite);
   wait(250);
   say_stop("Mmmmm", 1);
   say_stop("Noted.", 1);
  }
  if (&result == 2)
  {
   say_stop("Do you have anything in here on magic?", 1);
   wait(250);
   say_stop("`3Magic?  No such thing.", &current_sprite);
   wait(250);
   say_stop("I see... thanks.", 1);
  }
  if (&result == 3)
  {
   if (&mayor >= 6)
   {
    say_stop("Did you hear anything about that other town yet?", 1);
    wait(250);
    say_stop("`3Yeah actually, a man passed through here this morning,", &current_sprite);
    say_stop("`3he said the bridge was back up, so I'm sure you could", &current_sprite);
    say_stop("`3head over there and check it out.", &current_sprite);
    wait(250);
    say_stop("Okay, thanks.", 1);
    unfreeze(1);
    wait(1000);
    unfreeze(&current_sprite);
    return;
   }
   say_stop("Could you tell me about any other cool towns?", 1);
   wait(250);
   say_stop("`3There is a neat place east of Terris.", &current_sprite);
   wait(250);
   say_stop("`3But last I heard the bridge there was out.", &current_sprite);
   wait(250);
   say_stop("`3I'll let ya know if I hear anything though.", &current_sprite);
  }
  if (&result == 4)
  {
   say_stop("So what's been going on lately round here?", 1);
   wait(250);
   if (&mayor >= 6)
   {
    say_stop("`3Well, you should know hero!  Thanks for what you did,", &current_sprite);
    wait(250);
    say_stop("`3the mayor tells me you saved us all.", &current_sprite);
    wait(250);
    say_stop("Uh, well .. the mayor exaggerates just a bit,", 1);
    wait(250);
    say_stop("but yes, it was pretty much me.", 1);
    wait(250);
    say_stop("`3You're quite the popular guy,", &current_sprite);
    wait(250);
    say_stop("`3I even heard the mayor's daughter talking about you.", &current_sprite);
    wait(250);
    say_stop("Christina, really!??!  What did she say??", 1);
    wait(250);
    say_stop("`3Oh, I wasn't really listening that closely,", &current_sprite);
    wait(250);
    say_stop("`3just heard your name once or twice.", &current_sprite);
    wait(250);
    say_stop("Man!!", 1);
    sp_dir(1, 2);
    say_stop("Damn I'm cool!", 1);
    unfreeze(1);
    unfreeze(&current_sprite);
    return;
   }
    say_stop("`3Not much, everything's been pretty quiet", &current_sprite);
    wait(250);
    say_stop("`3people are waiting for the parade to happen soon.", &current_sprite);
    wait(250);
    say_stop("Oh.", 1);
    unfreeze(1);
    unfreeze(&current_sprite);
    return;


  }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 freeze(&current_sprite);
 say_stop("`3Oh my golly gosh, please don't hurt me mister...", &current_sprite);
 unfreeze(&current_sprite);
}
