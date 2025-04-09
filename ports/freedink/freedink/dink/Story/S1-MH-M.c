void main( void )
{
 if (&wizard_see == 2)
 {
  say("`0How goes the hunt Dink?", &current_sprite);
  return;
 }
 if (&wizard_see == 3)
 {
  sp_active(&current_sprite, 0);
  say("He's gone!!", 1);
  return;
 }
 if (&wizard_see == 4)
 {
  sp_active(&current_sprite, 0);
  return;
 }
 say("`0Ahh Dink, I've been expecting you.", &current_sprite);
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 if (&wizard_see == 0)
 {
  say_stop("Hi, it's me again.  Now who are you really?", 1);
  wait(200);
  say_stop("`0I am the Wizard Martridge.  A teacher of magic.", &current_sprite);
  wait(200);
  say_stop("Wow, I don't think I've ever seen your place around here before.", 1);
  wait(200);
  say_stop("`0I like being closer to nature.", &current_sprite);
  wait(200);
  say_stop("`0I've been watching you for a while Dink.", &current_sprite);
  wait(200);
  say_stop("Like, peeking in through my windows and such?", 1);
  wait(200);
  say_stop("`0No Dink, I have magic.", &current_sprite);
  wait(200);
  say_stop("`0You too may have the power, an ability for the supernatural.", &current_sprite);
  wait(200);
  say_stop("Really?  You think so?  Cool, what can I do?", 1);
  wait(200);
  say_stop("Can I like create chicks right in front of me and stuff?", 1);
  wait(200);
  say_stop("`0Uh, no.", &current_sprite);
  wait(200);
  say_stop("Well can I like float around and fly up into trees?", 1);
  wait(200);
  say_stop("`0Uh maybe, it depends...", &current_sprite);
  wait(200);
  say_stop("Can I throw death from my hands??", 1);
  wait(200);
  say_stop("`0Maybe I was wrong Dink.", &current_sprite);
  wait(200);
  say_stop("`0But these things can be hard to tell.", &current_sprite);
  &wizard_see = 1;
 }
 choice_start()
(&wizard_see == 1)"Tell him you're worthy"
 "Ask about Magic"
 "Nevermind"
 choice_end()
 wait(200);
 if (&result == 1)
 {
  int &boom;
  int &bottle;
  say_stop("Martridge, I .. I can handle it.  I'm prepared.", 1);
  wait(200);
  say_stop("I promise I'll be honorable and learn to use it right.", 1);
  wait(200);
  say_stop("`0Well Dink, you must prove yourself.", &current_sprite);
  wait(200);
  say_stop("Ah man, how do I do that?", 1);
  wait(200);
  say_stop("`0Well in a cave on these hills, there lies a beast.", &current_sprite);
  wait(200);
  say_stop("`0It's called a Bonca.  Slay it and return.", &current_sprite);
  wait(200);
  say_stop("I'll do it, I can fight the beast.", 1);
  wait(200);
  say_stop("`0Excellent, excellent.", &current_sprite);
  wait(200);
  say_stop("Where does it dwell?", 1);
  wait(200);
  say_stop("`0In a cave to the west Dink.", &current_sprite);
  wait(200);
  say_stop("I won't fail you.", 1);
  wait(200);
  &wizard_see = 2;
  say_stop("`0Here Dink, take this.  This red potion will strengthen you.", &current_sprite);
  &boom = create_sprite(187, 157, 7, 167, 1);
  sp_seq(&boom, 167);
  &bottle = create_sprite(187, 157, 0, 56, 1);
  playsound(24, 22052, 0, 0, 0);
  sp_script(&bottle, "rpotion");
 }
 if (&result == 2)
 {
  say_stop("Martridge, tell me about magic.", 1);
  wait(200);
  say_stop("`0Well magic is an ancient art.  Those who've known it", &current_sprite);
  wait(200);
  say_stop("`0have been great leaders, entertainers, and warriors.", &current_sprite);
  wait(200);
  say_stop("`0It's a great power and gift to those who can use it.", &current_sprite);
 }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 say("`0Why are you trying to hurt me Dink?", &current_sprite);
 //Warp the Wizard elsewhere
}
