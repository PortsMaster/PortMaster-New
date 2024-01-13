//void onStart()
//{
    //Utils::logInfo("ScriptingCallback: onStart");
//}

/** Visibility predicate used for opening/closing the big doors */
void big_door(int idKart)
{
    int unlocked_challenges = Challenges::getCompletedChallengesCount();
    int challenges = Challenges::getChallengeCount();
    
    // allow ONE unsolved challenge : the last one
    if (unlocked_challenges < challenges - 1)
    {
        GUI::displayModalMessage(GUI::translate("Complete all challenges to unlock the big door!"));
    }
}

void garage(int idKart)
{
    Track::pauseRace();
}

bool showDoorOpen(Track::TrackObject@ obj)
{
    int unlocked_challenges = Challenges::getCompletedChallengesCount();
    int challenges = Challenges::getChallengeCount();
    
    Utils::logInfo("allchallenges: unlocked_challenges=" + unlocked_challenges + ", challenges=" + challenges);
    
    // allow ONE unsolved challenge : the last one
    return unlocked_challenges >= challenges - 1;
}

bool showDoorClosed(Track::TrackObject@ obj)
{
    return !showDoorOpen(obj);
}

/** Visibility callback run for each challenge at startup, determines if it's visible or not */
bool isLocked(string name, Track::TrackObject@ obj)
{
    //Utils::logInfo("is un locked: " + name + " => " + Challenges::isChallengeUnlocked(name));
    
    // HACK: use this callback to create the billboard with the number of points
    Vec3 pos = obj.getOrigin();
    //Utils::logInfo("    position: " + pos.getX() + ", " + pos.getY() + ", " + pos.getZ());
    
    int required_points = Challenges::getChallengeRequiredPoints(name);
    //Utils::logInfo("    required_points: " + required_points);
    
    Track::createTextBillboard("" + required_points, pos);
    
    return !Challenges::isChallengeUnlocked(name);
}

void onForceFieldKartCollision(int idKart, const string library_instance_id, const string obj_id)
{
    // TODO: particles?
    Audio::playSound("forcefield");
    GUI::clearOverlayMessages();
    GUI::displayOverlayMessage(
        GUI::translate("You need more points\nto enter this challenge!\nCheck the minimap for\navailable challenges.")
    );
    
    Utils::logInfo("onForceFieldKartCollision");
}
