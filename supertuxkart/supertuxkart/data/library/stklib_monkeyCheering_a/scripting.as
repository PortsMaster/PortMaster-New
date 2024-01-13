namespace stklib_monkeyCheering_a
{
    void throwBanana(         int kart_id,
                     const string instance_id,
                     const string library_name)
    {
        Track::TrackObject@ obj = Track::getTrackObject(instance_id, library_name);
        // For low geometry detail
        if (obj is null)
        {
            Track::setTriggerReenableTimeout("banana_trigger", instance_id,
                999999.0);
            return;
        }

        Track::Mesh@ mesh = obj.getMesh();
        if (mesh is null || mesh.getAnimationSet() != 2)
        {
            // This monkey is not using banana animation set, disable the
            // trigger for this round of game
            Track::setTriggerReenableTimeout("banana_trigger", instance_id,
                999999.0);
            return;
        }

        mesh.setFrameLoopOnce(143, 198);
    }
}