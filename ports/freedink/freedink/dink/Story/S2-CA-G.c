void main( void )
{
int &jerry;
int &mcounter;
&jerry = 1;
sp_base_attack(&current_sprite, 720);
 sp_distance(&current_sprite, 60);
 sp_strength(&current_sprite, 50);
sp_hitpoints(&current_sprite, 100);
}

void attack( void )
{
playsound(36, 22050,0,&current_sprite, 0);
&mcounter = random(4000,0);
sp_attack_wait(&current_sprite, &mcounter);

}


void hit( void )
{
if (&story > 15)
  {
 say("`2Nice, you win the game, then start killing guards?  Get 'em!", &current_sprite);
sp_timing(&current_sprite, 0);
sp_speed(&current_sprite, 3);
return;
  }

 say("`2The guy just hit me!  I am now going to kill him.", &current_sprite);
sp_timing(&current_sprite, 0);
sp_speed(&current_sprite, 3);
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
         choice_start()
         "Ask about the history of the castle"
         "Ask about the history of the King"
         "Request an audience with King Daniel"
         "Leave"
         choice_end()

if (&result == 1)
  {
   Say_stop("Tell me about this grand castle, friendly Knight.", 1); 
wait(500);  
   Say_stop("`2Castle Goodheart has stood here for centuries.", &current_sprite);
wait(500);  
   Say_stop("`2It is a magnificent testament to what a monarchy can do.", &current_sprite);
wait(500);  
   Say_stop("That castle actually doesn't look that big.", 1); 
wait(500);  
   Say_stop("`2It's bigger from the inside.", &current_sprite);
wait(500);  
   Say_stop("Ah.", 1); 
  }

if (&result == 2)
  {
   Say_stop("Tell me about our good King.", 1); 
wait(500);  
   Say_stop("`2King Daniel has ruled with an iron hand for nearly a decade now.", &current_sprite);
wait(500);  
   Say_stop("`2It was his strategic brilliance that stopped the Great Goblin invasion of '23.", &current_sprite);
wait(500);  
   Say_stop("Did he kill them all?", 1); 
wait(500);  
   Say_stop("`2No.  After the war was won he created a special place for them to live in peace.", &current_sprite);
wait(500);  
   Say_stop("Wow, quite a guy.", 1); 

  }


if (&result == 3)
  {
   Say_stop("I must see the King at once.", 1); 
wait(500);  

if (&story < 9)
{
   Say_stop("`2And you are?", &current_sprite);
wait(500);  
   Say_stop("Dink Smallwood.", 1); 
wait(500);  

}
  if (&story < 8)
   {
   Say_stop("`2I've never heard of you.  Please, go back to your village and play hero there.", &current_sprite);
   }

  if (&story == 8)
   {
   Say_stop("`2Ah, the one that saved that little girl.  Nice work.", &current_sprite);
wait(500);  
   Say_stop("So you will grant me access?", 1); 
wait(500);  
   Say_stop("`2I'm sorry, the King is otherwise engaged today.", &current_sprite);
   }

  if (&story == 9)
   {
   Say_stop("`2Ah, the one that saved that little girl.  Nice work.", &current_sprite);
wait(500);  
   Say_stop("I have news about a Cast plot!", 1); 
wait(500);  
   Say_stop("`2I'm sorry, the King is otherwise engaged today.", &current_sprite);
   }


  if (&story == 10)
   {
   Say_stop("`2Hello, Smallwood.  Congratulations on foiling that attack in KernSin.", &current_sprite);
   wait(500);  
   Say_stop("It was no more than any other man would have done.", 1); 
   wait(500);  
   Say_stop("`2But alas, the King is visiting abroad.", &current_sprite); 
   wait(500);  
   Say_stop("Damn.", 1); 
   }

  if (&story == 11)
   {
   Say_stop("`2Hey, it's Sir Smallwood!", &current_sprite);
   wait(500);  
   Say_stop("So is the King home?", 1); 
   wait(500);  
   Say_stop("`2No - He's seeing Milder off before his journey to the Darklands.", &current_sprite); 
   wait(500);  
   Say_stop("Milder?", 1); 
   wait(500);  
   Say_stop("`2Yes, Flatstomp is the bravest man in the kingdom.", &current_sprite); 
   wait(500);  
   Say_stop("Grrrrrrr.", 1); 
   }



  if (&story > 11)
   {
   Say_stop("`2Hello, Smallwood.  Of course you may see the King!", &current_sprite);
   wait(500);  
   Say_stop("`2GUARD, OPEN THE GATE!", &current_sprite);
   enter();
   }


  }

   unfreeze(1);
   unfreeze(&current_sprite);
 

 }                                   
}

void die( void )
{
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 

wait(500);
say("Killing guards is fun!",1);
}

void enter( void )
{
 int &gate = sp(4);
 sp_seq(&gate, 68);
script_attach(1000);
wait(1000);
fade_down();
&player_map = 102;
sp_x(1, 314);
sp_y(1, 349);
load_screen(102);
draw_screen();
fade_up();
unfreeze(1);
kill_this_task();
}

