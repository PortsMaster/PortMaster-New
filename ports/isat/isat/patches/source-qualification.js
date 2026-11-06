'use strict';

(function qualifyGuestSources() {
  var sources = {
    "js/rpg_core.js": [
      "930ee1db401dff04792cc7a4ab3181065745795527130d0da564e95d8e91c515",
      "a943b1ef85e7b91a6b09c4b125965282d96f0fdce627ef435421778abcb3b178"
    ],
    "js/rpg_managers.js": "6434f299fba616ca3fedee8aa1b6e66d1b2e53b839cd21475e2ef7868f0c75f1",
    "js/rpg_objects.js": "db2db44e402a7890b97c17d7892410facec3fcb2ee48a3ff513ca6fba6f26111",
    "js/rpg_scenes.js": "2605309aeb212b86c7d50379cefd6620cf9b6dd0cf782a55e134594c994fd6ad",
    "js/rpg_sprites.js": "09435ecf207f81874a65de8893aabc988205e4983ad9ad6801bc038a581d932b",
    "js/rpg_windows.js": "79babbb19171940787a87e19b5222cc55c74afb978fab0772a409ec1d1e7fd45",
    "js/plugins/DisableMouse.js": "3d9583e09dfebfd1da58ab876ec4bc9ae2fceba66e09d516388464efbb5c80b5",
    "js/plugins/YEP_TestPlayAssist.js": "6df8c6b0969d14f8365be6fe99ecc5431cf52bd8af29856724072dbd8b17055f",
    "js/plugins/SRD_SuperToolsEngine.js": "a7aec74d55043936e912bba3c89e3800ce464b63f1f80414f799ec584abc3073",
    "js/plugins/SRD_HUDMaker.js": "662480a265fc7ed2cd29e4332d11b7a00a7067ca02bc408bbef7e68d9f4566a6",
    "js/plugins/Olivia_AntiPlayerStress.js": "0e4666e864f3deb6eb94fe7ef4cb98e4c8bd282f71eb50636604679c56110f29",
    "js/plugins/Olivia_MetaControls.js": "66c3fa900f9f99bf5540df8a7f76b8d90a3c9fdf9044296f9af41269f589f359",
    "js/plugins/JKL_PersistentData.js": [
      "85f963318d5fa53c886ac60fbfe797792d7957be87e9c925094e61a54f405d58",
      "202837994bfd11d41331743730e734ffaafbb781746d58edefd1264a8ce1c415"
    ],
    "js/plugins/SelfSwitchReset.js": "2b7af9143d52aec8615a52f376f0148ef9d1da953ed34e7325c7d3a70f778530",
    "js/plugins/Fix_NoActivity.js": "40ebef0c4e0c6c647e814dde82e596018997682daa3dd938197676af8ddad8f0",
    "js/plugins/YEP_UtilityCommonEvents.js": "e92a1e513cf75b78d7de868e479cf78509c02cecd8c730daeb4e655495b8c573",
    "js/plugins/TitleCommandPosition.js": "e267540b6ceab3513ad27e44d70361ebb1a258ea4752378c55b0ceb8bff69499",
    "js/plugins/MOG_TitleLayers.js": "ba510cb480cd7766ab428841632521b10e93dd6483441d2969ee3d882ba79598",
    "js/plugins/MOG_TitleLayers_CHANGE.js": "9e5509e18c151fc95d56e2a21ae642109099656d5697829898969e1c784accee",
    "js/plugins/HIME_WindowBackgroundColors.js": "6660889ffbe758a015f97ac4f667293d40024480f28914f52ee2a2741387f8e9",
    "js/plugins/No Autoshadow.js": "8e74f19abbbc66db49446c209ac9f994276f0fc0807b1de031a19ad3404b6ac3",
    "js/plugins/HIME_PreTitleEvents.js": "754d06683d18a5335e1e0d5211ebbc8067cf61187c3fe35f3c9e2d46c25abebe",
    "js/plugins/Insertdisc5_noVisualOption.js": "2d1bdd18bdf8c0ac774118fb9475031ac6e91e0d7336ebebcb02489e8da2c942",
    "js/plugins/ARP_TitleCommandExit.js": "07db12ab3651e657e4eccd87538ec5f02c0c7df6aa29820e2694465679190a40",
    "js/plugins/YEP_CoreEngine.js": "1b1350e2fdfbebbc7604232c23647530c805a2d1a56e332d3c56e835cc4f113d",
    "js/plugins/VE_BasicModule.js": "bc59e4784c6f716d1ba36452280f67fcde6f59fc485f7ed92c6b9f4602c7f58c",
    "js/plugins/YEP_OptionsCore.js": "45cf9de7e596605282e13ed4ede36a7bc9cfc48d2c960b0fc2ec76576f3d8a0b",
    "js/plugins/GamepadConfig.js": "feb5e743c2b80b1225698c00d3e9f7c5a734cb5e29035c7aaf312c6d6b558985",
    "js/plugins/KeyboardConfig.js": "26224c531efaeced97afc29681c9380e2264c804db00593ebe24795493b1ed71",
    "js/plugins/YEP_SaveCore.js": "c78662e6c5838b68a3cda12e7f3e65ab12ba3d1d699c3a253e1d8306212e89e4",
    "js/plugins/AccuratePlaytime.js": "189c7ae713722bb44f733686312058a96cb93677d0c8cc5f799f98faa99f68a2",
    "js/plugins/VE_ControlText.js": "e902aac347473dbeb56cfe256e4f7bf16aa662398ca205cffe8d5fa5c8fdcd65",
    "js/plugins/YEP_MessageCore.js": "17316469c3c15363873e302691713177cd6ec9c8b1b124d81ced45728318116e",
    "js/plugins/YEP_X_MessageSpeedOpt.js": "47ff344b374db43465822ffaac9200791b8d0f1c288f3f0dd967542f633be681",
    "js/plugins/YEP_X_ExtMesPack1.js": "b8755315c8249bee8702bd874d088f14860804c3252b2f8d98b63322cedba287",
    "js/plugins/YEP_X_ExtMesPack2.js": "20bb275cd21d77eb5cdfe9fb5430338c4197d215528c9daf6ebf3ce66cd1c70b",
    "js/plugins/SRD_ShakingText.js": "ae411437f9115c6092901bb20c374b284effea3636845de587d290f63d8c2e8e",
    "js/plugins/AutopauseAtPunctuation.js": "799a6df7dcafd7daf3a532de1b4c3b7bb16135b8b4d64c678701d2ee50859c5f",
    "js/plugins/Lostboy_MessagePause.js": "a2c8ae7472545cb7ff59193512fc50e5c009d79f8746907e5387c0c936336c6b",
    "js/plugins/MV_Unmissable_Skills.js": "d8b888f713550a586fc81464cfa1e6c36e00176cbccaeeb610f6f973ec8cc106",
    "js/plugins/YEP_BattleEngineCore.js": "e020b4152b3028ed51b76bb8d4044ff54d967d2a525e1d9a935f634b0ffc32a8",
    "js/plugins/YEP_X_AnimatedSVEnemies.js": "ba83f85cf0fe63a337dff282dbe290777e9f7bb2f6d0b1802436490b1271149d",
    "js/plugins/YEP_X_BattleSysATB.js": "02d2eb9e412be41ba8b17baaa010a1babbd9b23f1285ee47f79edd9a05edd70b",
    "js/plugins/YEP_X_ActSeqPack1.js": "b29229a1953b76fadf69474c70be15d90b95f1616b4a485b2fa04a4826f9ddf7",
    "js/plugins/YEP_BuffsStatesCore.js": "b62c11652663094cf19f719a3090ce3635e881c1a03e056a636e00f3bb6f29ec",
    "js/plugins/YEP_DamageCore.js": "1eff2d329a32c392e9850526b2b23b2702be9d4d4388a0c0cf7d8a75b1366df7",
    "js/plugins/YEP_TargetCore.js": "a7b6d36e084c1496da742b7e4eaa464da95ee039b1a8747f5fa91733627e7d25",
    "js/plugins/YEP_BattleAICore.js": "6d6ce07c9e9390fe633cfd9346878cd5fa40d28074166f414fa210de725f1251",
    "js/plugins/YEP_SkillCore.js": "9f092d4c92750600741619ea556c60f632849531140bc843c5efafa2059d45a8",
    "js/plugins/YEP_InstantCast.js": "702abd66cc4776eb4298b857c63f5448f34a037caf4eebc02b2679aa2e4ccbad",
    "js/plugins/YEP_X_SkillCooldowns.js": "73100c0d42da13cfa74e9f263e104036d82e7f25e933fd6b7251954ab972f662",
    "js/plugins/MrTS_SimpleReplaceSkill.js": "7ed1e05256105fb876efb8a7db2c5909ba593025786842cd2d3f334fab62009e",
    "js/plugins/YEP_BaseTroopEvents.js": "68bbbd4c1320fbc10f2c89c0f501ab643e2428dd2caf4ada83b73a01fbbc4c80",
    "js/plugins/Insertdisc5_changeCritDamage.js": "c097a8ff09309e0289db6069b933e08bf6d9d7aacff2c88719a2978217aa03d2",
    "js/plugins/YEP_Z_StateProtection.js": "3d4186c18c365d1bd7faa81de4d3e8dadbe642249abc1749963c1b7f48f8f271",
    "js/plugins/YEP_ImprovedBattlebacks.js": "ce2f7e336bf594b6cc5b005d1606508c3fcb2de1c4c21191c487eadf9dfe2685",
    "js/plugins/HIME_CustomDeathStates.js": "44aa97881696e811ec34a34aded9ec48762c7a6b4ee7227ff39d0be838def200",
    "js/plugins/Aries001_AnimationScreenEffects.js": "3d549581a0516903bd2d903970fdda927b883f10a6fdbeccb3049104a11c520e",
    "js/plugins/VE_DamagePopup.js": "573f9b96089a9f48b8e60e42038c24e05e702756025637bedcd7a0692e51056b",
    "js/plugins/DreamX_Ext_VE_DamagePopup.js": "849c7765cee21992b9930bdf4fc9636abffb487214440f46ff6f0b790a11cadc",
    "js/plugins/SRD_SkillExtender.js": "5a7627914cc29070af394ceadf44f202052396ac2b7744fbd0f7078a33b45c25",
    "js/plugins/MPP_EncounterEffect.js": "c4364c06ba9c5e4d08693888f4343141952cec4e48eea8fbae984b84be78d572",
    "js/plugins/Insertdisc5_NoRedWhenDead.js": "f877090568b6a0fac6e44e3cff285384a81578a0c687f0feceec6642be3525d4",
    "js/plugins/battlebeginoverride.js": "b4082034ce743b43f144488d43e9811545982d33263e5307e8e618297b150332",
    "js/plugins/bentelk_CombatContextHelp.js": "ee4a2cb090b2cb25e243f07fd27158ea53a3d8f423019529ff69799bb892818e",
    "js/plugins/YEP_WeaponUnleash.js": "8467835ba1b3a61b66afbfdcd51b10ab294b305f58291585dadc24d28b1aa3cf",
    "js/plugins/YEP_X_VisualHpGauge.js": "399988a63384429ebe3ad1ff642fe96aa50a39f4972c94197e929c13c218e2d8",
    "js/plugins/YEP_X_VisualATBGauge.js": "7178c83d90f656e07ea4127d40449137133020bf36803753b39ad85ab250e0e4",
    "js/plugins/WAY_Core.js": "92133d1c55765f392d0ad0dd48d978551744beb50c5ec0665b01b1c7060ebf68",
    "js/plugins/WAY_CustomFaceImageEval.js": "9093fab8a024898fd7708e6bac69ca6d052d78f81d715f4928597d245faba290",
    "js/plugins/OrangeHud.js": "e8c342eba6a162097b9500e7a6c4cf46beea9cf665a49d7f1ca61e6e20f8dd65",
    "js/plugins/OrangeHudLine.js": "ae2faa1b5e03da871befc2ea5d0a11f71191408eb7cdccb3cbf7fac954e38ee8",
    "js/plugins/OrangeHudVariableIcon.js": "15c47f5da7659952a07f53dff699d14aa8d1d7321275da378800923971ebb532",
    "js/plugins/Irina_VisualNovelBusts.js": "010e839e6e25cb6dc72d632695b5f49a1a590a45d0a0c9b97b4687ba8d17531d",
    "js/plugins/Olivia_AnimatedPictures.js": [
      "0a3937d2aaf270f45fd86093f42b59cbdca1579f19ebed898729adec0e769f77",
      "a1e3bb3d6861ed8901ddf19fa91bbd8dfc9923d1f813b4a92f0ceec431354905"
    ],
    "js/plugins/Olivia_HorrorEffects.js": "5a8952f68c4c4eebb2aca7df3c8f67174c6dff77bce69aa5e7343831215ba967",
    "js/plugins/HIME_StateChangeAnimations.js": "3c217fbc4a29a019279d9e7ff156100e46ac3584cee1b71428ff8e392726b6b1",
    "js/plugins/MOG_SceneMenu.js": "fda61b754a3014fef259edfcc8c1546297c33ab1289b6590d464d85ae1729a63",
    "js/plugins/YEP_MainMenuManager.js": "5d6e411471d53aa1c7bca9b75cf948059a32b03fe52ea9c3e2ef29e69294a3eb",
    "js/plugins/YEP_CommonEventMenu.js": "7dec452c2bd7074882d4ffc8139d4ddbe02a284f5263175fff976def5d081237",
    "js/plugins/YEP_X_CEMSetupPack2.js": "2633e6ff24c46c43f3f6a3f8fbd2b1cdccb610721e6d8fc65a3a2bfa2a4f5ad6",
    "js/plugins/Insertdisc5_ItemWindowUpdate.js": "07f285c3a1097f80ca2c0d384f6185c751b78c24b8dc6a4e0af5bb031a029ac5",
    "js/plugins/MOG_CursorBorder.js": "1521356f799ddc812413fd23f29166680637a38a7cea718055cf2de8f502c3ef",
    "js/plugins/Insertdisc5_changeDisableOpacity.js": "fd5e8552a910fcc1d7eb25e65a6ca85ee9ba1da4d40ee698aea36c5bc9f58a5e",
    "js/plugins/Insertdisc5_ChangeHealWindow.js": "9cf03da8fa9b9a340e460ab373d7722618a3c16b8a6282a4a41fa58186ca503b",
    "js/plugins/SRD_BattleStatusCustomizer.js": "27a5d969eaac2420efbe5bef9b4083be967c06c4ba0f264441465ae729cab4da",
    "js/plugins/SRD_BattleStatusCustomizer_Part2.js": "6363fbcfdbbeac705ba2358b26b150421547b6535267915ea486e2483dd84304",
    "js/plugins/YEP_BattleStatusWindow.js": "9ccbfe602c74f1fa2f2cf6d69b20950b580c9f8deac08838317c2572d6ec23f5",
    "js/plugins/BattleLogToMessage.js": "475d1061b5fdf7590e00b7ba0c8f010fd75356a35e00c95e436a2260721111ae",
    "js/plugins/YEP_X_MessageMacros1.js": "85830640706c7ebc27ce1a3f478a9959f70a78115b5cf83f2e2230a71e43ea04",
    "js/plugins/GALV_CharacterAnimations.js": "d944b0997d5983bbab2ac713875b7784db4930951828367ac5524939449eca7b",
    "js/plugins/YEP_EventCopier.js": "9e8452454a926079589ebec9e8f7647c66eacc796429e2afec2fad1208af7b48",
    "js/plugins/MOG_Weather_EX.js": "8013c4b81976dee8520e1732dec1bd18a6fa45ac28bd2d1a48a6773d3e4604b5",
    "js/plugins/Foreground.js": "88885a6e93e3e11a035186a59e7c574588362eeec7d2bd090e462189a4c36cd1",
    "js/plugins/YEP_MoveRouteCore.js": "c157fcd2e25a2960bc23645b6cc848bfd130f23d4f8370c3014ce9caba932276",
    "js/plugins/OrangeEventHitboxes.js": "7a756f201aa2f56f81a36551ec094b4cb640612081d95ffc9d61a1b753165e0e",
    "js/plugins/YEP_EventChasePlayer.js": "800083526c91a7879ad69f6c7498b01cbb2ef8c63adf8254ae6fa6591f29c0a6",
    "js/plugins/YEP_StopMapMovement.js": "ca5968011dfec8c3abbca9445209657c6d8bcd9e833105c02ea7202b1056932e",
    "js/plugins/Tyruswoo_FollowerControl.js": "9badd2533fceb45bb0a51f20c372eb5f3786c1ed2e0c763c95c1676cda3946ae",
    "js/plugins/HIME_GuestFollowers.js": "44c0939f4011250162ef46e5676a2c1fc5a669d58dec455b01b6d014381adcad",
    "js/plugins/Insertdisc5_changeBalloonPosition.js": "65507185d4f0ec3fffb44c77b7543488db33487209e3c14ea367d911db5e0db5",
    "js/plugins/Insertdisc5_waitFF.js": "05906b48bf1856b1737af45adf627e67d76be39e998a23993acd2e2c3ab64f25",
    "js/plugins/YEP_ItemCore.js": "26a6f756bad0d7f606a3ec3251b6dea986e415c19dda6677a048ac7790df340e",
    "js/plugins/YEP_X_ItemCategories.js": "f262f74be7ea34e898c746904344e0c5bf9b1b3efb2cd6056cffdfac13ad6a2f",
    "js/plugins/YEP_X_ItemRequirements.js": "82155313f5bb75deb5e5cbb4ba01de94372bee7d4306c520a0560bc3e243aac8",
    "js/plugins/MrTS_HideQuantities.js": "67824e92e72739c23ebbab919114325e6c4ac513e3d0929879d0352f4c25ffd3",
    "js/plugins/ALOE_ItemSkillSortPriority.js": "ce2f2516629f549f38899b8dc38b0a14b2172eab01ce6bc630e3375f062fc5c2",
    "js/plugins/YEP_EquipCore.js": "d0c4f99785b9e82fa63553b7474d2ddc9a5d23c5e73d09d147d604e03809a6a1",
    "js/plugins/Insertdisc5_noOptimize.js": "66808352597ba7f5b3f626e4ded3ba3fb2fe6503c6908e6dd7a4928a398429b1",
    "js/plugins/Insertdisc5_changeSkillStatusWindow.js": "cc72fed8189f5a37b9337f84ea88abc03fbe7a70ac5510b7f77833444dcddbbb",
    "js/plugins/YEP_X_AttachAugments.js": "ec89be2fd260af58bd90d134807463570814d2b1adccc20ef265dca8e9afd6cb",
    "js/plugins/Arisu_SealedBattleCommands.js": "022572510b292fee9465cf21f500b23d920116e48b072f0ec6123d2758f77c71",
    "js/plugins/Caethyril_MaxLevelRestriction.js": "b854246fed739398614e6e4558f7ffe2e462a1fa9fe1a48049832dafed86b096",
    "js/plugins/MultiLineChoices.js": "c3890970d06aaf27cf958f7c90598a9d70da49b15b891d9c206998a25e347036",
    "js/plugins/HIME_HMSChoiceDisplayMode.js": "692623818819e6d6d6642da2e3515e135a14aa46231abe282107c4d3f7a614c1",
    "js/plugins/ALOE_ConditionalChoices.js": "2af44cf98c678c2ef3bc41271f4bc67378c71b4fd4959d93529ad6647bb09e23",
    "js/plugins/YEP_SelfSwVar.js": "6298a2ce8a22c4ffad789cd339974cdc81dd92864177f2a6cb93c3d6fda0d395",
    "js/plugins/HIME_LargeChoices.js": "dc7b5fde79de6587b62a06518c3394ab05b45246044b41ee213eacd5f9f7d3e8",
    "js/plugins/ALOE_YEP_MenuParameterControl.js": "d385224c91f09ce61950c1000e2df22716c1c59ed93e7e0f6f20a16ccec6f8dd",
    "js/plugins/SRD_ShakingText_switchfix.js": "94bd7ffac103ff007a736e0caec5db5b2dc2460f161a5977b71d781fd2a5dfa6",
    "js/plugins/TDDP_NoFastForward.js": "cb6458abb4055f076ccc75e6de74588ff7fbd42b1a9aababaa9a02bb23000990",
    "js/plugins/master2015hp_InStarTimeSnippet.js": [
      "93804bde48b99b3618f48a11953b25cd4c05aa97f436e348fc755c8c1a84a873",
      "2ed857c443dcb572a5212c67d3ffa0cc9ce994fe379ed67aa994207a6322ef88"
    ],
    "js/plugins/master2015hp_snippetrev.js": "c5db1e8adc4ccfbec70eba3c5ef5afb9d8a9622ee8c5c169fa9961f5dfa7b514",
    "js/plugins/OrangeGreenworks.js": "0a77e00ad1008f10df8a4376cef7860ca63e826a1503c07b0a95764a4b47d5f5",
    "js/plugins/SRD_TranslationEngine.js": "a841a7761419a0cbd9dab13fe75c9d954f9af381cb3f0fdb56f54065d7e6c40d",
    "js/plugins/preventf12.js": "2f828d79e94bbe5482e9c4d5b6f69a80bd1f2b54cc32a95f24ab2fa1e54333a9",
    "js/plugins/StrangeWill_ChangeVolume.js": "b4277a92507e819509ab0f1898f64e9aae2e623a3ccd9277ecdb1547a3063e62",
    "js/plugins/RG19.js": "a1f4474b1b4528d3c50b574e8e73c00834ac93d10421ccd1b75404d609ab058a"
  };


  function hash(text) {
    return __pmjsBuiltinRequire('crypto').createHash('sha256')
      .update(text.replace(/\r\n/g, '\n')).digest('hex');
  }
  function matchesSource(file, source) {
    var expected = sources[file];
    if (!expected || typeof source !== 'string') return false;
    return (Array.isArray(expected) ? expected : [expected]).indexOf(hash(source)) >= 0;
  }
  PMJS.isatSourceMatches = matchesSource;
  PMJS.isatMethodHash = function(method) {
    return typeof method === 'function' && hash(Function.prototype.toString.call(method));
  };

  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.source-qualification', function() {
    function refuse(reason) {
      PMJS.isatSourceQualification = Object.freeze({ verified: false, reason: reason });
    }
    try {
      var checked = new Set();
      function verify(file) {
        if (checked.has(file)) return;
        var source = NativeHost.fs.readText(file);
        if (!matchesSource(file, source)) {
          throw Error('unreviewed source: ' + file);
        }
        checked.add(file);
      }
      ['rpg_core', 'rpg_managers', 'rpg_objects', 'rpg_scenes', 'rpg_sprites', 'rpg_windows'].forEach(function(name) {
        verify('js/' + name + '.js');
      });
      $plugins.forEach(function(plugin) {
        if (plugin.status) verify('js/plugins/' + plugin.name + '.js');
      });
    } catch (error) { return refuse(String(error.message || error)); }

    var dataHashes = {
      'data/Map030.json': '628daf9c24481f2a2cf1155dc735b6e1de097c7ecd216c95ea7c917821d63b8c',
      'data/CommonEvents.json': '24b75465d82a74c5cffc373bde9abd75d5dde4d0940e2217599585e1d1e6e279'
    };
    var dataReason = null;
    try {
      for (var file in dataHashes) {
        if (hash(NativeHost.fs.readText(file)) !== dataHashes[file]) throw Error('unreviewed ' + file);
      }
    } catch (error) { dataReason = String(error.message || error); }
    PMJS.isatSourceQualification = Object.freeze({ verified: true,
      dormontDataVerified: dataReason === null, dormontDataReason: dataReason });
  });
})();
