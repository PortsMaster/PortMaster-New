namespace gfx_advertisingScreenArena_a
{

    void onStart(const string instID) 
    {
        //Utils::logInfo ("hi");
        
        ArenaScreenTimeout@ timeout = ArenaScreenTimeout(0);
        Utils::TimeoutCallback@ timerDelegate = Utils::TimeoutCallback(timeout.onTimerComplete);
        Utils::setTimeoutDelegate(timerDelegate, 7.0);
        
        ArenaResetDisplay("gfx_advertisingScreenArena_a_main_proxy");
        ArenaResetDisplayText("gfx_advertisingScreenArena_a_main_proxy");
        ArenaEnableAd("gfx_advertisingScreenArena_a_main_proxy", 0);
        //Track::TrackObject@ part = Track::getTrackObject("gfx_advertisingScreenArena_a_main_proxy", "adscreen_follow_us_back");
        //part.setEnabled(false);
    }

    void ArenaResetDisplay(string instID) {
        
        Track::getTrackObject(instID, "adscreen_follow_us_back").setEnabled(false);
        Track::getTrackObject(instID, "adscreen_caldeira_back").setEnabled(false);
        Track::getTrackObject(instID, "adscreen_oceanic_back").setEnabled(false);
    }

    void ArenaResetDisplayText(string instID) {
        Track::getTrackObject(instID, "adscreen_follow_us").setEnabled(false);
        Track::getTrackObject(instID, "adscreen_caldeira").setEnabled(false);
        Track::getTrackObject(instID, "adscreen_oceanic").setEnabled(false);
    }

    void ArenaEnableAd(string instID, int adID)
    {
        ArenaResetDisplay(instID);
        ArenaResetDisplayText(instID);
        
        if (adID == 0)
        {
            Track::getTrackObject(instID, "adscreen_follow_us_back").setEnabled(true);
            Track::getTrackObject(instID, "adscreen_follow_us").setEnabled(true);
        }
        
        if (adID == 1)
        {
            Track::getTrackObject(instID, "adscreen_caldeira_back").setEnabled(true);
            Track::getTrackObject(instID, "adscreen_caldeira").setEnabled(true);
        }
        
        if (adID == 2)
        {
            Track::getTrackObject(instID, "adscreen_oceanic_back").setEnabled(true);
            Track::getTrackObject(instID, "adscreen_oceanic").setEnabled(true);
        }
    }

    class ArenaTextTimeout
    {

        string instID;
        
        void onTimerComplete2()
        {
            //Utils::logInfo("text disabled");
            ArenaResetDisplayText("gfx_advertisingScreenArena_a_main_proxy");
        }
    }

    class ArenaScreenTimeout
    {
        string instID;
        int counter;
        
        ArenaScreenTimeout(int initCounting)
        {
            this.counter = initCounting;
            this.instID = "gfx_advertisingScreenArena_a_main_proxy";
        }
        
        void onTimerComplete()
        {
            this.counter++;
            
            
            if(this.counter > 2)
            {
            //Utils::logInfo("o:o");
            this.counter = 0;
            }
            else
            {
                //Utils::logInfo("ahaha");
            }
            
            ArenaEnableAd(instID, this.counter);
            
            ArenaScreenTimeout@ timeout = ArenaScreenTimeout(this.counter);
            Utils::TimeoutCallback@ timerDelegate = Utils::TimeoutCallback(timeout.onTimerComplete);
            Utils::setTimeoutDelegate(timerDelegate, 7.0);
            
            ArenaTextTimeout@ timeout2 = ArenaTextTimeout();
            Utils::TimeoutCallback@ timerDelegate2 = Utils::TimeoutCallback(timeout2.onTimerComplete2);
            Utils::setTimeoutDelegate(timerDelegate2, 6.0);
        }
    }
}
