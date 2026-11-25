// Fade object may have been deactivated by culling; bring it back first.
if (!instance_exists(fadeOut))
    instance_activate_object(fadeOut);

if (instance_exists(fadeOut))
{
    fadeOut.play();
}
else
{
    // Fade object is truly gone: do what its callbacks would have done
    // so the game doesn't soft-lock.
    show_debug_message("oGamePlay Alarm2: fadeOut missing, using fallback");
    canPause = 1;
    global.isStop = 0;
    global.canRetry = 1;
    
    with (oEventObject)
        instance_destroy();
}
