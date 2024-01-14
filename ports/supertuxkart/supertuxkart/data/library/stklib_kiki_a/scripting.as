namespace stklib_kiki_a
{
    // Frame 0 to 109 is waving hand animation, used in stklib_carousel_a
    // Frame 110 to 287 is painting animation, used in stklib_kikiPainter_a
    void onStart(const string instID) 
    {
        array<Track::TrackObject@>@ tl = Track::getTrackObjectList();
        Track::TrackObject@ kiki_obj = null;
        Track::Mesh@ kiki_mesh = null;
        for (uint i = 0; i < tl.length(); i++)
        {
            if (tl[i].getName() == "stklib_kiki_a_main.spm")
            {
                // Originally kiki animation ends at 287 totally
                if (tl[i].getMesh() !is null &&
                    tl[i].getMesh().getAnimationSetFrames().length() == 2 &&
                    tl[i].getMesh().getAnimationSetFrames()[0] == 0 &&
                    tl[i].getMesh().getAnimationSetFrames()[1] == 300)
                {
                    @kiki_obj = @tl[i];
                    @kiki_mesh = @tl[i].getMesh();
                    break;
                }
            }
        }
        if (kiki_mesh !is null && kiki_obj.getParentLibrary() !is null)
        {
            // Try to see if this kiki is used by a meta library
            // kiki_obj is the kiki .spm in kiki library, so 2
            // getParentLibrary() will do the job
            Track::TrackObject@ meta =
                kiki_obj.getParentLibrary().getParentLibrary();
            if (meta !is null)
            {
                if (meta.getName() == "stklib_carousel_a")
                {
                    kiki_mesh.removeAllAnimationSet();
                    kiki_mesh.addAnimationSet(0, 109);
                    kiki_mesh.useAnimationSet(0);
                    return;
                }
                else if (meta.getName() == "stklib_kikiPainter_a")
                {
                    kiki_mesh.removeAllAnimationSet();
                    kiki_mesh.addAnimationSet(110, 300);
                    kiki_mesh.useAnimationSet(0);
                    return;
                }
            }
        }

        if (kiki_mesh !is null)
        {
            // For now use painting animation if kiki is used alone
            kiki_mesh.removeAllAnimationSet();
            kiki_mesh.addAnimationSet(110, 300);
            kiki_mesh.useAnimationSet(0);
        }
    }
}
