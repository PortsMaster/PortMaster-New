//for start button

void main( void )
{
int &crap;

}

void buttonon( void )
{
sp_pframe(&current_sprite, 2);
Playsound(20,22050,0,0,0);
&crap = create_sprite(204, 86, 0, 199, 1);
sp_reverse(&crap, 0);

sp_noclip(&crap, 1);

sp_seq(&crap, 199);

}

void buttonoff( void )
{
sp_pframe(&current_sprite, 1);
Playsound(21,22050,0,0,0);
sp_reverse(&crap, 1);
sp_seq(&crap, 199);
sp_brain(&crap, 7);

}

void click ( void )
{
//lets start a new game
Say_xy("`%Creating new game...", 0, 390);
wait(1);
   sp_x(1, 334);
   sp_y(1, 161);
   sp_base_walk(1, 70);
   sp_base_attack(1, 100);
    set_mode(2); //turn game on
reset_timer();
    sp_dir(1, 4);
    sp_brain(1, 1);
    sp_que(1, 0);
    sp_noclip(1, 0);
    //lets give him fists to start out with
    add_item("item-fst",438, 1);
    &cur_weapon = 1;
     //arm them for him too
//  initfont("SWEDISH");
    arm_weapon();
      //need this too
kill_this_task();
}
