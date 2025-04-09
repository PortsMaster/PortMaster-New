Scenario.Intro = {

  of_text_original: [
    '####### ######  ####### #     # ####### ####### ######  ######  ####### ######  ',
    '#     # #     # #       ##    # #       #     # #     # #     # #       #     # ',
    '#     # #     # #       # #   # #       #     # #     # #     # #       #     # ',
    '#     # ######  #####   #  #  # #####   #     # #     # #     # #####   ######  ',
    '#     # #       #       #   # # #       #     # #     # #     # #       #   #   ',
    '#     # #       #       #    ## #       #     # #     # #     # #       #    #  ',
    '####### #       ####### #     # #       ####### ######  ######  ####### #     # '],

  Start: function(pMissionNumber, pPhaseNumber) {

    Human.RandomXY(3);

    Objectives.KillAllEnemy.Random(2);
    Objectives.RescueHostages.Random(1);

    Structures.PlaceRandom("hut", "civilian", 5, 250);

    Strange.PlaceSpritesOnCharMap(SpriteTypes.GrenadeBox, this.of_text_original, 3, 20, 20 );

    Map.SpriteAdd(SpriteTypes.Helicopter_Missile_Human,  Session.HumanPosition.x,  Session.HumanPosition.y);
  },

  Settings: function() {
    Settings.FromSeed(7789);
    Settings.Random();
    Settings.Width = 150;
    Settings.Height = 100;
    Settings.TerrainType = Terrain.Types.Jungle;

    Settings.setObjectives( [Objectives.KillAllEnemy] );
  }
};
