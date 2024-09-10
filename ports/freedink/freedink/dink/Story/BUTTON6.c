void main ( void )
{
//player map

if (&s2-map == 0)
  {
   say("I don't own a map yet.",1);
   kill_this_task();
   return;
  }

show_bmp("tiles\map1.bmp", 1, 0);
kill_this_task();

}

