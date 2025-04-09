void main( void )
{
 //setup Mog and do cutscene
freeze(1);
 playmidi("1009.mid");

wait(500);
 say_stop("All this killing and still no answers.", 1);

 int &crap = create_sprite(317,301, 0, 0, 0);
 &temp2hold = &crap;
 sp_script(&crap, "en-gmog");
 freeze(&crap);
 
 wait(500);
 say_stop("`4Who dares wake the mighty Mog, king of Goblins?", &crap);
 wait(500);
 say_stop("What's this?  You have learned our tongue well, Mog.", 1);
 wait(500);
 say_stop("`4Of course.  I was raised by.. what is this?  My comrades litter the ground!", &crap);
 wait(500);
 say_stop("It was I who fell them.",1);
 wait(500);
say_stop("NOW TELL ME OF YOUR SECRET DEALINGS WITH THE CAST!", 1);
 wait(500);
 say_stop("`4You?  YOU?  I MUST AVENGE MY BROTHERS!", &crap);
 wait(500);
 sp_target(&crap, 1);
 sp_brain(&crap, 9);
screenlock(1);
unfreeze(1);
unfreeze(&crap);
}
