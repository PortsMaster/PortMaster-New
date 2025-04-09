//script for individual fireball
void main( void )
{
        int &mcrap;
        int &scrap;
       int &junk;
}

void damage( void )
{
//        playsound(18, 1000,0,0,0);

        &scrap = &current_sprite;
        kill_shadow(&scrap);
        sp_seq(&scrap, 94);
        sp_pseq(&scrap, 94);
        sp_frame(&scrap, 1);
        sp_brain(&scrap, 11);
         sp_touch_damage(&scrap, 4);
        sp_speed(&scrap, 0);
        &mcrap = sp_y(&scrap, -1);
     //   &mcrap -= 35;
        sp_y(&scrap, &mcrap);

// &mcrap = sp_pseq(&missile_target, -1);
// &scrap = sp_pframe(&missile_target, -1);
sp_script(&scrap, "dam-icee");

}
