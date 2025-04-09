//Goblin George

void main( void )
{
int &mcounter;
sp_brain(&current_sprite, 16);
sp_speed(&current_sprite, 1);
sp_distance(&current_sprite, 50);
sp_timing(&current_sprite, 66);
sp_exp(&current_sprite, 50);
sp_base_walk(&current_sprite, 760);
sp_defense(&current_sprite, 2);
sp_hitpoints(&current_sprite, 40);
preload_seq(765);
preload_seq(761);
preload_seq(763);
preload_seq(767);
preload_seq(769);
wait(3500);

say("`6heeloo, freen.  We kan took tegether?", &current_sprite);
}

void hit( void )
{
playsound(28, 22050,0,&current_sprite, 0);
&mcounter = random(3, 1);
sp_frame_delay(&current_sprite, 30);
sp_timing(&current_sprite, 0);
sp_speed(&current_sprite, 2);
sp_brain(&current_sprite, 9);
if (&mcounter == 1)
  say("`6osh!  Puheaze hooman! We chan bey freens!", &current_sprite);

if (&mcounter == 2)
  say("`6doon hort meeee!", &current_sprite);

if (&mcounter == 3)
  say("`6i won oose vilens!", &current_sprite);

}

void die( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 1); 
  say("Let that be a clear message to his people.  Haw!", 1);
}
void talk( void )
{
        freeze(&current_sprite);
        freeze(1);

 choice_start()
 "Ask the Goblin's name"
 "Ask what he is doing way out here"
 "Ask about the Goblin Sanctuary"
 "Leave"
 choice_end()

  if (&result == 1)
   {
    say_stop("What is your name, Goblin?", 1);
    wait(500);
    say_stop("`6my nam is george.  whe kin bey gud frins?", &current_sprite);
    wait(500);
    say_stop("I don't understand a thing you're saying.", 1);
   }


  if (&result == 2)
   {
    say_stop("Say, why aren't you in the Goblin sanctuary?", 1);
    wait(500);
    say_stop("`6i wans tu leaf weth hoomankind.", &current_sprite);
    wait(500);
    say_stop("Many people are afraid of goblins, you know.", 1);
    wait(500);
    say_stop("`6george is hoomankind.", &current_sprite); 
    wait(500);
    say_stop("Ah, I see.  Good luck to you.", 1);
   }

  if (&result == 3)
   {
    say_stop("So what's with that Goblin Sanctuary place?", 1);
    wait(500);
    say_stop("`6they ar BAD.  they can oonly anderstund ONE theng.", &current_sprite);
    wait(500);
    say_stop("And just what thing is that?  I may need to know this.", 1);
    wait(500);
    say_stop("`6voilense.  too summon mog yoo mus KILL many guuards.", &current_sprite); 
    wait(500);
    say_stop("Ah.  I'm not entirely sure who Mog is but..uh thanks.", 1);
   }


unfreeze(&current_sprite);
unfreeze(1);

 

}

