
void main(void)
{

}

void talk(void)
{
 if (&story > 3)
 {
 say_stop("This may have been what started that accident.", 1);
 say("But it really doesn't matter now.", 1);
 return;
 }
 if (&story == 3)
 {
 say("Maybe this got out of control.", 1);
 return;
 }
 say("Ahh, fire.  Warm.", 1);
}

void hit(void)
{
 if (&story > 3)
 {
 say("Stupid fireplace!", 1);
 return;
 }
 say("Ouch, that is hot!", 1);
}

