void talk( void )
{
        freeze(1);

     choice_start();
     "Press the red button"
     "Leave"
     choice_end();

if (&result == 1)
  {
       //get sprite # of item four (spinny thing) (in the editer)
        int &dcrap = sp(4);

Playsound(34,12050,0,0,1);
        sp_brain(&dcrap, 6);
        sp_frame_delay(&dcrap, 500);
        wait(1000);
Playsound(34,17050,0,0,1);

        sp_frame_delay(&dcrap, 400);
        wait(1000);
Playsound(34,19050,0,0,1);

        sp_frame_delay(&dcrap, 300);
        wait(900);
Playsound(34,22050,0,0,1);
        sp_frame_delay(&dcrap, 200);
        wait(800);
Playsound(34,24050,0,0,1);
        sp_frame_delay(&dcrap, 100);
        wait(700);
Playsound(34,26050,0,0,1);
        sp_frame_delay(&dcrap, 50);
        wait(600);
Playsound(34,29050,0,0,1);
        sp_frame_delay(&dcrap, 25);
        wait(500);

playsound(21, 8000, 0,0,0);

sp_nodraw(1, 1);
wait(500);
       script_attach(1000);
        fade_down();
        &player_map = 154;
        sp_x(1, 329);
        sp_y(1, 279);
        load_screen(154);
        draw_screen();
freeze(1);
        fade_up();
wait(1000);
playsound(21, 8000, 0,0,0);
sp_nodraw(1, 0);
unfreeze(1);

kill_this_task();
   }

unfreeze(1);
}
