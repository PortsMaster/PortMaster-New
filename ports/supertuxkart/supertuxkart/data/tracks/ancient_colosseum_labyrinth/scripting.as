bool isCTF(Track::TrackObject@ obj)
{
    // enum RaceManager::MINOR_MODE_CAPTURE_THE_FLAG is 2002
    return Track::getMinorRaceMode() == 2002;
}

bool isNotCTF(Track::TrackObject@ obj)
{
    // enum RaceManager::MINOR_MODE_CAPTURE_THE_FLAG is 2002
    return Track::getMinorRaceMode() != 2002;
}
