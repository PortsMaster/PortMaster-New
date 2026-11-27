// Level setup is now time-sliced in init_step() (see Create_0 / Step_0).
// Same steps and order as before; the oStage guard stops screen culling
// from deactivating objects before the area lists are fully built.
oStage.isMoveStop = 1;
initPhase = 1;
initIdx = 0;
initListBuilt = 0;
