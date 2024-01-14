bool isTrackReverse(Track::TrackObject@ obj)
{
    return Track::isReverse();
}

bool isNotNetworking(Track::TrackObject@ obj)
{
    return !Utils::isNetworking();
}
