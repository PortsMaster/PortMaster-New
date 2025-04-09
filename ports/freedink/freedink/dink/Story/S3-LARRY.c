void main( void )
{
 int &girl;
 &girl = 0;
 int &mom;
 &mom = random(3, 1);
 if (&mom == 1)
 {
  freeze(&current_sprite);
  say_stop("`4Hello sir.", &current_sprite);
  unfreeze(&current_sprite);
 }
}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Ask about the store"
 "See what's for sale"
 "Leave"
 choice_end()
  if (&result == 1)
  {
   say_stop("Hey, what kind of store you got here?", 1);
   wait(250);
   say_stop("`4We're Robinson Cabinets.", &current_sprite);
   wait(250);
   say_stop("`4We can supply all your wood furnishing needs.", &current_sprite);
   wait(250);
   say_stop("Oh, not for me then.  I've had bad experiences with furniture in the past.", 1);
   wait(250);
   say_stop("Things tend to light on fire, and people I know just die. :'(", 1);
   wait(250);
   say_stop("`4Okay then, if you need anything I'll be ...  over ... there.", &current_sprite);
  }
  if (&result == 2)
  {
   if (&girl == 1)
   {
    say_stop("So, any other deals?", 1);
    wait(250);
    say_stop("`4Please sir, no more, I need to tend to my daughter.", &current_sprite);
    wait(250);
    say_stop("`6DADDY!!!!!!!!!", &prom);
    wait(250);
    say_stop("`4See what I mean..", &current_sprite);
    unfreeze(1);
    unfreeze(&current_sprite);
    return;
   }
   int &prom;
   &prom = create_sprite(310, 460, 0, 0, 0);
   sp_brain(&prom, 16);
   sp_base_walk(&prom, 330);
   sp_speed(&prom, 1);
   sp_timing(&prom, 0);
   //set starting pic
   sp_pseq(&prom, 339);
   sp_pframe(&prom, 1);
   freeze(&prom);
   &girl = 1;
   say_stop("Any goofy specials this month?", 1);
   wait(250);
   say_stop("`4Nope, sorry.  We pretty much contract out by jobs", &current_sprite);
   wait(250);
   say_stop("`4on individual houses.  We also do countertops and the like.", &current_sprite);
   wait(250);
   say_stop("I see, well I don't own a house, but thanks for the info.", 1);
   wait(250);
   say_stop("`4Yeah, no problem ...", &current_sprite);
   say("`6DADDY!!!!!!!!!", &prom);
   say_stop("`4Oh no ...", &current_sprite);
   say("`6DADDY!!!!!!!!!", &prom);
   move_stop(&prom, 8, 250, 1);
   say_stop("`4Yes dear, what is it?", &current_sprite);
   wait(250);
   say_stop("`6I need a new dress.", &prom);
   wait(250);
   say_stop("`4But dear, we already got you one just last week.", &current_sprite);
   wait(250);
   say_stop("`6Well THAT one doesn't look as good in the sunlight,", &prom);
   wait(250);
   say_stop("`6let's just return it and get a new one.", &prom);
   wait(250);
   say_stop("`4Promise, I just don't know ....", &current_sprite);
   wait(250);
   say_stop("`6I SAID NOW!!", &prom);
   wait(250);
   say_stop("`4Okay, okay.", &current_sprite);
   unfreeze(&prom);
  }
 unfreeze(1);
 unfreeze(&current_sprite);
}

void hit( void )
{
 freeze(&current_sprite);
 say("`4Hey, stop that, you'll hurt the wood.", &current_sprite);
 unfreeze(&current_sprite);
}
