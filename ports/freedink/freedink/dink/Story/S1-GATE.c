void main( void )
{
 if (&little_girl < 2)
  {
   int &ran = random(2,1);
    if (&ran == 1)
     {
  preload_seq(331);
  preload_seq(333);
  preload_seq(337);
  preload_seq(339);
     int &girl = create_sprite(630, 180, 9, 331, 4);
     sp_script(&girl, "s1-lg");
     sp_base_walk(&girl, 330);
     sp_timing(&girl, 33);
     sp_speed(&girl, 1);
     move(&girl, 4, 590, 1);
     }
  }

 if (&story == 1)
  {
   &vision = 1;
  }

 if (&story == 5)
  {
   &vision = 1;
  }
}
