void main( void )
{
//set the vision, so can't or can use stairs
 if (&story > 10)
    {
     //saved town, lets use the stairs and whatnot
    &vision = 2;
    }

 if (&story < 11)
    {
     //can't use stairs
Debug("Yeah!");
    &vision = 1;
    }


 //Make Parents & Little girl
 preload_seq(69);
 preload_seq(411);
 preload_seq(339);
 int &mom;
 int &dad;
 int &girl;
 &mom = create_sprite(377, 127, 0, 0, 0);
 sp_brain(&mom, 16);
 sp_base_walk(&mom, 220);
 sp_speed(&mom, 1);
 sp_timing(&mom, 0);
 //set starting pic
 sp_pseq(&mom, 221);
 sp_pframe(&mom, 1);
 sp_script(&mom, "s4-h2p1");
 //Now the dad
 &dad = create_sprite(405, 148, 0, 0, 0);
 &temp4hold = &dad;
 sp_brain(&dad, 16);
 sp_base_walk(&dad, 410);
 sp_speed(&dad, 1);
 sp_timing(&dad, 0);
 //set starting pic
 sp_pseq(&dad, 411);
 sp_pframe(&dad, 1);
 sp_script(&dad, "s4-h2p2");
 &girl = create_sprite(235, 178, 0, 0, 0);
 sp_brain(&girl, 16);
 sp_base_walk(&girl, 330);
 sp_speed(&girl, 1);
 sp_timing(&girl, 0);
 //set starting pic
 sp_pseq(&girl, 331);
 sp_pframe(&girl, 1);
 sp_script(&girl, "s4-h2p3");
 freeze(&mom);
 freeze(&dad);
}

