/*
 *  class chapter_07
 *
 *
 *  Can NOT be used in network game !
 */


class tutorial.chapter_07 extends basic_chapter
{
  chapter_name  = "Bus networks"
  chapter_coord = coord(50,195)
  startcash     = 500000            // pl=0 startcash; 0=no reset
  load = 0

  gl_wt = wt_road
  gl_good = 0 //Passengers

  compass_nr = 0

  cty1 = {c = coord(52,194), name = ""}
  c_cty_lim1 = {a = coord(0,0), b = coord(0,0)}

  cty2 = {c = coord(115,268), name = ""}
  c_cty_lim2 = {a = coord(0,0), b = coord(0,0)}

  cty3 = {c = coord(124,326), name = ""}
  c_cty_lim3 = {a = coord(0,0), b = coord(0,0)}

  cty4 = {c = coord(125,378), name = ""}
  c_cty_lim4 = {a = coord(0,0), b = coord(0,0)}

  // Step 1
  goal_lod1 = set_transportet_goods(3)
  st1_c = tile_x(57,198,11)
  stop1 = tile_x(56,196,11)

  // Step 2
  goal_lod2 = set_transportet_goods(4)
  st2_c = tile_x(120,267,3)
  stop2 = tile_x(119,266,3)

  // Step 3
  goal_lod3 = set_transportet_goods(5)
  st3_c = tile_x(120,327,5)
  stop3 = tile_x(122,330,5)

  // Step 4
  goal_lod4 = set_transportet_goods(6)
  st4_c = tile_x(120,381,9)
  stop4 = tile_x(122,381,9)

  transfer_pass = 0

  function load_limits(city)  //Load all limits for citys
  {
    local list = []
    local c_nw = city.get_pos_nw()
    local c_se = city.get_pos_se()

    list.push({a = c_nw, b = c_se})                     // N
    list.push({a =  coord(c_nw.x, c_se.y), b = coord(c_se.x, c_nw.y)})    // W
    list.push({a = c_se, b = c_nw})                     // S
    list.push({a =  coord(c_se.x, c_nw.y), b = coord(c_nw.x, c_se.y)})    // E

    return list
  }

  function start_chapter()  //Inicia solo una vez por capitulo
  {

    cty1.name = get_city_name(cty1.c)
    local cty_buil1 = my_tile(cty1.c).find_object(mo_building).get_city()
    c_cty_lim1 = load_limits(cty_buil1)

    cty2.name = get_city_name(cty2.c)
    local cty_buil2 = my_tile(cty2.c).find_object(mo_building).get_city()
    c_cty_lim2 = load_limits(cty_buil2)

    cty3.name = get_city_name(cty3.c)
    local cty_buil3 = my_tile(cty3.c).find_object(mo_building).get_city()
    c_cty_lim3 = load_limits(cty_buil3)

    cty4.name = get_city_name(cty4.c)
    local cty_buil4 = my_tile(cty4.c).find_object(mo_building).get_city()
    c_cty_lim4 = load_limits(cty_buil4)

    compass_nr = my_compass()

    /*
    //Debug ---------------------------------------------------------------
    local opt = 0
    local del = false
    local text = "X"
    local nr = my_compass()

    my_tile(c_cty_lim1[nr].a).mark()
    my_tile(c_cty_lim1[nr].b).mark()

    label_bord(c_cty_lim1[nr].a, c_cty_lim1[nr].b, opt, del, text)
    //---------------------------------------------------------------
    */

    return 0
  }

  function set_goal_text(text){

    switch (this.step) {
      case 1:
        local t = st1_c
        local halt = t.get_halt()
        text.name = t.href(""+halt.get_name()+" ("+coord3d_to_string(t)+")")+""
        text.city = cty1.c.href(""+cty1.name +" ("+cty1.c.tostring()+")")+""
        text.stop = stop1.href("("+coord3d_to_string(stop1)+")")+""
        text.load = goal_lod1
        break

      case 2:
        local t = st2_c
        local halt = t.get_halt()
        text.name = t.href(""+halt.get_name()+" ("+coord3d_to_string(t)+")")+""
        text.city = cty2.c.href(""+cty2.name +" ("+cty2.c.tostring()+")")+""
        text.stop = stop2.href("("+coord3d_to_string(stop2)+")")+""
        text.load =  goal_lod2
        break

      case 3:
        local t = st3_c
        local halt = t.get_halt()
        text.name = t.href(""+halt.get_name()+" ("+coord3d_to_string(t)+")")+""
        text.city = cty3.c.href(""+cty3.name +" ("+cty3.c.tostring()+")")+""
        text.stop = stop3.href("("+coord3d_to_string(stop3)+")")+""
        text.load =  goal_lod3
        break

      case 4:
        local t = st4_c
        local halt = t.get_halt()
        text.name = t.href(""+halt.get_name()+" ("+coord3d_to_string(t)+")")+""
        text.city = cty4.c.href(""+cty4.name +" ("+cty4.c.tostring()+")")+""
        text.stop = stop4.href("("+coord3d_to_string(stop4)+")")+""
        text.load =  goal_lod4
        break

      case 5:
        break
    }
    text.get_load = load
    return text
  }

  function is_chapter_completed(pl) {
    local chapter_steps = 5
    local chapter_step = persistent.step
    local chapter_sub_steps = 0 // count all sub steps
    local chapter_sub_step = 0  // actual sub step

    switch (this.step) {
      case 1:
        if (!correct_cov)
          return 0

        if ( check_halt_merge(st1_c, stop1) ) {
          load = cov_pax(stop1, gl_wt, gl_good) - transfer_pass
        } else {
          transfer_pass = cov_pax(stop1, gl_wt, gl_good)
        }
        if(load>goal_lod1){
          load = 0
          transfer_pass = 0
          this.next_step()
        }
        //return 5
        break;

      case 2:
        if (!correct_cov)
          return 0

        if ( check_halt_merge(st2_c, stop2) ) {
          load = cov_pax(stop2, gl_wt, gl_good) - transfer_pass
        } else {
          transfer_pass = cov_pax(stop2, gl_wt, gl_good)
        }
        if(load>goal_lod2){
          load = 0
          transfer_pass = 0
          this.next_step()
        }
        //return 25
        break;

      case 3:
        if (!correct_cov)
          return 0

        if ( check_halt_merge(st3_c, stop3) ) {
          load = cov_pax(stop3, gl_wt, gl_good) - transfer_pass
        } else {
          transfer_pass = cov_pax(stop3, gl_wt, gl_good)
        }
        if(load>goal_lod3){
          load = 0
          transfer_pass = 0
          this.next_step()
        }
        //return 50
        break;

      case 4:
        if (!correct_cov)
          return 0

        if ( check_halt_merge(st4_c, stop4) ) {
          load = cov_pax(stop4, gl_wt, gl_good) - transfer_pass
        } else {
          transfer_pass = cov_pax(stop4, gl_wt, gl_good)
        }
        if(load>goal_lod4){
          load = 0
          transfer_pass = 0
          this.next_step()
        }
        //return 75
        break;

      case 5:
        //return 90
        return 100
        break;
    }
    local percentage = chapter_percentage(chapter_steps, chapter_step, chapter_sub_steps, chapter_sub_step)
    return percentage
  }

  function is_work_allowed_here(pl, tool_id, name, pos, tool) {
    local result=null // null is equivalent to 'allowed'
    local t = tile_x(pos.x, pos.y, pos.z)
    local way = t.find_object(mo_way)
    local nr = compass_nr
    switch (this.step) {
      case 1:
        if (tool_id==4096)
          return null

        if ((pos.x>=c_cty_lim1[nr].a.x-(1))&&(pos.y>=c_cty_lim1[nr].a.y-(1))&&(pos.x<=c_cty_lim1[nr].b.x+(1))&&(pos.y<=c_cty_lim1[nr].b.y+(1))){
          return null
        }
        else
          return translate("You can only use this tool in the city")+ " " + cty1.name.tostring()+" ("+cty1.c.tostring()+")."
      break;

      case 2:
        if (tool_id==4096)
          return null

        if ((pos.x>=c_cty_lim2[nr].a.x-(1))&&(pos.y>=c_cty_lim2[nr].a.y-(1))&&(pos.x<=c_cty_lim2[nr].b.x+(1))&&(pos.y<=c_cty_lim2[nr].b.y+(1))){
          return null
        }
        else
          return translate("You can only use this tool in the city")+cty2.name.tostring()+" ("+cty2.c.tostring()+")."
      break;

      case 3:
        if (tool_id==4096)
          return null

        if ((pos.x>=c_cty_lim3[nr].a.x-(1))&&(pos.y>=c_cty_lim3[nr].a.y-(1))&&(pos.x<=c_cty_lim3[nr].b.x+(1))&&(pos.y<=c_cty_lim3[nr].b.y+(1))){
          return null
        }
        else
          return translate("You can only use this tool in the city")+cty3.name.tostring()+" ("+cty3.c.tostring()+")."
      break;

      case 4:
        if (tool_id==4096)
          return null

        if ((pos.x>=c_cty_lim4[nr].a.x-(1))&&(pos.y>=c_cty_lim4[nr].a.y-(1))&&(pos.x<=c_cty_lim4[nr].b.x+(1))&&(pos.y<=c_cty_lim4[nr].b.y+(1))){
          return null
        }
        else
          return translate("You can only use this tool in the city")+cty4.name.tostring()+" ("+cty4.c.tostring()+")."
      break;

      case 5:
        return null;

    }
    if (tool_id==4096)
      return null

    return tool_id
  }

  function is_schedule_allowed(pl, schedule) {
    return null
  }

  function is_convoy_allowed(pl, convoy, depot)
  {
    if(this.step>4) 
      return null

    local result=null // null is equivalent to 'allowed'
    //Check load type
    local good_nr = 0 //Passengers
    local good = convoy.get_goods_catg_index()
    for(local j=0;j<good.len();j++){
      if(good[j]!=good_nr)
        return translate("The bus must be [Passengers].")
    }
    if (result == null){
      ignore_save.push({id = convoy.id, ig = true})  //Ingnora el vehiculo
      return null
    }
    return result = translate("It is not allowed to start vehicles.")
  }

  function script_text()
  {
    return null
  }

  function is_tool_active(pl, tool_id, wt) {
    local result = true
    return result
  }

  function is_tool_allowed(pl, tool_id, wt){
    if(this.step>4)
      return true

    local gt_list = [ t_icon.tram, t_icon.rail ]
    foreach (id in gt_list){
      if(id == tool_id)
        return false
    }
    local result = true
    return result
  }

}        // END of class

// END OF FILE
