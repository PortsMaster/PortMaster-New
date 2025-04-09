void main( void )
{
 int &pep;
 &pep = create_sprite(404, 151, 0, 0, 0);
 sp_brain(&pep, 16);
 sp_base_walk(&pep, 220);
 sp_speed(&pep, 1);
 sp_timing(&pep, 0);
 //set starting pic
 sp_pseq(&pep, 221);
 sp_pframe(&pep, 1);
 sp_script(&pep, "s4-h1p");
}
