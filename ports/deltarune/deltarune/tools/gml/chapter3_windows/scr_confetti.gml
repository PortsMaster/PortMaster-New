function scr_confetti(arg0, arg1, arg2, arg3)
{
    var __popper = instance_create(arg0, arg1, obj_confetti_popper);
    arg3 = floor(arg3);
    __popper.direction = arg2;
    __popper.count = arg3;
    return __popper;
}

function scr_confetti_ext(arg0, arg1, arg2, arg3, arg4 = 20, arg5 = 200, arg6 = 340, arg7 = 0, arg8 = 0, arg9 = 1000100)
{
    arg3 = floor(arg3);
    var __i = 0;
    for (__i = 0; __i < arg3; __i++)
    {
        var _d = instance_create(arg0, arg1, obj_confetti_overworld);
        with (_d)
        {
            direction = random_range(arg2 - 20, arg2 + 20);
            height = arg4;
            miny = arg5;
            maxy = arg6;
            topdrop = arg7;
            bottomdrop = arg8;
            maxDepth = arg9;
        }
    }
}

function scr_confetti_preload(arg0, arg1, arg2, arg3, arg4 = 20, arg5 = 200, arg6 = 340, arg7 = 0, arg8 = 0, arg9 = 1000100)
{
    arg3 = max(1, floor(arg3 / 2));
    var __i = 0;
    for (__i = 0; __i < arg3; __i++)
    {
        var _d = instance_create(arg0, arg1, obj_confetti_overworld);
        with (_d)
        {
            direction = random_range(arg2 - 20, arg2 + 20);
            height = arg4;
            miny = arg5;
            maxy = arg6;
            topdrop = arg7;
            bottomdrop = arg8;
            maxDepth = arg9;
            preload = 1;
            visible = false;
        }
    }
}

function scr_confetti_fire()
{
    with (obj_confetti_overworld)
    {
        if (preload)
        {
            preload = 0;
            speed = preload_speed;
            preload_speed = 0;
            visible = true;
        }
    }
}
