/*
 *  class chapter_00
 *
 *
 *  Can NOT be used in network game !
 */


class tutorial.chapter_00 extends basic_chapter
{
  chapter_name  = "Checking Compatibility"
  chapter_coord = coord(0,0)
  startcash     = 10          // pl=0 startcash; 0=no reset

  comm_script = false

  function start_chapter()  //Inicia solo una vez por capitulo
  {
    return 0
  }

  function set_goal_text(text){
    local tx_a = format("<em>%s %s<em>",pak_name, translate("OK"))
    if(!resul_version.pak) tx_a = "<st>"+pak_name+"</st>"

    local tx_b = format("<em>v%s %s<em>",simu_version, translate("OK"))
    if(!resul_version.st) tx_b = "<st>v"+simu_version+"</st>"

    text.pak = tx_a
    text.stv = tx_b

    text.current_stv = current_st
    text.current_pak = current_pak
    return text
  }

  function is_chapter_completed(pl) {

    this.step = 1
    return 0

  }

  function is_work_allowed_here(pl, tool_id, pos) {
    local label = tile_x(pos.x,pos.y,pos.z).find_object(mo_label)
    local result=null // null is equivalent to 'allowed'

    result = translate("Action not allowed")

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
    return null
  }
}        // END of class

// END OF FILE
