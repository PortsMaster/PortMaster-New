void main( void )
{
//Create text on wall
 int &text = say_xy("The best in bows", 18, 23);
debug("Ok, changing sprite &text");
 sp_kill(&text, 0);

 //Create salesperson or something
 int &pep;
 &pep = create_sprite(300, 130, 0, 0, 0);
 sp_brain(&pep, 16);
 sp_base_walk(&pep, 370);
 sp_speed(&pep, 1);
 sp_timing(&pep, 0);
 //set starting pic
 sp_pseq(&pep, 373);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s3-st2p");
}

