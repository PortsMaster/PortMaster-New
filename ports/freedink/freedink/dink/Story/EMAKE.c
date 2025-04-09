//make, contains info on making items given after a monster dies

void medium( void )
{
int &mcrap = random(20,1);

if (&mcrap == 1)
 {
 //lets give 'em a small heart
 int &crap = create_sprite(&save_x, &save_y, 6, 54, 1);
 sp_script(&crap, "sheart");
 return;
 }

if (&mcrap == 2)
 {
 //lets give 'em a large heart
 int &crap = create_sprite(&save_x, &save_y, 6, 54, 1);
 sp_script(&crap, "heart");
 return;
 }




if (&mcrap == 3)
{


    &mcrap = random(3,1);

        if (&mcrap == 1)
         {
        //give them food type 1
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 1);
        sp_script(&crap, "sfood");
        }
        if (&mcrap == 2)
        
        {
        //give them food type 2
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 2);
        sp_script(&crap, "sfood");
        }
        
        if (&mcrap == 3)
        
        {
        //give them food type 3
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 7);
        sp_script(&crap, "sfood");
        }
        
        if (&mcrap == 4)
        
        {
        //give them food type 4
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 8);
        sp_script(&crap, "sfood");
        }
   return;
}

 //lets give 'em a random amount of gold
 int &crap = create_sprite(&save_x, &save_y, 6, 178, 4);
 sp_script(&crap, "mgold");


}


void large( void )
{
int &mcrap = random(20,1);

if (&mcrap == 2)
 {
 //lets give 'em a large heart
 int &crap = create_sprite(&save_x, &save_y, 6, 54, 1);
 sp_script(&crap, "heart");
 return;
 }




if (&mcrap == 3)
{


    &mcrap = random(3,1);

        if (&mcrap == 1)
         {
        //give them food type 1
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 1);
        sp_script(&crap, "sfood");
        }
        if (&mcrap == 2)
        
        {
        //give them food type 2
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 2);
        sp_script(&crap, "sfood");
        }
        
        if (&mcrap == 3)
        
        {
        //give them food type 3
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 7);
        sp_script(&crap, "sfood");
        }
        
        if (&mcrap == 4)
        
        {
        //give them food type 4
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 8);
        sp_script(&crap, "sfood");
        }
   return;
}

 //lets give 'em a random amount of gold
 int &crap = create_sprite(&save_x, &save_y, 6, 178, 4);
 sp_script(&crap, "lgold");


}


void xlarge( void )
{
int &mcrap = random(20,1);

if (&mcrap == 2)
 {
 //lets give 'em a large heart
 int &crap = create_sprite(&save_x, &save_y, 6, 54, 1);
 sp_script(&crap, "heart");
 return;
 }




if (&mcrap == 3)
{


    &mcrap = random(3,1);

        if (&mcrap == 1)
         {
        //give them food type 1
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 1);
        sp_script(&crap, "sfood");
        }
        if (&mcrap == 2)
        
        {
        //give them food type 2
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 2);
        sp_script(&crap, "sfood");
        }
        
        if (&mcrap == 3)
        
        {
        //give them food type 3
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 7);
        sp_script(&crap, "sfood");
        }
        
        if (&mcrap == 4)
        
        {
        //give them food type 4
        int &crap = create_sprite(&save_x, &save_y, 6, 421, 8);
        sp_script(&crap, "sfood");
        }
   return;
}
debug("Making gold200");
 //lets give 'em a random amount of gold
 int &crap = create_sprite(&save_x, &save_y, 6, 178, 4);
 sp_script(&crap, "gold200");


}


void small( void )
{
int &mcrap = random(3,1);
if (&mcrap == 1)
 {
 //lets give 'em a small heart
 int &crap = create_sprite(&save_x, &save_y, 6, 54, 1);
 sp_script(&crap, "sheart");
 return;
 }

return;
}


