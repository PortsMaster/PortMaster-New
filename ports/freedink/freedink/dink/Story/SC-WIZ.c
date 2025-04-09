void main( void )
{
 int &pap;
 int &wherex;
 int &wherey;
}

void talk( void )
{
 &wherex = sp_x(&current_sprite, -1);
 &wherey = sp_y(&current_sprite, -1);
 freeze(1);
 freeze(&current_sprite);
 if (&story > 14)
 {
  say_stop("`6Good job on winning.", &current_sprite);
  wait(250);
  say_stop("`6Bye.", &current_sprite);
  int &mcrap = create_sprite(&wherex, &wherey, 7, 167, 1);
  sp_seq(&mcrap, 167);
  playsound(24, 22052, 0, 0, 0);
  unfreeze(1);
  unfreeze(&current_sprite);
  &snowc = 1;
  sp_active(&current_sprite, 0);  
  return;
 }
 say_stop("Who, who are you?", 1);
 wait(250);
 say_stop("`6Me, who are you, someone not a goblin in these parts?!?", &current_sprite);
 wait(250);                           
 say_stop("What are you talking about?", 1);
 wait(250);
 say_stop("`6The war, the goblin war!", &current_sprite);
 wait(250);
 say_stop("`6I must defend this castle, I can't let them take it back.", &current_sprite);
 wait(250);
 say_stop("The .. the goblin wars, those ended a long long time ago!!", 1);
 wait(250);
 say_stop("They haven't fought for over 100 years!", 1);
 wait(250);
 say_stop("`6What!?!", &current_sprite);
 wait(250);
 say_stop("`6Is this true?", &current_sprite);
 wait(250);
 say_stop("I'm afraid so ...", 1);
 wait(250);
 say_stop("`6What ... what of the city of KernSin?", &current_sprite);
 wait(250);
 say_stop("Ooooo, well, both the city and its castle were destroyed", 1);
 wait(250);
 say_stop("during the last part of the war 100 years ago.", 1);
 wait(250);
 say_stop("Later it was partly rebuilt and now is the smaller town of KernSin.", 1);
 wait(250);
 say_stop("`6This, this is so much.  Did we win the war?", &current_sprite);
 wait(250);
 say_stop("Yes.", 1);
 wait(1000);
 say_stop("`6I .. I have to go somewhere, think about what has happened.", &current_sprite);
 wait(250);
 say_stop("`6Thank you ... what is your name friend?", &current_sprite);
 wait(250);
 say_stop("Dink Smallwood sir.", 1);
 wait(250);
 say_stop("`6SMALLWOOD ?!?", &current_sprite);
 wait(250);
 say_stop("`6I thought you were exiled.", &current_sprite);
 wait(250);
 say_stop("What??", 1);
 wait(250);
 say_stop("`6Of course, 100 years ago, he would've had children by now.", &current_sprite);
 wait(250);
 say_stop("Hey, you wanna tell me what you're talking about?", 1);
 wait(250);
 say_stop("`6Your family has an interesting lineage.", &current_sprite);
 wait(250);
 say_stop("`6The ancient ones are drawn to you,", &current_sprite);
 wait(250);
 say_stop("`6they can draw and feed upon magic from your family.", &current_sprite);
 wait(250);
 say_stop("`6And if one were to destroy you, they would gain immense power.", &current_sprite);
 wait(250);
 say_stop("There is some chaos brewing in this land now.", 1);
 wait(250);
 say_stop("We don't know who's behind it either.  I was on my way to", 1);
 wait(250);
 say_stop("the darklands when I came here, I have to rescue a friend.", 1);
 wait(250);
 say_stop("`6Be careful Dink, whoever is behind this is probably an ancient,", &current_sprite);
 wait(250);
 say_stop("`6making it all seem to be someone else.", &current_sprite);
 wait(500);
 say_stop("`6I must go, beware Dink, and good luck.", &current_sprite);
 int &mcrap = create_sprite(&wherex, &wherey, 7, 167, 1);
 sp_seq(&mcrap, 167);
 playsound(24, 22052, 0, 0, 0);
 unfreeze(1);
 unfreeze(&current_sprite);
 &snowc = 1;
 sp_active(&current_sprite, 0);
}

void hit( void )
{
 &wherex = sp_x(&current_sprite, -1);
 &wherey = sp_y(&current_sprite, -1);
 say("`6Bad idea ...", &current_sprite);
 &pap = random(3, 1);
 if (&pap == 1)
 {
  int &mcrap = create_sprite(&wherex, &wherey, 7, 167, 1);
  sp_seq(&mcrap, 167);
  playsound(24, 22052, 0, 0, 0);
  int &mcrap2 = create_sprite(100, 143, 7, 167, 1);
  sp_seq(&mcrap2, 167);
  sp_x(&current_sprite, 100);
  sp_y(&current_sprite, 143);
 }
 if (&pap == 2)
 {
  int &mcrap = create_sprite(&wherex, &wherey, 7, 167, 1);
  sp_seq(&mcrap, 167);
  playsound(24, 22052, 0, 0, 0);
  int &mcrap2 = create_sprite(429, 151, 7, 167, 1);
  sp_seq(&mcrap2, 167);
  sp_x(&current_sprite, 429);
  sp_y(&current_sprite, 151);
 }
 if (&pap == 3)
 {
  int &mcrap = create_sprite(&wherex, &wherey, 7, 167, 1);
  sp_seq(&mcrap, 167);
  playsound(24, 22052, 0, 0, 0);
  int &mcrap2 = create_sprite(288, 301, 7, 167, 1);
  sp_seq(&mcrap2, 167);  
  sp_x(&current_sprite, 288);
  sp_y(&current_sprite, 301);  
 }
}
