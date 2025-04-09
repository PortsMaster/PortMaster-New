void main( void )
{
  int &spawnx;
  int &spawny;
  int &maybe;
  &maybe = random(8,1);
  if (&maybe == 1)
  {
  preload_seq(341);
  preload_seq(343);
  preload_seq(347);
  preload_seq(349);
  preload_seq(381);
  preload_seq(383);
  preload_seq(387);
  preload_seq(389);

	  &maybe = random(2,1);
	  if (&maybe == 1)
	  {
	  maketraveler();
	  }
	  else
	  {
	  other();
	  }
  }
}

void maketraveler( void )
{
	int &spawnx;
    int &spawny;
	int &crap;
	&spawnx = random(200,200);
	&spawny = random(100,150);
	&crap = create_sprite(&spawnx, &spawny, 9, 341, 5);
    sp_speed(&crap, 1);
	sp_timing(&crap, 33);
        sp_brain(&crap, 16);
	sp_base_walk(&crap, 340);
    sp_script(&crap, "s1-wand");
}

void other( void )
{
	int &spawnx;
    int &spawny;
	int &crap;
	&spawnx = random(200,200);
	&spawny = random(100,150);
	&crap = create_sprite(&spawnx, &spawny, 9, 381, 2);
	sp_speed(&crap, 1);
	sp_timing(&crap, 33);
        sp_brain(&crap, 16);
	sp_base_walk(&crap, 380);
    sp_script(&crap, "s1-wand2");
}
