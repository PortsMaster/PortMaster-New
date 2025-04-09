//script for wench


void main( void )
{

preload_seq(221);
preload_seq(223);
preload_seq(227);
preload_seq(229);


int &myrand;
sp_brain(&current_sprite, 16);
Debug("Hi, current sprite is &current_sprite!");
sp_base_walk(&current_sprite, 220);
sp_speed(&current_sprite, 1);

//set starting pic

sp_pseq(&current_sprite, 223);
sp_pframe(&current_sprite, 1);

mainloop:
wait(2500);
  unfreeze(&current_sprite);
if (&temp4hold == 1)
  {
   //dink is gonna fight
sp_speed(&current_sprite, 2);
sp_timing(&current_sprite, 0);
  }

sp_speed(&current_sprite, 1);
sp_timing(&current_sprite, 33);


&myrand = random(50, 1);

  if (&myrand == 1)
  {
  freeze(&current_sprite);
  say_stop_npc("`#Another round over here?", &current_sprite);
  }

  if (&myrand == 2)
  {
  freeze(&current_sprite);
  say_stop_npc("`#I'm so tired.. arg.", &current_sprite);
  }

  if (&myrand == 3)
  {
  freeze(&current_sprite);
  say_stop_npc("`#My feet hurt..", &current_sprite);
  }


  if (&myrand == 4)
  {
  freeze(&current_sprite);
  say_stop_npc("`#Can I take a break, boss?", &current_sprite);

  if (&temp4hold == 1)
  {
    goto mainloop;
  }
  say_stop_npc("`4Did hell freeze over?", &temphold);

  }



goto mainloop;
}


void hit( void )
{
freeze(&current_sprite);
wait(400);
say_stop_npc("`#Look with your eyes, not with your hands, honey.", &current_sprite);
wait(800);
goto mainloop;
}

void talk( void )
{

 freeze(1);
 freeze(&current_sprite);
         choice_start()
         "Ask for a date"
         "Belittle her in front of the others to appear macho"
         "Leave"
         choice_end()

        if (&result == 1)
        {

       if (&story > 15)
       {
        wait(400);
         say_stop("Wanna go get some food later?", 1);
        wait(400);
         say_stop("`#Oh yes!  Hey, hero Smallwood just asked me out!", &current_sprite);
        wait(400);
         say_stop("Ah, it's going to be easy to get used to this...", 1);
   unfreeze(1);
   goto mainloop;
   return;
         }

        wait(400);
         say_stop("Wanna go get some food later?", 1);
        wait(400);
         say_stop("`#Sorry, I'm working later.", &current_sprite);
        wait(400);
         say_stop("Ah.", 1);

        }

        if (&result == 2)
        {
        wait(400);
         say_stop("Hey wench!  How much is the beer here?", 1);
        wait(400);
         say_stop("`#Two gold, sir.", &current_sprite);
        wait(400);
         say_stop("How much for you?", 1);
        wait(400);
         say_stop("`#I'm not for sale, you lout!", &current_sprite);
        wait(400);
         say_stop("Come on honey, I got three gold jingling in my pocket!", 1);
        wait(400);
         say_stop("`#Get LOST!", &current_sprite);
        }


   unfreeze(1);
   goto mainloop;
   return;

}

