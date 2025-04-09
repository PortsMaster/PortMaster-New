void main( void)
{

int &fighting = 0;
if (&story < 15)
{
        preload_seq(24);
        preload_seq(161);
        init("load_sequence_now graphics\effects\magic\seth1w 581 75 43 133 -19 -16 23 16");
        init("load_sequence_now graphics\effects\magic\seth3w 583 75 44 126 -21 -21 19 16");
        init("load_sequence_now graphics\effects\magic\seth7w 587 75 42 123 -21 -16 18 16");
        init("load_sequence_now graphics\effects\magic\seth9w 589 75 44 125 -20 -16 20 16");
        init("load_sequence_now graphics\effects\magic\pose 580 75 41 129 -30 -16 31 10");
  return;
 }

sp_active(&current_sprite, 0);
}
  void talk (void)
  {

if (&story > 14)
  {
   say("Poor Milder.",1);
   return;
  }

if (&fighting == 1)
  {
   say("Milder, wake up!  Help me fight this guy!",1);
   return;
  }


    freeze(1);
   say_stop("Milder!  Milder!", 1);
   &fighting = 1;
   wait(300);
   say_stop_xy("`6<groan>", 20, 180);
   wait(300);
   say_stop("Can you hear me?", 1);
   wait(300);
   say_stop_xy("`6..pig farmer..is..that..you?", 20, 180);
   wait(300);
   say_stop("Yes!", 1);
   wait(300);
   say_stop("Er, no, I mean.. tell me what happened!", 1);
   wait(300);
   say_stop_xy("`6..I was left here to die by a monstrosity..", 20, 180);
   wait(300);
   say_stop("Ah, by the Cast?", 1);
   wait(300);
   say_stop_xy("`6..no..", 20, 180);
   wait(300);
   say_stop_xy("`6..the Cast were just a front.. he is pure evil..", 20, 180);
   wait(300);
   say_stop_xy("`6..run..run before it's too late..", 20, 180);
   wait(300);
choice_start();
"Refuse to leave without him"
"Take his advice"
choice_end();
   wait(300);

if (&result == 1)
  {
   say_stop("I will not leave without you, Milder.", 1);
   wait(300);
   say_stop_xy("`6..but why?  i was so mean to you as a kid...", 20, 180);
   wait(300);
   say_stop("It is the honorable thing to do.", 1);
   wait(300);
   say_stop_xy("`6..you are more of a knight than I ever was, dink...", 20, 180);
   wait(300);
   say_stop("Nonsense.  Can you walk?", 1);
   wait(300);
   say_stop_xy("`6..I think so..take my..", 20, 180);
  }


if (&result == 2)
  {
   say_stop("Alright, see ya.", 1);
   wait(300);
   say_stop_xy("`6..i..understand...tell Lyna I love her...", 20, 180);
   wait(300);
   say_stop("Tell her?  I'll SHOW her love... moohahahha!", 1);
   wait(300);
   say_stop_xy("`6..you little bitch...if I only had the strength to...", 20, 180);
  }

wait(1000);
playsound(24, 22052, 0, 0, 0);
int &mcrap = create_sprite(320, 100, 7, 167, 1);
sp_seq(&mcrap, 167);
wait(200);
&temp1hold = create_sprite(320, 150,0, 580, 1);


int &crap = get_burn();

if (&crap == 0)
playmidi("1004");
if (&crap > 0)
playmidi("1015");

wait(1000);
 say_stop_xy("`6NOOO!  IT'S HIM!", 20, 180);
 wait(300);
say_stop("What the!??!  Who the hell are you?", 1);
wait(300);
say_stop("`%I am the beginning and the end.", &temp1hold);
wait(300);
 say_stop_xy("`6..kill him, dink..kill him...", 20, 180);
wait(300);
say_stop("`%I am everything you love.", &temp1hold);
wait(300);
say_stop("`%I am everything you despise.", &temp1hold);
wait(300);
say_stop("You are sick and twisted is what you are.", 1);
wait(300);
say_stop_xy("`6..his name is Seth.. he is an ancient one...he killed the others..", 20, 180);
wait(300);
say("`4<casts explosion>", &temp1hold);
int &bomb = create_sprite(329, 256, 7,161,1);
sp_seq(&bomb, 161);
playsound(6, 22050, 0,0,0);

say_stop_xy("`6aaargh..", 20, 180);
wait(300);
say_stop("Milder?", 1);
wait(300);
say_stop("`4<grins evilly at you>", &temp1hold);
wait(300);
say_stop("FOR GOD, THE CROWN AND ALL THAT IS GOOD, I SHALL DESTROY YOU, SETH!", 1);

sp_script(&temp1hold, "s7-boss");
unfreeze(1);

  }
