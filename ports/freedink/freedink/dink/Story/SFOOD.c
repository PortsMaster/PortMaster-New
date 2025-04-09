//this script fills life up, from a small food

void main( )
{
        sp_touch_damage(&current_sprite, -1);
        sp_nohit(&current_sprite, 1);

}

void touch( void )
{
&life += 3;
if (&life > &lifemax)
 {
 &life = &lifemax;
 }
Playsound(10,22050,0,0,0);
sp_brain_parm(&current_sprite, 10);
say("Yum!",1);
sp_brain(&current_sprite, 12);
sp_touch_damage(&current_sprite, 0);
sp_timing(&current_sprite, 0);

  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
    {
     //this was placed by the editor, lets make it not come back
     editor_type(&hold, 1); 
     //kill food forever
    }


}
    