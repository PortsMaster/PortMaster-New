void main( void )
{
  if (&story > 6)
  {
  return;
  }
   &vision = 1;
   int &guy;
   &guy = create_sprite(400, 250, 9, 373, 4);
   freeze(&guy);
   sp_speed(&guy, 1);
   sp_timing(&guy, 33);
   sp_base_walk(&guy, 270);
   sp_script(&guy, "s1-brg2");
}
