/*
 *  class chapter_04
 *
 *
 *  Can NOT be used in network game !
 */

class tutorial.chapter_04 extends basic_chapter
{
  chapter_name  = "Setting Sail"
  chapter_coord = coord(156,190)

  startcash     = 1000000           // pl=0 startcash; 0=no reset
  gl_wt = wt_water

  //Step 4 =====================================================================================
  ch4_cov_lim1 = {a = 0, b = 0}

  //Step 5 =====================================================================================
  ch4_cov_lim2 = {a = 0, b = 0}

  //Step 7 =====================================================================================
  ch4_cov_lim3 = {a = 0, b = 0}

  c_way =  coord3d(0, 0, 0)
  cov_cir = 0

  //Step 1 =====================================================================================
  //Productor
  //fac_1 = {c = coord(168,189), c_list = null /*auto started*/, name = "" /*auto started*/, good = good_alias.oel}
  //fac_1 = factory_data.rawget("4")
  //f1_lim = {a = coord(168,189), b = coord(169,190)}

  //Fabrica
  //fac_2 = {c = coord(149,200), c_list = null /*auto started*/, name = "" /*auto started*/, good = good_alias.gas}
  //f2_lim = {a = coord(149,200), b = coord(150,201)}

  //Step 2 =====================================================================================
  //Para los muelles
  dock_list1 = [coord(151, 198)]

  //Step 3 =====================================================================================
  c_dep1 = coord(150, 190)
  d1_cnr = null //auto started

  //Step 4 =====================================================================================
  ship1_name_obj = get_veh_ch4(1)
  ship1_load = 100
  ship1_wait = 0

  sch_list1 = [coord(168, 189), coord(151, 198)]

  //Step 5 =====================================================================================
  //Para el canal acuatico
  c1_way = {a = coord3d(140,194,-3), b = coord3d(114,194,1), c = coord3d(127,194,-1)}
  c1_way_lim = {a = coord(114, 194), b = coord(140, 194)}

  //Consumidor Final
  //fac_3 = {c = coord(112,192), c_list = null /*auto started*/, name = "" /*auto started*/, good = good_alias.gas}

  d2_cnr = null //auto started
  sch_list2 = [coord(151, 198), coord(114, 194)]

  //Step 6 =====================================================================================
  sch_list3 = [coord(134,189), coord(187,141), coord(178,135)]
  dock_list2 = [coord(133,189), coord(188,141), coord(179,135)]

  //Step 7 =====================================================================================
  tur = coord(185,135)
  ship2_name_obj = get_veh_ch4(2)
  ship2_load = 100
  ship2_wait = 42282
  line1_name = "Test 5"

  //Script
  //----------------------------------------------------------------------------------
  sc_way_name = get_obj_ch4(1)
  sc_dock_name1 = get_obj_ch4(2)
  sc_dock_name2 = get_obj_ch4(3)
  sc_dock_name3 = get_obj_ch4(4)
  sc_dep_name = get_obj_ch4(5)

  function start_chapter()  //Inicia solo una vez por capitulo
  {

    if ( pak_name == "pak128" ) {
      c1_way_lim.a = coord(114, 193)
      c1_way.c = coord3d(127,193,-1)

    }

    local lim_idx = cv_list[(persistent.chapter - 2)].idx
    ch4_cov_lim1 = {a = cv_lim[lim_idx].a, b = cv_lim[lim_idx].b}
    ch4_cov_lim2 = {a = cv_lim[lim_idx+1].a, b = cv_lim[lim_idx+1].b}
    ch4_cov_lim3 = {a = cv_lim[lim_idx+2].a, b = cv_lim[lim_idx+2].b}

    d1_cnr = get_dep_cov_nr(ch4_cov_lim1.a,ch4_cov_lim1.b)
    d2_cnr = get_dep_cov_nr(ch4_cov_lim2.a,ch4_cov_lim2.b)

    local pl = 0
    if(this.step == 7){
            local c_dep = this.my_tile(c_dep1)
      local c_list = sch_list3
      start_sch_tmpsw(pl,c_dep, c_list)
    }
    return 0
  }

  function set_goal_text(text){

    local fac_1 = factory_data.rawget("4")
    local fac_2 = factory_data.rawget("5")
    local fac_3 = factory_data.rawget("6")

   switch (this.step) {
    case 1:

      if (pot0==0){
        text = ttextfile("chapter_04/01_1-2.txt")
        text.tx=ttext("<em>[1/2]</em>")
      }
      else {
        text = ttextfile("chapter_04/01_2-2.txt")
        text.tx=ttext("<em>[2/2]</em>")
      }
      break
    case 2:
      local c_list = dock_list1
      local txdoc = ""
            local dock_name = translate("Dock")
            local ok_tex = translate("OK")
      for(local j=0;j<c_list.len();j++){
        if (glsw[j]==0)
          txdoc += format("<a><st>%s %d</st>",dock_name,j+1) + c_list[j].href(" ("+c_list[j].tostring()+")")+"<br>"
        else
          txdoc += format("<em>%s %d</em>",dock_name,j+1) + " ("+c_list[j].tostring()+") <em>"+ok_tex+"</em><br>"
      }
      text.nr = c_list.len()
      text.dock = txdoc
      break
    case 3:

      break
    case 4:
      text.all_cov = d1_cnr
      text.load = ship1_load
      text.wait = get_wait_time_text(ship1_wait)
      break

    case 5:
      local c1 = coord(c1_way.a.x, c1_way.a.y)
      local c2 = coord(c1_way.b.x, c1_way.b.y)
      if(!correct_cov){
        local a = 3
        local b = 3
        text = ttextfile("chapter_04/05_"+a+"-"+b+".txt")
        text.tx=ttext("<em>["+a+"/"+b+"]</em>")
      }
      else if (pot0==0){
        local a = 1
        local b = 3
        text = ttextfile("chapter_04/05_"+a+"-"+b+".txt")
        text.tx=ttext("<em>["+a+"/"+b+"]</em>")
      }
      else if (pot1==0){
        local a = 2
        local b = 3
        text = ttextfile("chapter_04/05_"+a+"-"+b+".txt")
        text.tx=ttext("<em>["+a+"/"+b+"]</em>")
      }
      else if (pot2==0){
        local a = 3
        local b = 3
        text = ttextfile("chapter_04/05_"+a+"-"+b+".txt")
        text.tx=ttext("<em>["+a+"/"+b+"]</em>")
      }
      text.w1 = c1.href(" ("+c1.tostring()+")")+""
      text.w2 = c2.href(" ("+c2.tostring()+")")+""
      text.dock = sch_list2[1].href("("+sch_list2[1].tostring()+")")+""
      text.all_cov = d2_cnr
      text.load = ship1_load
      text.wait = get_wait_time_text(ship1_wait)

      break

    case 6:
      local list = dock_list2
      local txdoc = ""
            local dock_name = translate("Dock")
            local ok_tex = translate("OK")
      for(local j=0;j<list.len();j++){
        local c = coord(list[j].x, list[j].y)
        if (glsw[j]==0)
          txdoc += format("<a><st>%s %d</st>",dock_name,j+1) + c.href(" ("+c.tostring()+")")+"<br>"
        else
          txdoc += format("<em>%s %d</em>",dock_name,j+1) + " ("+c.tostring()+") <em>"+ok_tex+"</em><br>"
      }
      text.nr = list.len()
      text.dock = txdoc
      break

    case 7:
      local tx_list = ""
      local nr = sch_list3.len()
      local list = sch_list3
      for (local j=0;j<nr;j++){
        local c = coord(list[j].x, list[j].y)
        local tile = my_tile(c)
        local st_halt = tile.get_halt()

        if(tmpsw[j]==0 ){
          tx_list += format("<st>%s %d:</st> %s<br>", translate("Stop"), j+1, c.href(st_halt.get_name()+"("+c.tostring()+")"))
        }
        else{
          tx_list += format("<em>%s %d:</em> %s <em>%s</em><br>", translate("Stop"), j+1, st_halt.get_name(), translate("OK"))
        }
      }
      local c = coord(list[0].x, list[0].y)
      text.stnam = "1) "+my_tile(c).get_halt().get_name()+" ("+c.tostring()+")"
      text.list = tx_list
      text.ship = translate(ship2_name_obj)
      text.load = ship2_load
      text.wait = get_wait_time_text(ship2_wait)
      break

    case 8:

      break

   }
    text.dep1 = c_dep1.href("("+c_dep1.tostring()+")")+""
    text.sh = translate(ship1_name_obj)
    text.cir = cov_cir
    text.f1 = fac_1.c.href(""+fac_1.name+" ("+fac_1.c.tostring()+")")+""
    text.f3 = fac_2.c.href(""+fac_2.name+" ("+fac_2.c.tostring()+")")+""
    text.f4 = fac_3.c.href(""+fac_3.name+" ("+fac_3.c.tostring()+")")+""
    text.tur = tur.href(" ("+tur.tostring()+")")+""

    text.good1     = get_good_data(3, 3) //translate_objects_list.good_oil
    //text.g1_metric = get_good_data(3, 1)
    text.good2     = get_good_data(4, 3) //translate_objects_list.good_gas
    //text.g2_metric = get_good_data(4, 1)
    return text
  }

  function is_chapter_completed(pl) {
    local percentage=0
    save_pot()
    save_glsw()

    local fac_1 = factory_data.rawget("4")
    local fac_2 = factory_data.rawget("5")
    local fac_3 = factory_data.rawget("6")

    switch (this.step) {
      case 1:
        local next_mark = false
        local stop_mark = true
        if(pot0==0 || pot1 == 0){
          local list = fac_2.c_list
          try {
            next_mark = delay_mark_tile(list)
          }
          catch(ev) {
            return 0
          }
          if(next_mark && pot0 == 1){
            pot1=1
          }
        }
        else if (pot2==0 || pot3==0){
          local list = fac_1.c_list
          try {
            next_mark = delay_mark_tile(list)
          }
          catch(ev) {
            return 0
          }
          if(next_mark && pot2 == 1){
            pot3=1
          }
        }
        else if (pot3==1 && pot4==0){
          this.next_step()
        }
        return 5
        break;
      case 2:
        //Para los Muelles
        local siz = dock_list1.len()
        local c_list = dock_list1
        local name = translate("Build a Dock here!.")
        local good = good_alias.goods
        local label = true
        local all_stop = is_stop_building(siz, c_list, name, good, label)

        if (all_stop) {
          this.next_step()
        }

        return 5
        break;
      case 3:
        //Para Astillero
        local t1 = my_tile(c_dep1)
        local depot = t1.find_object(mo_depot_water)

        if (!depot){
          label_x.create(c_dep1, player_x(pl), translate("Build Shipyard here!."))
        }
        else{
          t1.remove_object(player_x(1), mo_label)
          pot0=1
        }
        if (pot1==1){
          this.next_step()
        }
        return 10+percentage
        break
      case 4:
        cov_cir = get_convoy_nr((ch4_cov_lim1.a), d1_cnr)

        if (cov_cir == d1_cnr){
          reset_stop_flag()
          this.next_step()
        }
        return 50
        break
      case 5:
        //Para el canal acuatico
        if (pot0==0){
          //Inicio del canal
          local c_start = coord(c1_way.a.x, c1_way.a.y)
          local t_start = my_tile(c_start)
          local way_start = t_start.find_object(mo_way)
          if (way_start && way_start.get_desc().get_topspeed()==0){
            t_start.mark()
            label_x.create(c_start, player_x(1), translate("Build Canal here!."))
          }
          else{
            t_start.unmark()
            t_start.remove_object(player_x(1), mo_label)
          }

          //Final del canal
          local c_end = coord(c1_way.b.x, c1_way.b.y)
          local t_end = my_tile(c_end)
          local way_end = t_end.find_object(mo_way)
          if (way_end &&  way_end.get_desc().get_topspeed()==0){
            t_end.mark()
            label_x.create(c_end, player_x(1), translate("Build Canal here!."))
          }
          else{
            t_end.unmark()
            t_end.remove_object(player_x(1), mo_label)
          }

          local coora = {x = c1_way.a.x, y = c1_way.a.y, z = c1_way.a.z }
          local coorb = {x = c1_way.b.x, y = c1_way.b.y, z = c1_way.b.z }

          local obj = false
          local dir = 6
          wayend = coorb
          local vel_min = 10
          local wt = gl_wt
          local fullway = update_way(coora, coorb, vel_min, wt) //test

          if (fullway.result){
            pot0=1
          }
          else
            c_way = fullway.c
        }
        //Para el cuarto muelle
        else if (pot0==1 && pot1==0){
          local t = my_tile(sch_list2[1])
          local dock4 = t.find_object(mo_building)
          public_label(t, translate("Build a Dock here!."))
          if(dock4){
            if(is_station_build(0, sch_list2[1], good_alias.goods)==null){
              t.remove_object(player_x(1), mo_label)
              pot1=1
            }
          }
        }
        //Vehiculos en circulacion
        else if (pot1==1 && pot2==0){
          cov_cir = get_convoy_nr((ch4_cov_lim2.a ), d2_cnr)

          if (cov_cir==d2_cnr)
            pot2=1
        }
        if (pot2==1 && pot3==0){
          reset_stop_flag()
          this.next_step()
        }
        return 65
        break
      case 6:
        //Para los Muelles
        local siz = dock_list2.len()
        local c_list = dock_list2
        local name = translate("Build a Dock here!.")
        local good = good_alias.passa
        local label = true
        local all_stop = is_stop_building(siz, c_list, name, good, label)

        if (all_stop) {
          this.next_step()
        }

        return 0
        break

      case 7:
                local c_dep = this.my_tile(c_dep1)
                local line_name = line1_name
                set_convoy_schedule(pl,c_dep, gl_wt, line_name)
        if(current_cov == ch4_cov_lim3.b){
          this.next_step()
        }
        return 0
        break

      case 8:
        reset_stop_flag()
        this.next_step()
        return 0
        break

      case 9:
        this.step=1
        persistent.step=1
        persistent.status.step = 1
        return 100
        break
    }
    percentage=(this.step-1)+1
    return percentage
  }

  function is_work_allowed_here(pl, tool_id, name, pos, tool) {
    glpos = coord3d(pos.x, pos.y, pos.z)
    local t = tile_x(pos.x, pos.y, pos.z)
    local ribi = 0
    local wt = 0
    local slope = t.get_slope()
    local way = t.find_object(mo_way)
    local bridge = t.find_object(mo_bridge)
    local label = t.find_object(mo_label)
    local building = t.find_object(mo_building)
    local sign = t.find_object(mo_signal)
    local roadsign = t.find_object(mo_roadsign)

    local fac_1 = factory_data.rawget("4")
    local fac_2 = factory_data.rawget("5")
    local fac_3 = factory_data.rawget("6")

    if (way){
      wt = way.get_waytype()
      if (tool_id!=4111)
        ribi = way.get_dirs()
      //if (!t.has_way(gl_wt))
        //ribi = 0
    }
    local result = translate("Action not allowed")    // null is equivalent to 'allowed'
    //glbpos = coord3d(pos.x,pos.y,pos.y)
    gltool = tool_id

    switch (this.step) {
      case 1:
        if (tool_id == 4096){
          if (pot0==0){
            local list = fac_2.c_list
            foreach(t in list){
              if(pos.x == t.x && pos.y == t.y) {
                pot0 = 1
                return null
              }
            }
          }
          else if (pot1==1){
            local list = fac_1.c_list
            foreach(t in list){
              if(pos.x == t.x && pos.y == t.y) {
                pot2 = 1
                return null
              }
            }
          }
        }
        else
          return translate("You must use the inspection tool")+" ("+pos.tostring()+")."

        break;
      //Construyendo los Muelles
      case 2:
        local c_list = dock_list1
        local good = good_alias.goods
        if((tool_id != 4096))
          return is_dock_build(pos, tool_id, c_list, good)
        break
      case 3:
        //Primer Astillero
        if (pos.x==c_dep1.x && pos.y==c_dep1.y){
          if (pot0==0){
            if (tool_id == tool_build_depot){
              pot0=1
              return null
            }
          }
          else if (pot0==1 && pot1==0){
            if (tool_id == 4096){
              pot1=1
              return null
            }
          }
        }
        else if (pot0==0)
          result = translate("Place the shipyard here")+" ("+c_dep1.tostring()+")."
        break
        //Enrutar barcos
      case 4:
        if (tool_id==4108){
          local c_list = sch_list1 //[sch_list1[1], sch_list1[0]]   //Lista de todas las paradas de autobus
          local c_dep = c_dep1 //Coordeadas del deposito
          local siz = c_list.len() //Numero de paradas
          result = translate("The route is complete, now you may dispatch the vehicle from the depot")+" ("+c_dep.tostring()+")."
          return is_stop_allowed_ex(result, siz, c_list, pos, gl_wt)
        }
        break
      case 5:
        if (pot0==0){
                    if(pos.x==c1_way.a.x && pos.y==c1_way.a.y){
                        if(tool_id==tool_remove_way || tool_id==4097)
              return result
                    }
          if (pos.x>=c1_way_lim.a.x && pos.y>=c1_way_lim.a.y && pos.x<=c1_way_lim.b.x && pos.y<=c1_way_lim.b.y){
            if (tool_id == tool_build_way && way && wt == wt_water)
              return null
          }
        }
        //Cuarto muelle
        else if(pot0==1 && pot1==0){
          if(my_tile(sch_list2[1]).find_object(mo_building)){
            if (tool_id==4097)
              return null
            if (is_station_build(0, sch_list2[1], good_alias.goods)!=null)
              return format(translate("Dock No.%d must accept goods"),4)+" ("+sch_list2[1].tostring()+")."
          }
          if(pos.x==sch_list2[1].x && pos.y==sch_list2[1].y){
            if(tool_id==tool_build_station){
              return null
            }
          }
        }
        //Enrutar Barcos
        else if (pot1==1 && pot2==0){
          if (tool_id==4108){
            local c_list = sch_list2   //Lista de todas las paradas de autobus
            local c_dep = c_dep1 //Coordeadas del deposito
            local siz = c_list.len() //Numero de paradas
            result = translate("The route is complete, now you may dispatch the vehicle from the depot")+" ("+c_dep.tostring()+")."
            return is_stop_allowed_ex(result, siz, c_list, pos, gl_wt)
          }
        }
        break

      case 6:

        local c_list = dock_list2
        local good = good_alias.passa
        if((tool_id != 4096))
          return is_dock_build(pos, tool_id, c_list, good)

        break

      case 7:
        if (tool_id==4108){
          local c_list = sch_list3 //Lista de todas las paradas de autobus
          local c_dep = c_dep1 //Coordeadas del deposito
          local siz = c_list.len()//Numero de paradas
          result = translate("The route is complete, now you may dispatch the vehicle from the depot")+" ("+c_dep.tostring()+")."
          return is_stop_allowed_ex(result, siz, c_list, pos, gl_wt)
        }
        break
    }
    if (tool_id == 4096){
      if (label && label.get_text()=="X")
        return translate("Indicates the limits for using construction tools")+" ("+pos.tostring()+")."
      else if (label)
        return translate("Text label")+" ("+pos.tostring()+")."
      result = null // Always allow query tool
    }
    if (label && label.get_text()=="X")
      return translate("Indicates the limits for using construction tools")+" ("+pos.tostring()+")."

    return result
  }

  function is_schedule_allowed(pl, schedule) {
    local result=null // null is equivalent to 'allowed'
    local nr =  schedule.entries.len()
    switch (this.step) {
      case 4:
        local selc = 0
        local load = ship1_load
        local time = ship1_wait
        local c_list = sch_list1 //[sch_list1[1], sch_list1[0]]
        local siz = c_list.len()
        return set_schedule_list(result, pl, schedule, nr, selc, load, time, c_list, siz)
      break
      case 5:
        local selc = 0
        local load = ship1_load
        local time = ship1_wait
        local c_list = sch_list2
        local siz = c_list.len()
        return set_schedule_list(result, pl, schedule, nr, selc, load, time, c_list, siz)
      break
      case 7:
        local selc = 0
        local load = ship2_load
        local time = ship2_wait
        local c_list = sch_list3
        local siz = c_list.len()
        local line = true
        result = set_schedule_list(result, pl, schedule, nr, selc, load, time, c_list, siz, line)
        if(result == null){
          local line_name = line1_name
          update_convoy_schedule(pl, gl_wt, line_name, schedule)
        }
        return result
      break
    }
    return translate("Action not allowed")
  }

  function is_convoy_allowed(pl, convoy, depot)
  {
    local result=null // null is equivalent to 'allowed'
    local wt = gl_wt
    switch (this.step) {
      case 4:
        if ((depot.x != c_dep1.x)||(depot.y != c_dep1.y))
          return translate("You must select the deposit located in")+" ("+c_dep1.tostring()+")."
        local cov = d1_cnr
        local in_dep = true
        local veh = 1
        local good_list = [good_desc_x(good_alias.oel).get_catg_index()] //Fuels
        local name = ship1_name_obj
        local st_tile = 1

        //Para arracar varios vehiculos
        local id_start = ch4_cov_lim1.a
        local id_end = ch4_cov_lim1.b
        local cir_nr = get_convoy_number_exp(sch_list1[1], depot, id_start, id_end)
        cov -= cir_nr

        result = is_convoy_correct(depot,cov,veh,good_list,name,st_tile)

        if (result!=null){
          local good = translate_objects_list.good_oil
          return ship_result_message(result, translate(name), good, veh, cov)
        }

        if (current_cov>ch4_cov_lim1.a && current_cov<ch4_cov_lim1.b){
          local selc = 0
          local load = ship1_load
          local time = ship1_wait
          local c_list = sch_list1
          local siz = c_list.len()
          return set_schedule_convoy(result, pl, cov, convoy, selc, load, time, c_list, siz)
        }

      break
      case 5:
        if ((depot.x != c_dep1.x)||(depot.y != c_dep1.y))
          return translate("You must select the deposit located in")+" ("+c_dep1.tostring()+")."
        local cov = d2_cnr
            local in_dep = true
        local veh = 1
        local good_list = [good_desc_x(good_alias.gas).get_catg_index()] //Fuels
        local name = ship1_name_obj
        local st_tile = 1

        //Para arracar varios vehiculos
        local id_start = ch4_cov_lim2.a
        local id_end = ch4_cov_lim2.b
        local cir_nr = get_convoy_number_exp(sch_list2[1], depot, id_start, id_end)
        cov -= cir_nr

        result = is_convoy_correct(depot,cov,veh,good_list,name,st_tile)
        if (result!=null){
          local good = translate_objects_list.good_gas
          return ship_result_message(result, translate(name), good, veh, cov)
        }
        if (current_cov>ch4_cov_lim2.a && current_cov<ch4_cov_lim2.b){
          local selc = 0
          local load = ship1_load
          local time = ship1_wait
          local c_list = sch_list2
          local siz = c_list.len()
          return set_schedule_convoy(result, pl, cov, convoy, selc, load, time, c_list, siz)
        }
      break
      case 7:
        if ((depot.x != c_dep1.x)||(depot.y != c_dep1.y))
          return translate("You must select the deposit located in")+" ("+c_dep1.tostring()+")."
        local cov = 1
        local veh = 1
        local good_list = [good_desc_x(good_alias.passa).get_catg_index()] //Passengers
        local name = ship2_name_obj
        local st_tile = 1

        result = is_convoy_correct(depot,cov,veh,good_list,name,st_tile)

        if (result!=null){
          local good = translate(good_alias.passa)
          return ship_result_message(result, translate(name), good, veh, cov)
        }
        if (current_cov>ch4_cov_lim3.a && current_cov<ch4_cov_lim3.b){
          local selc = 0
          local load = ship2_load
          local time = ship2_wait
          local c_list = sch_list3
          local siz = c_list.len()
          return set_schedule_convoy(result, pl, cov, convoy, selc, load, time, c_list, siz)
        }
      break
    }
    return result = translate("It is not allowed to start vehicles.")
  }

  function script_text()
  {
    local pl = 0
    switch (this.step) {
      case 1:
        if(pot0==0){
          pot0=1
        }
        if (pot2==0){
          pot2=1
        }
        return null
        break;
      case 2:
        //Para los muelles mrcancias
        local c_list = dock_list1
        local name = sc_dock_name1
        for(local j =0;j<c_list.len();j++){
          local tile = my_tile(c_list[j])
          tile.remove_object(player_x(1), mo_label)
          local tool = command_x(tool_build_station)
          local err = tool.work(player_x(pl), tile, name)
        }
        return null
        break;

      case 3:
        //Para Astillero
        local t1 = my_tile(c_dep1)
        local label = t1.find_object(mo_label)

        if (label){
          t1.remove_object(player_x(1), mo_label)
        }

        local tool = command_x(tool_build_depot)
        local err = tool.work(player_x(pl), t1, sc_dep_name)
        if (t1.find_object(mo_depot_water)){
          pot1=1
        }
        return null
        break;

      case 4:
        // Para enrutar barcos
        local player = player_x(pl)
        local c_depot = my_tile(c_dep1)
        comm_destroy_convoy(player, c_depot) // Limpia los vehiculos del deposito
        local depot = depot_x(c_depot.x, c_depot.y, c_depot.z)

        if (current_cov> ch4_cov_lim1.a && current_cov< ch4_cov_lim1.b){
          local sched = schedule_x(gl_wt, [])
          local t_list = is_water_entry(sch_list1)
          for(local j =0;j<t_list.len();j++){
            if(j == 0)
              sched.entries.append(schedule_entry_x(t_list[j], ship1_load, ship1_wait))
            else
              sched.entries.append(schedule_entry_x(t_list[j], 0, 0))
          }
          local c_line = comm_get_line(player, gl_wt, sched)

          local good_nr = good_desc_x(good_alias.oel).get_catg_index()  //Fuels
          local name = ship1_name_obj
          local cov_nr = d1_cnr  //Max convoys nr in depot
          for (local j = 0; j < cov_nr ; j++){
            if (!comm_set_convoy(cov_nr, c_depot, name))
              return 0
            local conv = depot.get_convoy_list()
            conv[j].set_line(player, c_line)
          }
          local convoy = false
          local all = true
          comm_start_convoy(player, convoy, depot, all)
        }
        return null
        break;

      case 5:
        //Para el canal acuatico
        if (pot0==0){
          local t1 = my_tile(coord(c1_way.a.x, c1_way.a.y))
          local t2 = my_tile(sch_list2[1])
          local way = t1.find_object(mo_way)
          local is_lab1 = t1.find_object(mo_label)
          local is_lab2 = t2.find_object(mo_label)

          t1.unmark()

          if (is_lab1){
            t1.remove_object(player_x(1), mo_label)
          }
          if (is_lab2){
            t2.remove_object(player_x(1), mo_label)
          }
          if (way)
            way.unmark()

          local coora = {x = c1_way.a.x, y = c1_way.a.y, z = c1_way.a.z }
          local coorb = {x = c1_way.b.x, y = c1_way.b.y, z = c1_way.b.z }
          local coorc = {x = c1_way.c.x, y = c1_way.c.y, z = c1_way.c.z }

          local t = command_x(tool_build_way)
          t.set_flags(1)

          local err = t.work(player_x(pl), coora, coorc, sc_way_name)
          err = t.work(player_x(pl), coorb, coorc, sc_way_name)


        }
        //Para el cuarto muelle
        if (pot1==0){
          local t = my_tile(sch_list2[1])
          t.unmark()
          local label = t.find_object(mo_label)
          if (label){
            t.remove_object(player_x(1), mo_label)
          }
          local tool = command_x(tool_build_station)
          local err = tool.work(player_x(pl), t, sc_dock_name2)
        }
        if (current_cov> ch4_cov_lim2.a && current_cov< ch4_cov_lim2.b){
          local player = player_x(pl)
          local c_depot = my_tile(c_dep1)
          comm_destroy_convoy(player, c_depot) // Limpia los vehiculos del deposito
          local depot = depot_x(c_depot.x, c_depot.y, c_depot.z)

          local t_list = is_water_entry(sch_list2)
          local sched = schedule_x(gl_wt, [])
          sched.entries.append(schedule_entry_x(t_list[0], ship1_load, ship1_wait))
          sched.entries.append(schedule_entry_x(t_list[1], 0, 0))
          local c_line = comm_get_line(player, gl_wt, sched)

          local good_nr = good_desc_x(good_alias.gas).get_catg_index()  //Fuels
          local name = ship1_name_obj
          local cov_nr = d2_cnr  //Max convoys nr in depot
          for (local j = 0; j < cov_nr; j++){
            if (!comm_set_convoy(cov_nr, c_depot, name))
              return 0
            local conv = depot.get_convoy_list()
            conv[j].set_line(player, c_line)
          }
          local convoy = false
          local all = true
          comm_start_convoy(player, convoy, depot, all)
        }
        return null
        break;

      case 6:
        local t_dep = my_tile(c_dep1)
        local depot = t_dep.find_object(mo_depot_water)

        if (!depot){
          local t = command_x(tool_build_depot)
          local err = t.work(player_x(pl), t_dep, sc_dep_name)
        }
        //Para los muelles Pasajeros
        local c_list = dock_list2
        local name = sc_dock_name3
        for(local j =0;j<c_list.len();j++){
          local t = my_tile(c_list[j])
          t.unmark()
          t.remove_object(player_x(1), mo_label)
          local tool = command_x(tool_build_station)
          tool.work(player_x(pl), t, name)
          glsw[j]=1
        }
        return null
        break;

      case 7:
        local player = player_x(pl)
        if (current_cov> ch4_cov_lim3.a && current_cov< ch4_cov_lim3.b){
          local c_depot = my_tile(c_dep1)
          comm_destroy_convoy(player, c_depot) // Limpia los vehiculos del deposito
          local depot = depot_x(c_depot.x, c_depot.y, c_depot.z)

          local sched = schedule_x(gl_wt, [])
          local t_list = is_water_entry(sch_list3)
          for(local j =0;j<t_list.len();j++){
            if(j == 0)
              sched.entries.append(schedule_entry_x(t_list[j], ship2_load, ship2_wait))
            else
              sched.entries.append(schedule_entry_x(t_list[j], 0, 0))
          }
          local c_line = comm_get_line(player, gl_wt, sched)

          local good_nr = good_desc_x(good_alias.passa).get_catg_index() //Passengers
          local name = ship2_name_obj
          local cov_nr = 1  //Max convoys nr in depot
          if (!comm_set_convoy(cov_nr, c_depot, name))
            return 0

          local conv = depot.get_convoy_list()
          conv[0].set_line(player, c_line)
          comm_start_convoy(player, conv[0], depot)
        }

        return null
        break;
    }
    return null
  }

  function is_tool_active(pl, tool_id, wt) {
    local result = false
    switch (this.step) {

      case 1:
        local t_list = []
        local wt_list = [gl_wt]
        local res = update_tools(t_list, tool_id, wt_list, wt)
        result = res.result
        if(res.ok)  return result
        break

      case 2:
        local t_list = [tool_build_station]
        local wt_list = [gl_wt]
        local res = update_tools(t_list, tool_id, wt_list, wt)
        result = res.result
        if(res.ok)  return result
        break

      case 3:
        local t_list = [-tool_remover, tool_build_depot]
        local wt_list = [gl_wt]
        local res = update_tools(t_list, tool_id, wt_list, wt)
        result = res.result
        if(res.ok)  return result
        break

      case 4://Schedule
        local t_list = [-tool_remover, -t_icon.ship]
        local wt_list = [gl_wt]
        local res = update_tools(t_list, tool_id, wt_list, wt)
        result = res.result
        if(res.ok)  return result
        break

      case 5:
        local t_list = [tool_build_way, tool_remove_way, tool_build_station]
        local wt_list = [gl_wt]
        local res = update_tools(t_list, tool_id, wt_list, wt)
        result = res.result
        if(res.ok)  return result
        break

      case 6:
        local t_list = [tool_build_station]
        local wt_list = [gl_wt]
        local res = update_tools(t_list, tool_id, wt_list, wt)
        result = res.result
        if(res.ok)  return result
        break

      case 7://Schedule
        local t_list = [-tool_remover, -t_icon.ship]
        local wt_list = [gl_wt]
        local res = update_tools(t_list, tool_id, wt_list, wt)
        result = res.result
        if(res.ok)  return result
        break
    }
    return result
  }

  function is_tool_allowed(pl, tool_id, wt){
    local result = true
    local t_list = [0] // 0 = all tools allowed
    local wt_list = [gl_wt]
    local res = update_tools(t_list, tool_id, wt_list, wt)
    result = res.result
    if(res.ok)  return result
    return result
  }

  function is_dock_build(pos, tool_id, c_list, good)
  {
    local result = 0
    local st = {all_correct = true, c = null, nr = 0}
    local err_tx = translate("Dock No.%d must accept [%s]")
    local siz = c_list.len()
    for(local j=0;j<siz;j++){
      local tile = my_tile(c_list[j])
      local halt = tile.get_halt()
      local buil = tile.find_object(mo_building)
      if(buil && st.all_correct){
        local st_list = building_desc_x.get_available_stations(11/*building_desc_x.station*/, 3, good_desc_x(good))
        local st_desc = buil.get_desc()
        local sw = false

        //gui.add_message(""+st_desc.get_type()+"  , "+st_desc.get_waytype()+"")
        foreach(st in st_list){
          if (st.get_name() == st_desc.get_name())
            sw=true
        }
        //gui.add_message(""+sw+"  , "+st_desc.get_waytype()+"")
        if(!sw){
          st.all_correct = false
          st.c = c_list[j]
          st.nr = j+1
        }
      }
      if (pos.x == c_list[j].x && pos.y == c_list[j].y){
        if(tool_id==tool_build_station){
          if(st.all_correct) result = null
        }
      }
      else if(tool_id==tool_build_station && result!=null){
        local c = coord(c_list[siz-j-1].x,c_list[siz-j-1].y)
        local tile = my_tile(c)
        local buil = tile.find_object(mo_building)
        //local current_halt = my_tile(st.c).get_halt()
        if(!buil)
          result = translate("Place the stops at the marked points")+" ("+c.tostring()+")."
      }
      if (j == (siz-1)){

        if (tool_id==tool_remover && !st.all_correct){
          local current_halt = my_tile(st.c).get_halt()
          if(current_halt){
            local tile_list = current_halt.get_tile_list()
            foreach(tile in tile_list){
              if(pos.x == tile.x && pos.y == tile.y)
                return null
            }
          }
        }

        if(!st.all_correct){
          result =  st.c ? format(err_tx, st.nr, translate(good))+" ("+st.c.tostring()+")." : translate("Action not allowed")
        }
        if(result == 0){
          result =  translate("Action not allowed")
        }
      }
    }
    return result
  }

  function ship_result_message(nr, name, good, veh, cov)
  {
    switch (nr) {
      case 0:
        return format(translate("You must select a [%s]."),name)
        break

      case 1:
        return format(translate("The number of ships must be [%d]."),cov)
        break

      case 2:
        return format(translate("The number of convoys must be [%d], press the [Sell] button."),cov)
        break

      case 3:
        return format(translate("The ship must be for [%s]."),good)
        break

      case 4:
        return translate("No barges allowed.")
        break

      default :
        return translate("The convoy is not correct.")
        break
    }
  }

  function update_way(coora, coorb, vel_min, wt)
  {
    local tile_start =  tile_x(coora.x, coora.y, coora.z)
    local way_start = tile_start.find_object(mo_way)
    if(way_start){
      way_start.mark()
      tile_start.mark()
      local start_wt = way_start.get_waytype()
      if(start_wt != wt) return {c = coora, result = false}
      local start_speed = way_start.get_desc().get_topspeed()
      if(start_speed<vel_min) return {c = coora, result = false}
      local dir_start = way_start.get_dirs()
      switch (dir_start) {
        case 1:  //y--
          coora.y--
        break
        case 2:  //x++
          coora.x++
        break
        case 4:  //y++
          coora.y++
        break
        case 8:  //x--
          coora.x--
        break
        default:
          if(coora.x >= coorb.x && coora.y == coorb.y){
            coora.x--
            dir_start = 8
          }
          else if(coora.x <= coorb.x && coora.y == coorb.y){
            coora.x++
            dir_start = 2
          }

          else if(coora.x == coorb.x && coora.y >= coorb.y){
            coora.y--
            dir_start = 4
          }
          else if(coora.x == coorb.x && coora.y <= coorb.y){
            coora.y++
            dir_start = 1
          }

        break
      }
      way_start.unmark()
      tile_start.unmark()
      while(true){
        local dir = 0
        local tile = tile_x(coora.x, coora.y, coora.z)
        local way = tile.find_object(mo_way)
        if(way){
          way.unmark()
          tile.unmark()
          local current_wt = way.get_waytype()
          if(current_wt != wt){
            way.mark()
            tile.mark()
            return {c = coora, result = false}
          }
          local speed = way.get_desc().get_topspeed()
          if(speed<vel_min){
            way.mark()
            tile.mark()
            return {c = coora, result = false}
          }
          dir = way.get_dirs()
          local c_z = coora.z -1
          for(local j = c_z;j<=(c_z+2);j++){
            local c_test = square_x(coora.x,coora.y).get_tile_at_height(j)
            local is_tile = true
            try {
               c_test.is_valid()
            }
            catch(ev) {
              is_tile = false
              //gui.add_message("This faill")
            }
            if(is_tile && c_test.is_valid()){
              local t = tile_x(coora.x, coora.y, coora.z)
              local way = c_test.find_object(mo_way)
              if(t.is_bridge())c_test.z = coora.z

              //gui.add_message(""+coora.y+","+c_test.z+"  - "+way+"")
              if(way){
                coora.z = c_test.z
                break
              }
            }
          }

          if(coora.x==coorb.x && coora.y==coorb.y && coora.z==coorb.z){
            return {c = coora, result = true}
          }
          if ((dir==1)||(dir==2)||(dir==4)||(dir==8)){
            way.mark()
            tile.mark()
            return {c = coora, result = false}
          }
          else if(dir_start == 1){ //y--
            switch (dir) {
              case 5:
                coora.y--
                dir_start = 1
              break
              case 6:
                coora.x++
                dir_start = 2
              break
              case 12:
                coora.x--
                dir_start = 8
              break
              default:
                coora.y--
              break
            }
          }
          else if(dir_start == 2){ //x++
            switch (dir) {
              case 9:
                coora.y--
                dir_start = 1
              break
              case 12:
                coora.y++
                dir_start = 4
              break
              default:
                coora.x++
              break
            }
          }
          else if(dir_start == 4){ //y++
            switch (dir) {
              case 3:
                coora.x++
                dir_start = 2
              break
              case 12:
                coora.x--
                dir_start = 8
              break
              case 9:
                coora.x--
                dir_start = 8
              break
              default:
                coora.y++
              break
            }
          }
          else if(dir_start == 8){ //x--
            switch (dir) {
              case 3:
                coora.y--
                dir_start = 1
              break
              case 6:
                coora.y++
                dir_start = 4
              break
              case 12:
                coora.y--
                dir_start = 12
              break
              default:
                coora.x--
              break
            }
          }
        }
        else return {c = coora, result = false}
      }
    }
    else return {c = coora, result = false}
  }
}        // END of class

// END OF FILE
