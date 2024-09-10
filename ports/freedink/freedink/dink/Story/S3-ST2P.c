void main( void )
{
 int &mom;
 &mom = random(3,1)
 if (&mom == 1)
 {
  say_stop("`1Good day sir.", &current_sprite);
 }
}

void hit( void )
{
int &rcrap = sp_pseq(&missle_source, -1);
int &scrap = compare_weapon("item-b1");
&scrap += compare_weapon("item-b2");
&scrap += compare_weapon("item-b3");
if (&rcrap == -1)
{
if (&scrap > 0)
{
	say("`1See, now that pierced my lung! Ouch!", &current_sprite);
	return;
}
}
say("`1That hurts and all, but you could be doing much more damage with a bow!", &current_sprite);
}

void buy( void )
{
buy:
int &junk = free_items();
say_stop("Well, despite the highway robbery, I'd like to get a bow.", 1);
if (&junk < 1)
 {
  choice_start()
  set_y 240
  title_start();
You are carrying too much.
  title_end();
  "Ok"
  choice_end()
  unfreeze(1);
  unfreeze(&current_sprite);
  return;
 }

if (&gold < 1000)
 {
  say_stop("`1I'm sorry sir, but you DON'T have enough gold!", &current_sprite);
  wait(250);
  say_stop("Whoops, sorry about that.", 1);
  unfreeze(1);
  unfreeze(&current_sprite);
  return;
 }

&gold -= 1000;

 say_stop("`1Excellent sir!  I'm sure you won't be disappointed.", &current_sprite);
 wait(250);
 say_stop("Yeah, well I'll let ya know.", 1);
   wait(250);
   say_stop("`1One more thing.. if you hold down the button you will draw", &current_sprite);
   wait(250);
   say_stop("`1your bow back farther, thus hitting harder.  No refunds.  Enjoy!", &current_sprite);
 add_item("item-b1",438, 8);
 unfreeze(1);
 unfreeze(&current_sprite);

}

void talk( void )
{
 freeze(1);
 freeze(&current_sprite);
 choice_start()
 "Ask about Bows"
 "Buy a Bow and some arrows for $1000"
 "Leave"
 choice_end()
  if (&result == 1)
  {

int &hasbow = count_item("item-b1");
   if (&hasbow > 0)
   {
   say_stop("Well, you talked me into it and I bought one.", 1);
   wait(250);
   say_stop("`1You will love your new bow, sir!", &current_sprite);
   wait(250);
   say_stop("Any tips on using it?", 1);
   wait(250);
   say_stop("`1Well... There is an old man who has a place on the beach near", &current_sprite);
   wait(250);
   say_stop("`1here who can teach you bow lore.  This will give you triple", &current_sprite);
   wait(250);
   say_stop("`1damage.. when it works.", &current_sprite);
   wait(250);
   say_stop("Cool!  How will I know his house?", 1);
   wait(250);
   say_stop("`1It's sort of hidden.", &current_sprite);

 unfreeze(1);
 unfreeze(&current_sprite);
 return;

   }

   say_stop("Good day.", 1);
   wait(250);
   say_stop("`1To you too sir, I am Arturous, at your service.", &current_sprite);
   wait(250);
   say_stop("Yes well, I was wondering how much you sold your bows for?", 1);
   wait(250);
   say_stop("`1My current price for a bow and arrows is 1000 gold.", &current_sprite);
   wait(250);
   say_stop("MAN!  Don't you think that's a little steep??", 1);
   wait(250);
   say_stop("`1Not at all, my quality is superb.", &current_sprite);
   wait(250);
   say_stop("Damn better be!", 1);
  }
  if (&result == 2)
  {
   goto buy;
  }
 unfreeze(1);
 unfreeze(&current_sprite);
}
