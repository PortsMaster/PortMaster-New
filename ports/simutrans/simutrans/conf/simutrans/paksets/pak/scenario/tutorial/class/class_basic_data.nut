/**
 *   @file class_basic_data.nut
 *   @brief sets the pakset specific data
 *
 *  all object names correspond to the names in the dat files
 *
 */

// placeholder for tools names in simutrans
tool_alias  <- {inspe = "Abfrage", road= "ROADTOOLS", rail = "RAILTOOLS", ship = "SHIPTOOLS", land = "SLOPETOOLS", spec = "SPECIALTOOLS"}

// placeholder for good names in pak64
good_alias  <- {mail = "Post", passa= "Passagiere", goods = "Goods", wood = "Holz", plan = "Bretter", coal = "Kohle", oel = "Oel" , gas = "Gasoline"}

// placeholder for shortcut keys names
  switch (pak_name) {
    case "pak64":
      key_alias  <- {plus_s = "+", minus_s = "-"}
      break
    case "pak64.german":
      key_alias  <- {plus_s = "+", minus_s = "-"}
      break
    case "pak128":
      key_alias  <- {plus_s = "Home", minus_s = "End"}
      break
  }

factory_data <- {}
function get_factory_data(id) {
  local t = factory_data.rawget(id)
  return t
}

/*
 *  rename factory names
 *  translate object name in to language by start scenario
 *
 *  set factory data
 */
function rename_factory_names() {

  local list = factory_list_x()
  foreach(factory in list) {
    // factory is an instance of the factory_x class
    local f_tile = factory.get_tile_list()
    local f_name = factory_x(f_tile[0].x, f_tile[0].y).get_desc().get_name()
    //gui.add_message("Current: "+factory_x(f_tile[0].x, f_tile[0].y).get_desc().get_name()+" translate: "+translate(f_name))

    factory_x(f_tile[0].x, f_tile[0].y).set_name(translate(f_name))

    if ( f_tile[0].x == 123 && f_tile[0].y == 160 ) {
      // Timber plantation
      //translate_objects_list.rawset("fac_1_name", translate(f_name))
      local t = factory_x(f_tile[0].x, f_tile[0].y).get_tile_list()
      local f = factory_x(f_tile[0].x, f_tile[0].y).get_fields_list()
      t.extend(f)

      factory_data.rawset("1", {name = translate(f_name), c_list = t, c = coord(f_tile[0].x, f_tile[0].y)})
      /*local d = factory_data.rawget("1")
      gui.add_message("factory_data rawin: "+factory_data.rawin("1"))
      gui.add_message("factory_data d.rawin: "+d.rawget("c_list"))
      //factory_data.1.rawset(")*/
    }
    if ( f_tile[0].x == 93 && f_tile[0].y == 153 ) {
      // Saw mill
      translate_objects_list.rawset("fac_2_name", translate(f_name))
      local t = factory_x(f_tile[0].x, f_tile[0].y).get_tile_list()
      factory_data.rawset("2", {name = translate(f_name), c_list = t, c = coord(f_tile[0].x, f_tile[0].y)})
    }
    if ( f_tile[0].x == 110 && f_tile[0].y == 190 ) {
      // Construction Wholesaler
      translate_objects_list.rawset("fac_3_name", translate(f_name))
      local t = factory_x(f_tile[0].x, f_tile[0].y).get_tile_list()
      factory_data.rawset("3", {name = translate(f_name), c_list = t, c = coord(f_tile[0].x, f_tile[0].y)})
    }
    if ( f_tile[0].x == 168 && f_tile[0].y == 189 ) {
      // Oil rig
      translate_objects_list.rawset("fac_4_name", translate(f_name))
      local t = factory_x(f_tile[0].x, f_tile[0].y).get_tile_list()
      factory_data.rawset("4", {name = translate(f_name), c_list = t, c = coord(f_tile[0].x, f_tile[0].y)})
    }
    if ( f_tile[0].x == 149 && f_tile[0].y == 200 ) {
      // Oil refinery
      translate_objects_list.rawset("fac_5_name", translate(f_name))
      local t = factory_x(f_tile[0].x, f_tile[0].y).get_tile_list()
      factory_data.rawset("5", {name = translate(f_name), c_list = t, c = coord(f_tile[0].x, f_tile[0].y)})
    }
    if ( f_tile[0].x == 112 && f_tile[0].y == 192 ) {
      // Gas station
      translate_objects_list.rawset("fac_6_name", translate(f_name))
      local t = factory_x(f_tile[0].x, f_tile[0].y).get_tile_list()
      factory_data.rawset("6", {name = translate(f_name), c_list = t, c = coord(f_tile[0].x, f_tile[0].y)})
    }
    if ( f_tile[0].x == 131 && f_tile[0].y == 235 ) {
      // Coal mine
      translate_objects_list.rawset("fac_7_name", translate(f_name))
      local t = factory_x(f_tile[0].x, f_tile[0].y).get_tile_list()
      factory_data.rawset("7", {name = translate(f_name), c_list = t, c = coord(f_tile[0].x, f_tile[0].y)})
    }
    if ( f_tile[0].x == 130 && f_tile[0].y == 207 ) {
      // Coal power station
      translate_objects_list.rawset("fac_8_name", translate(f_name))
      local t = factory_x(f_tile[0].x, f_tile[0].y).get_tile_list()
      factory_data.rawset("8", {name = translate(f_name), c_list = t, c = coord(f_tile[0].x, f_tile[0].y)})
    }

  }
      /*
      gui.add_message("factory_data rawin 1: "+factory_data.rawin("1"))
      gui.add_message("factory_data rawin 2: "+factory_data.rawin("2"))
      gui.add_message("factory_data rawin 3: "+factory_data.rawin("3"))
      gui.add_message("factory_data rawin 4: "+factory_data.rawin("4"))
      gui.add_message("factory_data rawin 5: "+factory_data.rawin("5"))
      gui.add_message("factory_data rawin 6: "+factory_data.rawin("6"))
      gui.add_message("factory_data rawin 7: "+factory_data.rawin("7"))
      gui.add_message("factory_data rawin 8: "+factory_data.rawin("8"))
      */

}

/*
 *  translate objects
 *
 *
 */
function translate_objects() {

  //translate_objects_list.inspec <- translate("Abfrage")
  translate_objects_list.rawset("inspec", translate("Abfrage"))

  translate_objects_list.rawset("tools_road", translate("ROADTOOLS"))
  translate_objects_list.rawset("tools_rail", translate("RAILTOOLS"))
  translate_objects_list.rawset("tools_ship", translate("SLOPETOOLS"))
  translate_objects_list.rawset("tools_special", translate("SPECIALTOOLS"))
  translate_objects_list.rawset("tools_slope", translate("SLOPETOOLS"))

  translate_objects_list.rawset("depot_road", translate("CarDepot"))
  translate_objects_list.rawset("depot_rail", translate("TrainDepot"))
  translate_objects_list.rawset("depot_ship", translate("ShipDepot"))
  translate_objects_list.rawset("depot_air", translate("1930AirDepot"))

  translate_objects_list.rawset("good_goods", translate("Goods"))

  translate_objects_list.rawset("good_mail", translate("Post"))
  translate_objects_list.rawset("good_passa", translate("Passagiere"))
  translate_objects_list.rawset("good_wood", translate("Holz"))
  translate_objects_list.rawset("good_plan", translate("Bretter"))
  translate_objects_list.rawset("good_coal", translate("Kohle"))
  translate_objects_list.rawset("good_oil", translate("Oel"))
  translate_objects_list.rawset("good_gas", translate("Gasoline"))

  // set toolbar with powerline tools
  if ( pak_name == "pak64.german" ) {
    translate_objects_list.rawset("tools_power", translate("POWERLINE"))
  } else {
    translate_objects_list.rawset("tools_power", translate("SPECIALTOOLS"))
  }
  //gui.add_message("Current: "+translate_objects_list.inspec)

  rename_factory_names()
}

/*
 *  set vehicle for chapter 2 step 4
 *
 */
function get_veh_ch2_st4() {
  switch (pak_name) {
    case "pak64":
      return "BuessingLinie"
      break
    case "pak64.german":
      return "OpelBlitz"
      break
    case "pak128":
      return "S_Kroytor_LiAZ-677"
      break
  }

}

/*
 *  set objects for chapter 2
 *
 *  id 1 = way name
 *  id 2 = bridge name
 *  id 3 = stations name
 *  id 4 = depot name
 *
 */
function get_obj_ch2(id) {
  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return "mip_cobblestone_road"
          break
        case 2:
          return "tb_classic_road"
          break
        case 3:
          return "BusStop"
          break
        case 4:
          return "CarDepot"
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return "asphalt_road"
          break
        case 2:
          return "ClassicRoad"
        break
        case 3:
          return "BusHalt_1"
          break
        case 4:
          return "CarDepot"
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return "Road_050"
          break
        case 2:
          return "Road_070_Bridge"
          break
        case 3:
          return "medium_classic_bus_stop"
          break
        case 4:
          return "CarDepot"
          break
      }
      break
  }
}

/*
 *  set vehicle for chapter 3
 *
 *  id 1 = step 5 loco
 *  id 2 = step 7 loco
 *  id 3 = step 11 loco
 *  id 4 = step 4 wag
 *  id 5 = step 7 wag
 *  id 6 = step 11 wag
 *
 */
function get_veh_ch3(id) {
  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return "3Diesellokomotive"
          break
        case 2:
          return "3Diesellokomotive"
          break
        case 3:
          return "NS1000"
          break
        case 4:
          return "Holzwagen"
          break
        case 5:
          return "Holzwagen"
          break
        case 6:
          return "TPPassagierwagen"
          break
      }
    break
    case "pak64.german":
      switch (id) {
        case 1:
          return "1Diesellokomotive"
          break
        case 2:
          return "1Diesellokomotive"
          break
        case 3:
          return "E41"
          break
        case 4:
          return "Bretterwagen"
          break
        case 5:
          return "Bretterwagen"
          break
        case 6:
          return "Bn_original"
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return "Haru_F7A"
          break
        case 2:
          return "Haru_F7A"
          break
        case 3:
          return "Renfe_279_(Benemerita)"
          break
        case 4:
          return "Holzwagen_0"
          break
        case 5:
          return "Holzwagen_0"
          break
        case 6:
          return "Passanger_waggon_2"
          break
      }
    break
  }

}

/*
 *  set objects for chapter 3
 *
 *  id 1 = way name
 *  id 2 = bridge name
 *  id 3 = stations name
 *  id 4 = depot name
 *  id 5 = tunnel name
 *  id 6 = signal name
 *  id 7 = overheadpower name
 *
 */
function get_obj_ch3(id) {
  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return "wooden_sleeper_track"
          break
        case 2:
          return "ClassicRail"
          break
        case 3:
          return "FreightTrainStop"
          break
        case 4:
          return "TrainDepot"
          break
        case 5:
          return "RailTunnel"
          break
        case 6:
          return "Signals"
          break
        case 7:
          return "SlowOverheadpower"
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return "Gleis_140"
          break
        case 2:
          return "ClassicRail"
        break
        case 3:
          return "MHzPS2FreightTrainStop"
          break
        case 4:
          return "TrainDepot"
          break
        case 5:
          return "RailTunnel_2"
          break
        case 6:
          return "Signals"
          break
        case 7:
          return "SlowOverheadpower"
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return "Rail_140_Tracks"
          break
        case 2:
          return "Rail_100_Bridge"
          break
        case 3:
          return "Container1TrainStop"
          break
        case 4:
          return "TrainDepot"
          break
        case 5:
          return "Rail_140_Tunnel"
          break
        case 6:
          return "Signals"
          break
        case 7:
          return "grey_type_catenary"
          break
      }
      break
  }
}

/*
 *  set vehicle for chapter 4
 *
 *  id 1 = step 4 ship
 *  id 2 = step 7 ship
 *
 */
function get_veh_ch4(id) {
  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return "EnCo_Oil_Ship"
          break
        case 2:
          return "SlowFerry"
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return "Oeltankschiff"
          break
        case 2:
          return "Ferry"
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return "MHz-OT5_Oil_Barge"
          break
        case 2:
          return "MV_Balmoral"
          break
      }
    break
  }

}

/*
 *  set objects for chapter 4
 *
 *  id 1 = way name
 *  id 2 = harbour 1 name (good)
 *  id 3 = cannel stop name
 *  id 4 = harbour 2 name (passenger)
 *  id 5 = depot name
 *
 */
function get_obj_ch4(id) {
  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return "Kanal"
          break
        case 2:
          return "LargeShipStop"
          break
        case 3:
          return "ChannelStop"
          break
        case 4:
          return "ShipStop"
          break
        case 5:
          return "ShipDepot"
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return "Kanal"
          break
        case 2:
          return "LargeShipStop"
        break
        case 3:
          return "ChannelStop"
          break
        case 4:
          return "ShipStop"
          break
        case 5:
          return "ShipDepot"
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return "canal_020"
          break
        case 2:
          return "Long_Goods_Dock"
          break
        case 3:
          return "canal_ware_stop"
          break
        case 4:
          return "ShipStop"
          break
        case 5:
          return "ShipDepot"
          break
      }
      break
  }
}

/*
 *  set vehicle for chapter 5
 *
 *  id 1 = step 2 truck (coal)
 *  id 2 = step 2 truck trail (coal)
 *  id 3 = step 4 truck (post)
 *  id 4 = step 4 ship (post)
 *
 */
function get_veh_ch5(id) {
  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return "Kohletransporter"
          break
        case 2:
          return "Kohleanhaenger"
          break
        case 3:
          return "Posttransporter"
          break
        case 4:
          return "Postschiff"
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return "Buessing_B8000_catg2"
          break
        case 2:
          return "anhaenger_catg2"
          break
        case 3:
          return "Post_Opel"
          break
        case 4:
          return "Tugboat"
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return "PMNV_50_Mack"
          break
        case 2:
          return "PMNV_Mack_Bulk_Trailer_0"
          break
        case 3:
          return "RVg_Post_Truck_1"
          break
        case 4:
          return "Post_Barge"
          break
      }
      break
  }

}

/*
 *  set objects for chapter 5
 *
 *  id 1 = road way name
 *  id 2 = truck stop name (good)
 *  id 3 = powerline way name
 *  id 4 = powerline transformer
 *  id 5 = depot name
 *  id 6 = post extension name
 *
 */
function get_obj_ch5(id) {
  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return "asphalt_road"
          break
        case 2:
          return "CarStop"
          break
        case 3:
          return "Powerline"
          break
        case 4:
          return "Aufspanntransformator"
          break
        case 5:
          return "CarDepot"
          break
        case 6:
          return "PostOffice"
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return "asphalt_road"
          break
        case 2:
          return "LKW_Station_1"
        break
        case 3:
          return "Powerline"
          break
        case 4:
          return "Aufspanntransformator" //PowerSource
          break
        case 5:
          return "CarDepot"
          break
        case 6:
          return "SmallPostOffice"
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return "Road_070"
          break
        case 2:
          return "CarStop"
          break
        case 3:
          return "Powerline"
          break
        case 4:
          return "Aufspanntransformator"
          break
        case 5:
          return "CarDepot"
          break
        case 6:
          return "PostOffice"
          break
      }
      break
  }
}

/*
 *  set vehicle for chapter 6
 *
 *  id 1 = step 2 airplane (passenger)
 *  id 2 = step 3 bus
 *  id 3 = step 4 bus
 *
 */
function get_veh_ch6(id) {
  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return "Fokker_F27"
          break
        case 2:
          return "BuessingLinie"
          break
        case 3:
          return "BuessingLinie"
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return "DC-3"
          break
        case 2:
          return "OpelBlitz"
          break
        case 3:
          return "OpelBlitz"
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return "SAC-Lockheed_Constellation_128_set"
          break
        case 2:
          return "S_Kroytor_LiAZ-677"
          break
        case 3:
          return "S_Kroytor_LiAZ-677"
          break
      }
      break
  }

}

/*
 *  set objects for chapter 6
 *
 *  id 1 = runway name
 *  id 2 = taxiway name
 *  id 3 = air stop name
 *  id 4 = air extension name
 *  id 5 = air depot name
 *  id 6 = road depot name
 *
 */
function get_obj_ch6(id) {
  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return "runway_modern"
          break
        case 2:
          return "taxiway"
          break
        case 3:
          return "AirStop"
          break
        case 4:
          return "Tower1930"
          break
        case 5:
          return "1930AirDepot"
          break
        case 6:
          return "CarDepot"
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return "runway_modern"
          break
        case 2:
          return "taxiway"
        break
        case 3:
          return "AirStop"
          break
        case 4:
          return "Tower1930"
          break
        case 5:
          return "1930AirDepot"
          break
        case 6:
          return "CarDepot"
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return "runway_modern"
          break
        case 2:
          return "air_movement_area"
          break
        case 3:
          return "AirStop_AirportBlg"
          break
        case 4:
          return "Terminal1950_AirportBlg_S"
          break
        case 5:
          return "1940AirDepot"
          break
        case 6:
          return "CarDepot"
          break
      }
      break
  }
}

/*
 *  set count wg for train
 *
 *  id 1 - chapter 3 : train good Holz
 *  id 2 - chapter 3 : train good Bretter
 *  id 3 - chapter 3 : train good Passagiere
 *
 */
function set_train_lenght(id) {

  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return 5
          break
        case 2:
          return 5
        break
        case 3:
          return 7
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return 4
          break
        case 2:
          return 4
        break
        case 3:
          return 5
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return 5
          break
        case 2:
          return 5
        break
        case 3:
          return 7
          break
      }
      break
  }
}

/*
 *  set transportet goods
 *
 *  id 1 - chapter 3 : train good Holz
 *  id 2 - chapter 3 : train good Bretter
 *  id 3 - chapter 7 : bus city Hepplock
 *  id 4 - chapter 7 : bus city Appingbury
 *  id 5 - chapter 7 : bus city Hillcross
 *  id 6 - chapter 7 : bus city Springville
 *
 */
function set_transportet_goods(id) {

  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return 60
          break
        case 2:
          return 30
        break
        case 3:
          return 20
          break
        case 4:
          return 40
          break
        case 5:
          return 80
          break
        case 6:
          return 160
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return 120
          break
        case 2:
          return 150
        break
        case 3:
          return 35
          break
        case 4:
          return 48
          break
        case 5:
          return 27
          break
        case 6:
          return 55
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return 60
          break
        case 2:
          return 30
        break
        case 3:
          return 20
          break
        case 4:
          return 40
          break
        case 5:
          return 80
          break
        case 6:
          return 160
          break
      }
      break
  }

}

/*
 *  set loading capacity
 *
 *  id 1 - chapter 2 step 4 : bus city Pollingwick
 *  id 2 - chapter 2 step 6 : bus Pollingwick - Dock
 *  id 3 - chapter 2 step 7 : bus Pollingwick - Malliby
 *
 */
function set_loading_capacity(id) {

  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return 100
          break
        case 2:
          return 100
          break
        case 3:
          return 100
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return 60
          break
        case 2:
          return 60
          break
        case 3:
          return 60
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return 100
          break
        case 2:
          return 100
          break
        case 3:
          return 100
          break
      }
      break
  }

}

/*
 *  set waiting time
 *
 *  id 1 - chapter 2 step 4 : bus city Pollingwick
 *  id 2 - chapter 2 step 6 : bus Pollingwick - Dock
 *  id 3 - chapter 2 step 7 : bus Pollingwick - Malliby
 *
 *
 *  1 day   = 2115
 *  1 hour  = 88
 */
function set_waiting_time(id) {

  switch (pak_name) {
    case "pak64":
      switch (id) {
        case 1:
          return 10571
          break
        case 2:
          return 10571
          break
        case 3:
          return 10571
          break
      }
      break
    case "pak64.german":
      switch (id) {
        case 1:
          return 2115
          break
        case 2:
          return 881
          break
        case 3:
          return 2555
          break
      }
      break
    case "pak128":
      switch (id) {
        case 1:
          return 10571
          break
        case 2:
          return 10571
          break
        case 3:
          return 10571
          break
      }
      break
  }

}

/*
 *  goods def
 *
 *  id = good id
 *  select  = define return data
 *            1 = translate metric
 *            2 = raw good name
 *            3 = translate good name
 *
 */
function get_good_data(id, select = null) {

  local good_n = null

      switch (id) {
        case 1:
          good_n = "Holz"
          break
        case 2:
          good_n = "Bretter"
          break
        case 3:
          good_n = "Oel"
          break
        case 4:
          good_n = "Gasoline"
          break
        case 5:
          good_n = "Kohle"
          break
      }

  local obj = good_desc_x(good_n)
  local output = null

      switch (select) {
        case 1:
          output = translate(obj.get_metric())
          break
        case 2:
          output = obj.get_name()
          break
        case 3:
          output = translate(obj.get_name())
          break
        case 4:

          break
        case 5:

          break
      }

  return output
}

/*
 *  factory prod and good data for textfiles
 *
 *  tile = tile_x factory
 *  g_id = good name
 *  read = "in" / "out"
 *
 *  return array[base_production, base_consumption, factor]
 */
 function read_prod_data(tile, g_id, read = null) {

  // actual not read good data
  local t = square_x(tile.x, tile.y).get_ground_tile()
  local good = get_good_data(g_id, 2)

  local obj = t.find_object(mo_building).get_factory()
  local obj_desc = obj.get_desc()

  local output = [0, 0, 0]

  if ( read == "in" ) {
    foreach(key,value in obj.input) {
      // print raw name of the good
      //gui.add_message("Input slot key: " + key)
      // print current storage
      if ( key == good ) {
        //gui.add_message("get_base_production(): " + value.get_base_production())
        //gui.add_message("get_base_consumption(): " + value.get_base_consumption())
        //gui.add_message("get_consumption_factor(): " + value.get_consumption_factor())

        output[0] = value.get_base_production()
        output[1] = value.get_base_consumption()
        output[2] = value.get_consumption_factor()

        break
      }
    }
  }

  if ( read == "out" ) {
    foreach(key,value in obj.output) {
      // print raw name of the good
      //gui.add_message("Output slot key: " + key)
      // print current storage
      if ( key == good ) {
        //gui.add_message("get_base_production(): " + value.get_base_production())
        //gui.add_message("get_base_consumption(): " + value.get_base_consumption())
        //gui.add_message("get_production_factor(): " + value.get_production_factor())

        output[0] = value.get_base_production()
        output[1] = value.get_base_consumption()
        output[2] = value.get_production_factor()

        break
      }
    }
  }

  return output

 }

function get_info_file(txt_file) {

  //ttextfile("info/build_bridge.txt")
  switch (pak_name) {
    case "pak64":
      switch (txt_file) {
        case "bridge":
          return ""
          break
        case "tunnel":
          return ""
          break
        case "info":
          return ttextfile("info/info_pak64.txt")
          break
      }
      break
    case "pak64.german":
      switch (txt_file) {
        case "bridge":
          return ""
          break
        case "tunnel":
          return ""
          break
        case "info":
          return ttextfile("info/info_pak64perman.txt")
          break
      }
      break
    case "pak128":
      switch (txt_file) {
        case "bridge":
          return ttextfile("info/build_bridge_128.txt")
          break
        case "tunnel":
          return ttextfile("info/build_tunnel_128.txt")
          break
        case "info":
          return ttextfile("info/info_pak128.txt")
          break
      }
      break
  }

}
