//for quit button

void main( void )
{
int &crap;
}

void buttonon( void )
{
sp_pframe(&current_sprite, 2);
Playsound(20,22050,0,0,0);
&crap = create_sprite(446, 417, 0, 198, 1);
sp_noclip(&crap, 1);
sp_reverse(&crap, 0);

sp_seq(&crap, 198);

}

void buttonoff( void )
{
sp_pframe(&current_sprite, 1);
Playsound(21,22050,0,0,0);
sp_brain(&crap, 7);
sp_reverse(&crap, 1);
sp_seq(&crap, 198);

}

void click(void)
}
Playsound(17,22050,0,0,0);
kill_game();

}
