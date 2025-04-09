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
            DER FREEDROIDRPG LEVEL-EDITOR

=== EINFÜHRUNG ===

FreedroidRPG besitzt einen eingebauten Level-Editor. Dieser Editor bietet alle Möglichkeiten, um Karten für dieses Spiel zu gestalten und zu testen.

Man kann ihn vom Hauptmenü aus aufrufen (auf "Level-Editor" klicken) oder direkt ausführen, mit Hilfe des Kommandos "freedroidRPG -e".

    --- Hinweise ---
Um nützliche Hinweise und Erklärungen für bestimmte Buttons zu bekommen, während man mit der Maus darauf zeigt, klickt man auf die weiße Sprechblase nahe dem rechten Bildrand (untere Symbolleiste).

    --- Weiterführende Details ---
Details über Hindernisse und Gegenstände erscheinen, wenn man mit der rechten Maustaste im oberen Objektauswahlbereich darauf klickt.

    --- Navigation ---
Um die aktuelle Ebene zu wechseln, klicke auf die jeweilige Nummer auf der Minikarte unten rechts oder wähle die gewünschte Ebene im Menü des Level-Editors (wird später genauer beschrieben).

    --- Karten bearbeiten ---
Es gibt 4 Bearbeitungs-Modi: Hindernis-Modus, Boden-Modus, Gegenstands-Modus und Wegpunkt-Modus.

Der Button unten links, den man gewählt hat, zeigt, welche Objekte man wählen oder platzieren kann.
Wenn ein Button gewählt wurde, kann man das Objekt, das auf dem Band oben am Bildschirm gezeigt wird, platzieren. Mit Hilfe der Register kann man weitere Objekte wählen.

Wähle den Objekttyp, den du platzieren willst, auf dem oberen Objektauswahlbildschirm. Klicke einfach mit der linken Maustaste drauf. Zur besseren Übersicht sind die Objekte in verschiedene Gruppen eingeteilt.

Drücke die Leertaste, um in den Auswahlmodus zu wechseln. Passend dazu ändert sich der Mauszeiger. Jetzt ist es möglich, bereits platzierte Objekte des aktuellen Objekt-Modus auszuwählen.
Wichtiger Hinweis: Wenn man z.B. im Hindernis-Modus ist, kann man keine Gegenstände oder Bodenteile auswählen.


        Hindernis-Bearbeitungsmodus:

Um diesen Modus zu wählen, klicke auf den Button namens "Hindernis" in der Kategorieauswahl links unten.
Wurde ein Hindernis gewählt, klicke auf die Stelle auf der Karte, wo es platziert werden soll.
Sollte dies zu unpräzise sein, kann man stattdessen den Ziffernblock zum Platzieren benutzen.
Um die Steuerung mit dem Ziffernblock zu vereinfachen, bewege den Mauszeiger zu den 5 Buttons oberhalb der Kategorieauswahl und klicke den ersten von links an. Dadurch wird ein Gitter aus Hilfslinien angezeigt (mit Ziffern darin). Diesen Gittermodus kann man jederzeit über diesen Button oder über das Rechtsklickmenü ändern.
Die Ziffern entsprechen den Tasten auf dem Ziffernblock. Drücke die "1" und das Hindernis wird auf dem Feld mit der Ziffer "1" platziert.
Auf diese Art ist es jedoch umständlich, wenn man eine große Mauer platzieren will. Einfacher geht es, wenn man die linke Maustaste gedrückt hält und den Zeiger in die Richtung bewegt, wo die Mauerteile hingehören sollen. Dies funktioniert mit den meisten Wandteilen dieses Spiels.
Solange man die linke Maustaste gedrückt hält während man Mauerteile platziert, reicht ein einfacher Klick mit der rechten Maustaste, um den Vorgang wieder abzubrechen.
Außerdem gibt es ein paar spezielle Objekte. Glaswände, brüchige Ziegelsteinmauern, aber auch Fässer und Kisten, die mit ein paar Schlägen zerstört werden können, wobei die letzten beiden Gegenstände hinterlassen können. Truhen können ebenfalls Gegenstände beinhalten.
Das Symbol mit den gekreuzten Fußspuren ist kein wirkliches Objekt, sondern ein unsichtbarer Bereich (ein sog. Kollisionsrechteck). Solche Rechtecke sind der Kern jedes Objekts, weil sie den Spieler daran hindern, dass man mitten hindurch läuft, anders als bei Bodenteilen und Wegpunkten.

            Wie man Hindernisse wählt

Halte die linke Maustaste und ziehe ein Rechteck über die Hindernisse, die du wählen willst. Lasse die Maustaste wieder los und die gewählten Hindernisse erhalten eine andere Farbe, nur um zeigen, dass sie gewählt wurden. Um weitere Objekte außerhalb eines solchen Rechtecks zu wählen, halte die Taste Strg/Ctrl gedrückt und klicke sie einzeln an oder ziehe weitere Rechtecke.
Dadurch lassen sich mehrere Hindernisse wählen. Um zwischen diesen hin und her zu wechseln, drücke die Taste N oder klicke auf das Symbol mit dem Stuhl und dem Brett darauf.
Das Symbol mit dem Mülleimer löscht die gewählten Objekte.
Man kann auch Objekte ausschneiden (Strg+X), kopieren (Strg+C) oder wieder einfügen (Strg+V). Ausgeschnittene Objekte zählen ebenfalls als gelöscht, wenn man sie nicht wieder einfügt ;) .
Um die gewählten Hindernisse zu bewegen, halte zuerst die linke Shift-Taste und danach die linke Maustaste, während man auf eines der gewählten Objekte zeigt. Allerdings kann dies etwas unpräzise sein.

            Objekte in Truhen platzieren

Wähle einfach die gewünschte Truhe und klicke auf den ersten Button von links in der oberen Symbolleiste.
Nun wird dir ein Bildschirm angezeigt, der dem Verkaufsbildschirm ähnelt.
Auf dem Bildschirm wird ein Messer angezeigt (welches sich noch nicht in der Truhe befindet). Wähle es und klicke auf den Button "Verkaufen".
Wähle nun die Gegenstände, die in die Truhe gelegt werden sollen.
Damit sind die Gegenstände im oberen Bereich des Verkaufsbildschirms gemeint.
Um einen Gegenstand wieder aus der Truhe zu entfernen, wähle ihn einfach und klicke auf "Kaufen".
Über das rote Kreuz kann der Bildschirm verlassen werden.

            Wie man ein Schild beschriftet

Wähle das Schild und füge eine Objektbezeichnung mit Schildtext hinzu. Speichere die Karte und beende das Programm.
Öffne die Leveldatei (zu finden unter map/levels.dat) mit einem beliebigen Texteditor und suche nach der Objektbezeichnung, die du vergeben hast. Ändere die Zeile über dem Text von "type=30" in "type=32" und speichere.
Wenn du im Spiel nun auf dieses Schild klickst, wird der Text, den du eingegeben hast, erscheinen.

            Einen Dialog im Terminal hinzufügen

Wähle das Terminal und füge eine Objektbezeichnung mit dem Dialognamen, den du benutzen willst, hinzu. Speichere die Karte und beende das Programm.
Öffne die Leveldatei (zu finden unter map/levels.dat) mit einem beliebigen Texteditor und suche nach der Objektbezeichnung, die du vergeben hast.
Ändere die Zeile über dem Text von "type=30" in "type=32" und speichere. Wenn du im Spiel nun auf dieses Terminal klickst, wird der Dialog, den du gewählt hast, erscheinen.

        Boden-Bearbeitungsmodus:

Dieser Modus funktioniert so ähnlich wie der Hindernis-Modus, nur mit dem Unterschied, dass du hier eine Vielzahl von Bodenteilen wählen kannst.
Um einen größeren Bereich mit einem einzigen Bodenteil zu füllen, wähle zuerst das gewünschte Teil und halte und ziehe die linke Maustaste über den Bereich. Die Bodenteile werden auf der aktuellen Ebene platziert.
Alle Bodenteile dienen nur zur Dekoration und besitzen keine Besonderheiten.

Die Sichtbarkeit von Bodenschichten kann über einen entsprechenden Button eingestellt werden. Allerdings wird er nur angezeigt, wenn man auch mehrere Schichten benutzt.
Klicke mit der linken Maustaste auf den Button, um entweder nur eine Schicht oder alle gleichzeitig anzuzeigen. Klicke mit der rechten Maustaste auf den Button, um die aktuell sichtbare Schicht zu wechseln.

            Bodenarten auswählen

Die Auswahl ist so einfach wie im Hindernis-Modus. Bodenteile können wie im vorherigen Abschnitt beschrieben verschoben werden.
Bei Leveln mit mehreren Schichten wird nur der aktuell sichtbare Teil gewählt. Sieht man nur eine Schicht, dann kann man nur diese Teile verschieben.

Damit man nur die aktuelle Schicht im Blick hat, muss man einfach auf das Lampensymbol klicken, um die Hindernisse auszublenden. Klickt man ein weiteres Mal auf den Button, sind die Hindernisse wieder sichtbar.
Das Symbol mit dem türkisen Rechteck repräsentiert die Kollisionsrechtecke. Diese Rechtecke markieren die Bereiche, die Hindernisse blockieren. Tux kann diese Bereiche nicht betreten.
Wenn du diesen Button aktivierst und einen Test durchführst (wird später genauer erklärt), dann werden die Rechtecke weiterhin angezeigt. Dies ist nützlich, um zu testen, ob ein Spieler eine Lücke betreten kann oder nicht.

        Gegenstands-Bearbeitungsmodus:

Du kannst ebenso Gegenstände mitten auf der Karte platzieren.
Gegenstände sind Objekte, die der Spieler aufheben kann. Sie können getragen, manche auch benutzt oder ausgerüstet werden.
Einige Gegenstände können benutzt werden, um das Spiel voranzutreiben, andere, um dem Spieler Vorteile zu verschaffen, und wieder andere, die gar nichts bewirken.
Wähle den Gegenstandsmodus und klicke auf einen Gegenstand, der im Objektauswahlbildschirm angezeigt wird. Bei einigen Gegenständen muss auch eine Menge angegeben werden, bevor man sie platzieren kann.
Die Menge kann mit den Pfeilbuttons eingestellt werden oder indem die blaue Kugel nach links oder rechts verschoben wird.
Drücke "G", um einen besseren Überblick zu bekommen, welche Gegenstände verfügbar sind (kann auch benutzt werden um Gegenstände abzulegen, sie werden dann bei der Zielmarkierung platziert). Drücke Escape, um keine Gegenstände abzulegen.
Ein Klick auf den Button mit gekreuzten Stiefeln hat dieselbe Wirkung.


        Wegpunkt-Bearbeitungsmodus:

Momentan können Droiden (bzw. alle Nicht-Spieler-Charaktere, genannt NPCs) sich auf vordefinierten Wegpunkten auf der Karte bewegen.
Um einen Wegpunkt zu setzen, drücke die Taste "W". Hiermit wird ein Wegpunkt auf dem Rechteck unter der Zielmarkierung aktiviert oder deaktiviert.
Ebenso kann man einfach auf die Karte klicken, um dort einen Wegpunkt zu setzen. Klickt man danach auf eine andere Stelle, wird ein weiterer Wegpunkt gesetzt, der automatisch mit dem vorherigen verbunden wird.
Klickt man auf einen bereits existierenden Wegpunkt, kann man diesen mit einem weiteren verbinden (einfach den 2. Punkt als nächstes anklicken).
Jedenfalls gibt es einen Unterschied zwischen beiden Platzierungsmethoden. Verbindet man 2 Wegpunkte mit Hilfe der Tastatur, sind die Verbindungen unidirektional.
D.h., wenn man eine Verbindung von Punkt A zu Punkt B erstellt, wird der Roboter sich nur von A nach B bewegen, aber nicht umgekehrt.
Um eine solche Verbindung zu löschen, muss man sie mit einer Verbindung in die entgegengesetzte Richtung "überlagern" (dies funktioniert nicht mit bidirektionalen Verbindungen!).
Bidirektionale Verbindungen werden automatisch erstellt, wenn man sie per Mausklick setzt.
Wichtiger Hinweis: Wegpunkte auf verschiedenen Karten können nicht miteinander verbunden werden!
Wegpunkte werden ebenfalls verwendet, um zufällig generierte Bots zu platzieren. Dies kann bei einigen Wegpunkten relativ ungünstig sein.
"Normale" Wegpunkte, wo Roboter platziert werden, sind weiß, "spezielle" Punkte, welche von NPCs benutzt werden sollten, sind violett.
Diese beiden Arten von Wegpunkten können im oberen Auswahlbereich benutzt werden. Um einen weißen Wegpunkt in einen violetten umzuwandeln oder umgekehrt, drücke Shift+W.
Stelle vorher sicher, dass die Wege zwischen den Punkten nicht durch Hindernisse blockiert sind.
Zur automatischen Überprüfung der ganzen Karte, kann der Kartenvalidator, der später erklärt wird, benutzt werden.


        Bezeichnungen festlegen:

Es gibt zwei Arten von Tabellen: Kartenbezeichner und Hindernisbezeichner.
Es muss sichergestellt sein, dass jede Bezeichnung einmalig ist.
Ein leerer Eintrag löscht den dazu gehörigen Bezeichner.


            Kartenbezeichner festlegen

Kartenbezeichner sind nötig, um Startpunkte für NPCs zu definieren (siehe ReturnOfTux.droids), Ereignisse, die auftreten, wenn Tux darüber stolpert (siehe events.dat), oder Orte an denen sich NPCs mittels Lua-Skript-Dateien bewegen (Ereignisse, Aufgaben und Dialoge).
Um einen neuen Kartenbezeichner zu definieren, drücke die Taste "M" auf der Tastatur oder klicke auf dem Button mit einem M auf einem Schild. Du wirst aufgefordert eine Bezeichnung einzugeben. Es sei angemerkt, dass ein farbiger Kreis über jedem Kartenteil erscheint, das einen solchen Bezeichner erhalten hat.
Der Kartenbezeichner wird automatisch auf dem Teil platziert, dass sich in der Mitte des Bildschirms befindet.
Es ist jederzeit möglich, alle Droiden/NPCs ein- oder auszublenden, indem man den Button mit dem 302-er Roboter betätigt.

            Hindernisbezeichner festlegen

Um Hindernisse mit bestimmten Ereignissen (die während einer Aufgabe auftreten) zu verknüpfen, muss man ihnen ebenfalls Bezeichner zuweisen. Wenn man z.B. ein bestimmtes Wandteil verschwinden lassen will, dann muss diesem Teil ein Name oder eine ID zugewiesen werden, damit es in einer Skript-Definition angesprochen werden kann.
Auf diese Weise kann man Hindernissen ebenso Dialoge hinzufügen, damit man mit ihnen reden kann als wären sie gewöhnliche NPCs.
Damit ein Hindernis einen Bezeichner erhalten kann, muss es zuvor ausgewählt sein (wurde im Hindernis-Modus bereits beschrieben).
Klicke auf das Symbol mit dem Schild und dem O darauf und du wirst aufgefordert diesem Hindernis einen neuen Bezeichner zu vergeben.

Außerdem ist es möglich mit Hilfe des kleinen Symbols mit dem Kreis die zuvor beschriebenen Kartenbezeichner ein- oder auszublenden, um Verwechslungen zu vermeiden.

        Wie man die Karte abspeichert:

Um eine Karte abzuspeichern, klicke auf das Diskettensymbol oben rechts im Editor-Bildschirm. Mit dem Türsymbol kann der Editor verlassen werden.
Ebenso kann man ein Menü mittels der Taste Escape aufrufen, in dem diese Optionen zur Verfügung stehen.


Generelle Tipps:

	Überblick
Um den Vergrößerungsfaktor zu ändern, drücke die Taste "O" oder klicke auf die Lupe.
Die dritte Möglichkeit ist, beide Maustasten zu drücken, um verschiedene Ansichten auszuprobieren.


	Das Editor-Menü

Diese Menü wird mit der Taste Escape aufgerufen.

		"Ebenen:"
Hier kann man schnell zwischen den Ebenen navigieren. Dabei kann man die Pfeiltasten benutzen, wenn diese Option aktiviert ist, 
um zwischen der nächsten oder vorherigen Ebene (abhängig von deren Nummerierung) zu wechseln, oder, indem man drauf klickt, die Nummer der Ebene eingibt und mit Enter bestätigt.

		Ebenenoptionen
				Ebene:	Siehe vorherige Beschreibung
				Name:	Der Name der Karte, die nahe des GPS oben rechts im Spielbildschirm gezeigt wird. Die Anzeige des GPS kann innerhalb des Spiels im Optionsmenü abgeschaltet werden.
				Größe:	Hier kann die Größe der aktuellen Ebene eingestellt werden. Wähle die Ecke, wo einige Teile hinzugefügt oder entfernt werden sollen und klicke auf die Pfeilbuttons.
				Bodenschichten: Um die Anzahl der Schichten für die aktuelle Ebene zu ändern, benutze die Pfeilbuttons.
				Eckverbindungen:	Hier kann man die Ebenen festlegen, die mit dieser Ebene verbunden sein sollen. Dafür muss man nur jeder Ecke die richtige Ebenennummer zuweisen.
								Eine Ebene kann nur mit einer weiteren Ebene (also genau eine pro Ecke) in jeder der 4 Himmelsrichtungen verbunden sein (also Norden, Süden, Westen, Osten).
				Zufallsverlies:	Ist diese Option aktiviert, wird der Aufbau der Karte zufällig generiert, wie ein Verlies eben. Zusätzlich kann die Anzahl der Teleporter bestimmt werden, die zu dieser Karte hin oder von ihr weg führen.
								Zufällig generierte Karten beinhalten automatisch alles was nötig ist, Wegpunkte, Roboter, Hindernisse, usw.
				Item-Klasse für Hindernisse:	Bestimme, welche Art von Gegenständen in Fässern/Truhen/Kisten versteckt sein sollen.
				Teleporterblockade:	Mach es dem Spieler (un)möglich, sich von dieser Karte wegzuteleportieren.
				Teleporterpaar:	Besonders wichtig, wenn zwei Karten nicht direkt miteinander verbunden sind. Hier kann festgelegt werden, welche Teleporter auf welcher Karte miteinander verbunden sind. Wer zufällig generierte Karten benutzt, sollte diese Einstellung auf keinen Fall vergessen.
				Licht:			Wie gut soll die Karte ausgeleuchtet sein? Drücke die Leertaste, um zwischen Normalmodus (gesamte Karte ist sichtbar) und Zusatzmodus (Licht wird nur von bestimmten Objekten ausgestrahlt, wie Lampen oder Pilzen) zu wechseln.
				Hintergrundmusik:	Hier kann das Musikstück ausgewählt werden, welches abgespielt wird, wenn der Spieler die Karte betritt. Mögliche Stücke befinden sich in ./sound/music/ .
									Einfach den Dateinamen inklusive der Endung .ogg eintippen.
				Unendlich Ausdauer:	Ist diese Option aktiviert, wird sich Tux' Ausdauer nicht reduzieren, wenn er über die Karte rennt. Sollte nur für Karten benutzt werden, auf denen sich keine feindlichen NPCs befinden, wie z.B. Ebene 0, oder die Stadt.
				hin/entf Ebene:		Hier kann eine neue Ebene hinzugefügt oder eine bestehende entfernt werden.

		Erweiterte Optionen
Hier kann der Kartenvalidator gestartet werden.
Der Kartenvalidator prüft bei allen verbundenen Wegpunkten, ob sich keine Hindernisse zwischen ihnen befinden. Eine detailliertere Ausgabe, welche die entsprechenden, blockierten Verbindungen auflistet, kann im Terminial/der Kommandozeile gefunden werden, falls diese im Hintergrund läuft, oder in der globalen Datei error.log.
Außerdem wird geprüft, ob sich Hindernisse am Kartenrand an kritischen Stellen befinden.
Dieser Schnelltest sollte IMMER benutzt werden, bevor man behauptet, die Karte sei fertig.
Dieser Test kann auch mit Hilfe des Kommandos "freedroidRPG -b leveltest" gestartet werden.

		Einen Spieltest durchführen
Hiermit kann man kleinere Änderungen sofort testen, als wäre die Karte bereits im Spiel integriert.
Wenn man diesen Modus wieder verlässt, werden alle Hindernisse wiederhergestellt, z.B. zerstörte Kisten, sodass man die Karte weiter bearbeiten kann.




Tasten:
Leertaste					Zwischen Auswahl- und Platzierungsmodus wechseln
W						Wegpunkt setzen
Shift+W					Wegpunktfarbe ändern (weiß/violett)
Escape					Menü aufrufen
Ziffern 1-9 (Ziffernblock)	zum Platzieren von Objekten auf den nummerierten Feldern (die Felder, die im Hilfslinienmodus gezeigt werden)
N						wechsle zwischen mehreren gewählten Objekten (nächstes)
Z						letzte Aktion rückgängig machen
Y						letzte rückgängig gemachte Aktion wiederherstellen
C						Pfade zwischen Wegpunkten setzen
Strg/Ctrl+X or Backspace		gewählte Objekte ausschneiden, kann auch zum löschen genutzt werden
Strg/Ctrl+C					gewählte Objekte kopieren
Strg/Ctrl+V					ausgeschnittene/kopierte Objekte einfügen
Alt+Shift				gewählte Objekte mit gedrückter linker Maustaste verschieben
Pfeiltasten				Kartenansicht verschieben
Strg/Ctrl+Pfeiltasten			Kartenansicht schneller verschieben
Mausrad				im Auswahlbildschirm blättern
Strg/Ctrl+Bild hoch/runter	im Auswahlbildschirm blättern
G						Gegenstände zum Platzieren auswählen
T						3x3 Felder großes, transparentes Zielkreuz ein-/ausblenden
M						Kartenbezeichner unter dem Zielkreuz oder auf dem gewählten Teil hinzufügen/ändern
o						vergrößern/verkleinern
Tab						zum nächsten Editiermodus wechseln
Shift+Tab				zum vorherigen Editiermodus wechseln
F						zum nächsten Objektreiter wechseln
Shift+F					zum vorherigen Objektreiter wechseln


Wer Probleme beim Editor entdeckt, sollte uns kontaktieren.
Falls ihr coole Karten erstellt habt, schickt sie uns ebenfalls. Wir beißen nicht. :)
]]
}
