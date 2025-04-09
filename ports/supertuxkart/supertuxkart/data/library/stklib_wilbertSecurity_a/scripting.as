namespace stklib_wilbertSecurity_a
{
    // Frame 0 to 20 is "calm down" animation
    // Frame 21 to 48 is handstand animation
    // Frame 49 to 190 is painting animation, used in stklib_wilberPainter_a
    void onStart(const string instID) 
    {
        array<Track::TrackObject@>@ tl = Track::getTrackObjectList();
        Track::TrackObject@ wilber_obj = null;
        Track::Mesh@ wilber_mesh = null;
        for (uint i = 0; i < tl.length(); i++)
        {
            if (tl[i].getName() == "stklib_wilbertSecurity_a_main.spm")
            {
                // Originally wilber animation ends at 190 totally
                if (tl[i].getMesh() !is null &&
                    tl[i].getMesh().getAnimationSetFrames().length() == 2 &&
                    tl[i].getMesh().getAnimationSetFrames()[0] == 0 &&
                    tl[i].getMesh().getAnimationSetFrames()[1] == 190)
                {
                    @wilber_obj = @tl[i];
                    @wilber_mesh = @tl[i].getMesh();
                    break;
                }
            }
        }
        if (wilber_mesh !is null && wilber_obj.getParentLibrary() !is null)
        {
            // Try to see if this wilber is used by a meta library
            // wilber_obj is the wilber .spm in wilber library, so 2
            // getParentLibrary() will do the job
            Track::TrackObject@ meta =
                wilber_obj.getParentLibrary().getParentLibrary();
            if (meta !is null)
            {
                if (meta.getName() == "stklib_wilberPainter_a")
                {
                    wilber_mesh.removeAllAnimationSet();
                    wilber_mesh.addAnimationSet(49, 190);
                    wilber_mesh.useAnimationSet(0);
                    return;
                }
            }
        }

        if (wilber_mesh !is null)
        {
            // If wilber is used alone, use random animation set
            wilber_mesh.removeAllAnimationSet();
            wilber_mesh.addAnimationSet(0, 20);
            wilber_mesh.addAnimationSet(21, 48);
            wilber_mesh.useAnimationSet(Utils::randomInt(0, 2));
        }
    }
}
