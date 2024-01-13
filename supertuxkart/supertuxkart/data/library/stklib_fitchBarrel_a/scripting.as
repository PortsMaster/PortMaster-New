void onFitchBarrelCollision(int idKart, const string libraryInstance, const string objID)
{
    if (Utils::isNetworking())
        return;
    //Utils::logInfo("Wall Collision! Kart " + idKart + " with obj " + objID + " from " + libraryInstance);
    Vec3 velocity = Kart::getVelocity(idKart);
    //Utils::logInfo("Kart velocity : " + velocity.getLength());
    if (velocity.getLength() > 2.5)
        blowUpFitchBarrel(libraryInstance);
}

class FitchBarrelTimeout
{
    string instID;

    FitchBarrelTimeout(string instID)
    {
        this.instID = instID;
    }

    void onTimerComplete()
    {

        array<string> barrel_parts = {
            "stklib_fitchBarrel_a_cover",
            "stklib_fitchBarrel_a_bodyPartA",
            "stklib_fitchBarrel_a_bodyPartB",
            "stklib_fitchBarrel_a_bodyPartC",
            "stklib_fitchBarrel_a_bodyPartD",
            "stklib_fitchBarrel_a_bodyPartE",
            "stklib_fitchBarrel_a_bottom"
        };

        uint counter = 0;
        while(counter < barrel_parts.length())
        {
            Track::TrackObject@ part = Track::getTrackObject(this.instID, barrel_parts[counter]);
            part.setEnabled(false);
            counter++;
        }
    }
}


void blowUpFitchBarrel(string instID)
{
    Track::TrackObject@ wall = Track::getTrackObject(instID, "stklib_fitchBarrel_a_main");
    wall.setEnabled(false);

    array<string> barrel_parts = {
            "stklib_fitchBarrel_a_cover",
            "stklib_fitchBarrel_a_bodyPartA",
            "stklib_fitchBarrel_a_bodyPartB",
            "stklib_fitchBarrel_a_bodyPartC",
            "stklib_fitchBarrel_a_bodyPartD",
            "stklib_fitchBarrel_a_bodyPartE",
            "stklib_fitchBarrel_a_bottom"
        };

        uint counter = 0;
        while(counter < barrel_parts.length())
        {
            Track::TrackObject@ part = Track::getTrackObject(instID, barrel_parts[counter]);
            part.setEnabled(true);
            counter++;
        }

    Track::TrackObject@ obj = Track::getTrackObject(instID, "stklib_fitchBarrel_a_sandExplosion");
    if (obj !is null)
    {
        // Will be null if particles are disabled
        Track::ParticleEmitter@ emitter = obj.getParticleEmitter();
        emitter.setEmissionRate(1.0);
        emitter.stopIn(0.1);
    }

    FitchBarrelTimeout@ timeout = FitchBarrelTimeout(instID);
    Utils::TimeoutCallback@ timerDelegate = Utils::TimeoutCallback(timeout.onTimerComplete);
    Utils::setTimeoutDelegate(timerDelegate, 20.0);
}



