void main(void )
{
int &mycrap = create_sprite(&save_x, &save_y, 0, 161, 1);
sp_script(&mycrap, "dam-bomn");
sp_range(&mycrap, 30);
sp_brain(&mycrap, 17);
playsound(6, 22050, 0,0,0);
sp_seq(&mycrap, 161);
//sp_touch_damage(&mycrap, 10);
sp_strength(&mycrap, 25);
 }

