//makes stars around Dink

void main( void )

int &myx = sp_x(1,-1);
int &myy = sp_y(1,-1);
&myy -= 60;
int &mcrap = create_sprite(&myx, &myy, 6, 169, 1);
sp_seq(&mcrap, 169);
sp_script(&mcrap, "shrink");
&myy -= 30;
&myx -= 30;
int &dcrap = create_sprite(&myx, &myy, 6, 169, 3);
sp_seq(&dcrap, 169);
sp_frame(&dcrap, 3);
sp_script(&dcrap, "shrink");

&myy += 10;
&myx += 60;
int &rcrap = create_sprite(&myx, &myy, 6, 169, 6);
sp_script(&rcrap, "shrink");
sp_seq(&rcrap, 169);
sp_frame(&rcrap, 6);

kill_this_task();
}
