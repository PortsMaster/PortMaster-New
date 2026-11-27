ins_create(0, 0, "Instances", 126);
ins_create(0, 0, "Instances", 120);
ins_create(0, 0, "Screen", 107);
ins_create(0, 0, "Instances", 183);
ins_create(0, 0, "Instances", 57);
ins_create(0, 0, "Effect", 207);
ins_create(0, 0, "Instances", 238);
ins_create(0, 0, "Instances", 97);
ins_create(0, 0, "Instances", 44);
alarm[1] = 1;
initPhase = 0;
initIdx = 0;
initList = [];
initListBuilt = 0;
initBudget = 200;
canPause = 0;
fadeOut = -4;
global.canRetry = 0;
fadeWateTime = 30;
playerMoveTime = 15;
fadeTime = 30;
gameEndWateTime = 60;
fadeOut = ins_create(0, 0, "HUD", 211);
fadeOut.start(fadeTime, function()
{
    canPause = 1;
    
    with (oEventObject)
        instance_destroy();
});
fadeOut.addEvent(playerMoveTime, function()
{
    global.isStop = 0;
    global.canRetry = 1;
});
fadeOut.pause();

function close()
{
    game_end();
}

function close_start()
{
    alarm[0] = gameEndWateTime;
}

function init_collect(arg0)
{
    initList = [];
    
    with (arg0)
        array_push(other.initList, id);
}

function init_finish()
{
    if (global.isFirstOping || global.isGameClear || !global.isFirstCheckPoint)
    {
        with (oPlayer)
        {
            x = global.startX;
            y = global.startY;
            isGround = 1;
            isPrevGround = 1;
        }
        
        oStage.isNullRespone = 1;
        
        if (global.isGameClear)
            global.isGameClear = 0;
        
        if (global.isFirstOping)
            global.isFirstOping = 0;
    }
    else
    {
        with (oPlayer)
        {
            x = global.checkPointX;
            y = global.checkPointY;
            isGround = 1;
            isPrevGround = 1;
            
            with (instance_place(x, y + 1, oCheckPoint))
                check_point_active_reboot();
        }
    }
    
    with (oBaseArea)
        area_check_deactive();
    
    with (oBaseArea)
        area_check_active();
    
    // Fade object may have been deactivated during setup/culling; bring it back.
    instance_activate_object(fadeOut);
    
    oStage.isMoveStop = 0;
    alarm[2] = fadeWateTime;
}

function init_step()
{
    var budget = initBudget;
    
    while (budget > 0 && initPhase > 0)
    {
        if (!initListBuilt)
        {
            initIdx = 0;
            
            switch (initPhase)
            {
                case 1:
                    init_collect(oBaseDoor);
                    break;
                
                case 2:
                case 5:
                    init_collect(oBaseConduct);
                    break;
                
                case 3:
                case 4:
                case 6:
                    init_collect(oMoveWallBase);
                    break;
            }
            
            initListBuilt = 1;
        }
        
        if (initPhase == 7)
        {
            initPhase = 0;
            init_finish();
            return;
        }
        
        var size = array_length(initList);
        
        while (budget > 0 && initIdx < size)
        {
            var ins = initList[initIdx];
            initIdx++;
            budget--;
            
            if (!instance_exists(ins))
                continue;
            
            switch (initPhase)
            {
                case 1:
                case 3:
                    with (ins)
                        event_user(3);
                    
                    break;
                
                case 2:
                    with (ins)
                    {
                        var p = object_get_parent(object_index);
                        
                        if (p != 119 && p != 224)
                            event_user(3);
                    }
                    
                    break;
                
                case 4:
                    with (ins)
                        event_user(6);
                    
                    break;
                
                case 5:
                    with (ins)
                        event_user(4);
                    
                    break;
                
                case 6:
                    with (ins)
                        event_user(7);
                    
                    break;
            }
        }
        
        if (initIdx >= size)
        {
            initPhase++;
            initListBuilt = 0;
            initList = [];
        }
    }
}
