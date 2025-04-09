void main( void )
{
 int &pap;
}

void talk( void )
{
 freeze(1);
 choice_start()
 "Take a drink"
 "Drop in a coin"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   say("Ah, refreshing.", 1);
   &life = &lifemax;
   Playsound(22,22050,0,0,0);
  }
  if (&result == 2)
  {
   if (&gold < 1)
   {
    say("I don't have any coins!", 1);
    unfreeze(1);
    return;
   }
   &gold -= 1;
   &pap = random(4, 1);
   if (&pap == 1)
   {
    say("I hope this helps.", 1);
   }
   if (&pap == 2)
   {
    say("For luck.", 1);
   }
   if (&pap == 3)
   {
    say("Hope that wish comes true.", 1);
   }
   if (&pap == 4)
   {
    say("For Mother.", 1);
   }
  }
 unfreeze(1);
}
