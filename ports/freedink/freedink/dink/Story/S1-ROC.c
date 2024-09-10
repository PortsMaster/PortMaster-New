void main( void )
{
 sp_speed(&current_sprite, 1);
 int &mydir;
 if(&rock_placement == 1)
 {
  sp_x(&current_sprite, 350);
  draw_hard_map();
 }
}

void talk( void )
{
 say_stop("Hey, looks like there's an opening behind this rock.", 1);
}

void push( void )
{

 if (&strength < 4)
 {
  say_stop("It's too heavy for me.  If I was a little stronger...", 1);
  return;
 }

   &mydir = sp_dir(1, -1);

   if (&rock_placement == 0)
   {
   //rock is over hole

   if (&mydir == 6)
     {
      say("It's .. it's moving...", 1);
      freeze(1);
      move_stop(&current_sprite, 6, 350, 1);
      unfreeze(1);
      draw_hard_map();
      &rock_placement = 1;
      return;
      }
   }

   if (&rock_placement == 1)
   {
    //rock has already been pushed, can we push it back?

   if (&mydir == 4)
    {
      say("..heavy..heavy..", 1);
      freeze(1);
      move_stop(&current_sprite, 4, 285, 1);
      unfreeze(1);
      draw_hard_map();
      &rock_placement = 0;
      return;
     }
   }

      say("It won't budge from this angle.", 1);

}
