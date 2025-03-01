/*
 *  class basis_chapter
 *
 *
 *  Can NOT be used in network game !
 */

//Global coordinate for mark build tile
currt_pos <- null

//----------------Para las señales de paso------------------------
persistent.sigcoord <- null
sigcoord  <- null
//-----------------------------------------------------------------

//Para la gestion de vias
// Results for fullway, c = coord3d, p = plus, r = result, m = marked, l = look, s = slope, z = coor.z save
r_way <- { c = coord3d(0, 0, 0), p = 0, r = false, m = false, l = false, s = 0, z = null}
r_way_list <- {}
wayend <- coord3d(0, 0, 0)
//-------------------------------------------------------------------------------------------------------------

// Mark / Unmark build in to link
gl_buil_list <- {}

// Total de carga recibida
reached <- 0

tile_delay      <- 0x0000000f & time()       //delay for mark tiles
gl_tile_i       <- 0

/**
  * chapter description : this is a placeholder class
  */
class basic_chapter
{

  chapter_name  = ""  // placeholder for chapter name
  chap_nr       = 1   // count the chapter number
  step          = 1   // count the step inside the chapter  1="step A"
  startcash     = 0   // pl=0 startcash; 0=no reset

  glpos     = coord3d(0,0,0)
  gltool    = null
  glresult  = null
  tmpsw     = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  tmpcoor   = []
  stop_flag = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
  st_cover  = settings.get_station_coverage()

  glmark = coord3d(0,0,0) //coordenadas para realizar  unmark

  //Para las pendientes
  slope_estatus = [0,0,0,0,0,0]

  //--------------------way scan ------------------------------------
  cursor_sw     = false
  bridge_sw     = false
  sch_sw        = false
  stop_sw       = false
  bridge_count  = 0
  //-----------------------------------------------------------------

  //Underground View
  under_lv  = settings.get_underground_view_level()
  unde_view = -128
  norm_view = 127

  map_siz = world.get_size()

  constructor(pl)
  {
    scenario.short_description = scenario_name + " - " + translate(this.chapter_name)
    // tools disabled/enabled
    general_disabled_tools(pl)
    //this.set_all_rules(pl)
    this.step = 1
  }

  // FUNCTIONS TO REWRITE
  function set_goal_text(text)
  {
    return text
  }

  function get_rule_text(pl,path)
  {
    local text = ""
    switch (persistent.chapter) {
      case 0 :
        text = ttextfile( path + "rule.txt" )
        break
      default :
        text = ttextfile( "rule.txt" )
        break
    }
    return text.tostring()
  }

  /*
   *  calculate percentage chapter complete
   *
   *  ch_steps  = count chapter steps
   *  step      = actual chapter step
   *  sup_steps = count sub steps in a chapter step
   *  sub_step  = actual sub step in a chapter step
   *
   *  no sub steps in chapter step, then set sub_steps and sub_step to 0
   *
   * This function is called during a step() and can alter the map
   *
   */
  function chapter_percentage(ch_steps, ch_step, sub_steps, sub_step)
  {
    local percentage_step = 100 / ch_steps

    local percentage = percentage_step * ch_step

    local percentage_sub_step = 0
    if ( sub_steps > 0 && sub_step > 0) {
      percentage_sub_step = (percentage_step / sub_steps ) * sub_step
      percentage += percentage_sub_step
    }

    if ( ch_step <= ch_steps ) {
      percentage -= percentage_step
    }

    //gui.add_message("ch_steps "+ch_steps+" ch_step "+ch_step+" ch_steps "+sub_steps+" sub_step "+sub_step)

    return percentage
  }

  function is_chapter_completed(pl)
  {
    local percentage = 0
    return percentage
  }

  // BASIC FUNCTIONS, NO REWRITE

  //Para arrancar vehiculos usando comm  ----------------------------------------------------------------
  function comm_set_convoy(cov_nr, coord, name, veh_nr = false)
    /*1 Numero de convoy actual,******
    * 2 coord del deposito,        *
    * 3 Name del vehiculo,         *
    * 4 Numero de remolques/bagones)*/
  {
    local pl = player_x(0)
    local depot = depot_x(coord.x, coord.y, coord.z)  // Deposito /Garaje
    local cov_list = depot.get_convoy_list() // Lista de vehiculos en el deposito
    local d_nr = cov_list.len()   //Numero de vehiculos en el deposito
    if (d_nr>cov_nr && !veh_nr)
      return false
    local wt = depot.get_waytype()
    local veh_list = vehicle_desc_x.get_available_vehicles(wt)  //Lista de todos los vehiculos
    for(local j = 0;j<veh_list.len();j++){
      local veh_name = veh_list[j].get_name()
      //gui.add_message(""+veh_name+" --> "+name+"")
      if (veh_name == name) {
        if (veh_nr){
          if (!cov_list)
            return false
          try {
            depot.append_vehicle(pl, cov_list[cov_nr], veh_list[j])
          }
          catch(ev) {
            continue
          }
        }
        else {
          depot.append_vehicle(pl, convoy_x(gcov_id+1), veh_list[j])
          basic_convoys().checks_all_convoys()
        }
        if (depot.get_convoy_list().len()==0)
          return false
        else
          return true
      }
    }
  }

  function comm_destroy_convoy(pl, coord){
    local depot = depot_x(coord.x, coord.y, coord.z)  // Deposito /Garaje
    local cov_list = depot.get_convoy_list() // Lista de vehiculos en el deposito
    local d_nr = cov_list.len()   //Numero de vehiculos en el deposito
    if ( d_nr == 0)
      return true
    for (local j = 0;j<d_nr;j++){
      try {
        cov_list[j].destroy(pl)
      }
      catch(ev) {
        continue
      }
    }
    return true
  }


  function comm_start_convoy(player, cov, depot, all = false)
  {
    if(all) {
      depot.start_all_convoys(player)
    }
    else{
      depot.start_convoy(player, cov)
    }
    return null
  }

  function comm_get_line(player, wt, sched)
  {
    player.create_line(wt)
    // find the line - it is a line without schedule and convoys
    local list = player.get_line_list()
    local c_line = null
    foreach(line in list) {
      if (line.get_waytype() == wt  &&  line.get_schedule().entries.len()==0) {
        // right type, no schedule -> take this.
        c_line = line
        break
      }
    }
    //gui.add_message(""+sched.entries.len()+" "+sched.waytype)
    if(wt != sched.waytype) return gui.add_message("Err Waytype: "+wt +" :: "+ sched.waytype)
    c_line.change_schedule(player, sched)

    return c_line
  }

  //----------------------------------------------------------------------------------------------------------------

  //-------------------------

  function checks_convoy_nr(nr, max)
  {
    for(local j=0;j<max;j++){
      local result = true
      try {
         cov_save[nr+j].get_pos()
      }
      catch(ev) {
        result = false
      }
      if (result){
        if (cov_save[nr+j].is_in_depot()){
          return null
        }
      }
      else
        return null
    }
    return format(translate("The number max of vehicles in circulation must be [%d]."),max)
  }
  function get_convoy_nr(nr, max)
  {
    local cov_nr = 0
    for(local j = 1; j <= max; j++){
      local result = true
      try {
         cov_save[nr+j].get_pos()
      }
      catch(ev) {
        result = false
      }
      if (result){
        //gui.add_message(""+j+"::"+cov_save[nr+j].is_in_depot()+"")
        if (cov_save[nr+j].is_in_depot())
          continue
        else
          cov_nr++
      }
    }
    return cov_nr
  }

  function update_convoy_removed(convoy, pl)
  {
    //gui.add_message("update_convoy_removed: "+convoy + " Correct "+correct_cov)
    if(cov_save.len() <= current_cov) {
      cov_save.push(convoy)
      if(correct_cov){
        gcov_nr++
        persistent.gcov_nr = gcov_nr
        current_cov = gcov_nr
        persistent.current_cov = gcov_nr
      }
    }
    else{
      cov_save[current_cov]=convoy
      if(correct_cov){
        gcov_nr++
        persistent.gcov_nr = gcov_nr
        current_cov = gcov_nr
        persistent.current_cov = gcov_nr
      }
    }
  }

  function is_cov_valid(cnv){
    local result = true
    // cnv - convoy_x instance saved somewhat earlier
    try {
       cnv.get_pos() // will fail if cnv is no longer existent
       // do your checks
    }
    catch(ev) {
      result = false
    }
    return result
  }

  /*
   *  check is tile halt2 in tilelist halt1
   *
   *  halt1 = tile_x
   *  halt2 = tile_x
   *
   */
  function check_halt_merge(halt1, halt2) {
    local tile_list = halt1.get_halt().get_tile_list()
    local check_tile = coord3d_to_string(halt2)

    for ( local x = 0; x < tile_list.len(); x++ ) {
      if ( coord3d_to_string(tile_list[x]) == check_tile ) {
        //gui.add_message("check_halt_merge "+check_tile + " return true")
        return true
      }
    }

    return false
  }

  function cov_pax(c, wt, good){
    local halt = tile_x(c.x, c.y, c.z).get_halt()
    local cov_nr = 0
    if(halt) {
        local cov_list = halt.get_convoy_list()
        foreach(cov in cov_list) {
          if (cov.get_waytype()!=wt)
            continue
          local cov_good = cov.get_goods_catg_index()
          for(local j=0;j<cov_good.len();j++){
            if(cov_good[j]==good)
              cov_nr += cov.get_transported_goods()[0]
          }
        }
        local lin_list = halt.get_line_list()
        foreach(line in lin_list) {
          local cov_lin = line.get_convoy_list()
          foreach(cov in cov_lin) {
            if (cov.get_waytype()!=wt)
              continue

            local cov_good = cov.get_goods_catg_index()
            for(local j=0;j<cov_good.len();j++){
              if(cov_good[j]==good){
                cov_nr += cov.get_transported_goods()[0]
              }
            }
          }
        }
    }
    return cov_nr
  }


  function checks_convoy_schedule(convoy, pl)
  {
    local cov_test = true
    local result = 0
    try {
       convoy.get_pos() // will fail if cnv is no longer existent
       // do your checks
    }
    catch(ev) {
      cov_test = false

    }
    if (cov_test){
      if (convoy){
        local line = convoy.get_line()
        local schedule = convoy.get_schedule()
        if (line && line.is_valid()){
          schedule = line.get_schedule()
        }
        if(schedule && schedule.entries.len() > 1){
          sch_sw = true
          result = is_schedule_allowed(pl, schedule)
        }
      }
    }
    return {res = result, cov = cov_test}
  }

  function get_city_name(coord)
  {
    return city_x(coord.x, coord.y).get_name()
  }

  function next_step()
  {
    scr_jump = false
    this.step++
    persistent.step = this.step
    persistent.status.step = this.step
    fail_count = 1 //reinicia el contador de fallos en uso de herramientas

    //------------------------------------------------------ Test
    reset_pot() //reset all pot test
    reset_tmpsw()
    reset_glsw()
    // tools disabled/enabled
    general_disabled_tools(player_x.nr)
    //-------------------------------------------------------

    // make here screen refresh
    return null   // null is equivalent to 'allowed'
  }

  function backward_step()
  {
    this.step--
    persistent.step = this.step

    //------------------------------------------------------ Test
    reset_pot() //reset all pot test
    reset_tmpsw()
    reset_glsw()
    // tools disabled/enabled
    general_disabled_tools(player_x.nr)
    //-------------------------------------------------------

    // make here screen refresh
    return null   // null is equivalent to 'allowed'
  }

  function step_nr(nr)
  {
    this.step=nr
    persistent.step = this.step

    //------------------------------------------------------ Test
    reset_pot() //reset all pot test
    reset_tmpsw()
    reset_glsw()
    // tools disabled/enabled
    general_disabled_tools(player_x.nr)
    //-------------------------------------------------------

    // make here screen refresh
    return null   // null is equivalent to 'allowed'
  }


  function my_step(i)
  {
    return "step_" + ( i < 10 ? "0":"" ) + i
  }

  function ttxst(i)
  {
    return "txtst_" + ( i < 10 ? "0":"" ) + i
  }


  function tx_script()
  {
    return "scr"
  }


  function has_way(waytyp,cube)   // cube height is only used from "nw.z" value
  {
    local res = true
    for (local x = cube.nw.x; x <= cube.se.x; x++)
      for (local y = cube.nw.y; y <= cube.se.y; y++)
        if ( square_x(x,y).get_tile_at_height(cube.nw.z).has_way(waytyp) == false )
          res = false
    return res
  }


  function is_inside_cube(pos,nw,se)  // two positions coord3d for a cube se.z is lower nw.z
  {
    if ( pos.x < nw.x || pos.y < nw.y || pos.x > se.x || pos.y > se.y ||
         pos.z > nw.z || pos.z < se.z )
      return false
    else  return true
  }


  function give_ttext(text,coord)   // coord=coord3d or cube={ne,se}  ttext with {pos} or {cube}
  {
        local result = ttext(text)
    local modus = true
    try { coord.x } catch(coord) { modus = false }
    if (modus)
      result.pos  = pos_to_text(coord)
    else  result.cube = cube_to_text(coord)
    return result.tostring()
  }


  function give_title()
  {
    return "<br><em>"+translate("Chapter")+" "+this.chap_nr+"</em> - "+translate(this.chapter_name)+"<br><br>"
  }


  function get_goal_text(pl,path)
  {
    local text = ttextfile( path + "goal.txt" )
    local text_step = ttextfile( path + "goal_" + this.my_step(this.step) + ".txt" )
    if ( persistent.chapter == 7 && this.step > 0 && this.step < 5 ) {
      text_step = ttextfile( path + "goal_step_01x04.txt" )
    }
    for (local i = 0; i <= 15; i++){
      text[this.my_step(i)] = ""
      text[this.ttxst(i)] = "<em>"
    }
    text_step = this.set_goal_text(text_step)
    text[my_step(this.step)] = text_step.tostring()
    text[ttxst(this.step)] = "<st>"
    if (correct_cov)
      text["scr"] = "<em>--></em> <a href='script:script_text()'>"+ translate("Go to next step")+"  >></a>"
    else
      text["scr"] = "--> <st>"+ translate("Advance not allowed")+"</st>"
    return text.tostring()
  }

  function cube_to_text(cube)
  {
    return "("+cube.nw.x+","+cube.nw.y+","+cube.nw.z+" - "+cube.se.x+","+cube.se.y+","+cube.se.z+")"
    }

  function pos_to_text(pos)
  {
    local cd = coord(pos.x,pos.y)
    return "("+cd.tostring()+")"
    }


  function my_tile(coord)
  {
    return square_x(coord.x,coord.y).get_ground_tile()
    //return square_x(coord.x,coord.y).get_tile_at_height(coord.z)
  }

  function my_compass()
  {
    local c_max = {x = map_siz.x-1, y = map_siz.y-1}
    local c = coord(0,0)
    local text = c.tostring()

    local res_c = {x = 0, y = 0}
    local ttx = ""
    local siz = text.len()
    for(local j=0;j<siz;j++){
      local tx = format("%c",text[j])
      try {
        tx.tointeger()
      }
      catch(ev) {
        if(tx==","){
          res_c.x = ttx.tointeger()
          ttx = ""
          continue
        }
        continue
      }
      ttx+=tx
      if(j == siz-1){
        res_c.y = ttx.tointeger()
      }
    }
    //gui.add_message("Res: "+ res_c.x +" -- "+res_c.y)
    //gui.add_message("MAX: "+ c_max.x +" -- "+c_max.y)
    if(res_c.x == 0 && res_c.y == 0){
      //gui.add_message("N")
      return 0
    }
    else if(res_c.x == c_max.y && res_c.y == 0){
      //gui.add_message("W")
      return 1
    }
    else if(res_c.x == c_max.x && res_c.y == c_max.y){
      //gui.add_message("S")
      return 2
    }
    else if(res_c.x == 0 && res_c.y == c_max.x){
      //gui.add_message("E")
      return 3
    }
    return null
  }

  function is_waystop_correct(player,schedule,nr,load,wait,coord, line = false)
  {
    local result = 0
    // coord = x,y,z place to compare the waystop
    // nr = number of schedule.entrie to compare
    local nr2 = schedule.entries.len()-1
    local nr_st = nr
    if (nr2<nr){
      nr = nr2
    }

    local entrie

    try {
       entrie = schedule.entries[nr]
    }
    catch(ev) {
      if(!line)
        reset_tmpsw()   //reinicia las paradas seleccionadas
      return translate("The schedule list must not be empty.")
    }
    if(schedule.entries.len()<=1) {
      if(!line)
        reset_tmpsw()   //reinicia las paradas seleccionadas
      return translate("The schedule list must not be empty.")
    }
    local halt   = entrie.get_halt( player_x(player) )
    local targ_t = this.my_tile(coord)

    local target = square_x(coord.x,coord.y).get_halt()
    if(!target)
      return gui.add_message("Error aqui, not station here!. "+ coord)

    local target_list = square_x(coord.x,coord.y).get_halt_list()

    if (!halt) return translate("The schedule is not correct.")
    local t_list = halt.get_tile_list()
    local t2_list = targ_t.is_water() ? get_tiles_near_stations(t_list) : target.get_tile_list()
    local c_buld1 = targ_t.is_water() ? coord : t2_list[0].find_object(mo_building).get_pos()
    local c_buld2 = targ_t.is_water() ? coord : t_list[0].find_object(mo_building).get_pos()

    if(targ_t.is_water()){
      for(local i=0;i<t2_list.len();i++){
        if (targ_t.x==t2_list[i].x && targ_t.y==t2_list[i].y){
          result = null
        }
      }
    }
    else if((c_buld1.x == c_buld2.x) && (c_buld1.y == c_buld2.y)) {
      result = null
    }

    if (result!=null){
      local text = ttext("The waystop {nr} '{name}' isn't on place {pos}")
      text.name = target_list[0].get_name()
      text.pos = pos_to_text(coord)
      text.nr = (nr_st+1)
      result = text.tostring()
      return result
    }

    if (entrie.load != load) {
      local text = ttext("The load of waystop {nr} '{name}' isn't {load}% {pos}")
      text.name = target_list[0].get_name()
      text.pos = pos_to_text(coord)
      text.load = load
      text.nr = (nr+1)
      return text.tostring()
    }

    //gui.add_message(""+entrie.wait+" "+wait +" "+nr)
    if (abs(entrie.wait-wait)>7) {

      local text = ttext("The waittime in waystop {nr} '{name}' isn't {wait} {pos}")
      local txwait = get_wait_time_text(wait)
      text.name = target_list[0].get_name()
      text.pos = pos_to_text(coord)
      text.wait = txwait
      text.nr = (nr+1)
      return text.tostring()
    }
    return result
  }

  function get_wait_time_text(wait)
  {
    return ""+difftick_to_string(wait*(tick_wait))+""
  }

  function is_station_build(player,coord,good)
  {
    local halt   = this.my_tile(coord).get_halt()
    local result = null     // returns null if it is build
    if ( halt == null )
      result = this.give_ttext("You didn't build a station at {pos}",coord)
    else
    {
      if ( ! halt.accepts_good( good_desc_x(good) ) )
        result = this.give_ttext("The station at {pos} doesn't accept freight",coord)
      if (  !(halt.get_owner() <=> player_x(player)) )
        result = this.give_ttext("The station at {pos} isn't your station",coord)
    }
    return result
  }

  function is_convoy_correct(depot,cov,veh,good_list,name, max_tile, is_st_tile = false)
  {
    local cov_list = depot.get_convoy_list()
    local cov_nr = cov_list.len()
    //Check if there is a convoy
    //gui.add_message(""+cov+"")
    if (cov_nr==0){
      return "nop"
    }

    local veh_list = cov_list[cov_nr-1].get_vehicles()
    local veh_nr = veh_list.len()
    //To check the name of the locomotive
    local veh_name = veh_list[0].get_name()
    //gui.add_message(""+veh_name+"")
    if (veh_name!=name)
      return 0

    //Check the number of vehicles and station tile ----
    local cov_tile = cov_list[cov_nr-1].get_tile_length()
    if(is_st_tile){
      if(cov_tile<max_tile)
        return 6
      if(cov_tile>max_tile)
        return 5
    }
    else {
      if(veh_nr<veh){
        return 4
      }
      if(max_tile!=cov_tile)
        return 5
    }
    //---------------------------------------------------

    //Check the number of convoys ------------------------
    if (cov_nr<cov){
      //Check load type -----------------------------------
      local good = cov_list[cov_nr-1].get_goods_catg_index()
      local good_count=0
      for(local j=0;j<good.len();j++){
        //gui.add_message("a = "+good[j]+", b = "+good_nr+"")
        for(local i=0;i<good_list.len();i++){
          if(good[j]==good_list[i])
            good_count++
        }
        //if(good[j]!=good_nr)
          //return 3
      }
      if(good_count != good_list.len() || good_count != good.len())
        return 3
      //----------------------------------------------------
      return 1
    }
    if (cov_nr>cov)
      return 2
    //----------------------------------------------------

    //Check load type -----------------------------------
    local good = cov_list[cov-1].get_goods_catg_index()
    local good_count=0
    for(local j=0;j<good.len();j++){
      for(local i=0;i<good_list.len();i++){
        //gui.add_message("a = "+good[j]+", b = "+good_list[i]+"")
        if(good[j]==good_list[i])
          good_count++
      }
      //if(good[j]!=good_nr)
        //return 3
    }
    if(good_count != good_list.len() || good_count != good.len())
      return 3
    //----------------------------------------------------

    return null
  }

  function is_convoy_correct_ext(depot,  good_nr, cov, veh, cab, name, wag_name, cab_name)
  {
    local res = {good = false, name = false, cov = false, veh = false, cab = false}
    local cov_list = depot.get_convoy_list()
    local cov_nr = cov_list.len()

    //Check if there is a convoy
    if (cov_nr==0){
      return res
    }

    //Check the number of convoys
    if (cov_nr==cov)
      res.cov = true

        //Check name car and cab
    for (local j=0;j<cov_nr;j++){
      local veh_list = cov_list[j].get_vehicles()

      //To check the name of the locomotive
      local c_name = veh_list[0].get_name()
      if (c_name==name)
        res.name = true

      //Check load type
      local good = cov_list[j].get_goods_catg_index()
      for(local i=0;i<good.len();i++){
        if(good[i]==good_nr)
          res.good = true
      }
      //Check the number of cars
      local veh_nr = veh_list.len()
      local wag_nr = 0
      local cab_nr = 0
      for(local i=0;i<veh_nr;i++){
        local name = veh_list[i].get_name()
        if (name == wag_name)
          wag_nr++
        if (name == cab_name)
          cab_nr++
      }
      if (wag_nr == veh)
        res.veh = true

      if (cab_nr == cab)
        res.cab = true
    }
    return res
  }

  function is_conv_schedule_correct(pl,all,nr,load,wait,cov,convoy,coord,line=false)
  {
    //Check if schedule is correct
    local conv_sch = convoy.get_schedule()
    local entries = null

    if (conv_sch)
      entries = conv_sch.entries
    else
      return 0
    local sch_nr = entries.len()
    if (sch_nr!=all)
      return 1
    if (entries[nr].load!=load)
      return 2
    if (entries[nr].wait!=wait)
      return 3

    if (line){
      local cov_line = convoy.get_line()
      if (cov_line){
        if (!cov_line.is_valid())
          return 4
      }
      else
        return 5
    }
    local t_list = entries[nr].get_halt(player_x(pl)).get_tile_list()
    if (tile_list(t_list, coord))
      return null

    return 6
  }

  function set_schedule_list(result, pl, schedule, nr, selc, load, time, c_list, siz, line = false)
  {
    if (nr > siz)
      return format(translate("The schedule needs to have %d waystops, but there are %d ."),siz, nr)

    for(local j=0;j<siz;j++){
      if (j==selc){
        result = is_waystop_correct(pl, schedule, j, load, time, c_list[j]), line
      }

      else if (result==null){
        result = is_waystop_correct(pl, schedule, j, 0, 0, c_list[j], line)

        }
      else
        return result
    }
    return result
  }

  function set_schedule_convoy_back(result, pl, cov, convoy, selc, load, time, c_list, siz, line, back)
  {
    local all = back? siz+siz-2 : siz
    for(local j=0;j<siz;j++){
      if (j==selc)
        result = is_conv_schedule_correct(pl, all, j, load, time, cov, convoy, c_list[j], line)
      else if (result==null)
        result = is_conv_schedule_correct(pl, all, j, 0, 0, cov, convoy, c_list[j], line)

      else break
    }

    if(back){
      local nr = siz
      for(local j=siz-2;j>0;j--){
        if (result==null)
          result = is_conv_schedule_correct(pl, all, nr, 0, 0, cov, convoy, c_list[j], line)
        else
          break
        nr++
      }
    }

    if (result!=null){
      switch (result) {
        case 4:
          return translate("The line is not correct.")
        break

        case 5:
          return translate("First create a line for the vehicle.")
        break

        default :
          return translate("The schedule is not correct.")
        break
      }
    }

    if (result == null){
      update_convoy_removed(convoy, pl)

    }
    return result
  }

  function set_schedule_convoy(result, pl, cov, convoy, selc, load, time, c_list, siz, line = false)
  {
    for(local j=0;j<siz;j++){
      if (j==selc)
        result = is_conv_schedule_correct(pl, siz, j, load, time, cov, convoy, c_list[j], line)
      else if (result==null)
        result = is_conv_schedule_correct(pl, siz, j, 0, 0, cov, convoy, c_list[j], line)

      else break
    }
    //gui.add_message(""+result)
    if (result!=null){
      switch (result) {
        case 4:
          return translate("The line is not correct.")
        break

        case 5:
          return translate("First create a line for the vehicle.")
        break

        default :
          return translate("The schedule is not correct.")
        break
      }
    }

    if (result == null){
      update_convoy_removed(convoy, pl)

    }
    return result
  }

  function tile_list(t_list, coord)
  {
    local t_nr = t_list.len()
    for(local j=0;j<t_nr;j++){
      if ((t_list[j].x==coord.x)&&(t_list[j].y==coord.y)){
        return true
      }
    }
    return false
  }

  function jump_to_link_executed(pos)
  {
    if (currt_pos){
      local t = tile_x(currt_pos.x,currt_pos.y,currt_pos.z)
      local build = t.find_object(mo_building)
      if(build){
        local t_list = gl_buil_list
        foreach(t in t_list){
          t.find_object(mo_building).unmark()
        }
        gl_buil_list = {}
        currt_pos = null
      }
    }
    local t = tile_x(pos.x,pos.y,pos.z)
    local build = t.find_object(mo_building)

    if(build){
      local t_list = build.get_tile_list()
      foreach(t in t_list){
        gl_buil_list[coord3d_to_key(t)] <- t
        t.find_object(mo_building).mark()
      }
      currt_pos = pos
    }
    return null
  }

  function get_convoy_number(coord, wt, in_dep = false)  //Permite contar los vehiculos en las estaciones /paradas
  {
    local halt = this.my_tile(coord).get_halt()
    local cov_list = halt.get_convoy_list()
    local cov_nr = 0
    foreach(cov in cov_list) {
      if (cov.get_waytype()==wt){
        if(!cov.is_in_depot())
          cov_nr++
        else if(in_dep)
          cov_nr++
      }
    }
    local lin_list = halt.get_line_list()
    foreach(line in lin_list) {
      local cov_lin = line.get_convoy_list()
      foreach(cov in cov_lin) {
        if (cov.get_waytype()==wt){
          if(!cov.is_in_depot())
            cov_nr++
          else if(in_dep)
            cov_nr++
        }
      }
    }
    return cov_nr
  }

  function get_convoy_number_exp(coord, c_dep, id_start, id_end, in_dep = false)  //Permite contar los vehiculos en las estaciones /paradas
  {
    local halt = this.my_tile(coord).get_halt()
    local cov_list = halt.get_convoy_list()
    local cov_nr = 0
    foreach(cov in cov_list) {
      local cov_dep = cov.get_home_depot()
        if (cov_dep.x == c_dep.x && cov_dep.y == c_dep.y){
          //gui.add_message("("+cov.is_in_depot()+" .. "+cov.id+") .. ??"+id_end+"")
          if(!cov.is_in_depot()){
            for (local j =id_start ;j<cov_save.len();j++){
              if(cov.id == cov_save[j].id){
                cov_nr++
                break
              }
            }
          }
          else if(in_dep)
            cov_nr++
        }
    }
    local lin_list = halt.get_line_list()
    foreach(line in lin_list) {
      local cov_lin = line.get_convoy_list()
      foreach(cov in cov_lin) {
        local cov_dep = cov.get_home_depot()
        if (cov_dep.x == c_dep.x && cov_dep.y == c_dep.y){
          //gui.add_message("("+cov.is_in_depot()+" .. "+cov.id+") .. ??"+id_end+"")
          if(!cov.is_in_depot()){
            for (local j =id_start ;j<cov_save.len();j++){
              if(cov.id == cov_save[j].id){
                cov_nr++
                break
              }
            }
          }
          else if(in_dep)
            cov_nr++
        }
      }
    }
    return cov_nr
  }

  function get_depot_number(pl, depot, coord, good, max)
  {
    local halta = this.my_tile(coord).get_halt()  //Halt de la estacion
    local cov_list = depot.get_convoy_list()    //Lista de vehiculos en el deposito
    local cov_nr = 0                //Contador de vehiculos
    local sch = null
    foreach(cov in cov_list) {
      local line = cov.get_line()
      if (line)
        sch = line.get_schedule()

      else
        sch = cov.get_schedule()

      if (sch){
        local nr = sch.entries.len()
        for(local j=0;j<nr;j++) {
          //if (cov_nr==max)
            //return cov_nr
          local haltb = sch.entries[j].get_halt(player_x(pl))   //Halt de la estacion asociada al vehiculo
          //if (halta.is_connected(haltb, good_desc_x(good))){
            local t_list = sch.entries[j].get_halt(player_x(pl)).get_tile_list()
            if (tile_list(t_list, coord))
              cov_nr++
            continue
          //}
        }
      }
    }
    //gui.add_message(""+cov_nr+"")
    return cov_nr
  }

  function get_reached_target(coord, good)
  {
    local factory = factory_x(coord.x, coord.y)
    return factory.input[good].get_received().reduce(sum)
  }

  function save_pot()
  {
    if (persistent.pot[0]!=0)pot0=persistent.pot[0]
    if (persistent.pot[1]!=0)pot1=persistent.pot[1]
    if (persistent.pot[2]!=0)pot2=persistent.pot[2]
    if (persistent.pot[3]!=0)pot3=persistent.pot[3]
    if (persistent.pot[4]!=0)pot4=persistent.pot[4]
    if (persistent.pot[5]!=0)pot5=persistent.pot[5]
    if (persistent.pot[6]!=0)pot6=persistent.pot[6]
    if (persistent.pot[7]!=0)pot7=persistent.pot[7]
    if (persistent.pot[8]!=0)pot8=persistent.pot[8]
    if (persistent.pot[9]!=0)pot9=persistent.pot[9]
    if (persistent.pot[10]!=0)pot10=persistent.pot[10]

    persistent.pot[0]=pot0
    persistent.pot[1]=pot1
    persistent.pot[2]=pot2
    persistent.pot[3]=pot3
    persistent.pot[4]=pot4
    persistent.pot[5]=pot5
    persistent.pot[6]=pot6
    persistent.pot[7]=pot7
    persistent.pot[8]=pot8
    persistent.pot[9]=pot9
    persistent.pot[10]=pot10

    return null
  }

  function save_glsw()
  {
    for(local j=0;j<20;j++){
      if (persistent.glsw[j]!=0)
        glsw[j]=persistent.glsw[j]

      persistent.glsw[j]=glsw[j]
    }
    return null
  }

    function backward_pot(pnr)
  {
    if (pnr==0) {pot0 = 0; persistent.pot[pnr]=pot0}
    if (pnr==1) {pot1 = 0; persistent.pot[pnr]=pot1}
    if (pnr==2) {pot2 = 0; persistent.pot[pnr]=pot2}
    if (pnr==3) {pot3 = 0; persistent.pot[pnr]=pot3}
    if (pnr==4) {pot4 = 0; persistent.pot[pnr]=pot4}
    if (pnr==5) {pot5 = 0; persistent.pot[pnr]=pot5}
    if (pnr==6) {pot6 = 0; persistent.pot[pnr]=pot6}
    if (pnr==7) {pot7 = 0; persistent.pot[pnr]=pot7}
    if (pnr==8) {pot8 = 0; persistent.pot[pnr]=pot8}
    if (pnr==9) {pot9 = 0; persistent.pot[pnr]=pot9}
    if (pnr==10) {pot10 = 0; persistent.pot[pnr]=pot10}

    return null
  }

  function backward_glsw(pnr)
  { for(local j=0;j<20;j++){
      if (pnr==j){
        glsw[j]=0
        persistent.glsw[j]=glsw[j]
      }
    }

    return null
  }

    function reset_pot()
  {
    pot0 = 0
    pot1 = 0
    pot2 = 0
    pot3 = 0
    pot4 = 0
    pot5 = 0
    pot6 = 0
    pot7 = 0
    pot8 = 0
    pot9 = 0
    pot10 = 0
    persistent.pot[0]=0
    persistent.pot[1]=0
    persistent.pot[2]=0
    persistent.pot[3]=0
    persistent.pot[4]=0
    persistent.pot[5]=0
    persistent.pot[6]=0
    persistent.pot[7]=0
    persistent.pot[8]=0
    persistent.pot[9]=0
    persistent.pot[10]=0

    return null
  }

  function reset_glsw()
  { for(local j=0;j<20;j++){
      glsw[j]=0
      persistent.glsw[j]=glsw[j]
    }

    return null
  }

  function reset_tmpsw()
  { for(local j=0;j<20;j++){
      tmpsw[j] = 0

    }
    tmpcoor = []
    return null
  }

  function reset_stop_flag()
  { for(local j=0;j<20;j++){
    stop_flag[j]=0
    }
    return null
  }

  function count_tunnel(coora, max){
    local way = tile_x(coora.x, coora.y, coora.z).find_object(mo_way)
    local r_dir = way? way.get_dirs():0
    if(!way)return true
    local result = false
    if(r_dir == 2){
      for(local j = 0;true;j++){
        local t = tile_x((coora.x + j), coora.y , coora.z)
        if (!t.is_valid()){
          return false
        }
        local w = t.find_object(mo_way)
        if (!w){
          t.z--
          w = t.find_object(mo_way)
        }
        local slope = t.get_slope()
        local dir = w? w.get_dirs():0
        //gui.add_message(""+t.x+","+t.y+","+t.z+"::"+slope+"")
        if(w && j==max && (dir==2 || dir==10))result = true
        else if(w && j>max)result = false
        if(slope != 0) return result
      }
    }
    else if(r_dir == 8){
      for(local j = 0;true;j++){
        local t = tile_x((coora.x - j), coora.y , coora.z)
        if (!t.is_valid()){
          return false
        }
        local w = t.find_object(mo_way)
        if (!w){
          t.z--
          w = t.find_object(mo_way)
        }
        local slope = t.get_slope()
        local dir = w? w.get_dirs():0
        if(w && j==max && (dir==2 || dir==10))result = true
        else if(w && j>max)result = false
        if(slope != 0) return result
      }
    }
    else if(r_dir == 4){
      for(local j = 0;true;j++){
        local t = tile_x(coora.x, (coora.y + j), coora.z)
        if (!t.is_valid()){
          return false
        }
        local w = t.find_object(mo_way)
        if (!w){
          t.z--
          w = t.find_object(mo_way)
        }
        local slope = t.get_slope()
        local dir = w? w.get_dirs():0
        if(w && j==max && (dir==4 || dir==5))result = true
        else if(w && j>max)result = false
        if(slope != 0) return result
      }
    }
    else if(r_dir == 1){
      for(local j = 0;true;j++){
        local t = tile_x(coora.x, (coora.y - j), coora.z)
        if (!t.is_valid()){
          return false
        }
        local w = t.find_object(mo_way)
        if (!w){
          t.z--
          w = t.find_object(mo_way)
        }
        local slope = t.get_slope()
        local dir = w? w.get_dirs():0
        if(w && j==max && (dir==1 || dir==5))result = true
        else if(w && j>max)result = false
        if(slope != 0) return result
      }
    }
    return result
  }
  //Comprueba conexion entre vias
  //dir 0 = auto
  //dir 2 = coorda.y--
  //dir 3 = coorda.y++
  //dir 5 = coorda.x++
  //dir 6 = coorda.x--
  function get_fullway(coora, coorb, dir, obj, tun=false)
  {
    local tilea = tile_x(coora.x,coora.y,coora.z)
    local tileb = tile_x(coorb.x,coorb.y,coorb.z)
    local way = tilea.find_object(mo_way)
    local res = r_way
    res.c = coora
    res.r = false
    if (!way)
      return res
    if (obj){
      if (obj == mo_wayobj){
        if(!way.is_electrified()){
          way.mark()
          if (!tun)
            label_x.create(coora, player_x(1), translate("Here"))
          return res
        }
        else{
          tilea.remove_object(player_x(1), mo_label)
          way.unmark()
        }
      }
    }

    local r_dir = way_x(coora.x, coora.y, coora.z).get_dirs()
    if (dir == 0) dir = c_dir(coora, coorb, r_dir)
    local c_way = coora
    local ribi = 0
    local vl = array(10)
    vl[3]=3
    vl[5]=5
    vl[2]=2
    vl[6]=6
    if (dir==1){
      if (r_dir==2 || r_dir==10)
        dir=6
      else if (r_dir==4 || r_dir==5)
        dir=2
      else if (r_dir==3){
        tilea.find_object(mo_way).unmark()
        dir=2
        coora.y--
      }
      else if (r_dir==6){
        tilea.find_object(mo_way).unmark()
        dir=3
        coora.y++
      }
    }
    else if (dir==2){
      if (r_dir==1)
        coora.y--
    }
    else if (dir==3){
      if (r_dir==4)
        coora.y++
    }
    else if (dir==4){
      if (r_dir==1 || r_dir==5)
        dir=3
      else if (r_dir==8 || r_dir==10)
        dir=5
      else if (r_dir==3){
        tilea.find_object(mo_way).unmark()
        dir=5
        coora.x++
      }
      else if (r_dir==9){
        tilea.find_object(mo_way).unmark()
        dir=6
        coora.x--
      }
    }
    else if (dir==5){
      if (r_dir==2)
        coora.x++
    }
    else if (dir==6){
      if (r_dir==8)
        coora.x--
    }
    local count = 0
    res.l = false
    res.p = 0
    while(true){
      local tile = tile_x(coora.x,coora.y,coora.z)
      local tunnel = tile.find_object(mo_tunnel)
      local bridg = tile.find_object(mo_bridge)
      local way_hold = tile.find_object(mo_way)
      local slp = tile.get_slope()
      local type = false
      local t_type = false
      local way = false
      local ribi = false
      local squ = square_x(coora.x,coora.y)
      local sq_z = squ.get_ground_tile().z

      if(tun){
        if(tile.z == sq_z){
          local test = squ.get_tile_at_height(coora.z -1)
          if(test != null)
            coora.z--
        }
        else  {

          local c_z = coora.z -1
          for(local j = c_z;j<=(c_z+2);j++){
            local c_test = squ.get_tile_at_height(j)
            if(c_test && c_test.is_valid()){
              local way = c_test.find_object(mo_way)
              if(way){
                if(!tun && sq_z != c_test.z)
                  continue
                //gui.add_message("way "+coora.x+" :: "+coora.z+","+c_test.z+"  -p "+res.p+" :: slp "+ slope.to_dir(c_test.get_slope()) +" - "+slope.to_dir(res.s))
                if(sq_z != c_test.z && ( slp != 0 && (slope.to_dir(c_test.get_slope()) == res.s || res.s == 0)) && (c_test.z == coora.z || res.p == 1 )){
                  res.p = 1
                }
                else res.p = 0
                if(way_hold && way.get_dirs() == way_hold.get_dirs()) {
                  coora.z = c_test.z
                  break

                }
                //gui.add_message("way2 "+coora.x+" :: "+coora.z+","+c_test.z+"  - "+sq_z+" :: slp "+ slp)
                coora.z = c_test.z
                break
              }
            }
          }
        }
      }
      else{
        if(res.z != null){
          for(local j = 0;j<3;j++){
            local t_test = squ.get_tile_at_height(tile.z + j)
            if(t_test){
              local test_brid = t_test.find_object(mo_bridge)
              if(test_brid){
                //gui.add_message("Brid "+t_test.x+","+t_test.y+","+t_test.z+"  - "+t_test.is_bridge()+"")
                coora.z = t_test.z
                bridg = test_brid
                break

              }
            }
          }
        }
        if(bridg){
          res.z = res.z == null? (coora.z+1) : res.z

        }
        else{
          res.z = null
          if(squ.get_tile_at_height(coora.z)== null){
            coora.z = sq_z
          }
        }
      }

      r_way_list[coord3d_to_key(coora)] <- coora
      persistent.r_way_list = r_way_list
      res.c = coora
      local t = tile_x(coora.x, coora.y, coora.z)
      way = t.find_object(mo_way)

      local nw_slp = slope.to_dir(t.get_slope())
      if( nw_slp == 0) res.p = 0

      res.s = nw_slp
      //gui.add_message("way "+coora.x+","+coora.y+","+coora.z+"  - "+squ.get_tile_at_height(coora.z)+"")
      if(way){
        if (res.m && t.is_marked() || !res.m && !t.is_marked()){
          if (count>1){
            res.l = true
            res.m = !res.m

            return res
          }
          else
            count ++
        }
        if (res.m){
          if(!t.is_marked())
            t.mark()
        }
        else {
          if(t.is_marked())
            t.unmark()
        }
        ribi = t.find_object(mo_way).get_dirs()
      }
      else{
        return res
      }

      //gui.add_message("way "+coora.x+","+coora.y+","+coora.z+"  - "+ribi+"")
      if (obj){
        if (obj == mo_wayobj){
          if(!way.is_electrified()){
            way.mark()
            if (!tun)
              label_x.create(coora, player_x(1), translate("Here"))

            return res
          }
          else{
            t.remove_object(player_x(1), mo_label)
            way.unmark()
          }
        }
      }
      if(coora.x==coorb.x && coora.y==coorb.y && coora.z==coorb.z){
        if (t_type)
          way.unmark()
        if (res.m){
          return res
        }
        else{
          r_way_list = {}
          persistent.r_way_list = r_way_list
          res.r = true
          return res
        }
      }

      if ((ribi==1)||(ribi==2)||(ribi==4)||(ribi==8)){
        //gui.add_message(""+ribi+"---"+name+" ("+coora.x+","+coora.y+","+coora.z+")")
        way.mark()
        //Detecta la pocision del cursor
        cursor_control(coora)
        res.m = !res.m
        return res
      }
      else{
        way.unmark()
      }

      if (dir==2){

        if (ribi==5){
          coora.y--
          continue
        }

        else if (ribi==6){
          dir = vl[5]
          coora.x++
          continue
        }
        else if (ribi==12){
          dir = vl[6]
          coora.x--
          continue
        }

        else if (ribi==14){
          dir = vl[5]
          coora.x++
          continue
        }

        else if ((ribi==7 || ribi==11 || ribi==13 || ribi==15)){
          coora.y--
          continue
        }
      }

      else if (dir==3){

        if (ribi==5){
          coora.y++
          continue
        }

        else if (ribi==3){
          dir = vl[5]
          coora.x++
          continue
        }

        else if (ribi==9){
          dir = vl[6]
          coora.x--
          continue
        }

        else if (ribi==11){
          dir = vl[5]
          coora.x++
          continue
        }

        else if ((ribi==7 || ribi==13 || ribi==14 || ribi==15)){
          coora.y++
          continue
        }
      }
      else if (dir==5){

        if (ribi==10){
          coora.x++
          continue
        }
        else if (ribi==12){
          dir = vl[3]
          coora.y++
          continue
        }
        else if (ribi==9){
          dir = vl[2]
          coora.y--
          continue
        }
        else if (ribi==13){
          dir = vl[2]
          coora.y--
          continue
        }
        else if ((ribi==7 || ribi==11 || ribi==14 || ribi==15)){
          coora.x++
          continue
        }
      }
      else if (dir==6){

        if (ribi==10){
          coora.x--
          continue
        }

        else if (ribi==3){
          dir = vl[2]
          coora.y--
          continue
        }
        else if (ribi==6){
          dir = vl[3]
          coora.y++
          continue
        }

        else if (ribi==7){
          dir = vl[3]
          coora.y++
          continue
        }

        else if ((ribi==11 || ribi==14 || ribi==15)){
          coora.x--
          continue
        }
      }
      return res
    }
  }

  function c_dir(coora, coorb, ribi)
  {
    local dir = 0
    //coorda.x-- y coorda.y--
    if(coora.x>coorb.x && coora.y>coorb.y){
      if(ribi==5)
        return dir=5

      else if(ribi==10)
        return dir=6
      return dir=1
    }

    //coorda.x y coorda.y--
    else if(coora.x==coorb.x && coora.y>coorb.y){
      return dir=2
    }

    //coorda.x y coorda.y++
    else if(coora.x==coorb.x && coora.y<coorb.y){
      return dir=3
    }

    //coorda.x y++ coorda.y++
    else if(coora.x<coorb.x && coora.y<coorb.y){
      return dir=4
    }

    //coorda.x++ y coorda.y
    else if(coora.x<coorb.x && coora.y==coorb.y){
      return dir=5
    }

    //coorda.x-- y coorda.y
    else if(coora.x>coorb.x && coora.y==coorb.y){
      return dir=6
    }

    else
      return dir
  }

  function get_dir_start(coord,opt = 0)
  {
    local way = tile_x(coord.x,coord.y,coord.z).find_object(mo_way)
    if (!way)
      return 0

    local ribi = way.get_dirs()

    //Normal
    if (opt==0){

      if (ribi==1)
        return 3

      else if (ribi==2)
        return 6

      else if (ribi==4)
        return 2

      else if (ribi==8)
        return 5

      else
        return 0
    }
    //Inverso
    if (opt==1){

      if (ribi==1)
        return 2

      else if (ribi==2)
        return 5

      else if (ribi==4)
        return 3

      else if (ribi==8)
        return 6

      else
        return 0
    }
    return null
  }

  //Pendiente de media altura
  function slope_rotate(slope)
  {
    local test=coord3d(0,0,1)
    local txt=test.tostring()
    if (txt=="0,0,1"){
      if (slope==4)
        return true
    }

    else if (txt=="127,0,1"){
      if (slope==28)
        return true
    }

    else if (txt=="127,127,1"){
      if (slope==36)
        return true
    }
    else if (txt=="0,127,1"){
      if (slope==12)
        return true
    }
    else
      return false
  }

  function way_is_bridge(coord, ribi)
  {
    local tile = tile_x(coord.x, coord.y, coord.z)
    local way = tile.find_object(mo_way)
    local wt = way.get_waytype()
    local t
    local count = 1
    foreach(r in dir.nsew){

      t = tile.get_neighbour(wt,r)
      while (t  &&  t.is_bridge()  &&  !t.is_ground()){
        t = t.get_neighbour(wt,r)
        count++
      }
      if (t  && t.is_bridge()){
        count++
        return count
      }
    }
    return count

  }

  function all_control(result, wt, st, way, ribi, tool_id, pos, coor, name, plus = 0){
    local t = tile_x(coor.x, coor.y, coor.z)
    local brig = t.find_object(mo_bridge)
    local desc = way_desc_x.get_available_ways(wt, st)
    if ((tool_id==tool_remove_way)||(tool_id==tool_remover)){
      if (way && way.get_waytype() != wt)
        return result

      else {
        local cur_key = coord3d_to_key(pos)
        result = translate("Action not allowed")+" ("+pos.tostring()+")."
        if(way && way.get_desc().get_system_type() == st_elevated)
          return null

        foreach(key, c in r_way_list){
          if(key == cur_key){
            //delete r_way_list[key] //Delate objt example
            //gui.add_message("key: "+key+" ckey: "+cur_key)
            return null
            break
          }
        }
        local br = tile_x(pos.x, pos.y, pos.z).find_object(mo_bridge)
        if(br){
          local br_key = coord3d_to_key(coord3d(pos.x, pos.y, t.z))
          foreach(key, c in r_way_list){
            if(key == br_key){
              //delete r_way_list[key] //Delate objt example
              //gui.add_message("kkey: "+key+" br_key: "+br_key)
              return result
            }
          }
          return null
        }
        return result
      }
    }
    else if (r_way.l)
      return translate("The track is stuck, use the [Remove] tool here!")+" ("+coord3d_to_string(t)+")."

    //Control para que los puentes funcionen bien
    bridge_control(way, tool_id)
    if (bridge_sw){
      return null
    }
    else if ((pos.x == t.x && pos.y == t.y && pos.z == t.z)||(cursor_sw)){
      if (tool_id==tool_build_way || tool_id==tool_build_tunnel){
        if ((ribi==0) || (ribi==1) || (ribi==2) || (ribi==4) || (ribi==8)){
		if(t.find_object(mo_tunnel)){
			return null
		}
          foreach(d in desc){
            //gui.add_message(d.get_name()+" :: "+name)
            if(d.get_name() == name){
              return null
            }
          }
          return translate("Action not allowed")+" ("+pos.tostring()+")."
        }
        else{
          under_lv = settings.get_underground_view_level()
          //gui.add_message("pos: "+coor+" plus: "+r_way.p )
          if (under_lv != norm_view){
            local sq = square_x(pos.x,pos.y)
            local sq_z = sq.get_ground_tile().z
            local c_test = sq.get_tile_at_height(t.z+plus)
            if((!c_test || !way) && under_lv <= t.z && pos.z < sq_z){
              return null
            }
          }
          return translate("No intersections allowed")+" ("+pos.tostring()+")."
        }
      }
      else
        return translate("Action not allowed")+" ("+pos.tostring()+")."
    }
    else if(brig) {
      if (tool_id==tool_build_way) {
        if ((ribi==0) || (ribi==1) || (ribi==2) || (ribi==4) || (ribi==8)){
          return null
        }
      }
    }
    else{
      foreach(d in desc){
        //gui.add_message(d.get_name()+" :: "+name)
        if(d.get_name() == name){
          return translate("Connect the Track here")+" ("+coord3d(coor.x, coor.y, coor.z).tostring()+")."
        }
      }
      return translate("Action not allowed")+" ("+pos.tostring()+")."
    }
    return ""
  }

  function cursor_control(coord)
  {

    local tile_coord = tile_x(coord.x, coord.y, coord.z)
    //local tile_pos = tile_x(pos.x, pos.y, pos.z)
    if (tile_coord.find_object(mo_pointer))
      return cursor_sw = true

    else
      return cursor_sw = false


    return null
  }

  function bridge_control(way, tool_id){

    if (tool_id==4111 && way ) { bridge_sw = true}
    if (bridge_count >2){
      bridge_count = 0
      bridge_sw = false
    }
    if (bridge_sw && tool_id==4110){bridge_count++}

    else if (bridge_sw && !way){bridge_count = 0}

    return null
  }

  function get_corret_slope(slope, corret_slope)
  {
    //gui.add_message(""+slope +" "+corret_slope)
    if (slope==corret_slope ) { //72
      return true
    }

    else if(slope==36){
      slope_estatus[0] = 1      //Es de media altura ? ?
      slope_estatus[1] = 0      //Es de es terreno plano ??
      slope_estatus[2] = 1    //noreste ??
      slope_estatus[3] = 0    //noroeste ??
      slope_estatus[4] = 0    //sureste ??
      slope_estatus[5] = 0    //suroeste ??
    }
    else if(slope==4){
      slope_estatus[0] = 1      //Es de media altura ? ?
      slope_estatus[1] = 0      //Es de es terreno plano ??
      slope_estatus[2] = 0    //noreste ??
      slope_estatus[3] = 0    //noroeste ??
      slope_estatus[4] = 0    //sureste ??
      slope_estatus[5] = 1    //suroeste ??
    }
    else if(slope==12){
      slope_estatus[0] = 1      //Es de media altura ? ?
      slope_estatus[1] = 0      //Es de es terreno plano ??
      slope_estatus[2] = 0    //noreste ??
      slope_estatus[3] = 0    //noroeste ??
      slope_estatus[4] = 1    //sureste ??
      slope_estatus[5] = 0    //suroeste ??
    }
    else if(slope==28){
      slope_estatus[0] = 1      //Es de media altura ? ?
      slope_estatus[1] = 0      //Es de es terreno plano ??
      slope_estatus[2] = 0    //noreste ??
      slope_estatus[3] = 1    //noroeste ??
      slope_estatus[4] = 0    //sureste ??
      slope_estatus[5] = 0    //suroeste ??
    }
    else if(slope==8){
      slope_estatus[0] = 0      //Es de media altura ? ?
      slope_estatus[1] = 0      //Es de es terreno plano ??
      slope_estatus[2] = 0    //noreste ??
      slope_estatus[3] = 0    //noroeste ??
      slope_estatus[4] = 0    //sureste ??
      slope_estatus[5] = 1    //suroeste ??
    }
    else if(slope==24){
      slope_estatus[0] = 0      //Es de media altura ? ?
      slope_estatus[1] = 0      //Es de es terreno plano ??
      slope_estatus[2] = 0    //noreste ??
      slope_estatus[3] = 0    //noroeste ??
      slope_estatus[4] = 1    //sureste ??
      slope_estatus[5] = 0    //suroeste ??
    }
    else if(slope==56){
      slope_estatus[0] = 0      //Es de media altura ? ?
      slope_estatus[1] = 0      //Es de es terreno plano ??
      slope_estatus[2] = 0    //noreste ??
      slope_estatus[3] = 1    //noroeste ??
      slope_estatus[4] = 0    //sureste ??
      slope_estatus[5] = 0    //suroeste ??
    }
    else if(slope==0){
      slope_estatus[0] = 0      //Es de media altura ? ?
      slope_estatus[1] = 1      //Es de es terreno plano ??
      slope_estatus[2] = 0    //noreste ??
      slope_estatus[3] = 0    //noroeste ??
      slope_estatus[4] = 0    //sureste ??
      slope_estatus[5] = 0    //suroeste ??
    }
    return false

  }

  function get_signa(t, nr, addr)
  {
    local ribi
    if  (t.find_object(mo_signal))
      ribi = way_x(t.x, t.y, t.z).get_dirs_masked()
    else ribi = 0

    if (t.find_object(mo_roadsign)){
      //t.remove_object(player_x(0), mo_roadsign)
      glsw[nr] = 0
      sigcoord = null
      persistent.sigcoord = sigcoord
      return translate("It must be a block signal!")+" ("+coord3d_to_string(t)+")."
    }
    if (glsw[nr] == 0 && ribi != addr){
      sigcoord = t
      persistent.sigcoord = sigcoord
      return null
    }
    else if (glsw[nr] == 1)return translate("The signal is ready!")+" ("+coord3d_to_string(t)+")."

    if (sigcoord && t.x == sigcoord.x && t.y == sigcoord.y){
      if (ribi == addr){
        glsw[nr] = 1
        sigcoord = null
        persistent.sigcoord = sigcoord
        return translate("The signal is ready!")+" ("+coord3d_to_string(t)+")."
      }

    }
    return translate("The signal does not point in the correct direction")+" ("+coord(sigcoord[0].x,sigcoord[0].y).tostring()+")."
  }

    function get_stop(pos,cs,result,load1,load2,cov,count,sw)
  {
    local allret = {cs=cs,result=result,count=count,pot=null}
    local st_c = coord(pos.x,pos.y)

    if ((count>0)&&(((is_station_build(0, cs[count-1], load1)==null))||(is_station_build(0, cs[count-1], load2)==null))){
      if (load1!="Passagiere"&&load2!="Passagiere")
        allret.result = 1
      else if (load1!="Post"&&load2!="Post")
        allret.result = 2
      else if (load1!="goods_"&&load2!="goods_")
        allret.result = 3
      allret.count = count
      allret.pot=0
      return allret
    }
    else if (sw==0){

      local coora = coord(st_c.x-(cov), st_c.y-(cov))
      local coorb = coord(st_c.x+(cov), st_c.y+(cov))

      if (cov!=0){
        for (local j = coora.x ;j<=coorb.x;j++){
          for (local i = coora.y;i<=coorb.y;i++){
            local tile = tile_x(j, i, 0)

            if (tile.get_halt()){
              local building = map_object_x(j, i, 0, mo_building)
              if (building.get_owner().nr == 0){
                allret.result=translate("It is to close to the other stop")+" ("+coord(j, i).tostring()+")."
                return allret
              }
            }
          }
        }
      }

      cs[count] = {x=st_c.x,y=st_c.y}
      allret.cs = cs
      st_cov[count]= {x1=st_c.x+cov, y1=st_c.y+cov, x2=st_c.x-cov, y2=st_c.y-cov}
      count++
      allret.count = count
      allret.result=null
      allret.pot=1
    }

    else if (sw==1){
      st_cov[count]= {x1=st_c.x+cov, y1=st_c.y+cov, x2=st_c.x-cov, y2=st_c.y-cov}
      if (count==0){
        cs[count] = {x=st_c.x,y=st_c.y}
        allret.cs = cs
        count++
        allret.count = count
        allret.result=null
        allret.pot=1
        return allret
      }
      for(local j=0;(count>0)&&(j<count);j++){
        if((pos.x<=st_cov[j].x1)&&(pos.y<=st_cov[j].y1)&&(pos.x>=st_cov[j].x2)&&(pos.y>=st_cov[j].y2)){
          cs[count] = {x=st_c.x,y=st_c.y}
          allret.cs = cs
          count++
          allret.count = count
          allret.result=null
          allret.pot=1
          return allret
        }
      }
      allret.result= 0 //format(translate("Place station No.%d first"),count+1)+" ("+coord(cs[count].x,cs[count].y).tostring()+")."
      return allret
    }

    return allret

  }

  function mark_waypoint(coora, coorb, cov, del, text, wt, dptype)
  {
    local result = {coord = array(30), nr=0}
    local stnr = 0
    if (!del){
      for (local j = coora.x ;j<=coorb.x;j++){
        for (local i = coora.y;i<=coorb.y;i++){
          local c_label = coord(j,i)
          local coora = coord(j-(cov), i-(cov))
          local coorb = coord(j+(cov), i+(cov))
          for (local j = coora.x ;j<=coorb.x;j++){
            for (local i = coora.y;i<=coorb.y;i++){
              local label = tile_x(j,i,0).find_object(mo_label)
              if (label && label.get_text()==text)
                c_label = coord(j,i)
            }
          }
          local tile = tile_x(c_label.x, c_label.y, 0)

          local label = tile.find_object(mo_label)
          local way = tile.find_object(mo_way)
          local slope = tile.get_slope()
          local depot = tile.find_object(dptype)

          if (!label && way && slope==0 && !depot){
            if (way.get_waytype()!=wt)
              continue

            local ribi = way.get_dirs()
            if ((ribi==1)||(ribi==2)||(ribi==4)||(ribi==8)||(ribi==10)||(ribi==5)){
              label_x.create(c_label, player_x(1), translate(text))
              way.mark()
              local c_sa = coord(c_label.x, c_label.y)
              result.coord[stnr] = {x = c_sa.x, y = c_sa.y}
              stnr++
            }
          }
        }
      }
    }

    if (del){
      for (local j = coora.x ;j<=coorb.x;j++){
        for (local i = coora.y;i<=coorb.y;i++){
          local c_label = coord(j,i)
          local tile = tile_x(c_label.x, c_label.y, 0)
          local label = tile.find_object(mo_label)
          local way = tile.find_object(mo_way)
          if (label && label.get_text()==text){
            tile.remove_object(player_x(1), mo_label)

          }
          if (way)
            way.unmark()
        }
      }
    }
    result.nr = stnr
    return result
  }

    function get_dep_cov_nr(a,b){
    local nr = -1
    for(local j=a;j<b;j++){
      nr++
    }
    return nr
  }

    function start_sch_tmpsw(pl,coord, c_list){
    local depot = null
    try {
      depot = depot_x(coord.x, coord.y, coord.z)  // Deposito /Garaje
    }
    catch(ev) {
      return null
    }
    if(depot){
      local c2d = "coord"
      local cov_list = depot.get_convoy_list() // Lista de vehiculos en el deposito
      local d_nr = cov_list.len()   //Numero de vehiculos en el deposito
      if (d_nr > 0){
            local cov_line = cov_list[0].get_line()
        if(cov_line){
          local sch = cov_line.get_schedule()
          local sch_nr = sch.entries.len()
          if(sch_nr>0){
              for(local j=0;j<c_list.len();j++){
              try {
                 sch.entries[j]
              }
              catch(ev) {
                continue
              }
              local c = c_list[j]
              local type = typeof(c)
              local halt1 = sch.entries[j].get_halt( player_x(pl) )
              local tile_c = type == c2d ? my_tile(c) : tile_x(c.x, c.y, c.z)
              local halt2 = tile_c.get_halt()
              local t1_list = halt1.get_tile_list()
              local t2_list = halt2.get_tile_list()
              local c_buld1 = t1_list[0].find_object(mo_building).get_pos()
              local c_buld2 = t2_list[0].find_object(mo_building).get_pos()
              if(c_buld1.x == c_buld2.x && c_buld1.y == c_buld2.y){
                tmpsw[j] = 1
                tmpcoor.push(tile_c)
              }
            }
          }
        }
      }
    }
  }

    function set_convoy_schedule(pl, coord, wt, line_name)
    {
    local depot = depot_x(coord.x, coord.y, coord.z)  // Deposito /Garaje
    local cov_list = depot.get_convoy_list() // Lista de vehiculos en el deposito
    local d_nr = cov_list.len()   //Numero de vehiculos en el deposito
        if (d_nr == 0) reset_tmpsw()
    if (d_nr == 1 && active_sch_check){
            active_sch_check = false
            local cov_line = cov_list[0].get_line()
            local play =  player_x(pl)
            local sched = schedule_x(wt, [])
      local siz = tmpcoor.len()
      for(local j = 0; j < siz; j++) {
        local c = tmpcoor[j]
            if (tmpsw[j] == 1){
          //gui.add_message("("+tmpcoor[j].x+","+tmpcoor[j].y+")")
              sched.entries.append(schedule_entry_x(c, 0, 0))
        }
        else {
          break
        }
          }
        local entrie

        try {
           entrie = sched.entries[1]
        }
        catch(ev) {
          return null
        }
            if (!cov_line)
                play.create_line(wt)

            else if (cov_line.get_name() == line_name && cov_line.get_waytype() == wt){
                cov_line.change_schedule(play, sched)
            return null
            }
        // find the line - it is a line without schedule and convoys
        local list = play.get_line_list()
        local c_line = null
        foreach(line in list) {
                if (line.get_name() == line_name && line.get_waytype() == wt){
                    c_line = line
                    break
                }
                else {
                if (line.get_waytype() == wt  &&  line.get_schedule().entries.len()==0) {
                  // right type, no schedule -> take this.
                        line.set_name(line_name)
                  c_line = line
                  break
                }
                }
        }
      if(c_line){
        c_line.change_schedule(play, sched)
        cov_list[0].set_line(play, c_line)
      }

        return null
        }
        return null
    }

    function update_convoy_schedule(pl, wt, name, schedule)
    {     //gui.add_message("noooo")
        local play =  player_x(pl)

      // find the line - it is a line without schedule and convoys
      local list = play.get_line_list()

        foreach(line in list) {
            if (line.get_name() == name && line.get_waytype() == wt){

                line.change_schedule(play, schedule)
                //cov.set_line(play, line)
            }
        }

      return null
    }

  function is_stop_allowed(result, siz, c_list, pos)
  {
    local st_count=0
    for(local j=0;j<siz;j++){
      if (glsw[j]==1)
        st_count++
    }
    if (st_count<siz){
      local c2d = "coord"
      for(local j=0;j<siz;j++){
        local c = c_list[j]
        local type = typeof(c)
        local t = type == c2d ? my_tile(c) : tile_x(c.x, c.y, c.z)
        if(tmpsw[j]==0){
          if ((pos.x == c.x)&&(pos.y == c.y)){
            tmpsw[j] = 1
            tmpcoor.push(t)
            return null
          }
          else{
            local halt = t.get_halt()
            return format(translate("Select station No.%d [%s]"),j+1 , halt.get_name())+" ("+coord3d_to_string(t)+")."
          }
        }
        if (j == siz-(1))
          return result
      }
    }

    return 0
  }

  function is_stop_allowed_ex(result, siz, list, pos, wt)
  {
    local t_list = is_water_entry(list)
    local t = tile_x(pos.x, pos.y, pos.z)
    local buil = t.find_object(mo_building)
    local is_wt = buil ? buil.get_waytype():null

    local has_way = t.has_way(wt)

    if(t.is_water()){
      is_wt = wt_water
      has_way = true
    }

    local get_cl = square_x(pos.x, pos.y).get_climate()
    local st_count=0
    for(local j=0;j<siz;j++){
      if (glsw[j]==1)
        st_count++
    }
    if (st_count<siz){
      local j = 0
      local c2d = "coord"
      foreach(t in t_list){

        local c = list[j]
        local type = typeof(c)
        local st_t = type == c2d ? my_tile(c) : tile_x(c.x, c.y, c.z)
        local halt = st_t.get_halt()
        local tile_list = halt.get_tile_list()
        local max = tile_list.len()
        //local c_lim_list = {a = tile_list[0], b = tile_list[max-1]}
        //gui.add_message(""+j+" :: "+tmpsw[j])
        if(tmpsw[j] == 0){
          //if(max == 1 && t.is_water()) return check_water_tile(result, tile_list[0], pos, j)
          if(wt == wt_water && t.is_water()){
            local area = get_tiles_near_stations(tile_list)
            for(local i=0;i<area.len();i++){
              local t_water = my_tile(area[i])
              //t_water.mark()
              //gui.add_message(""+t_water.x+","+t_water.y+"")
              if (pos.x == t_water.x && pos.y == t_water.y){
                if(t_water.is_water()){
                  tmpsw[j] = 1
                  tmpcoor.push(t)
                  result = null
                  break
                }
                else
                  result = format(translate("Select station No.%d"),j+1)+" ("+c.tostring()+")."
              }
              else
                result = format(translate("Select station No.%d"),j+1)+" ("+c.tostring()+")."
            }
            return result
          }
          foreach(tile in tile_list){
            if (pos.x == tile.x && pos.y == tile.y && pos.z == tile.z){
              if(has_way && wt == is_wt){
                tmpsw[j] = 1
                tmpcoor.push(st_t)
                return null
              }
              else
                return format(translate("Select station No.%d"),j+1)+" ("+c.tostring()+")."
            }
          }
          return format(translate("Select station No.%d"),j+1)+" ("+c.tostring()+")."
        }
        j++
        if (j == t_list.len())
          return result
      }
    }

    return 0
  }
  function get_c_key(c, i){
    local res =  ("coord_" + c.x + "_" + c.y + "_" + c.z +"_"+i).toalnum()
    gui.add_message(""+res)
    return res
  }

  function get_tiles_near_stations(tile_list)
  {
    local cov = settings.get_station_coverage()
    local area = []

    local ftiles = tile_list
    foreach (c in ftiles) {
      for(local dx = -cov; dx <= cov; dx++) {
        for(local dy = -cov; dy <= cov; dy++) {
          if (dx==0 && dy==0) continue;

          local x = c.x+dx
          local y = c.y+dy

          if (x>=0 && y>=0 && world.is_coord_valid({x=x,y=y})){
            local tile = square_x(x, y).get_ground_tile()
            area.append( tile );

          }
        }
      }
    }
    return area.len() > 0 ?  area : []
  }

  function check_water_tile(result, t, pos, nr)
  {
    local tile = my_tile(pos)
    local halt = tile.get_halt()
    local slope = tile.get_slope()


    switch (slope){
      case 0:
      break
      case 4:
        t.y--
      break

      case 12:
        t.x--
      break

      case 28:
        t.x++
      break

      case 36:
        t.y++
      break

      case 56:
        t.x++
      break

      case 72:
        t.y++
      break

      default:
      return "nope"
      break
    }
    if(pos.x == c.x && pos.y == c.y){
      if(tmpsw[nr]==0){
        tmpsw[nr] = 1
        tmpcoor.push(t)
        return null
      }
      return result
    }

    return format(translate("Select station No.%d"),nr+1)+" ("+c.tostring()+")."
  }

  function is_stop_building(siz, c_list, lab_name, good, label_sw = false)
  {
    local player = player_x(1)
    local count = 0
    for(local j=0;j<siz;j++){
      local c = c_list[j]
      local t = my_tile(c)
      local buil = t.find_object(mo_building)
      local label = t.find_object(mo_label)
      local way = t.find_object(mo_way)
      local halt = t.get_halt()
      if(t.is_marked())
        t.remove_object(player, mo_label)

      if(buil && halt){
        local desc = buil.get_desc()
        local g_list = get_build_load_type(desc)
        local is_good = station_compare_load(good, g_list)
        if(is_good) {
          if(way){
            way.unmark()
          }
          glsw[j]=1
          count++
          if (count==siz) {
            return true
          }
        }
      }
      else{
        glsw[j]=0
        if (way && !way.is_marked()){
          way.mark()
        }
        if (!label && !t.is_marked()) {
          label_x.create(c, player, lab_name)
        }
      }
    }
    return false
  }

  function is_stop_building_ex(siz, list, lab_name)
  {
    local player = player_x(1)
    local count = 0
    for(local j=0;j<siz;j++){
      local c = list[j].c
      local name = list[j].name
      local good = list[j].good
      local t = my_tile(c)
      local label = t.find_object(mo_label)
      local way = t.find_object(mo_way)
      local buil = t.find_object(mo_building)
      local halt = t.get_halt()

      //gui.add_message("b"+glsw[j]+" "+j)

      if(buil && halt){
        local desc = buil.get_desc()
        local g_list = get_build_load_type(desc)
        local is_good = station_compare_load(good, g_list)
        if(name == "" && is_good) {
          if(way){
            way.unmark()
          }
          glsw[j]=1
          count++
          if (count==siz) {
            return true
          }
        }
        if(name == desc.get_name() && is_good){
          glsw[j]=1
          count++
          if (count==siz) {
            return true
          }
        }
      }
      else {
        if(way){
          way.mark()
        }
        else{
          public_label(t, lab_name)
        }
      }
    }
    return false
  }

  function build_stop(nr, c_list, tile, way, slope, ribi, label, pos)
  {

    local result = 0
    if (!way)
      return translate("You can only build stops on roads")+" ("+pos.tostring()+")."
    else if (slope!=0)
      return translate("You can only build stops on flat ground")+" ("+pos.tostring()+")."
    else if (label && label.get_text()=="X")
      return translate("Indicates the limits for using construction tools")+" ("+pos.tostring()+")."
    else if (ribi==3 || ribi==6 || ribi==9 || ribi==12)
      return translate("You can only build on a straight road")+" ("+pos.tostring()+")."
    else if (ribi==7 || ribi==11 || ribi==13 || ribi==14 || ribi==15)
      return translate("It is not possible to build stops at intersections")+" ("+pos.tostring()+")."

    for(local j=0;j<nr;j++){
      local halt = tile_x(c_list[j].x, c_list[j].y, 0).get_halt()
      if (halt){
        local name = halt.get_name()
        local is_good = halt.accepts_good(good_desc_x(good_alias.passa))
        if (!is_good){
          return format(translate("The %s stop must be for %s"),name, translate("Passagiere"))+" ("+coord(c_list[j].x,c_list[j].y).tostring()+")."
        }
      }
    }
    for(local j=0;j<nr;j++){
      local st_c = coord(c_list[j].x, c_list[j].y)
      local mail = good_alias.mail
      local goods = good_alias.goods
      if ((pos.x == st_c.x) && (pos.y == st_c.y)){
        if (glsw[j]==0){
          way.unmark()
          return null
        }
        else
          return translate("There is already a stop here")+" ("+coord(c_list[j].x,c_list[j].y).tostring()+")."
      }
      else if (glsw[j]==0)
        result = translate("Place the stops at the marked points")+" ("+coord(c_list[j].x,c_list[j].y).tostring()+")."
    }
    return result

  }
  function get_build_load_type(desc)
  {
    local list = []
    if (desc.enables_pax())
      list.push(good_alias.passa)

    if (desc.enables_mail())
      list.push(good_alias.mail)

    if (desc.enables_freight())
      list.push(good_alias.goods)

    return list
  }

  function station_compare_load(good, g_list)
  {
    local is_good = false
    local type = typeof(good)
    if(type == "array"){
      local siz =  good.len()
      local count = 0
      foreach(g in g_list){
        foreach(i in good){
          if(i == g)
            count++
        }
      }
      if(count == siz)
        is_good = true
    }
    else {
      foreach(g in g_list){
        if(g == good)
          is_good = true
      }
    }
    return is_good
  }
  function get_good_text(good)
  {
    local tx = ""
    local type = typeof(good)
    if(type=="array"){
      foreach(i in good){
        if(tx != "")
          tx+= ", "
        tx+= translate(i)+""
      }
    }
    else
      return translate(good)

    return tx
  }

  function get_build_name(siz, desc, freight, wt)
  {
    local list = building_desc_x.get_available_stations(desc, wt, good_desc_x(freight))
    foreach(build in list) {
      if (build.is_available(0) && (siz == null || build.get_size(0).x == siz.x &&  build.get_size(0).y == siz.y)) {
        //gui.add_message(""+build.get_name())
        return build.get_name()
      }
    }
    return "No have build!"
  }

  function get_way_name(kh, wt, st)
  {
    local list = way_desc_x.get_available_ways(wt, st)
    foreach(way in list) {
      if (way.is_available(0) && way.get_topspeed() >= kh) {
        //gui.add_message(""+way.get_name())
        return way.get_name()
      }
    }
    return "No have way!"
  }

  function build_stop_ex(nr, list, tile)
  {
    local result = 0
    for(local j=0; j<nr; j++){
      local good = list[j].good
      local name = list[j].name
      local c = list[j].c
      //gui.add_message(""+glsw[j]+" "+j+" "+nr+" "+c)
      local tile = my_tile(c)
      local buil = tile.find_object(mo_building)
            local halt = tile.get_halt()
      if(buil){
        local desc = buil.get_desc()
        local halt_name = halt.get_name()
        local g_list = get_build_load_type(desc)
        local is_good = station_compare_load(good, g_list)
        if (!is_good){
          local tx_good = get_good_text(good)
          local tx = "The extension building for station [%s] must be for [%s], use the 'Remove' tool"
          return format(translate(tx), halt_name, tx_good)+" ("+c.tostring()+")."
        }

                local build_name = buil.get_desc().get_name()
                local st_name = translate(""+name+"")
                if (name != "" && build_name != name){
          local tx = "The extension building for station [%s] must be a [%s], use the 'Remove' tool"
                    return format(translate(tx), halt_name, st_name )+" ("+c.tostring()+")."
        }
      }
    }
    for(local j=0; j<nr; j++){
      local c = list[j].c
      //gui.add_message("a"+glsw[j])
      if ((tile.x == c.x) && (tile.y == c.y)){
        if (glsw[j]==0){
          return null
        }
        else
          return translate("There is already a stop here")+" ("+c.tostring()+")."
      }
      else if (glsw[j]==0)
        result = translate("Place the stops at the marked points")+" ("+c.tostring()+")."
    }
    return result

  }

  function delete_stop(nr, c_list, way, pos)
  {
    for(local j=0;j<nr;j++){
      if (c_list[j] != null){
        local stop = tile_x(c_list[j].x,c_list[j].y,0).find_object(mo_building)
        if ((pos.x==c_list[j].x)&&(pos.y==c_list[j].y)&&(stop)){
          way.mark()
          return null
        }
      }
    }
    return translate("You can only delete the stops.")
  }

  function delete_stop_ex(nr, list, pos)
  {
    for(local j=0;j<nr;j++){
      local c = list[j].c
      if (c != null){
        local stop = my_tile(c).find_object(mo_building)
        if ((pos.x == c.x)&&(pos.y == c.y)&&(stop)){
          return null
        }
      }
    }
    return translate("You can only delete the stops.")
  }

  function tile_bord(coora, coorb, opt, del)
  {
    if (opt==0){
      if (!del){
        for (local j = coora.x ;j<=coorb.x;j++){
          local coor1 = coord(j, coora.y)
          local coor2 = coord(j, coorb.y)
          tile_x(coor1.x, coor1.y, 0).mark()
          tile_x(coor2.x, coor2.y, 0).mark()

          for (local i = coora.y;i<=coorb.y;i++){
            coor1 = coord(coora.x, i)
            coor2 = coord(coorb.x, i)
            tile_x(coor1.x, coor1.y, 0).mark()
            tile_x(coor2.x, coor2.y, 0).mark()
          }
        }
      }

      else {
        for (local j = coora.x ;j<=coorb.x;j++){
          local coor1 = coord(j, coora.y)
          local coor2 = coord(j, coorb.y)
          tile_x(coor1.x, coor1.y, 0).unmark()
          tile_x(coor2.x, coor2.y, 0).unmark()

          for (local i = coora.y;i<=coorb.y;i++){
            coor1 = coord(coora.x, i)
            coor2 = coord(coorb.x, i)
            tile_x(coor1.x, coor1.y, 0).unmark()
            tile_x(coor2.x, coor2.y, 0).unmark()
          }
        }
      }
    }
    if (opt==1){
      if (!del){
        for (local j = coora.x ;j<=coorb.x;j++){
          for (local i = coora.y;i<=coorb.y;i++){
            tile_x(j,i,0).mark()
          }
        }
      }
      if (del){
        for (local j = coora.x ;j<=coorb.x;j++){
          for (local i = coora.y;i<=coorb.y;i++){
            tile_x(j,i,0).unmark()
          }
        }
      }
    }
  }
  function label_bord(coora, coorb, opt, del, text, wt=null)
  {
    local c_a = coord(coora.x, coora.y)
    local c_b = coord(coorb.x, coorb.y)
    if (opt==0){
      if (!del){
        for (local j = c_a.x ;j<=c_b.x;j++){
          local coor1 = coord(j, c_a.y)
          local coor2 = coord(j, c_b.y)
          local label1 = tile_x(coor1.x, coor1.y, 0).find_object(mo_label)
          local label2 = tile_x(coor2.x, coor2.y, 0).find_object(mo_label)
          if (!label1){
            label_x.create(coor1, player_x(1), translate(text))
            local label = tile_x(coor1.x,coor1.y,0).find_object(mo_label)
            if (label)
              label.mark()
          }
          if (!label2){
            label_x.create(coor2, player_x(1), translate(text))
            local label = tile_x(coor2.x,coor2.y,0).find_object(mo_label)
            if (label)
              label.mark()
          }
          for (local i = c_a.y;i<=c_b.y;i++){
            coor1 = coord(c_a.x, i)
            coor2 = coord(c_b.x, i)
            label1 = tile_x(coor1.x, coor1.y, 0).find_object(mo_label)
            label2 = tile_x(coor2.x, coor2.y, 0).find_object(mo_label)
            if (!label1){
              label_x.create(coor1, player_x(1), translate(text))
              local label = tile_x(coor1.x,coor1.y,0).find_object(mo_label)
              if (label)
                label.mark()
            }
            if (!label2){
              label_x.create(coor2, player_x(1), translate(text))
              local label = tile_x(coor2.x,coor2.y,0).find_object(mo_label)
              if (label)
                label.mark()
            }
          }
        }
      }

      if (del){

        for (local j = c_a.x ;j<=c_b.x;j++){

          local coor1 = my_tile(coord(j, c_a.y))
          local coor2 = my_tile(coord(j, c_b.y))

          local tile1 = tile_x(coor1.x, coor1.y, coor1.z)
          local tile2 = tile_x(coor2.x, coor2.y, coor2.z)

          local label1 = tile1.find_object(mo_label)
          if (label1 && label1.get_text()==text){
            tile1.remove_object(player_x(1), mo_label)
          }
          local label2 = tile2.find_object(mo_label)
          if (label2 && label2.get_text()==text){
            tile2.remove_object(player_x(1), mo_label)
          }
          for (local i = c_a.y;i<=c_b.y;i++){
            local coor1 = my_tile(coord(c_b.x, i))
            local coor2 = my_tile(coord(c_a.x, i))

            local tile1 = tile_x(coor1.x, coor1.y, coor1.z)
            local tile2 = tile_x(coor2.x, coor2.y, coor2.z)

            local label1 = tile1.find_object(mo_label)
            if (label1 && label1.get_text()==text){
              tile1.remove_object(player_x(1), mo_label)
            }
            local label2 = tile2.find_object(mo_label)
            if (label2 && label2.get_text()==text){
              tile2.remove_object(player_x(1), mo_label)
            }
          }
        }
      }
    }
    if (opt==1){
      if (!del){
        for (local j = c_a.x ;j<=c_b.x;j++){
          for (local i = c_a.y;i<=c_b.y;i++){
            label_x.create(coord(j, i), player_x(1), translate(text))
            local label = tile_x(j,i,0).find_object(mo_label)
            label.mark()
          }
        }
      }
      if (del){
        for (local j = c_a.x ;j<=c_b.x;j++){
          for (local i = c_a.y;i<=c_b.y;i++){
            local tile = tile_x(j, i)
            local label = tile.find_object(mo_label)
            if (label && label.get_text()==text)
              tile.remove_object(player_x(1), mo_label)
          }
        }
      }
    }
    if (opt==2){
      if (!del){
        for (local j = c_a.x ;j<=c_b.x;j++){
          for (local i = c_a.y;i<=c_b.y;i++){
            local c = my_tile(coord(j, i))
            local tile = tile_x(c.x, c.y, c.z)
            local way = tile.find_object(mo_way)
            if (way && way.get_waytype()==wt)
              label_x.create(c, player_x(1), translate(text))
          }
        }
      }
      if (del){
        for (local j = c_a.x ;j<=c_b.x;j++){
          for (local i = c_a.y;i<=c_b.y;i++){
            local c = my_tile(coord(j, i))
            local tile = tile_x(c.x, c.y, c.z)
            local way = tile.find_object(mo_way)
            local label = tile.find_object(mo_label)
            if (way && way.get_waytype()==wt && label && label.get_text()==text){
              local c = my_tile(coord(j, i))
              tile.remove_object(player_x(1), mo_label)
            }
          }
        }
      }
    }
    return null
  }

  function delay_mark_tile_list(list, stop = false)
  {

    if (stop){
      foreach(t in list){
        t.unmark()
        foreach(obj in t.get_objects()){
          obj.unmark()
        }
      }
      return true
    }
    local crr_delay = 0x0000000f & time()

    if(crr_delay == tile_delay){
      for(;gl_tile_i < list.len(); ){
        local t = list[gl_tile_i]
        t.mark()
        foreach(obj in t.get_objects()){
          obj.mark()
        }

        gl_tile_i++
        break
      }
      if(gl_tile_i == list.len()){
        tile_delay = 0x0000000f & (crr_delay+1)
        gl_tile_i = 0
      }
      return false
    }
    else {
      for(;gl_tile_i < list.len(); ){
        local t = list[gl_tile_i]
        t.unmark()
        foreach(obj in t.get_objects()){
          obj.unmark()
        }

        gl_tile_i++
        break
      }
      if(gl_tile_i == list.len()){
        tile_delay = 0x0000000f & (crr_delay+1)
        gl_tile_i = 0
      }
      return true
    }
  }

  function delay_mark_tile(list, stop = false)
  {
    if (stop){
      foreach(t in list){
        t.unmark()
        foreach(obj in t.get_objects()){
          obj.unmark()
        }
      }
      return true
    }
    local crr_delay = 0x0000000f & time()
    if(crr_delay == tile_delay){
      foreach(t in list){
        t.mark()
        foreach(obj in t.get_objects()){
          obj.mark()
        }
      }
      return false
    }
    else{
      tile_delay = 0x0000000f & (crr_delay+1)
      foreach(t in list){
        t.unmark()
        foreach(obj in t.get_objects()){
          obj.unmark()
        }
      }
      return true
    }
  }

  function lock_tile_list(c_list, siz, del, pl, text = "X")
  {
      if (!del) {
        for (local j = 0 ;j<siz;j++){
          label_x.create(c_list[j], player_x(pl), text)
        }
      }
      else {
        for (local j = 0 ;j<siz;j++){
          local tile = tile_x(c_list[j].x,c_list[j].y,0)
          tile.remove_object(player_x(pl), mo_label)

        }
      }
  }

  function bus_result_message(nr, name, veh, cov)
  {
    switch (nr) {
      case 0:
        return format(translate("Select the Bus [%s]."),name)
        break

      case 1:
        return format(translate("The number of bus must be [%d]."),cov)
        break

      case 2:
        return format(translate("The number of convoys must be [%d], press the [Sell] button."),cov)

      case 3:
        return translate("The bus must be [Passengers].")
        break

      case 4:
        return format(translate("Must not use trailers [%d]."),veh-1)
        break

      default:
        return translate("The convoy is not correct.")
        break
    }
  }

  function is_water_entry(list, under = false)
  {
    local siz = list.len()
    local nw_list = []
    local c2d = "coord"
    for (local j = 0; j<siz; j++){
      local c = list[j]
      local type = typeof(c)
      if(type != c2d) {
        local t = tile_x(c.x, c.y, c.z)
        nw_list.push(t)
        continue
      }
      local tile = my_tile(c)
      local buil = tile.find_object(mo_building)
      local way = tile.find_object(mo_way)

      if (buil && !way) {
        local t_list = buil.get_tile_list();
        local area = get_tiles_near_stations(t_list)
        local save_t = null
        for(local i=0;i<area.len();i++){
          local t_water = my_tile(area[i])
          if(t_water.is_water()){
            local buil2 = t_water.find_object(mo_building)
            save_t = t_water
            if(buil2){
              save_t = t_water
              break
            }
          }
        }
        nw_list.push(save_t)
        continue
      }
      else{

        local t = my_tile(list[j])
        nw_list.push(t)
      }
    }

    return nw_list
  }

  //dir 1 = x++
  //dir 2 = y++
  //dir 3 = x--
  //dir 4 = y--
  function clean_track_segment(t, siz, opt) {
    local tool = command_x(tool_remover)

    if (opt==1) {
      for (local j = 0; j<siz;j++){
        tool.work(player_x(1), t, "")
        t.x++

      }
    }
    else if (opt==2) {
      for (local j = 0; j<siz;j++){
        tool.work(player_x(1), t, "")
        t.y++
      }
    }
    else if (opt==3) {
      for (local j = 0; j<siz;j++){
        tool.work(player_x(1), t, "")
        t.x--
      }
    }
    else if (opt==4) {
      for (local j = 0; j<siz;j++){
        tool.work(player_x(1), t, "")
        t.y--
      }
    }
  }

  function tunnel_build_check(start, end, under,  max, dir){
    local count = tunnel_get_max(start, end, max, dir)
    local t = tile_x(r_way.c.x, r_way.c.y, r_way.c.z)

    //gui.add_message(""+count+" :: "+max+" :: "+start.tostring()+" :: "+dir+" :: "+r_way.c.tostring())
    if(count <= max) {
      return under_way_check(under, dir)
    }

    return "lol"
  }

  function tunnel_get_max(start, end, max, dir){

    local count = 0

    if (dir == 8) {
      for (local j = start.x; j<end.x ;j++){
        count++
      }
    }
    else if (dir == 1) {
      for (local j = start.y; j<end.y ;j++){
        count++
      }
    }
    else if (dir == 2) {
      for (local j = start.x; j>end.x ;j--){
        count++
      }
    }
    else if (dir == 4) {
      for (local j = start.y; j>end.y ;j--){
        count++
      }
    }

    return count
  }

  function under_way_check(under, dir){
    local result =  translate("The tunnel is not correct, use the [Remove] tool here")+" ("+r_way.c.tostring()+".)"
    local t = tile_x(r_way.c.x, r_way.c.y, r_way.c.z)
    local way = t.find_object(mo_way)
    local ribi = way? way.get_dirs() : 0

    //gui.add_message(""+ribi)
    if(ribi != dir)
      return result

    local z = square_x(t.x, t.y).get_ground_tile().z
    for (local j = z; j>=under;j--){
      if (j == r_way.c.z)
        continue
      t.z = j
      if (t.find_object(mo_way))
        return result

      //gui.add_message(""+t.x +","+t.y+","+t.z)
    }
    return null
  }

  function underground_message(plus = 0){
    under_lv = settings.get_underground_view_level()
    if(under_lv == norm_view)
      return translate("First you need to activate the underground view / sliced map view.")

    else if(under_lv != unde_view){
      if(under_lv != r_way.c.z + plus)
        return format(translate("Layer level in sliced map view should be: %d"), r_way.c.z + plus)

    }
  }

  function public_label(t, name)
  {
    if(t.is_marked())
      t.remove_object(player_x(1), mo_label)

    local label = t.find_object(mo_label)
    local cursor = t.find_object(mo_pointer)

    if(!label && !t.is_marked() && !cursor){
      label_x.create(t, player_x(1), name)

      label = t.find_object(mo_label)
      if(label)
        label.mark()
    }
    return null
  }

}

// END OF FILE
