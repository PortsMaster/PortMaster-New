bool isNotCTF(Track::TrackObject@ obj)
{
    // enum RaceManager::MINOR_MODE_CAPTURE_THE_FLAG is 2002
    return Track::getMinorRaceMode() != 2002;
}

bool isCTF(Track::TrackObject@ obj)
{
    return !isNotCTF(obj);
}

bool hasFlooding(Track::TrackObject@ obj)
{
    // Disable water flooding when there's AI karts because they can't handle it
    int karts = Track::getNumberOfKarts();
    int players = Track::getNumLocalPlayers();

    // Always on in network game if not CTF
    return isNotCTF(obj) &&
        (Utils::isNetworking() || !(karts > players));
}

bool hasNoFlooding(Track::TrackObject@ obj)
{
    return !hasFlooding(obj);
}
