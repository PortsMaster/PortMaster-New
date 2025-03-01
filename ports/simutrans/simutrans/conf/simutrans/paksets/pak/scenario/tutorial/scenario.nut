/*
 *  Tutorial Scenario
 *
 *
 *  Can NOT be used in network game !
 */
const nut_path = "class/"             // path to folder with *.nut files
include("set_data")                   // include set data
include(nut_path+"class_basic_data")  // include class for object data
translate_objects_list <- {}          // translate list
translate_objects()                   // add objects to translate list

const version = 2001
scenario_name               <- "Tutorial Scenario"
scenario.short_description  = scenario_name
scenario.author             = "Yona-TYT & Andarix"
scenario.version            = (version / 1000) + "." + ((version % 1000) / 100) + "." + ((version % 100) / 10) + (version % 10)
scenario.translation        <- ttext("Translator")

resul_version <- {pak= false , st = false}

persistent.version  <- version  // stores version of script
persistent.select   <- null     // stores user selection
persistent.chapter  <- 1        // stores chapter number
persistent.step     <- 1        // stores step number of chapter

persistent.status <- {chapter=1, step=1} // save step y chapter

script_test <- true

persistent.st_nr <- array(30)     //Numero de estaciones/paradas

scr_jump <- false
pending_call <- false

gl_percentage <- 0
persistent.gl_percentage <- 0

persistent.r_way_list <- {}       //Save way list in fullway

//----------------------------------------------------------------

cov_save <- [convoy_x(0)]               //Guarda los convoys en lista
ignore_save <- [{id = -1, ig = true}]   //Marca convoys ingnorados

persistent.ignore_save <- []

//-------------Guarda el estado del script------------------------
persistent.pot <- [0,0,0,0,0,0,0,0,0,0,0]

persistent.glsw <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
pglsw <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

pot0 <- 0
pot1 <- 0
pot2 <- 0
pot3 <- 0
pot4 <- 0
pot5 <- 0
pot6 <- 0
pot7 <- 0
pot8 <- 0
pot9 <- 0
pot10 <- 0
glsw <- [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

//---------------------Contador global de vehiculos----------------------------
persistent.gcov_nr <- 0
gcov_nr <- 0
persistent.gcov_id <- 1
gcov_id <- 0
persistent.gall_cov <- 0
gall_cov <-0
persistent.current_cov <- 0
current_cov <- 0
cov_sw <- true
correct_cov <- true

//----------------------------------------------------------------
gui_delay       <- true    //delay for open win

fail_num        <- 10       //numr for the count of try
fail_count      <- 1       //if tool fail more of fail_num try


//Schedule activate
active_sch_check <- false

  simu_version  <- "124.2.3"
  current_st    <- "0"

include(nut_path+"class_basic_gui")   // include class for tools disabled/enabled

// table containing all system_types
all_systemtypes <- [st_flat, st_elevated, st_runway, st_tram]

// Complemento para obtener tiempo de espera
tick_wait <- 16

chapter            <- null                    // used later for class
chapter_max        <- 7                       // amount of chapter
select_option      <- { x = 0, y = 0, z = 1 } // place of station to control name
select_option_halt <- null                    // placeholder for halt_x
tutorial           <- {}                      // placeholder for all chapter CLASS


//returns pakset name (lower case)
function get_set_name(name)
{
  local s = name.find(" ")
  name = name.slice(0, s)
  name = name.tolower()
  return name
}

function string_analyzer()
{
  local result = {pak= false , st = false}
  //Check version and pakset name
  current_pak = get_set_name(get_pakset_name())
  current_st = get_version_number()

  local p_siz = {a = pak_name.len(), b = current_pak.len()}

  //Pak name analyzer  ----------------------------------------------------------------------------------------------------------
  local siz_a = max(p_siz.a, p_siz.a)
  local count_a = 0
  local tx_a = ""
  for(local j=0;j<siz_a;j++){
    try {
      pak_name[count_a]
    }
    catch(ev) {
      break
    }
    if(count_a>0 && current_pak[j]!=pak_name[count_a]){
      break
    }
    if(current_pak[j]==pak_name[count_a]){
      tx_a += format("%c",current_pak[j])
      count_a++
      continue
    }
  }
  if(pak_name == tx_a) result.pak = true
  //gui.add_message("Current: "+current_pak+"  Tx: "+tx_a+"  Pak: "+pak_name+" result: "+result.pak)
  //------------------------------------------------------------------------------------------------------------------------------

  local s_siz = {a = simu_version.len(), b = current_st.len()}

  local val_a = []
  local val_b = []

  // Analyzer scenario simutrans version -----------------------------------------------------------------------------------------
  local value_a = ""
  for(local j=0;j<s_siz.a;j++){
    local tx = format("%c",simu_version[j])
    local result = get_integral(tx)
    if(result.res){
      value_a += tx
      if(j == s_siz.a-1) {
        val_a.push(value_a.tointeger())
        continue
      }
    }
    else {
      if(j == s_siz.a-1) {
        val_a.push(value_a.tointeger())
        continue
      }
      if(result.val == "."){
        val_a.push(value_a.tointeger())
        value_a = ""
        continue
      }
    }
  }
  //-------Debug ====================================
  /*
  local txta = ""
  for(local j=0; j<val_a.len() ;j++){
    txta += (val_a[j] +" :: ")
  }
  gui.add_message("list A: "+txta +" -- val_a siz: "+val_a.len())
  */
  //-------Debug ====================================
  //------------------------------------------------------------------------------------------------------------------------------

  // Analyzer current simutrans version -------------------------------------------------------------------------------------
  local value_b = ""
  for(local j=0;j<s_siz.b;j++){
    local tx = format("%c",current_st[j])
    local result = get_integral(tx)
    if(result.res){
      value_b += tx
      if(j == s_siz.b-1) {
        val_b.push(value_b.tointeger())
        continue
      }
    }
    else {
      if(j == s_siz.b-1) {
        val_b.push(value_b.tointeger())
        continue
      }
      if(result.val == "."){
        val_b.push(value_b.tointeger())
        value_b = ""
        continue
      }
    }
  }
  //-------Debug ====================================
  /*
  local txtb = ""
  for(local j=0; j<val_b.len() ;j++){
    txtb += (val_b[j] +" :: ")
  }
  gui.add_message("list B: "+txtb +" -- val_b siz: "+val_b.len())
  */
  //-------Debug ====================================
  //------------------------------------------------------------------------------------------------------------------------------

  // Compare both simutrans versions -----------------------------------------------------------------------------------------
  local siz_va = val_a.len()
  local siz_vb = val_b.len()
  local siz_min = min(siz_va, siz_vb)
  for(local i = 0; i < siz_min; i++ ) {
    local num_a = val_a[i]
    local num_b = val_b[i]
    //gui.add_message("Array test -- val_a "+num_a+"  val_b "+num_b+" -- siz_A "+siz_va+" siz_B "+siz_vb)
    //gui.add_message("Val type -- val_a "+type(num_a)+"  val_b "+type(num_b)+"")
    if(num_a < num_b) {
      result.st = true
      return result
    }
    else if(num_a > num_b) {
      result.st = false
      return result
    }
    if (i == (siz_min-1)) {
      if(siz_va <= siz_vb) {
        result.st = true
        return result
      }
      else {
        result.st = false
        return result
      }
    }
  }
  //-------------------------------------------------------------------------------------------------------------------------------
  //gui.add_message("result st: "+result.st+"  result pak:" +result.pak)
  return result
}

function get_integral(tx)
{
  local result = {val = null, res = false}
  local evet = false
  try {
    tx.tointeger()
  }
  catch(ev) {
    evet = true
  }
  if(evet){
    result.val = tx
    result.res = false
  }
  else{
    result.val = tx.tointeger()
    result.res = true
  }
  return result
}

{
  //Check version and pakset name
  resul_version = string_analyzer()
  include(nut_path+"class_basic_convoys")     // include class for detect eliminated convoys
  include(nut_path+"class_basic_chapter")     // include class for basic chapter structure

}

for (local i = 0; i <= chapter_max; i++)    // include amount of chapter classes
  include(nut_path+"class_chapter_"+(i < 10 ? "0"+i:i) )
// Marked for deletion ----------------------------------------------------
chapter            <- tutorial.chapter_02       // must be placed here !!! 
//-------------------------------------------------------------------------


/**
  * This function will be called, whenever a user clicks to jump to the next step
  * It must not alter the map or call a tool!
  * Hence we just set a flag and handle all map changes in is_scenario_completed()
  */
function script_text()
{
  local pause = debug.is_paused()
  if (pause)
    return gui.add_message(translate("Advance is not allowed with the game paused."))
  if(!correct_cov){
    gui.add_message(""+translate("Advance not allowed"))
    return null
  }
  if(scr_jump)
    // already jumping
    return null
  pending_call = true   // indicate that we want to skip to next step
  return null
}


function sum(a,b)
{
  return a+b
}

function my_chapter()
{
  return "chapter_"+(chapter.chap_nr < 10 ? "0":"")+chapter.chap_nr+"/"
}

function scenario_percentage(percentage)
{
  return min( ((persistent.chapter == 0? 1-1 : persistent.chapter -1) * 100 + percentage) / tutorial.len(), 100 )
}

function load_chapter(number,pl)
{
  rules.clear()
  general_disabled_tools(pl)
  if (!resul_version.pak || !resul_version.st){
    number = 0
    chapter = tutorial["chapter_"+(number < 10 ? "0":"")+number](pl)
    chapter.chap_nr = number
  }
  else{
    chapter = tutorial["chapter_"+(number < 10 ? "0":"")+number](pl)
    if ( (number == persistent.chapter) && (chapter.startcash > 0) )  // set cash money here
      player_x(0).book_cash( (chapter.startcash - player_x(0).get_cash()[0]) * 100)

    chapter.chap_nr = persistent.chapter
    //persistent.step = persistent.status.step
  }
}

function load_conv_ch(number, step, pl)
{
    rules.clear()
    general_disabled_tools(pl)
  if (!resul_version.pak || !resul_version.st){
    number = 0
    chapter = tutorial["chapter_"+(number < 10 ? "0":"")+number](pl)
    chapter.chap_nr = number
  }
  else{
    chapter = tutorial["chapter_"+(number < 10 ? "0":"")+number](pl)

    if ( (number == persistent.chapter) && (chapter.startcash > 0) )  // set cash money here
      player_x(0).book_cash( (chapter.startcash - player_x(0).get_cash()[0]) * 100)

    chapter.step_nr(step)
    persistent.chapter = number
    chapter.chap_nr = number
    chapter.start_chapter()
  }
}

function set_city_names()
{
  foreach ( city in city_list_x() )
  {
    local name = ttext( city.get_name() )
    if (name.tostring() != "") city.set_name( name.tostring() )
  }
}


/*
 * test functions generating the GUI strings
 * These must return fast and must not alter the map!
 */
function get_info_text(pl)
{
  local info = ttextfile("info.txt")
  local help = ""
  local i = 0
  //foreach (chap in tutorial)
  for (i=1;i<=chapter_max;i++)
    help+= "<em>"+translate("Chapter")+" "+(i)+"</em> - "+translate(tutorial["chapter_"+(i<10?"0":"")+i].chapter_name)+"<br>"
  info.list_of_chapters = help

  info.first_link = "<a href=\"goal\">"+(chapter.chap_nr <= 1 ? translate("Let's start!"):translate("Let's go on!") )+"  >></a>"

  info.pakset_info = get_info_file("info")

  return info
}

function get_rule_text(pl)
{
  return chapter.give_title() + chapter.get_rule_text( pl, my_chapter() )
}

function get_goal_text(pl)
{

  return chapter.give_title() + chapter.get_goal_text( pl, my_chapter() )
}

function get_result_text(pl)
{
   // finished ...
  if(persistent.chapter>7) {
    local text = ttextfile("finished.txt")
    return text
  }

  local text = ttextfile("result.txt")
  //local percentage = chapter.is_chapter_completed(pl)
  text.ratio_chapter = gl_percentage
  text.ratio_scenario = scenario_percentage(gl_percentage)
  return chapter.give_title() + text.tostring()
}

function get_about_text(pl)
{
  local about = ttextfile("about.txt")
  about.short_description = scenario_name
  about.version = scenario.version
  about.author = scenario.author
  about.translation = scenario.translation

  return about
}

function get_debug_text(pl)
{
  return null
}

function start()
{
  gui_delay = false

  // rename factorys to language translate
  //rename_factory_names() // call in translate_objects()
  // set translate objects
  translate_objects()

  set_city_names()
  resume_game()
}

function labels_text_debug()
{
  local t1 = tile_x(0, 0, 27)
  local t2 = tile_x(1, 0, 27)

  if(!t1.find_object(mo_label) || !t2.find_object(mo_label)){
    label_x.create(t1, player_x(1), translate(""+persistent.chapter))
    label_x.create(t2, player_x(1), translate(""+chapter.step))
  }
  else {
    local l1 = label_x(t1.x, t1.y, t1.z)
    local l2 = label_x(t2.x, t2.y, t2.z)

    if(correct_cov){
      local ch_nr = l1.get_text().tointeger()
      local st_nr = l2.get_text().tointeger()
      if(persistent.chapter == ch_nr){
        l1.set_text(""+persistent.chapter)

        if(chapter.step <= (st_nr+1)){
          l2.set_text(""+chapter.step)
        }
        else {
          gui.add_message("Error1 here: CH "+persistent.chapter +" : ST "+chapter.step)

          //Se se regresa al valor anterior en caso de error
          persistent.status.step = st_nr
          persistent.step = st_nr
          chapter.step = st_nr
        }
      }
      else {
        if(chapter.step != 1){
          gui.add_message("Error2 here: CH "+persistent.chapter +" : ST "+chapter.step)

          //Se restauran todos en caso de error
          persistent.status.step = 1
          persistent.step = 1
          chapter.step = 1
        }
        l1.set_text(""+persistent.chapter)
        l2.set_text("1")
      }
    }
  }
}


/**
  * This function check whether finished or not
  * Is runs in a step, so it can alter the map
  * @return 100 or more, the scenario will be "win" and the scenario_info window
  *                      show the result tab
  */
function is_scenario_completed(pl)
{
  // finished ...
  if(persistent.chapter > chapter_max) {
    return 100
  }

  //-------Debug ====================================
  //gui.add_message(""+glsw[0]+"")
  //gui.add_message("!!!!!"+persistent.step+" ch a "+st_nr[0]+"  !!!!! "+persistent.status.step+"  -- "+chapter.step+"")
  //------------------------------------------------------------------------------------------------------------------------------
  if (pl != 0) return 0     // other player get only 0%

  

  if (currt_pos){
    local t = tile_x(currt_pos.x,currt_pos.y,currt_pos.z)
    local build = t.find_object(mo_building)
    if (!t.is_marked() && build){
      local t_list = gl_buil_list
      foreach(t in t_list){
        t.find_object(mo_building).unmark()
      }
      gl_buil_list = {}
      currt_pos = null
    }
  }
  if(fail_count == null){
    if (fail_num <= 0){
      gui.open_info_win_at("goal")
      fail_count = 1
      fail_num = 10
    }
    else fail_num--
  }
  if(gui_delay){
    gui.open_info_win_at("goal")
    gui_delay = false
  }
  //-------Debug ====================================
  //gui.add_message(""+current_cov+"  "+gall_cov+"")
  //------------------------------------------------------------------------------------------------------------------------------
  //Para los convoys ---------------------
  if (gall_cov != current_cov){
    basic_convoys().checks_convoy_removed(pl)
  }

  gall_cov = basic_convoys().checks_all_convoys()
  if(!correct_cov && gall_cov==gcov_nr){
    load_conv_ch(persistent.status.chapter, persistent.status.step, pl)
  }
  correct_cov = basic_convoys().correct_cov_list()
  persistent.gall_cov = gall_cov

  //-------Debug ====================================
  //gui.add_message("gall_cov-> "+gall_cov+":: gcov_nr-> "+gcov_nr+":: current_cov-> "+current_cov+":: Step-> "+chapter.step+":: PersisStep-> "+persistent.step+":: Status->"+persistent.status.step+"")
  //-------Debug ====================================
  //------------------------------------------------------------------------------------------------------------------------------

  if(!correct_cov) {
    if (!resul_version.pak || !resul_version.st)
      chapter.step = 1
    else
      chapter.step = persistent.step
    chapter.start_chapter()
    return 1
  }

  chapter.step = persistent.step

  if (pending_call) {
    // since we cannot alter the map in a sync_step
    pending_call = false
    scr_jump = true // we are during a jump ...
    chapter.script_text()
    scr_jump = false
  }

  local percentage = chapter.is_chapter_completed(pl)
  gl_percentage = percentage
  persistent.gl_percentage = gl_percentage

  if (percentage >= 100){ // give message , be sure to have 100% or more
    local text = ttext("Chapter {number} - {cname} complete, next Chapter {nextcname} start here: ({coord}).")
    text.number = persistent.chapter
    text.cname = translate(""+chapter.chapter_name+"")

    persistent.chapter++
    persistent.status.chapter++

    // finished ...
    if(persistent.chapter > chapter_max) {
      rules.clear()
      rules.gui_needs_update()
      scr_jump = true
      return 100
    }

    load_chapter(persistent.chapter, pl)
    chapter.chap_nr = persistent.chapter
    percentage = chapter.is_chapter_completed(pl)
     // ############## need update of scenario window

    text.nextcname = translate(""+chapter.chapter_name+"")
    text.coord = chapter.chapter_coord.tostring()
    chapter.start_chapter()  //Para iniciar variables en los capitulos
    if (persistent.chapter >1) gui.add_message(text.tostring())
  }
  percentage = scenario_percentage(percentage)
  if ( percentage >= 100 ) {    // scenario complete
    local text = translate("Tutorial Scenario complete.")
    gui.add_message( text.tostring() )
  }
  return percentage
}

function is_work_allowed_here(pl, tool_id, name, pos, tool)
{
  local pause = debug.is_paused()
  //if (pause) return translate("Advance is not allowed with the game paused.")

  //return tile_x(pos.x,pos.y,pos.z).find_object(mo_way).get_dirs()
  if (pl != 0) return null
  if(scr_jump){
    return null
  }
  local result = translate("Action not allowed")
  if (correct_cov){
    local result = chapter.is_work_allowed_here(pl, tool_id, name, pos, tool)
    return fail_count_message(result, tool_id, tool)
  }
  else {
    if (tool_id==4108 || tool_id==4096)
      result = null
  }
  return fail_count_message(result, tool_id, tool)
}

function fail_count_message(result, tool_id, tool)
{
  //gui.add_message(result+" ")
  if(result != "" && !tool.is_drag_tool && tool_id != tool_build_tunnel){
    //gui.add_message("fail_count: "+fail_count + "Tool: "+tool_id)
    if (fail_count && result != null){
      fail_count++
      if (fail_count >= fail_num){
        fail_count = null
        return translate("Are you lost ?, see the instructions shown below.")
      }
    }
    else if (result == null)
      fail_count = 1
  }
  return result
}

function is_schedule_allowed(pl, schedule)
{
  local pause = debug.is_paused()
  //if (pause) return translate("Advance is not allowed with the game paused.")

    local result = null

  if (pl != 0) return null

  result = chapter.is_schedule_allowed(pl, schedule)
    if (result != null)
         active_sch_check = true
    else
         active_sch_check = false

    return result
}

function is_convoy_allowed(pl, convoy, depot)
{
  local pause = debug.is_paused()
  //if (pause) return translate("Advance is not allowed with the game paused.")

  local result = null
  basic_convoys().checks_convoy_removed(pl)
  //gui.add_message("Run ->"+current_cov+","+correct_cov+" - "+gall_cov+"")
  if (pl != 0) return null
  result = chapter.is_convoy_allowed(pl, convoy, depot)
  return result
}

function is_tool_allowed(pl, tool_id, wt, name)
{
  local result = true

  if (tool_id == 0x2005) return false
  else if (tool_id == 0x4006) return false
  else if (tool_id == 0x4029) return false
  else if (tool_id == 0x401c) return false
  //else if(tool_id == t_icon.mono) return false

  result = chapter.is_tool_allowed(pl, tool_id, wt)
    return result
}

function is_tool_active(pl, tool_id, wt, name)
{
  local result = true
  if (pl != 0) return false

  result = chapter.is_tool_active(pl, tool_id, wt)
  return result
}

function jump_to_link_executed(pos)
{
  chapter.jump_to_link_executed(pos)
  return null
}

//--------------------------------------------------------
datasave <- {cov = cov_save}

class data_save {
  // Convoys
  function convoys_save() {return datasave.cov;}
  function _save() { return "data_save()"; }
}

persistent.datasave <- datasave

convoy_x._save <- function()
{
  return "convoy_x(" + id + ")"
}
//-----------------------------------------------------------

function resume_game()
{
  basic_convoys().set_convoy_limit()
  //Mark all text labels
  foreach(label in world.get_label_list()){
    if(label.get_owner().nr == 1)
      label.mark()
  }
  //Check version and pakset name
  resul_version = string_analyzer()

  // Datos guardados
  //-----------------------------------------------------
  // copy it piece by piece otherwise the reference
  foreach(key,value in persistent.datasave)
  {
    datasave.rawset(key,value)
  }
  persistent.datasave = datasave

  // Se obtienen los datos guardados
  cov_save  = data_save().convoys_save()

//-------------------------------------------------------
  gcov_nr = persistent.gcov_nr
  gall_cov = persistent.gall_cov
  current_cov = persistent.current_cov
  gcov_id = persistent.gcov_id
  sigcoord = persistent.sigcoord
  ignore_save = persistent.ignore_save

  pot0=persistent.pot[0]
  pot1=persistent.pot[1]
  pot2=persistent.pot[2]
  pot3=persistent.pot[3]
  pot4=persistent.pot[4]
  pot5=persistent.pot[5]
  pot6=persistent.pot[6]
  pot7=persistent.pot[7]
  pot8=persistent.pot[8]
  pot9=persistent.pot[9]

  gl_percentage = persistent.gl_percentage

  for(local j=0;j<20;j++){
    if (persistent.glsw[j]!=0)
      glsw[j]=persistent.glsw[j]
    persistent.glsw[j]=glsw[j]
  }

  r_way_list = persistent.r_way_list
  
  if(persistent.chapter > chapter_max) {
    // scenario was finished
    return;
  }

  load_chapter(persistent.chapter,0)      // load correct chapter for player=0

  chapter.step = persistent.step    // set chapter step from persistent

  select_option_halt = tile_x( 0, 0, select_option.z ).find_object(mo_label)

  chapter.start_chapter()
}

function get_line_name(halt)
{
  local lin_list = halt.get_line_list()

  foreach(line in lin_list) {
    return "<em>"+line.get_name()+"</em>"
  }
  return "<s>not line</s>"
}

function coord3d_to_key(c)
{
  return ("coord3d_" + c.x + "_" + c.y + "_" + c.z).toalnum();
}

// END OF FILE
