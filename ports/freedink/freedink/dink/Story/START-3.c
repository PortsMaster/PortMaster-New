//for info button

void main( void )
{
int &crap;
}

void buttonon( void )
{
sp_pframe(&current_sprite, 2);
Playsound(20,22050,0,0,0);
&crap = create_sprite(270, 421, 0, 197, 1);
sp_noclip(&crap, 1);
sp_reverse(&crap, 0);
sp_seq(&crap, 197);
return;
}

void buttonoff( void )
{
sp_pframe(&current_sprite, 1);
Playsound(21,22050,0,0,0);
sp_brain(&crap, 7);
sp_reverse(&crap, 1);
sp_seq(&crap, 197);
return;

}

void click(void)
}
sp_brain(1,0);
Playsound(17,22050,0,0,0);
choice_start();
"The price"
"How to order"
choice_end();
wait(300);

if (&result == 2)
  {
say_stop_xy("`%Call toll free 1-888-218-3881 to order.", 0,390);
wait(200);
say_stop_xy("`%Or, order ONLINE (securely) at www.rtsoft.com/dink/", 0,390);

sp_brain(1,13);
return;
  }
int &ddink;

say_stop_xy("`%Preorder now for only $15 + 4.95 shipping! (within US)", 0,390);
wait(200);
say_stop_xy("`%(preorder price valid until 10-31-97)", 0,390);
&ddink = create_sprite(660, 400, 0, 74, 1);
sp_noclip(&ddink, 1);
sp_base_walk(&ddink, 70);
sp_speed(&ddink, 4);
sp_timing(&ddink, 0);

wait(600);

say_stop("Wait a minute!", &ddink);
wait(300);
move_stop(&ddink, 4, 500, 1);
wait(500);
sp_pseq(&ddink, 72);
sp_pframe(&ddink, 1);
wait(500);
say_stop("Hi.", &ddink);
wait(300);
sp_pseq(&ddink, 74);
sp_pframe(&ddink, 1);

wait(300);


Playsound(9,22050,0,0,0);
sp_seq(&ddink, 104);
sp_speed(&dinklogo, 4);
sp_timing(&dinklogo, 0);
wait(500);


sp_pframe(&current_sprite, 1);
Playsound(21,22050,0,0,0);
sp_brain(&crap, 7);
sp_reverse(&crap, 1);
sp_seq(&crap, 197);
wait(800);



move_stop(&dinklogo, 4, -400, 1);
sp_pseq(&ddink, 74);
sp_pframe(&ddink, 1);
say_stop("This game is only $15?", &ddink);
wait(300);

say_stop_xy("`%Yes.", 0,390);
say_stop("Is this some kind of joke?  This ain't funny.", &ddink);
wait(200);
say_stop_xy("`%Nope, no joke.", 0,390);
wait(200);


move_stop(&ddink, 7, 300, 1)
move_stop(&ddink, 1, 350, 1)
move_stop(&ddink, 2, 400, 1)

wait(200);
say_stop("Incredible!!!  Thank you magic voice.", &ddink);
wait(200);
move_stop(&ddink, 4, -100, 1)
wait(500);
say_stop_xy("`%Anytime.", 0,390);

sp_active(&ddink, 0);
move_stop(&dinklogo, 6, 320, 1);
Playsound(21,22050,0,0,0);

sp_pframe(&current_sprite, 2);
Playsound(20,22050,0,0,0);
&crap = create_sprite(270, 421, 0, 197, 1);
sp_noclip(&crap, 1);
sp_reverse(&crap, 0);
sp_seq(&crap, 197);
sp_brain(1,13);

}
