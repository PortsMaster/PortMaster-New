void main( void )
{

if (&story > 11)
{
 //Script for the weapons shop in the Dragon Town on Joppa
 preload_seq(411);
 preload_seq(413);
 preload_seq(417);
 preload_seq(419);
 int &what;
 int &pep;
 &what = random(2, 1);
 if (&what == 1)
 {
  &pep = create_sprite(196, 118, 0, 0, 0);
 }
 if (&what == 2)
 {
  &pep = create_sprite(443, 176, 0, 0, 0);
 }
 sp_brain(&pep, 16);
 sp_base_walk(&pep, 410);
 sp_speed(&pep, 1);
 sp_timing(&pep, 0);
 //set starting pic
 sp_pseq(&pep, 411);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s5-st1p");

 }
}
