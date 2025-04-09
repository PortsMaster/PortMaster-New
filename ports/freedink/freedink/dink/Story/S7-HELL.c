void main( void )
{

int &crap = get_burn();

if (&crap == 0)
playmidi("1006");
if (&crap > 0)
playmidi("1018");

if (&s7-boat == 0)
  {
 preload_seq(426);
 int &boat = create_sprite(726,287, 0,426,1);
 sp_script(&boat, "s7-boat");
 sp_speed(&boat, 1);
 sp_timing(&boat, 66);
 sp_brain(&boat, 6);
 sp_seq(&boat, 426);
 sp_frame_delay(&boat, 200);
  &s7-boat = 1;
   }

}
