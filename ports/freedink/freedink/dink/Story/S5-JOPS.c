void main( void )
{
 if (&s5-jop == 0)
   {
    &s5-jop = 1;
    wait(900);
    say("Weird.  This town looks deserted.",1);
   }

if (&s5-jop == 2)
  {
   //make guy
   &temp1hold = create_sprite(560, 330, 0,0,0);
   sp_script(&temp1hold, "s5-fguy");

   //make mom
   &temp2hold = create_sprite(400, 310, 0,0,0);
   sp_script(&temp2hold, "s5-fmom");

   //make daughter
   &temp3hold = create_sprite(40, 320, 0,0,0);
   sp_script(&temp3hold, "s5-fd");


  }

}
