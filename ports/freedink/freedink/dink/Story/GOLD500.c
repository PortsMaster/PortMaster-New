//this script is for 500 gold

void main(void )
{
        sp_pseq(&current_sprite, 178);
        sp_frame(&current_sprite, 4); //so the seq will start
   //     sp_brain(&current_sprite, 6);
        sp_touch_damage(&current_sprite, -1);
        sp_nohit(&current_sprite, 1);


//create shiny thingie
&save_x = sp_x(&current_sprite, -1);
&save_y = sp_y(&current_sprite, -1);
&save_y += random(5,1);
int &startframe = random(5,1);
int &spark = create_sprite(&save_x, &save_y, 15, 165, 1);
sp_seq(&spark, 165);
sp_nohit(&spark, 1);
sp_frame(&spark, &startframe);
sp_brain_parm(&spark, &current_sprite);

}

void touch( void )
{
&gold += 500;
say("I found 500 gold.",1);
sp_brain_parm(&current_sprite, 10);
sp_brain(&current_sprite, 12);
sp_touch_damage(&current_sprite, 0);
sp_timing(&current_sprite, 0);

  //kill this item so it doesn't show up again for this player
  int &hold = sp_editor_num(&current_sprite);
  if (&hold != 0)
  editor_type(&hold, 1); 

}
