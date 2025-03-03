/*
 *  list messages
 *
 *
 *
 */

/*
 *  single messages
 *
 *  id - message id
 *   1 = You can only delete the stops.
 *   2 = Action not allowed
 *
 *
 *
 *
 *
 *
 *
 *
 */
function get_message(id) {
  local txt_message = ""

  switch(id) {
    case: 1
      txt_message = translate("You can only delete the stops.")
      break
    case: 2
      txt_message = translate("Action not allowed")
      break
    case: 3

      break
    case: 4

      break
    case: 5

      break
    case: 6

      break
    case: 7

      break
  }

  return txt_message

}

/*
 *  messages with a tile
 *
 *  id    - message id
 *  tile  - coord from tile : x,y or x,y,z
 *
 *  id list
 *   1 = Action not allowed (x, y, z).
 *   2 = Connect the road here (x, y, z).
 *   3 = The route is complete, now you may dispatch the vehicle from the depot (x, y, z).
 *   4 = You must build the bridge here (x, y, z).
 *   5 = Indicates the limits for using construction tools (x, y, z).
 *   6 = Text label (x, y, z).
 *   7 = You must first build a stretch of road (x, y, z).
 *   8 = You must build the depot in (x, y, z).
 *
 *
 *
 */
function get_tile_message(id, tile) {
  local txt_tile = ""
  if ( tile.len() == 2 ) {
    txt_tile = coord_to_string(tile)
  } else if ( tile.len() == 3 ) {
    txt_tile = coord3d_to_string(tile)
  } else {
    txt_tile = tile
  }

  local txt_message = ""

  switch(id) {
    case: 1
      txt_message = translate("Action not allowed")+" ("+txt_tile+")."
      break
    case: 2
      txt_message = translate("Connect the road here")+" ("+txt_tile+")."
      break
    case: 3
      txt_message = translate("The route is complete, now you may dispatch the vehicle from the depot")+" ("+txt_tile+")."
      break
    case: 4
      txt_message = translate("You must build the bridge here")+" ("+txt_tile+")."
      break
    case: 5
      txt_message = translate("Indicates the limits for using construction tools")+" ("+txt_tile+")."
      break
    case: 6
      txt_message = translate("Text label")+" ("+txt_tile+")."
      break
    case: 7
      txt_message = translate("You must first build a stretch of road")+" ("+txt_tile+")."
      break
    case: 8
      txt_message = translate("You must build the depot in")+" ("+txt_tile+")."
      break
    case: 9

      break
  }

  return txt_message

}

/*
 *  messages with a string/digit include
 *
 *  id    - message id
 *  data  - digit or string
 *
 *  id list
 *   1 = You must build the %d stops first.
 *   2 = Only %d stops are necessary.
 *
 *
 *
 *
 *
 *
 */
function get_data_message(id, data) {
  local txt_message = ""

  switch(id) {
    case: 1
      txt_message = format(translate("You must build the %d stops first."), data)
      break
    case: 2
      txt_message = format(translate("Only %d stops are necessary."), data)
      break
    case: 3

      break
    case: 4

      break
    case: 5

      break
    case: 6

      break
    case: 7

      break
  }

  return txt_message

}


/*
 *  messages with a string/digit and tile
 *
 *  id    - message id
 *  data  - digit or string
 *  tile  - coord from tile : x,y or x,y,z
 *
 *  id list
 *   1 = Stops should be built in [%s] (x, y, z).
 *   2 = You must build a stop in [%s] first (x, y, z).
 *   3 = Select station No.%d") (x, y, z).
 *
 *
 *
 *
 *
 */
function get_tiledata_message(id, data, tile) {
  local txt_tile = ""
  if ( tile.len() == 2 ) {
    txt_tile = coord_to_string(tile)
  } else if ( tile.len() == 3 ) {
    txt_tile = coord3d_to_string(tile)
  } else {
    txt_tile = tile
  }

  local txt_message = ""

  switch(id) {
    case: 1
      txt_message = format(translate("Stops should be built in [%s]"), data)+" ("+txt_tile+")."
      break
    case: 2
      txt_message = format(translate("You must build a stop in [%s] first"), data)+" ("+txt_tile+")."
      break
    case: 3
      txt_message = format(translate("Select station No.%d"), data)+" ("+txt_tile+")."
      break
    case: 4

      break
    case: 5

      break
    case: 6

      break
    case: 7

      break
    case: 8

      break
    case: 9

      break
  }

  return txt_message

}


/*








*/
