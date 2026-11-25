if (initPhase > 0)
{
    init_step();
    exit;
}

if (canPause && oInput.keyPause && instance_number(oPause) <= 0)
{
    ins_create(0, 0, "Screen", 33);
    audio_play_sound(sndPause, 0, false);
}

if (global.isGameTimeUpdate)
    global.gameTime = min(global.gameTime + 1, global.maxGameTime);
