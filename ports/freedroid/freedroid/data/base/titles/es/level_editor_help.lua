---------------------------------------------------------------------
-- This file is part of Freedroid
--
-- Freedroid is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Freedroid is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Freedroid; see the file COPYING. If not, write to the
-- Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
-- MA 02111-1307 USA
----------------------------------------------------------------------

title_screen{
song = "Bleostrada.ogg",
text = [[
            EL EDITOR DE NIVELES DE FREEDROIDRPG

=== INTRODUCCIÓN === 

FreedroidRPG viene con un editor de niveles integrado. Este editor de niveles te permite controlar todo aspecto de un mapa normal de FreedroidRPG y guardar mapas.

Puedes acceder al mismo desde el menú principal (click en "Editor de Niveles") o ejecutando 'freedroidRPG -e'.

    --- Herramientas ---
Para conmutar descripciones de la interfaz mientras el puntero señala, haga click al botón de burbuja de conversación localizado cerca del borde derecho de la ventana (fila inferior de botones).

    --- Sumarioxdfgdzfs ---
Sumarios sobre obstáculos y objetos aparecerán si les haces click derecho en el selector de objetos superior.

    --- Navegación ---
Para cambiar el nivel actual, haga click en el número de un nivel cercano en el minimapa de la esquina inferior derecha, o seleccione el nivel deseado desde el menú del editor.

    --- Edición de mapas ---
Hay cuatro modos de edición: edición de Obstáculos, edición de Suelo, edición de Objetos, y edición de Puntos de camino.

El botón seleccionada abajo a la derecha indica los objetos que puedes seleccionar o colocar.
Cuando un botón está seleccionado, y estás en un modo de colocación, el objeto que colocarás es indicado por el selector de la parte superior de la pantalla. La selección en el mismo se halla dividida por las pestañas inmediatamente bajo el mismo.

Puedes seleccionar el tipo de obstáculo que quieras que sea colocado en el mapa en el selector de objeto superior. Simplemente haz click en él para seleccionarlo. Los obstáculos se dividen en grupos para proveer mejor visión general.

Presionando espacio, entrarás en el modo de selección siendo indicado por el cursor cambiado. Sólo puedes seleccionar grupos de objetos representados por el modo de objeto activado.
Nota importante: Sólo serás capaz de seleccionar cosas que se incluyen en el modo seleccionado, si estás en modo obstáculo, no podrás seleccionar objetos o baldosas de suelo.


        Modo de edición de Obstáculo:

Para seleccionar este modo, haga click en el botón que dice 'Obstáculo' del selector de categoría en el área inferior izquierda.
Teniendo seleccionado un obstáculo, simplemente haga click en algún lugar del mapa para colocarlo en la posición del cursor.
Puesto que hacer click es un poco impreciso, también puede usar su teclado numérico para posicionar obstáculos.
Haga click al más a la izquierda de los cinco botones sobre el selector de categoría para tener una cuadrícula con números. Use el click derecho para activarla y click derecho para cambiar el modo de la misma.
Estos números se refieren a los números de su teclado numérico si dispone de uno. Presionar '1' colocará el obstáculo seleccionado en el selector en la posición del dígito '1' en la cuadrícula púrpura.
Puesto que colocar una línea de muros es bastante ineficiente, puedes simplemente mantener el click izquierdo y una línea de muros es colocada mientras mueves el puntero si tienes un objeto muro seleccionado. Esto funciona con los muros más comunes en FreedroidRPG.
Mientras sujete el botón izquierdo colocando muros, un click derecho eliminará todos los muros que dibujó tras comenzar a presionar el botón izquierdo.
Hay algunos objetos especiales. Los muros de vidrio y los muros de ladrillos agrietados, pero también barriles y cajas pueden ser destruidos con unos pocos golpes, mientras que los dos últimos podrían expulsar objetos. Los cofres pueden ser abiertos y también pueden contener objetos.
El símbolo con huellas tachadas no es realmente un objeto sino un área de bloqueo invisible ('rectángulo de colisión'). Los rectángulos de colisión son el núcleo de todo obstáculo puesto que previenen simplemente caminar a través de ellos como puede hacerse con las baldosas de suelo o los puntos de camino.

            Selección de obstáculos

Manteniendo el botón izquierdo del mouse puede seleccionar un rectángulo de obstáculos. Tras soltar el botón, los obstáculos seleccionados se tornarán de un color distinto indicando que se hallan seleccionando. Para seleccionar obstáculos fuera del rectángulo, mantenga 'Ctrl' y haga click en el obstáculo o dibuje otro rectángulo.
Usted podría haber automáticamente seleccionado varios obstáculos con un click. Puede cambiar entre ellos haciendo click en el icono con la silla y la estantería, o presionando 'n'.
El icono con el cubo de basura puede borrar el obstáculo seleccionado.
También puede cortar (Ctrl+x, purede ser usado para borrar mediante no pegarlos ;) ), copiar (Ctrl+c) y pegar (Ctrl+v) obstáculos cortados o copiados.
Puedes mover obstáculos seleccionados manteniendo shift izquierdo y arrastrando el objeto. Sin embargo, esto puede ser bastante impreciso.

            Colocar objetos en Cofres

Simplemente seleccione el cofre deseado y haga click en el botón más a la izquierda en la fila superior de botones.
Se te pasará a una pantalla similar a la pantalla de tienda.
Se mostrará un cuchillo (que en realidad no se halla en el cofre por cierto), selecciónelo y haga click en 'vender'.
Seleccione los objetos que quiere que sean expulsados cuando el jugador abre el cofre.
Estos objetos se mostrarán en la barra de compra superior.
Para eliminar uno de estos, simplemente selecciónelo y haga click en 'comprar'.
La cruz roja le saca de la pantalla.

            Añadir texto a un Cartel

Seleccione el cartel y añada una etiqueta de obstáculo con el texto del cartel. Guarde el mapa y salga.
Abra el documento del nivel (map/levels.dat) y halle la nueva etiqueta de obstáculo. Cambie la línea sobre el texto de 'type=30' ' a type=32' y guarde.
Ahora cuando haga click en el cartel en el juego su mensaje corto aparecerá.

            Añadiendo un Diálogo a un Terminal

Seleccione el terminal y añada una etiqueta de obstáculo con el nombre de diálogo que desee usar. Guarde el mapa y salga.
Abra el documento de nivel (map/levels.dat) y halle la nueva etiqueta de obstáculo.
Change the line above the text from 'type=30' to 'type=32' and save. Now when you click on the terminal in the game it will start the dialog you selected.

        Floor edit mode:

The floor edit mode works quite similar to the obstacle edit mode. You can select different types of floors at the object selector.
To fill a region with a single floor tile, first select the tile to use, then click and drag the left mouse button until it covers the desired region. The floor tiles are placed on the current floor layer.
There are no floors that are special in any way, they are pure decoration.

The visibility of floor layers can be controlled by a button with the layer icon. The button is only displayed for levels with multilayer floors.
Left click on the button switches between a single floor layer displayed and all floor layers displayed. Right click on the button changes the current floor layer.

            Selecting floor types

Selecting is as easy as in the the obstacle mode. Floor tiles can be moved to with the method described above.
For levels with multilayer floors only visible floor layers are selected. When a single floor layer is visible, only the tiles in the current floor layer are selected.

In order to have a look at the floor only, click the lamp icon to have no obstacles displayed. Another click will let obstacles appear again.
The icon with the turquoise rectangle displays collision rectangles. These rectangles indicate the blocking-area of an obstacle. Tux can't walk on such an area.
If you turn it on and playtest (explained later) your map, the rectangles are still displayed if activated which is quite useful for testing whether the player can pass a gap or not.

        Item edit mode:

You can place items to be used by the player on the map, too.
Items are objects that the player can pick up. They can be they can be carried, some even be used or equipped.
Some items are used to move the plot forward, others provide bonuses to the player, while still others do nothing at all.
Select the item mode and click on an item displayed at the object selector. For some items, you must specify an amount before they are placed.
You can set it by clicking the arrow buttons or dragging the blue orb to the left or the right.
Press 'g' to have a better overview of what items are available (can also be used for dropping, items will be dropped at the crosshair). Hit 'Esc' to abort the process without dropping any items.
You can also click the icon with the crossed-out boots to perform this.


        Waypoint edit mode:

Currently, droids (meaning all non-player characters) move around on levels using predefined waypoints.
To plant a waypoint, press the 'w' key. This will toggle the waypoint on the rectangle under the crosshair.
You can also click the map at a position you want to have a waypoint having this mode activated. Another click somewhere else plants another waypoint and automatically connects the previous selected one with it.
Clicking on a preexisting waypoint lets you connect it with another one (just click the other one, too, to do it).
However, there is a difference between those two planting methods. When you connect two waypoints using the keyboard, the connections will be unidirectional.
That means that when you make a connection from waypoint A to waypoint B, the bot will only be able to walk from A to B but not back.
You can remove an unidirectional connection by 'overlying' it with another one going into the very direction as the one you want to delete (this does not work with bidirectional connections!).
Bidirectional connections are however automatically done using the click method to connect waypoints.
Important note: It is not possible to connect waypoints on different maps with each other!
Waypoints are also used to position randomly spawned bots. However this might be inappropriate for some waypoints.
There are 'normal' ones which are white, for respawning bots and 'special', purple ones which should be used for NPCs. The normal ones are used for spawned bots, the purple ones should be used for NPCs.
You can select these different types of waypoints in the upper selection bar. To turn a normal waypoint into a purple one or back again, press shift+w.
Please make sure that paths between waypoints are not blocked by an obstacle in between of two waypoints.
To automatically check a entire map for this, you can use the map level validator which is explained later.


        Planting Labels:

There are two kinds of tables: map labels and obstacle labels.
Please make sure that each label ID is unique.
Giving an empty string will delete the respective label.


            Planting map labels

Map labels are used to define starting locations of NPCs (see ReturnOfTux.droids), events that occur when Tux moves over them (see events.dat), or locations used for movement of NPCs through the lua script files (events, quests, and the dialogs).
To define a new map label, press the 'm' key on the keyboard or click the button with the M on the sign on it. You will be prompted for the map label. Note that there will be a colorful circle appearing on any map tile that has been fitted with a map label.
The map label will be automatically planted on the tile in the middle of the screen.
You can switch the displaying of droids/NPCs on or off pressing the button with the 302 bot on it.

            Planting obstacle labels

Obstacle labels are important so that some obstacles can be marked for events to happen (for example during a quest). If e.g. an event is supposed to remove a special wall obstacle, then this obstacle must be given a name or ID first, so it can be referred to later in the definition of the event.
You can also use them to add dialogs to obstacles, so you can talk to them as they were NPCs.
To plant a label on an obstacle, you must first mark this obstacle (see obstacle mode explanation above).
Clicking the icon with the sign and the O on it you will be prompted for the new label to attach to this obstacle.

You can toggle display of map labels using the small icon with the label-circle on it.

        Saving maps:

In order to save a map, click the small disk icon in the upper right area of the editor screen. The door icon lets you exit the editor.
You can also do this via the menu that is opened by pressing the 'Esc' key.


General tips:

	Getting overview
In order to change the zoom factor, press the 'o' key or click the icon with the magnifying glass on it.
Try left and right clicking in order to access different zoom factors.


	The editor menu

You can access this menu by pressing ESC.

		"Level:"
Here you can easily navigate to other levels. You can either use the arrow keys having this option selected
in order to switch to the next or previous (refers to level numbers) level, or, clicking on it, enter the number of the desired level and press enter.

		Level options
				Level:	See above for explanation
				Name:	The map name displayed at the GPS in the upper right corner of the game screen. You can disable the GPS in-game using the options menu.
				Size:	You can increase or reduce the size of your level. Select the desired edge where you want to add/remove a line of tiles and click the <- or -> arrow buttons.
				Floor layers: In order to change the number of floor layers for the current level, use the <- or -> arrow buttons.
				Edge interface:	Here you can set the levels that shall be next to the current level. Enter the level number for the respective edge.
								A level can only have one adjacent level (one it touches edges with) in each of the four cardinal directions (North, South, West, East).
				Random dungeon:	If you set this option to 'Yes', the map will automatically generate a dungeon. You set the number of teleporters to and from this map clicking on the option.
								Randomly generated dungeons automatically will have everything necessary, like waypoints, bots, and obstacles, set.
				Item drop class for obstacles:	Set of what item class items dropped by barrels/chests/crates should be.
				Teleport blockade:	Make it (im)possible to teleport away from a level.
				Teleport pair:	This important if you make a dungeon that is not directly connected to another map. You can set the number of exits and entrances for a randomly generated dungeon here.
				Light:			How much light would you like to have? Press space to switch between ambient (general brightness of the present map) and bonus (light emitted by some obstacles, such as lamps or mushrooms) mode.
				Background music:	Here you can set a music track to be played while the player walks around on the map. Possible tracks can be found in ./sound/music/ .
									Just enter the file name including the .ogg extension.
				Infinite running Stamina:	If you have this set to "yes", Tux' stamina will not decrease while running across the map. This should only be used if the level has no hostile NPCs on it, like on level 0, the Town, for example.
				add/rem level:		Lets you add a new level or remove the current level.

		Advanced options
Here you can run the map level validator.
The map level validator checks all the paths between connected waypoints to ensure they are not blocked by obstacles. More detailed output explaining which paths are blocked can be found in the terminal, given the case that the game is run using it, or a global error output file.
It can also check if you have obstacles near map borders in a critial way.
This should ALWAYS be run before calling a map finished.
"freedroidRPG -b leveltest" does also run this check.

		Playtest mapfile
Allows you to playtest your modifications easily.
If you leave this mode, obstacle changes that were made while playing, destroying crates for example, will be reverted to the time where you started playtesting.




Keys:
space					toggle planting/selection mode
w						plant waypoint
shift+w					toggle mode for waypoints to 'random bot' or 'NPC'
escape					access menu
numberpad digits 1-9	used to plant obstacles at the respective positions of the grid
n						cycle through selected obstacles (next)
z						undo last action
y						redo last undid action
c						set paths between waypoints
ctrl+x or backspace		cut selected object(s), can be used to delete objects by not pasting afterwards
ctrl+c					copy selected object(s)
ctrl+v					paste cut/copied object(s)
alt+shift				drag/move selected object using the mouse
arrow keys				scroll around the map
ctrl+arrow keys			scroll around in bigger steps
mousewheel				scroll through obstacles of the object selector
ctrl+pageup/page down	scroll through obstacles of the object selector
g						access drop item screen
t						toggle 3x3 transparency around the crosshair
m						add/edit a map label at the position of the crosshair or the selected tile
o						zoom
tab						switch to the next editing mode
shift+tab				switch to the previous editing mode
f						switch to the next object tab
shift+f					switch to the previous object tab


If you encounter problems with the editor, please contact us.
Also, don't be afraid to send us maps if you made something cool, we don't bite. :)
]]
}
