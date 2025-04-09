void talk( void )
{
 say("Wow, they have a dish.",1);
}

void HIT( void )
{
int &dish = sp(7);
int &crap = sp_pframe(&dish, -1);
if (&crap > 1)
  {
sp_reverse(&dish, 1);
sp_seq(&dish, 425);

  } else
  {
sp_reverse(&dish, 0);
sp_seq(&dish, 425);

  }



}

