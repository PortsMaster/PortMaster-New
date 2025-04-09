void main( void )
{

if (&s4-duck == 0)
        {
         &vision = 1;
        return;
        }

if (&s4-duck == 2)
        {
                &vision = 2;
                return;
        
        }
if (&s4-duck == 1)
{
                 &vision = 1;
        wait(1);
         //the wait allows the screen to be drawn before we continue
          //remove rocks hardness and sprite
           int &rcrap = sp(15);
          sp_hard(&rcrap, 1);
          draw_hard_map(&current_sprite);
          sp_active(&rcrap, 0);
          //remove the cracks as well, as they would look silly now
          &rcrap = sp(16);
          sp_active(&rcrap, 0);
          &rcrap = sp(26);
          sp_active(&rcrap, 0);

 }


}
