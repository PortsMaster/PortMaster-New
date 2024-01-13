void onStart()
{
    Utils::logInfo("onStart(): start Driving Tutorial");
    switch (GUI::getRaceGUIType())
    {
        case GUI::KEYBOARD_GAMEPAD:
            GUI::displayStaticMessage(
                GUI::translate("Accelerate with <%s>, and steer with <%s> and <%s>.",
                    GUI::getKeyBinding(GUI::PlayerAction::ACCEL),
                    GUI::getKeyBinding(GUI::PlayerAction::STEER_LEFT),
                    GUI::getKeyBinding(GUI::PlayerAction::STEER_RIGHT)
                )
            );
            break;
        case GUI::STEERING_WHEEL:
            GUI::displayStaticMessage(
                GUI::translate("Accelerate by touching the upper part of the wheel, and steer by moving left or right.")
            );
            break;
        case GUI::ACCELEROMETER:
            GUI::displayStaticMessage(
                GUI::translate("Accelerate by moving the accelerator upwards, and steer by tilting your device.")
            );
            break;
        case GUI::GYROSCOPE:
            GUI::displayStaticMessage(
                GUI::translate("Accelerate by moving the accelerator upwards, and steer by rotating your device.")
            );
            break;
        }
}

void onBoxHitByItem(int itemType, int idKart, const string objID)
{
    // Test
    Utils::logInfo("ScriptingCallback: onBoxHitByItem. Item = " + itemType + "; idKart = " + idKart + "; objID = " + objID);
}

void onKartKartCollision(int idKart1, int idKart2)
{
    // Test
    Utils::logInfo("ScriptingCallback: onKartKartCollision: " + idKart1 + " - " + idKart2);
}

void tutorial_bananas(int idKart)
{
    Utils::logInfo("tutorial_bananas(Kart " + idKart + "): Triggered");
    GUI::displayStaticMessage(
        GUI::translate("Avoid bananas!"),
    GUI::ERROR);
}

void tutorial_giftboxes(int idKart)
{
    Utils::logInfo("tutorial_giftboxes(Kart " + idKart + "): Triggered");
    if (GUI::getRaceGUIType() == GUI::KEYBOARD_GAMEPAD)
    {
        GUI::displayStaticMessage(
            GUI::translate("Collect gift boxes, and fire the weapon with <%s> to blow away these boxes!",           
                GUI::getKeyBinding(GUI::PlayerAction::FIRE)
            )
        );
    }
    else
    {
        GUI::displayStaticMessage(
            GUI::translate("Collect gift boxes, and fire by pressing the bowling icon to blow away these boxes!")
        );
    }
}

void tutorial_backgiftboxes(int idKart)
{
    Utils::logInfo("tutorial_backgiftboxes(Kart " + idKart + "): Triggered");
    if (GUI::getRaceGUIType() == GUI::KEYBOARD_GAMEPAD)
    {
        GUI::displayStaticMessage(
            GUI::translate("Press <%s> to look behind.\nFire the weapon with <%s> while pressing <%s> to fire behind!",
                GUI::getKeyBinding(GUI::PlayerAction::LOOK_BACK),
                GUI::getKeyBinding(GUI::PlayerAction::FIRE),
                GUI::getKeyBinding(GUI::PlayerAction::LOOK_BACK)
            )
        );
    }
    else
    {
        GUI::displayStaticMessage(
            GUI::translate("Press the mirror icon to look behind.\nFire the weapon behind by holding the mirror icon and then swiping to the bowling icon!")
        );
    }
}

void tutorial_nitro_use(int idKart)
{
    Utils::logInfo("tutorial_nitro_use(Kart " + idKart + "): Triggered");
    if (GUI::getRaceGUIType() == GUI::KEYBOARD_GAMEPAD)
        GUI::displayStaticMessage(
            GUI::translate("Use the nitro you collected by pressing <%s>!",
                GUI::getKeyBinding(GUI::PlayerAction::NITRO)
            )
        );
    else
        GUI::displayStaticMessage(
            GUI::translate("Use the nitro you collected by pressing the nitro icon")
        );
}

void tutorial_nitro_collect(int idKart)
{
    Utils::logInfo("tutorial_nitro_collect(Kart " + idKart + "): Triggered");
    GUI::displayStaticMessage(
        GUI::translate("Collect nitro bottles (we will use them after the curve).")
    );
}

void tutorial_rescue(int idKart)
{
    Utils::logInfo("tutorial_rescue(Kart " + idKart + "): Triggered");
    if (GUI::getRaceGUIType() == GUI::KEYBOARD_GAMEPAD)
        GUI::displayStaticMessage(
            GUI::translate("Oops! When you're in trouble, press <%s> to be rescued.",
                GUI::getKeyBinding(GUI::PlayerAction::RESCUE)
            ),
        GUI::ERROR);
    else
        GUI::displayStaticMessage(
            GUI::translate("Oops! When you're in trouble, press the bird icon to be rescued."),
        GUI::ERROR);
}

void tutorial_skidding(int idKart)
{
    Utils::logInfo("tutorial_skidding(Kart " + idKart + "): Triggered");
    if (GUI::getRaceGUIType() == GUI::KEYBOARD_GAMEPAD)
    {
        GUI::displayStaticMessage(
            GUI::translate("Accelerate and press the <%s> key while turning to skid.\nSkidding for a short while can help you turn faster to take sharp turns.",
                GUI::getKeyBinding(GUI::PlayerAction::DRIFT)
            )
        );
    }
    else
    {
        GUI::displayStaticMessage(
            GUI::translate("Accelerate and press the skid icon while turning to skid.\nSkidding for a short while can help you turn faster to take sharp turns.",
                GUI::getKeyBinding(GUI::PlayerAction::DRIFT)
            )
        );
    }
}

void tutorial_skidding2(int idKart)
{
    Utils::logInfo("tutorial_skidding2(Kart " + idKart + "): Triggered");
    GUI::displayStaticMessage(
        GUI::translate("Note that if you manage to skid for several seconds, you will receive a bonus speedup as a reward!")
    );
}

void tutorial_endmessage(int idKart)
{
    Utils::logInfo("tutorial_endmessage(Kart " + idKart + "): Triggered");
    GUI::displayMessage(
        GUI::translate("You are now ready to race. Good luck!"),
    GUI::ACHIEVEMENT);
}

void tutorial_exit(int idKart)
{
    Utils::logInfo("tutorial_exit(Kart " + idKart + "): Tutorial quitted");
    Track::exitRace();
}

void tutorial_discard(int idKart)
{
    Utils::logInfo("tutorial_discard(Kart " + idKart + "): Discarded a Message");
    GUI::discardStaticMessage();
}

// ============= DEBUG TESTS ==============
void debug_squash()
{
    int idKart = 0;
    Utils::logInfo("Testing squash");
    Kart::squash(idKart, 5.0);
}

void debug_set_velocity()
{
    int idKart = 0;
    Utils::logInfo("Testing setVelocity");
    Kart::setVelocity(idKart, Vec3(0, 10, 0));
}

// TODO: teleport doesn't work very well
void debug_teleport()
{
    int idKart = 0;
    Utils::logInfo("Testing getLocation + teleport");
    Vec3 loc = Kart::getLocation(idKart);
    Utils::logInfo(Utils::insertValues("Kart %s location : %s %s %s", idKart + "", loc.getX() + "", loc.getY() + "", loc.getZ() + ""));
    Kart::teleport(idKart, Vec3(loc.getX() - 3, loc.getY(), loc.getZ() - 3));
}
