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
            KARTREDIGERAREN I FREEDROIDRPG

=== INTRODUKTION ===

FreedroidRPG har en inbyggd kartredigerare. Med den kan du styra alla delar i en vanlig karta i FreedroidRPG och spara kartor.

Du når den från huvudmenyn (klicka på "Kartredigerare") eller kör "freedroidRPG -e".

    --- Verktygstips ---
För att visa/dölja verktygstipsen som dyker upp där musen hovrar, klicka på den vita pratbubblan nära fönstrets högra kant (i den nedre knappraden).

    --- Kort information ---
Kort information om hinder och objekt visas om du högerklickar på dem i den över objektlisten.

    --- Navigation ---
För att byta karta, klicka på siffrorna i minikartan i nedre högra hörnet eller välj önskat område från kartredigerarens meny (beskrivs senare).

    --- Kartredigering ---
Det finns fyra redigeringslägen: hinder-, golv-, föremåls- och waypoint-redigering.

Vilka sorters objekt du kan markera/placera ut bestäms av knapparna nere till höger.
När någon av knapparna är markerad och du är i placeringsläge, visar listen längst upp på skärmen det objekt som kommer placeras ut. Objekten i listen grupperas i flikar, i listens undre kant.

Du kan välja det hinder du vill placera ut i objektlisten längst upp. Klicka helt enkelt på det. Hindren har grupperats upp för att bli lättare att överskåda.

Genom att trycka mellanslag byter du till markeringsläge, vilket den ändrade muspekaren visar. Du kan endast markera objekt som ingår i det valda redigeringsläget.
OBS: Om du är i hinderredigeringsläget kommer du inte kunna markera t.ex. föremål eller golvplattor.


        Hinderredigeringsläget:

För att välja detta läge, klicka på knappen "Hinder" i lägesväljaren nere till höger.
När du valt ett hinder, klicka någonstans på kartan för att placera ut det där.
Eftersom musklick är lite oprecisa kan du även använda numpad för att placera ut hinder.
Klicka på den knappen längst till vänster i knappraden ovanför lägesväljaren (den föreställer ett rutnät) för att visa/dölja ett rutnät med siffror. Vänsterklicka på den för att växla mellan olika sorts rutnät.
Numren i rutnätet representerar numren på numpad - om du har en. Ett tryck på "1" kommer placera det valda objektet i objektlisten på 1:an i det lila rutnätet.
Eftersom detta är ett ganska ineffektivt att sätta ut väggar på kan du istället hålla ned vänster musknapp och dra. Väggar kommer placeras ut där du drar musen, om du har valt ett väggobjekt i objektlisten. Detta sätt fungerar för de vanligaste väggarna i FreedroidRPG.
Om du, medan du håller vänster musknapp nedtryckt, högerklickar kommer alla väggar du ritat sedan du tryckte ned vänster musknapp raderas.
Det finns några speciella objekt. Glasväggar och spruckna tegelväggar, men även tunnor och lådor, kan förstöras med några slag, och de senare kan även ge ifrån sig föremål. Kistor kan öppnas och kan även innehålla föremål.
Symbolen som föreställer överkryssade fotsteg är egentligen inget objekt utan en osynligt blockerat område ("kollisionsrektangel"). Kollisionsrektanglar finns nära inpå alla hinder och förhindrar att du går igenom dem precis som du kan göra med waypoints eller golvplattor.

            Markera hinder

När du håller ned vänster musknapp kan du markera en rektangel av hinder. När du släppt musknappen ändras hindrens färg vilket betyder att de är markerade. För att markera hinder som inte är inom räckhåll för rektangeln håller du ner "Ctrl" och klickar på hindret du vill markera eller så ritar du en till rektangel.
Du kanske automatiskt markerat flera hinder i ett klick. Du kan växla mellan hindren genom att klick på knappen som föreställer en stol och en hylla eller genom att trycka "n".
Knappen med soptunnan raderar de markerade hindren.
Du kan även klippa ut (Ctrl+x, kan även radera hinder genom att man aldrig klistrar i dem igen ;) ), kopiera (Ctrl+c) och klistra in (Ctrl+v) hinder från urklipp.
Du kan flytta markerade hinder genom att hålla ner vänster shift och dra hindret. Men detta sätt kan vara mycket oprecist.

            Placera objekt i kistor

Markera önskad kista och klicka på knappen längst till vänster i översta knappraden.
Du hamnar på en skärm som ser ut som den när du köper saker.
Där finns det en kniv (som för övrigt inte ligger i kistan), markera den och klicka på "sälj"-knappen.
Välj de föremål du vill att kistan ska ge ifrån sig när spelaren öppnar den.
De föremålen visas i den övre listen i "butiken".
För att ta bort ett av dessa föremål, markera det och klicka på "köp".
Det röda krysset tar dig därifrån.

            Sätta text på en skylt

Markera skylten och lägg till en hinderetikett med önskad text. Spara kartan och avsluta.
Öppna kartfilen (map/levels.dat) och leta åt din hinderetikett. Ändra raden ovanför från "type=30" till "type=32" och spara.
När du nu klickar på skylten i spelet dyker ett kort meddelande upp.

            Ge en terminal en dialog

Markera terminalen och lägg till en hinderetikett med dialognamnet du vill använda. Spara kartan och avsluta.
Öppna kartfilen (map/levels.dat) och leta åt din hinderetikett.
Ändra raden ovanför från "type=30" till "type=32" och spara. Nu när du klickar på terminalen i spelet kommer den starta den önskade dialogen.

        Golvredigeringsläget:

Golvredigeringsläget fungerar ungefär som hinderredigeringsläget. Du kan välja olika sorters golv i objektlisten.
För att fylla ett område med en viss sorts golvplatta, välj den golvplatta du vill använda, klicka och dra med vänstra musknappen tills du fyllt området. Golvplattorna läggs på det aktuella golvlagret.
Golv  har inga speciella egenskaper, de är bara dekoration.

Golvlagrens synlighet styrs med knappen som föreställer flera lager. Knappen visas bara på kartor med flerlagergolv.
Vänsterklick på knappen växlar mellan att visa ett golvlager eller alla golvlager. Högerklick på knappen byter aktuellt golvlager.

            Markera golvplattor

Markering är lika enkelt som i hinderläget. Golvplattor kan flyttas på samma sätt som beskrivits tidigare.
På kartor med flerlagergolv markeras endast synliga golvlager. När bara ett enda golvlager är synligt markeras endast det lagrets golvplattor.

För att ta en titt på golvet, klicka på knappen med lampan och alla hinder döljs. Ytterligare ett klick visar alla hinder igen.
Ikonen med den turkosa rektangeln visar alla kollisionsrektanglar. Dessa rektanglar visar blockeringsområden runt hinder. Tux kan inte gå där.
Om du visar dem och testspelar din karta (förklaras senare), kommer rektanglarna fortfarande synas vilket kan vara ganska praktiskt när du ska testa om spelaren kan komma igenom en passage eller inte.

        Föremålsredigeringsläget:

Du kan även placera ut föremål som spelaren kan använda.
Föremål är objekt som spelaren kan plocka upp. De kan transporteras och vissa kan även användas eller bäras.
Vissa föremål är en del av spelets plot, andra är bonusar för spelaren och ytterligare andra gör ingenting alls.
Välj föremålsredigering och klicka på ett föremål i objektlisten. Vissa föremål kräver även att du anger mängden du vill placera ut.
Du kan ange det genom att klicka på pilknapparna eller dra den runda knoppen till vänster eller höger.
Tryck "g" för att få bättre översikt över alla föremål som finns (kan även användas för att släppa föremål på korshåren). Tryck "Esc" för att avbryta utan att släppa några föremål.
Du kan även klicka på knappen som föreställer de överkryssade stövlarna.


        Waypoint-redigeringsläge:

För tillfället rör sig droider (d.v.s alla Non Player Characters) längs förutbestämda waypoints.
Tryck "w" för att placera en waypoint. Det lägger en waypoint på rektangeln under korshåret.
Du kan även klicka någonstans på kartan när du är i waypoint-redigeringsläget. Ett till klick någonstans skapar en till waypoint och förbinder den automatiskt med den senast markerade.
Att klicka på en befintlig waypoint låter dig förbinda den med en annan (klicka bara på den andra också).
Men det finns en skillnad mellan dessa två metoder att placera waypoints. När du förbinder två waypoints via tangentbordet blir förbindelserna enkelriktade.
Det betyder att när du gör en förbindelse mellan waypoint A och waypoint B kommer bottarna endast gå från A till B men inte tillbaka.
Du kan ta bort en enkelriktad förbindelse genom att skapa en till ovanpå i samma riktning som du vill ta bort (detta fungerar inte med dubbelriktade förbindelser).
Dubbelriktade förbindelser skapas dock automatiskt när du använder klick-metoden för att förbinda waypoints.
OBS: Det är inte möjligt att förbinda waypoints på olika kartor med varandra!
Waypoints används även till att slumpmässigt placera ut bottar. Men det kanske inte passar för alla waypoints.
Det finns "vanliga", vita, waypoints som används för "återställbara" bottar och röda waypoints som bör användas för NPCs.
Du kan välja mellan dessa olika sorter i objektlisten. För att göra en vanlig waypoint till en röd eller vice versa, tryck shift+w.
Se till att inte placera några hinder i vägen för förbindelsen mellan två waypoints.
För att automatiskt kontrollera detta på en hel karta kan du använda kartkontrollen, vilket förklaras senare.


        Placera etiketter:

Det finns två sorters etiketter: kartetiketter och hinderetiketter.
Se till att varje etiketts ID är unikt.
Att ge den ett tomt ID kommer ta bort den.


            Placera kartetiketter

Kartetiketter används för att bestämma utgångspunkterna för NPCs (se ReturnOfTux.droids), händelser som inträffar när Tux går över dem (se events.dat), eller platser som används för att flytta NPCs via lua-script (händelser, uppdrag, och dialoger).
För att skapa en ny kartetikett, tryck "m" på tangentbordet eller klicka på knappen med ett M på (?). Du kommer frågas efter ett namn på etiketten. Lägg märke till den färgglada cirkeln som visas på marken där en kartetikett placerats.
Kartetiketten kommer placeras i mitten av skärmen (under korshåret).
Du kan visa eller dölja droider/NPCs genom att klicka på knappen med bott 302 på.

            Placera hinderetiketter

Hinderetiketter gör så att hinder kan markeras för att sedan förknippas med en händelse (t.ex. i ett uppdrag). Om t.ex. en händelse ska flytta en speciell vägg måste den väggen först fått ett namn eller ID så att man kan hänvisa till det namnet senare när man skapar händelsen.
Du kan även använda dem till att ge hinder dialoger, så du kan prata med dem som om de var NPCs.
För att ge ett hinder en etikett markerar du först hindret (se förklaring av hinderredigeringsläget ovan).
Klicka på knappen som föreställer en skylt med ett O; du blir ombedd att ge etiketten ett namn.

Du kan visa eller dölja etiketter genom att klicka på knappen med en etikett-cirkel.

        Spara kartor:

För att spara en karta: klicka på knappen med en diskett, uppe i höger hörn. Med dörrknappen stänger du kartredigeraren.
Du kan även göra det via menyn som visas när du trycker "Esc".


Allmänna tips:

	Få översikt
För att ändra zoom, tryck på "o"-tangenten eller på knappen med ett förstoringsglas.
Vänster- och högerklicka för olika zoomnivåer.


	Redigerarens meny

Du kommer åt menyn genom att trycka på "Esc".

		"Område:"
Här kan du enkelt navigera till andra områden. Du kan antingen använda piltangenterna när det här alternativet är markerat
för att byta till föregående eller nästa (se områdets nummer) område, eller klicka på det, skriva in önskat nummer och slå enter.

		Områdesegenskaper
				Område:	Se ovan
				Namn:	Kartnamnet som visas i det övre högra hörnet i spelet. Du kan stänga av kartnamnet i menyn inställningar.
				Storlek:	Du kan öka eller minska storleken på ditt område. Välj önskad kant där du vill lägga till/tar bort rader och klicka på <- eller -> knappen.
				Golvlager: För att ändra antal golvlager, använd <- och -> knapparna.
				Kanter:	Här ställer du in vilka områden som ska ligga kant i kant med detta område. Ange ett nummer för varje kant.
								Ett område kan endast ha ett intilliggande område per kant (norr, söder, väster, öster).
				Slumpad labyrint:	Om du väljer "ja" här kommer kartan automatiskt skapa en labyrint. Du ställer in antal teleportrar till och från kartan genom att klicka på alternativet.
								Slumpade labyrinter innehåller allt som behövs, bl.a. vapen, bottar och hinder.
				Klass på föremål som släpps:	Ställ in vilken klass det ska vara på föremålen som släpps av tunnor/kistor/lådor.
				Teleportblockad:	Gör det (o)möjligt att teleportera till och från området.
				Teleportpar:	Detta är viktigt om du gör en labyrint som inte är direkt anknuten till ett annat område. Du kan ställa in antal utgångar och ingångar för slumpmässiga labyrinter här.
				Ljus:			Hur ljust vill du ha det? Tryck mellanslag för att växla mellan omgivningsläge (allmänt ljus) och bonusläge (ljus som sprids av vissa hinder t.ex. lampor och svampar).
				Bakgrundsmusik:	Här kan du välja ett musikspår som spelas när spelaren går i området. Tillgängliga spår finns i ./sound/music/ .
									Skriv in filnamnet inklusive tillägget (.ogg).
				Obegränsad löparuthållighet:	Om du ställer detta till "ja" kommer Tux uthållighet inte minska när han springer runt i området. Detta bör endast användas på områden utan fiender, t.ex. område 0, Stan.
				Skapa/radera område:		Låter dig lägga till ett nytt område eller ta bort det aktuella området.

		Avancerade inställningar
Här kan du köra kartkontrollen.
Kartkontrollen kontrollerar att inga vägar mellan waypointsen blockeras av hinder. Mer detaljerad utdata om vilka vägar som är blockerade syns i terminalen, om spelet körs från en sådan, eller i den globala "error output"-filen.
Den kontrollerar också om du har hinder för nära kanterna.
Den bör ALLTID köras innan en karta kan förklaras färdig.
"freedroidRPG -b leveltest" kör även det här testet.

		Testspela kartan
Ett smidigt sätt att testa dina ändringar på.
När du lämnar detta läge kommer alla ändringar du kan ha gjort, t.ex. förstörda lådor, återställas som de var när du började testspela.




Tangenter:
mellanslag			växla mellan placerings- och markeringsläge
w				placera waypoint
shift+w			växla waypointläge mellan "slumpmässig bott" och "NPC"
esc				visa menyn
numpad 1-9			används för att placera hinder på respektive positioner i rutnätet
n				bläddra mellan markerade hinder (nästa)
z				ångra senaste ändring
y				gör om senast ångrad ändring
c				koppla ihop waypoints med varandra
ctrl+x eller backsteg	klipp ut objekt, kan användas för att radera genom att aldrig klistra in
ctrl+c				kopiera markerade objekt
ctrl+v				klistra in urklippta/kopierade objekt
alt+shift			dra/flytta markerat objekt med musen
piltangenter			flytta omkring kartan
ctrl+piltangenter		flytta omkring snabbare
mushjul			skrolla igenom objekten i objektlisten
ctrl+page up/page down	skrolla igenom objekten i objektlisten
g				visa föremålsskärmen
t				slå på/av 3x3 rutors genomskinlighet runt korshåren
m				skapa/ändra en kartetikett vid korshåren eller på markerad golvplatta
o				zooma
tab				byt till nästa redigeringsläge
shift+tab			byt till föregående redigeringsläge
f				byt till nästa flik i objektlisten
shift+f			byt till föregående flik i objektlisten


Om du stöter på problem med kartredigeraren, kontakta oss är du snäll.
Och var inte rädd att skicka oss kartor om du gjort något coolt, vi bits inte. :)
]]
}
