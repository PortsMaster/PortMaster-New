//item fireball

void use( void )
{
freeze(1);

say_stop("Vas Neeko Matrid Osana", 1);

 if (&player_map == 366)
   {
    preload_seq(167);
playsound(24, 22052, 0, 0, 0);

    int &dcrap = create_sprite(300, 90, 12, 167, 1);
    sp_seq(&dcrap, 167);
    sp_brain_parm(&dcrap, 400);
    wait(500);
playsound(24, 22052, 0, 0, 0);

    int &dcrap = create_sprite(350, 30, 12, 167, 1);
    sp_seq(&dcrap, 167);
    sp_brain_parm(&dcrap, 400);
    wait(1000);
    playsound(43, 22050,0,0,0);
    &temp1hold = 1;
   }

 unfreeze(1);
 &magic_level = 0;
 draw_status();

}

void disarm(void)
{
&magic_cost = 0;
kill_this_task();
}

void arm(void)
{
Debug("Preloading fireball");

int &basehit;
int &mholdx;
int &mholdy;
int &junk;
int &mshadow;
int &mydir;
&magic_cost = 200;
}

void pickup(void)
{
Debug("Player now owns this item.");
kill_this_task();
}

void drop(void)
{
Debug("Item dropped.");
kill_this_task();
}


