/*
 *  class chapter_01
 *
 *
 *  Can NOT be used in network game !
 */


class tutorial.chapter_01 extends basic_chapter
{
  chapter_name  = "Getting Started"
  chapter_coord = coord(113,189)
  startcash     = 500000          // pl=0 startcash; 0=no reset

  comm_script = false

  // Step 1 =====================================================================================
  c_fac = coord(149,200)
  c_st  = coord(117,197)
  tx_cty = "This is a town centre"
  tx_fac = "This is a factory"
  tx_st = "This is a station"
  tx_link = "This is a link"

  // Step 2 =====================================================================================
  c_test = coord3d(0,0,1)

  // Step 3 =====================================================================================
  c_buil1 = coord(113,189)
  c_buil2 = coord(113,185)
  buil1_name = "" //auto started
  buil2_name = "" //auto started
  buil2_list = null //auto started

  // Step 4 =====================================================================================
  cit_list = null //auto started
  city_lim = {a = coord(109,181), b = coord(128,193)}
  cty1 = {c = coord(111,184), name = ""}

  function start_chapter()  //Inicia solo una vez por capitulo
  {
    cty1.name = get_city_name(cty1.c)
    local t = my_tile(cty1.c)
    local buil = t.find_object(mo_building)
    cit_list = buil ? buil.get_tile_list() : null

    t = my_tile(c_buil1)
    buil = t.find_object(mo_building)
    buil1_name = buil ? translate(buil.get_name()):"No existe"

    t = my_tile(c_buil2)
    buil = t.find_object(mo_building)
    buil2_name = buil ? translate(buil.get_name()):"No existe"

    return 0
  }

  function set_goal_text(text){
    switch (this.step) {
      case 1:
        text.pos = cty1.c.href("("+cty1.c.tostring()+")")
        text.pos1 = cty1.c.href(""+translate(tx_cty)+" ("+cty1.c.tostring()+")")
        text.pos2 = c_fac.href(""+translate(tx_fac)+" ("+c_fac.tostring()+")")
        text.pos3 = c_st.href(""+translate(tx_st)+" ("+c_st.tostring()+")")
        text.link = "<a href='script:script_text()'>"+translate(tx_link)+"  >></a>"
      break;
      case 3:
        text.pos = "<a href=\"("+c_buil1.x+","+c_buil1.y+")\">"+buil1_name+" ("+c_buil1.tostring()+")</a>"
        text.buld_name = "<a href=\"("+c_buil2.x+","+c_buil2.y+")\">"+buil2_name+" ("+c_buil2.tostring()+")</a>"
      break;
      case 4:
        text.pos2 = "<a href=\"("+cty1.c.x+","+cty1.c.y+")\">" + translate("Town Centre")+" ("+cty1.c.tostring()+")</a>"
      break;

    }
    text.town = cty1.name
    text.tool1 =  translate(tool_alias.inspe)
    return text
  }

  function is_chapter_completed(pl) {
    local chapter_steps = 4
    local chapter_step = persistent.step
    local chapter_sub_steps = 0 // count all sub steps
    local chapter_sub_step = 0  // actual sub step

    local txt=c_test.tostring()
    switch (this.step) {
      case 1:
        if (pot0 == 1) {
          this.next_step()
        }
        //return chapter_percentage(chapter_steps, 1, 0, 0)
        break

      case 2:
        if (txt!="0,0,1" || pot0 == 1) {
          //Creea un cuadro label
          local opt = 0
          local del = false
          local text = "X"
          label_bord(city_lim.a, city_lim.b, opt, del, text)
          this.next_step()
        }
        //return chapter_percentage(chapter_steps, 2, 0, 0)
        break

      case 3:
        local next_mark = true
        local c_list1 = [my_tile(c_buil1)]
        local c_list2 = [my_tile(c_buil2)]
        local stop_mark = true
        if (pot0==0) {
          try {
             next_mark = delay_mark_tile(c_list1)
          }
          catch(ev) {
            return 0
          }
        }
        else if (pot0==1 && pot1==0) {
          try {
             next_mark = delay_mark_tile(c_list1, stop_mark)
          }
          catch(ev) {
            return 0
          }
          pot1=1
        }
        if (pot1==1 && pot2==0) {
          try {
             next_mark = delay_mark_tile(c_list2)
          }
          catch(ev) {
            return 0
          }
        }
        else if (pot2==1 && pot3==0) {
          try {
             next_mark = delay_mark_tile(c_list2, stop_mark)
          }
          catch(ev) {
            return 0
          }
          pot3=1
        }
        if (pot3==1 && pot4==0){
          comm_script = false
          this.next_step()
        }
        //return chapter_percentage(chapter_steps, 3, 0, 0)
        break
      case 4:
        local next_mark = true
        local list = cit_list
        local stop_mark = true

        try {
           next_mark = delay_mark_tile(list)
        }
        catch(ev) {
          return 0
        }
        if (pot0 == 1 && next_mark) {
          next_mark = delay_mark_tile(list, stop_mark)
          comm_script = false
          this.next_step()
        }
        break
      case 5:
        persistent.step=1
        persistent.status.step = 1
        //return 100
        break

    }
    local percentage = chapter_percentage(chapter_steps, chapter_step, chapter_sub_steps, chapter_sub_step)
    return percentage
  }

  function is_work_allowed_here(pl, tool_id, name, pos, tool) {
    local label = tile_x(pos.x,pos.y,pos.z).find_object(mo_label)
    local result=null // null is equivalent to 'allowed'

    result = translate("Action not allowed")

    switch (this.step) {
      case 1:
        break
      case 2:
        break
      case 3:
        if(tool_id == 4096) {
          if(pot0==0){
            if ((pos.x == c_buil1.x)&&(pos.y == c_buil1.y)){
              pot0 = 1
              return null
            }
          }
          else if (pot1==1 && pot2==0){
            if ((pos.x == c_buil2.x)&&(pos.y == c_buil2.y)){
              pot2 = 1
              return null
            }
          }
        }
        break
      case 4:
        if (tool_id == 4096){
          local list = cit_list
          foreach(t in list){
            if(pos.x == t.x && pos.y == t.y) {
              pot0 = 1
              return null
            }
          }
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

  function is_tool_active(pl, tool_id, wt) {
    local result = true
    return result
  }

  function is_tool_allowed(pl, tool_id, wt){
    local result = true
    return result
  }

  function script_text()
  {
    if (this.step==1){
      pot0=1
    }
    else if (this.step==2){
      pot0 = 1
    }
    else if(this.step==3){
      comm_script = true
      //Creea un cuadro label
      local opt = 0
      local del = false
      local text = "X"
      label_bord(city_lim.a, city_lim.b, opt, del, text)
      pot0=1
      pot2=1
    }
    else if (this.step==4){
      comm_script = true
      pot0 = 1
    }
    return null
  }
}        // END of class

// END OF FILE
