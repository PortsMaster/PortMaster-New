void main( void )
{
 preload_seq(221);
 preload_seq(223);
 preload_seq(225);
 preload_seq(227);
 preload_seq(229);
 sp_base_walk(&current_sprite,220);
 sp_brain(&current_sprite, 16);
 sp_speed(&current_sprite,1);
 sp_timing(&current_sprite,33);
 sp_nohit(&current_sprite, 1);
 sp_nodraw(&current_sprite, 1);
 int &wait;

loop:

&wait = random(3000,1000);
wait(&wait);

&wait = random(5, 1);

if (&wait == 1)
  {
    say_stop("`#Woe are us!",&current_sprite);

  }

if (&wait == 2)
  {

    say_stop("`#You cannot hurt us Dink.",&current_sprite);

  }

if (&wait == 3)
  {
    sp_nodraw(&current_sprite, 1);
    say_stop("`#You cannot see us Dink.",&current_sprite);

  }

if (&wait == 4)
  {
    sp_nodraw(&current_sprite, 0);
    say_stop("`#LOOK UPON MY DEFORMED FACE!",&current_sprite);
    wait(500);
    say_stop("Spirit, leave me alone!",1);
  }

if (&wait == 5)
  {
    say_stop("`#Some of us like to eat humans.  I would leave if I were you.",&current_sprite);
    wait(500);
    say_stop("I am not afraid, ghost.",1);
  }



goto loop;

}


