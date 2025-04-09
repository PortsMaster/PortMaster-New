//script for fish to jump out of water randomly, and be killed.

void main( void )
  {
   //fish anim
   preload_seq(434);
   //splash anim
   preload_seq(433);
   sp_frame_delay(&current_sprite, 110);
   sp_hitpoints(&current_sprite, 25);
   //set to normal size
   sp_size(&current_sprite, 100);
   //give monster brain, but freeze
   sp_brain(&current_sprite, 9);
   freeze(&current_sprite);
  int &timer;

   int &splash;

  loop:

   //can't be hit or seen yet
   sp_nohit(&current_sprite, 1);
   sp_nodraw(&current_sprite, 1)

  //random wait
  &timer = random(6000,0);
  wait(&timer);
  playsound(35, 20000, 3000, &current_sprite, 0);
  //let's splash around
   sp_nohit(&current_sprite, 0);
   sp_nodraw(&current_sprite, 0)
   sp_seq(&current_sprite, 434);
   wait(700);

  //create splash sprite where fish is

  &save_x = sp_x(&current_sprite, -1);
  &save_y = sp_y(&current_sprite, -1);
  &save_y += 1;
  &save_x -= 30;

   &splash = create_sprite(&save_x, &save_y, 7, 0,0);
   sp_nohit(&splash, 1);
   sp_seq(&splash, 433);
   //playnoise

   goto loop;

  }


void die( void )
{


//let's give 'em a random amount of exp, what fun!

 int &rand = random(100, 50);
 add_exp(&rand, &current_sprite);

 sp_brain(&current_sprite, 0);

  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 6); 


 sp_active(&current_sprite, 0);


}
