void main( void )
{
 preload_seq(331);
 preload_seq(333);
 preload_seq(335);
 preload_seq(337);
 preload_seq(339);
 sp_base_walk(&current_sprite,330);
 sp_brain(&current_sprite, 16);
 sp_speed(&current_sprite,1);
 sp_timing(&current_sprite,33);
 sp_nohit(&current_sprite, 1);
 int &wait;
   sp_nodraw(&current_sprite, 1);
wait(4000);

loop:
&wait = random(3000,2000);
wait(&wait);

&wait = random(8, 1);

if (&wait == 1)
  {
    say_stop("`#I'm hungry mommy.",&current_sprite);

  }

if (&wait == 2)
  {

    say_stop("`#I feel so old.. yet why have I not aged?",&current_sprite);

  }

if (&wait == 3)
  {
    sp_nodraw(&current_sprite, 1);
    say_stop("`#Last thing I remember is that group of knights.. and blood.",&current_sprite);

  }

if (&wait == 4)
  {
    sp_nodraw(&current_sprite, 0);
    say_stop("`#I HATE IT HERE!",&current_sprite);
    playsound(12,22050,0,&current_sprite,0);
  }

if (&wait == 5)
  {
    say_stop("`#Is the man lost, mommy?  Like we are?",&current_sprite);
  }

if (&wait == 6)
  {
    say_stop("`#Would you like to see me take my head off?",&current_sprite);
  }

if (&wait == 7)
  {
  sp_nodraw(&current_sprite, 0);
  }

if (&wait == 8)
  {
   sp_nodraw(&current_sprite, 1);
  }


goto loop;

}

void hit( void )
{
 say_stop("`#<giggles>  That tickles!",&current_sprite);
 goto loop;

}

