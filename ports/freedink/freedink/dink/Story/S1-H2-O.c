//old woman who has a pet duck
void main( void )
{
 if (&old_womans_duck == 5)
 {
  say("`3Hello murderer!!", &current_sprite);
 
 }

 if (&old_womans_duck == 0)
 {
  say("`3Why hello, Dink.", &current_sprite);
 
 }

 if (&old_womans_duck == 1)
 {
  say("`3Oh Dink, I'm so worried - have you found him?", &current_sprite);
 }

 if (&old_womans_duck == 2)
 {
  &old_womans_duck = 4;
  say_stop("`3Oh Dink, look who is here!", &current_sprite);
  wait(200);
  say("`3Also Dink, your mother was looking for you.", &current_sprite);
 }
}

void talk( void )
{

if (&old_womans_duck == 5)
  {
   say("`3Get away from me!", &current_sprite);
   return;
  }




if (&story > 3)
  {
  say_stop("`3I'm so sorry about your mother Dink,", &current_sprite);
  wait(200);
  say_stop("`3she was a good woman.", &current_sprite);
  if (&old_womans_duck == 3)
   {
   say_stop("`3Kinda funny, my duck missing and your Mom dead.", &current_sprite);
   }
  if (&old_womans_duck == 5)
   {
   say_stop("`3Kinda funny, my duck and your Mom dead.", &current_sprite);
   }
 // goto talk;
  unfreeze(&current_sprite);
  unfreeze(1);

  return;
  }

if (&old_womans_duck == 2)
  {
  say_stop("`3I'm so grateful to you, Dink!  You are such a dear!", &current_sprite);
  unfreeze(&current_sprite);
  unfreeze(1);
  return;
  }

if (&old_womans_duck == 4)
  {
  say_stop("`3I'm so grateful to you, Dink!  You are wonderful!", &current_sprite);
  unfreeze(&current_sprite);
  unfreeze(1);
  return;

  }


if (&old_womans_duck == 3)
  {
  say_stop("`3I wonder where my duck is?", &current_sprite);

  unfreeze(&current_sprite);
  unfreeze(1);
 say("<chortles>", 1);
  return;
  }



if (&old_womans_duck == 1)
  {
  say_stop("`3You must keep searching for Quackers!  I loved him!", &current_sprite);
  unfreeze(&current_sprite);
  unfreeze(1);
  return;
  }

talk:
freeze(1);
freeze(&current_sprite);
choice_start()
"Ask about her well being"
(&old_womans_duck == 0)"Ask after her pet"
"Inquire about all her bottles"
"Leave"
choice_end()

if (&result == 4)
  {

  unfreeze(&current_sprite);
  unfreeze(1);

  }

wait(300);
if (&result == 1)
 {
  say_stop("How are you today, Ethel?", 1); 
  wait(500);
  if (&old_womans_duck == 0)
  {
  say_stop("`3Not so good, Dink.  Little Quackers is missing!", &current_sprite);
  unfreeze(&current_sprite);
  unfreeze(1);
  return;
  }
  say_stop("`3I'm fine Dink, thank you for asking.", &current_sprite);
 }

if (&result == 2)
 {
  say_stop("Where is the little one today?", 1); 
  wait(500);
  say_stop("`3Quackers is gone!  Will you help me find him?", &current_sprite);
  wait(500);
  choice_start()
  "Agree whole heartedly"
  "Barely agree"
  "Tell her where she can stick 'Quackers'"
  choice_end()
  wait(300);

  if (&result == 1)
   {
  say_stop("I will find him at once dear Ethel, do not doubt this!", 1); 
  wait(500);
  say_stop("`3Thank you Dink!", &current_sprite);
  wait(500);
  &old_womans_duck = 1;
  }

  if (&result == 2)
   {
  say_stop("Yeah, I guess if I see 'em I'll send him home.  Maybe.", 1); 
  wait(500);
  say_stop("`3I see...thank.. you .. I guess.", &current_sprite);
  wait(500);
  &old_womans_duck = 1;
  }
  if (&result == 3)
   {
  say_stop("You're pathetic.  Find your own duck.", 1); 
  wait(500);
  say_stop("`3I.. I... didn't know... <begins to tear up>", &current_sprite);
  wait(500);
  unfreeze(1);
  unfreeze(&current_sprite);
  return;
  }
}
if (&result == 3)
 { 
  say_stop("Hey Ethel, what's with all the spirits on the wall there?", 1);
  say_stop("You really like to party don't you?", 1);
  wait(200);
  say_stop("`3What Dink?", &current_sprite);
  wait(200);
  say_stop("You know, all drowning away your problems on the weekend", 1);
  say_stop("waking up with guys you don't even know.", 1);
  say_stop("Ahh the regrets, right Ethel?", 1);
  wait(200);
  say_stop("`3Dink ..", &current_sprite);
  say_stop("`3You've got problems.", &current_sprite);
 }


}

  unfreeze(&current_sprite);
  unfreeze(1);
}

