void main( void )
{
 int &bet;
 int &pick;
 int &win;
 &win = 0;
 if (&duckgame == 1)
 {
  &duckgame = 0;
  &vision = 1;
  int &junk;
  int &pap;
  int &pep;
  int &duck1;
  int &duck2;
  &pep = create_sprite(120, 245, 0, 0, 0);
  sp_brain(&pep, 3);
  sp_base_walk(&pep, 20);
  sp_speed(&pep, 1);
  sp_timing(&pep, 0);
  sp_size(&pep, 204);
  sp_hitpoints(&pep, 10);
  //set starting pic
  sp_pseq(&pep, 23);
  sp_pframe(&pep, 1);
  sp_script(&pep, "s8-duck4");
  freeze(1);
  freeze(&pep);
  //Begin the crack!!
  say_stop("`3Ok Dink, we like our games here bloody,", &pep);
  wait(250);
  say_stop("`3that's why we have duck fights!!", &pep);
  wait(250);
  betting:
  say_stop("`3Place your bets.", &pep);
  choice_start()
  "Bet 50"
  "Bet 100"
  "Bet 200"
  "Stop"
  choice_end()
  if (&result == 1)
  {
   if (&gold < 50)
   {
    say_stop("`3Hey, you don't have enough to play!", &pep);
    wait(250);
    say_stop("`3Come back later.", &pep);
    unfreeze(1);
    unfreeze(&current_sprite);
    return;
   }
   &bet = 50;
  }
  if (&result == 2)
  {
   if (&gold < 100)
   {
    if (&gold < 50)
    {
     say_stop("`3Hey, you don't have enough to play!", &pep);
     unfreeze(1);
     unfreeze(&current_sprite);
     return;
    }
    say_stop("You can't bet that much.", &pep);
    goto betting;
   }
   &bet = 100;
  }
  if (&result == 3)
  {
   if (&gold < 200)
   {
    if (&gold < 50)
    {
     say_stop("`3Hey, you don't have enough to play!", &pep);
     unfreeze(1);
     unfreeze(&current_sprite);
     return;
    }
    say_stop("You can't bet that much.", &pep);
    goto betting;
   }
   //Check
   &bet = 200;
  }
  if (&result == 4)
  {
   unfreeze(1);
   unfreeze(&pep);
   return;
  }
  say_stop("`3Who are you betting on?", &pep);
  choice_start()
  "Bet on duck 1"
  "Bet on duck 2"
  choice_end()
  if (&result == 1)
  {
   say_stop("Give me number one.", 1);
   &pick = 1;
   wait(250);
  }
  if (&result == 2)
  {
   say_stop("Give me number two.", 1);
   &pick = 2;
   wait(250);
  }
  //Let battle begin...
  say_stop("`3The bets are in, let's fight!", &pep);
  //Spawn ducks..
  if (&win == 1)
  {
   playsound(24, 22052, 0, 0, 0);
   int &mcrap2 = create_sprite(428, 256, 7, 167, 1);
   sp_seq(&mcrap2, 167);
   &duck2 = create_sprite(428, 256, 0, 0, 0);
   sp_brain(&duck2, 3);
   sp_base_walk(&duck2, 20);
   sp_size(&duck2, 204);
   //set starting pic
   sp_pseq(&duck2, 24);
   sp_pframe(&duck2, 1);
   goto fight;
  }
  if (&win == 2)
  {
   playsound(24, 22052, 0, 0, 0);
   int &mcrap = create_sprite(229, 256, 7, 167, 1);
   sp_seq(&mcrap, 167);
   &duck1 = create_sprite(229, 256, 0, 0, 0);
   sp_brain(&duck1, 3);
   sp_base_walk(&duck1, 20);
   sp_size(&duck1, 204);
   //set starting pic
   sp_pseq(&duck1, 26);
   sp_pframe(&duck1, 1);
   goto fight;
  }
  //Duck 1
  playsound(24, 22052, 0, 0, 0);
  int &mcrap = create_sprite(229, 256, 7, 167, 1);
  sp_seq(&mcrap, 167);
  &duck1 = create_sprite(229, 256, 0, 0, 0);
  sp_brain(&duck1, 3);
  sp_base_walk(&duck1, 20);
  sp_size(&duck1, 204);
  //set starting pic
  sp_pseq(&duck1, 26);
  sp_pframe(&duck1, 1);
  //Duck 2
  playsound(24, 22052, 0, 0, 0);
  int &mcrap2 = create_sprite(428, 256, 7, 167, 1);
  sp_seq(&mcrap2, 167);
  &duck2 = create_sprite(428, 256, 0, 0, 0);
  sp_brain(&duck2, 3);
  sp_base_walk(&duck2, 20);
  sp_size(&duck2, 204);
  //set starting pic
  sp_pseq(&duck2, 24);
  sp_pframe(&duck2, 1);

  goto fight;
  unfreeze(1);
 }
}
   
void check( void )
{
 check:
 if (&win == 1)
 {
  if (&pick == 1)
  {
   say_stop("`3Congradulations!", &pep);
   &gold += &bet;
   goto betting;
  }
  say_stop("`3To bad, better luck next time.", &pep);
  &gold -= &bet;
  goto betting;
 }
 if (&win == 2)
 {
  if (&pick == 2)
  {
   say_stop("`3Congratulations!", &pep);
   &gold += &bet;
   goto betting;
  }
  say_stop("`3Too bad, better luck next time.", &pep);
  &gold -= &bet;
  goto betting;
 }
}

void fight( void )
{
 fight:
 wait(500);
 &pap = random(2, 1);
 if (&pap == 1)
 {
  //Duck 2 WINS
  playsound(42,22050,0,0,0);
  &junk = create_sprite(410, 256, 11, 506, 1);
  sp_seq(&junk, 514); 
  sp_dir(&junk, 4);
  sp_speed(&junk, 4);
  sp_flying(&junk, 1);
  wait(570);
  sp_active(&junk, 0);
  &junk = create_sprite(229, 256, 7, 168, 1);
  sp_seq(&junk, 70);
  playsound(38,22050,0,0,0);
  hurt(&duck1, 10);
  wait(1200);  
  say_stop("`3You win this time.", &duck1);
  hurt(&duck1, 10);
  //sp_active(&duck1, 0);
  &win = 2;
 }
 if (&pap == 2)
 {
  //DUCK 1 WINS
  playsound(42,22050,0,0,0);
  &junk = create_sprite(240, 256, 11, 506, 1);
  sp_seq(&junk, 516); 
  sp_dir(&junk, 6);
  sp_speed(&junk, 4);
  sp_flying(&junk, 1);
  wait(570);
  sp_active(&junk, 0);
  &junk = create_sprite(428, 256, 7, 168, 1);
  sp_seq(&junk, 70);
  playsound(38,22050,0,0,0);
  hurt(&duck2, 10);
  wait(1200);  
  say_stop("`3You've beaten me.", &duck2);
  hurt(&duck2, 10);
  //Sp_active
  &win = 1;
 }
 goto check;
}
