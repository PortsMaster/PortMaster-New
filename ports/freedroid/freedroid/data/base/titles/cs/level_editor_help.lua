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
            EDITOR ÚROVNÍ FREEDROIDRPG

=== ÚVOD ===

Hra FreedroidRPG obsahuje vestavěný editor úrovní. Tento editor vám umožňuje ovládat jakýkoli aspekt normální mapy hry FreedroidRPG a její uložení.

Je přístupný z hlavního menu (klikněte "Editor úrovní") nebo spuštěním "freedroidRPG -e".

    --- Bublinová nápověda ---
Chcete-li přepnout popisy rozhraní během pohybu myši, klikněte na ikonu bílé bubliny nacházící se v blízkosti okraje pravého okna (spodní řádek tlačítek).

    --- Souhrnné informace ---
Souhrnné informace o překážkách a předmětech se zobrazí, pokud na ně kliknete pravým tlačítkem v horním výběru objektů.

    --- Navigace ---
Pro změnu současné úrovně klikněte na sousední číslo úrovně v pravém dolním rohu minimapy nebo vyberte požadovanou úroveň z menu editoru (popsáno později).

    --- Editace map ---
Existují čtyři módy editace: Editace překážek, editace podlahy, editace předmětů a editace navigačních bodů.

Zvolené tlačítko v levém dolním rohu ukazuje objekty, které lze vybrat nebo vložit.
Když je tlačítko vybráné a jste v režimu umístění, je objekt, který bude umístěn, zvýrazněn v pásovém menu horní části obrazovky. Výběr v pásu karet je rozdělen záložkami ihned pod ním.

Můžete si vybrat typ překážky, kterou chcete umístit na mapu v horním výběru objektů. Pro jeho výběr na něj jednoduše klikněte. Pro lepší přehled jsou překážky rozděleny do skupin.

Stisknutím mezerníku vstoupíte do režimu výběru, který je znázorněn změnou kurzoru. Můžete si vybrat pouze skupinu objektů reprezentovaných aktuálně aktivním režimem objektů.
Důležitá poznámka: Budete moci vybrat jen věci, které jsou zahrnuty v aktuálně zvoleném režimu. Jste-li v režimu překážek, nebudete moci vybrat předměty nebo podlahovou dlažbu.


        Editační mód překážek:

Za účelem výběru tohoto režimu, klikněte na tlačítko "Překážka" ve výběru kategorií v levé dolní části.
Po výběru překážky stačí kliknout kamkoli na mapu, abyste ji umístili na pozici kurzoru.
Vzhledem k trochu nepřesné povaze kliknutí lze k umístění překážky použít i numerickou klávesnici.
Klikněte na úplně vlevo umístěné tlačítko z pětice tlačítek (zobrazuje malou mřížku) nad výběrem kategorie, aby došlo k zobrazení mřížky s čísly. Použijte levé tlačítko myši pro zapnutí a vypnutí mřížky a pravé tlačítko myši pro změnu režimu mřížky.
Tato čísla se vztahují k číslům na vaší numerické klávesnici, pokud ji máte. Stisk klávesy "1" bude pokládat překážku, která je zvýrazněná ve výběru objektů na pozici číslice "1" na fialové roštu.
Vzhledem k tomu, že je takové umísťování řady stěn poměrně neefektivní, můžete jednoduše podržte levé tlačítko myši a stěny umísťovat ve směru pohybu kurzoru, pokud máte vybrán objekt zdi. To funguje ve hře FreedroidRPG s většinou běžných stěn.
Při držení levého tlačítka myši a umísťování zdí bude mít kliknutí pravým tlačítkem myši efekt odstranění všech zdí, které jste nakreslili od startu stisknutí levého tlačítka myši.
Existuje několik speciálních objektů. Skleněné zdi a popraskané cihlové zdi, ale rovněž sudy a bedny mohou být několika údery zničeny, zatímco poslední dvě překážky mohou uvolnit i předměty. Truhly lze otevřít a mohou také obsahovat předměty.
Symbol s přeškrtnutou stopou není ve skutečnosti objekt, ale pouze neviditelná oblast blokování ("kolizní obdélník"). Kolizní obdélníky jsou samotným jádrem každého objektu, protože zabraňují procházení skrze ně, jak je to možné v případě navigačních bodů a podlahových dlaždic.

            Výběr překážky

Podržením levého tlačítka myši můžete vybrat několik překážek najednou. Po uvolnění tlačítka myši vybrané překážky změní barvu, což oznamuje jejich vyběr. Chcete-li dodatečně vybrat další překážky, které nejsou v rozsahu původního výběru, podržte "Ctrl" a klikněte na překážku nebo proveďte další výběr více překážek.
Jedním kliknutím můžete automaticky vybrat několik překážek. Můžete přepínat mezi překážkami kliknutím na ikonu s židlí a policí nebo stiskem 'n'.
Ikona s košem odstraní vybranou překážku.
Překážku můžete také vyříznout (Ctrl+x lze také použít ke smazání překážek, pokud je opětovně nevložíte ;) ), kopírovat (Ctrl+c) a vkládat (Ctrl+v) vyříznuté nebo zkopírované překážky.
Stisknutím a táhnutím levého tlačítka myši lze vybranou překážkou pohybovat. To však může být poměrně nepřesné.

            Vkládání předmětů do truhel

Jednoduše vyberte požadovanou truhlu a klikněte na tlačítko úplně vlevo v horní řadě tlačítek.
Budete přesměrováni na obrazovku, která vypadá jako obrazovka obchodu.
K dispozici bude nůž (který ve skutečnosti mimochodem není umístěn v truhle), vyberte jej a klikněte na tlačítko "prodat".
Vyberte předmět, který má být upuštěn, když hráč otevře truhlu.
Tyto předměty budou zobrazeny v horní liště obchodu.
S cílem odstranit jednu z těchto položek, ji jednoduše vyberte a klikněte na "koupit".
Červený kříž vás dostane ven z obrazovky.

            Přidání textu na značku

Vyberte značku a přidejte popisek překážky se znaménkem textu. Uložte mapu a opusťte ji.
Otevřete soubor úrovně  (map/levels.dat) a najděte nový popisek překážky. Změňte řádek nad textem od "type=30" do "type=32" a uložte ho.
Nyní, když kliknete na značku ve hře, zobrazí se vaše krátká zpráva.

            Přidání dialogu do terminálu

Vyberte terminál a přidejte popisek překážky se jménem dialogu, který si přejete použít. Uložte mapu a opusťte ji.
Otevřete soubor úrovně (map/levels.dat) a najděte nový popisek překážky.
Změňte rádek nad textem mezi "type=30" a "type=32" a uložte ji. Nyní, když kliknete na terminál ve hře, spustí se dialog, který jste vybrali.

        Editační mód podlahy:

Režim úpravy podlah funguje podobně jako režim úprav překážek. Můžete si vybrat různé typy podlah ve výběru objektů.
Chcete-li vyplnit oblast jednou podlahovou dlaždicí, vyberte nejprve dlaždici k použití, klikněte na tlačítko a přetáhněte ji levým tlačítkem myši, dokud nebude pokrývat požadovanou oblast. Podlahové dlaždice jsou umístěny na aktuální podlahovou vrstvu.
Nejsou zde žádné speciální podlahy, všechny mají jen obyčejnou dekoraci.

Viditelnost podlahové vrstvy lze kontrolovat tlačítkem s ikonou vrstvy. Tlačítko je zobrazeno jen v úrovních majících vícevrstvé podlahy.
Klikněte levým tlačítkem myši na tlačítko pro přepnutí mezi zobrazením jedné podlahové vrstvy a všemi podlahovými vrstvami. Klikněte pravým tlačítkem myši na tlačítko pro změnu aktuální vrstvy podlahy.

            Výběr typů podlah

Výběr je stejně snadný jako v režimu překážek. Dlaždice mohou být přesunuty podle metody popsané výše.
Pro úrovně s vícevrstvými podlahami jsou vybrány pouze viditelné podlahové vrstvy. Je-li vidět jedna podlahová vrstva, jsou vybrány jen dlaždice pro aktuální podlahovou vrstvu.

Abyste se mohli podívat jen na podlahu, klikněte na ikonu lampy, aby zmizely všechny zobrazené překážky. Další kliknutí opět překážky zobrazí .
Ikona s tyrkysovým obdélníkem zobrazuje kolizi obdélníků. Tyto obdélníky označují blokující oblast překážky. Tux nemůže po takové ploše chodit.
Pokud ji zapnete a provedete herní test mapy (vysvětleno později), obdélníky jsou stále zobrazeny, pokud byly aktivovány, což je velmi užitečné pro testování, zda hráč může mezerou projít, nebo ne.

        Editační mód předmětů:

Na mapě můžete také rozmístit předměty, které mají být hráčem použity.
Předměty jsou objekty, které může hráč zvednout. Mohou být nošeny, některé lze i použit nebo se jimi vybavit.
Některé předměty jsou použity pro posun děje vpřed, jiné dávají hráči bonus, zatímco ty další nedělají nic.
Vyberte mód předmětů a klikněte na předmět zobrazení ve výběru předmětů. U některých předmětů je nutné zadat jejich počet ještě před tím, než jsou umístěny.
Můžete ho nastavit kliknutím na tlačítka se šipkami nebo přetažením modré koule doleva nebo doprava.
Stiskněte "g" pro lepší přehled dostupných předmětů (lze také použít pro upuštění, předměty budou upuštěny na míste zaměřovače). Stisněte "Esc" pro ukončení procesu bez upuštění předmětu.
Tuto akci lze také provést stisknutím ikony s přeškrtnutými botami.


        Editační mód navigačních bodů:

Momentálně se droidi (ve smyslu nehrajících postav) pohybují po úrovni za pomoci předdefinovaných navigačních bodů.
K položení navigačního bodu stiskněte klávesu "w". To přepne navigační bod na obdélník pod zaměřovacím křížkem.
Lze také kliknou na pozici v mapě, kde si přejete mít navigační bod s tímto módem aktivován. Další kliknutí na novou pozici umístí další novagační bod a automaticky ho propojí s předchozím vybraným bodem.
Kliknutí na již existující navigační bod vám umožní jeho propojení s jiným bodem (stačí na jiný bod kliknout).
Nicméně, mezi těmito dvěma metodami pokládání navigačních bodů je rozdíl. Pokud spojíte dva body pomocí klávesnice, spojení bude jednosměrné.
To znamená, že když uděláte spojení z bodu A do bodu B, bot bude schopen cestovat z bodu A do B, ale už ne zpět.
Jednosměrné spojení lze odebrat jeho "překrytím" jiným spojením jdoucím tím samým směrem jako spojení, které chcete odebrat (to nefunguje u obousměrného spojení!)
Obousměrná spojení jsou vytvářena automaticky použitím  myši k propojení navigačních bodů.
Důležitá poznámka: Není možné spojit navigační body mezi různými mapami!
Navigační body jsou také používány k náhodnému vzniku botů. To však může být pro některé navigační body nevhodné.
Jsou "normální" body bílé barvy určené ke vzniku botů a "zvláštní" fialové, které by měly být použity pro NPC. Normální body se používají pro vznik botů, fialové by měly být použity pro nehrající postavy.
Tyto různé typy navigačních bodů lze vybrat v horní liště výběru. Pro přepnutí normálního bodu na fialový nebo obráceně stisněte shift+w.
Ujistěte se prosím, že cesta mezi dvěma navigačními body není blokovaná překážkou.
Chcete-li toto automaticky zkontrolovat v celé mapě, můžete použít kontrolu mapy úrovně.


        Přidávání štítků:

Existují dva druhy štítků: štítky map a štítky překážek.
Ujistěte se, že má každý štítek unikátní ID.
Zadáním prázdného znaku smažete příslušný štítek.


            Přidávání štítků map

Štítky map jsou používány k definování pozic nehrajících postav (viz ReturnOfTux.droids], událostí, ke kterým dochází při pohybu Tuxe okolo těchto postav (viz events.dat) nebo míst používaných pro pohyb nehrajících osob pomocí skriptu lua (události, úkoly a dialogy).
Chcete-li definovat nový štítek mapy, stiskněte tlačítko "m" na klávesnici nebo klikněte na tlačítko se znakem M. Budete vyzváni k zadání štítku mapy. Všimněte si barevného kruhu, který se objeví na jakémkoli dlaždici mapy, která byla vybavena mapového štítkem.
Štítek mapy bude automaticky položen na dlaždici uprostřed obrazovky.
Můžete přepínat mezi zobrazením a vypnutím droidů/nehrajících postav stisknutím tlačítka s botem typu 302.

            Přidávání štítků překážek

Štítky překážek jsou důležité, takže některé překážky lze označit uskutečněním událostí (například v průběhu plnění úkolu). Pokud má například nějaká událost vyjmout speciální překážku typu zdi, pak musí mít tato překážka nejprve jméno nebo ID, takže se na ni lze později odvolávat v popisu události.
Můžete je také použít pro přiřazení dialogů k překážkám, takže s nimi můžete mluvit, jako by byly nehrající postavy.
Pro přiložení štítku k překážce ji nejprve musíte označit (viz vysvětlení módu překážek výše).
Kliknutím na ikonu s nápisem O budete vyzváni k zadání nového označení, které bude připojeno k této překážce.

Můžete přepínat zobrazení mapy štítků pomocí malé ikony s kruhovým štítkem.

        Ukládání map:

Abyste uložili mapu, klikněte na malou ikonu diskety v pravé horní části obrazovky editoru. Ikona dveří umožňuje ukončení editoru.
Můžete to také udělat přes menu, které lze vyvolat stiskem klávesy "Esc".


Obecné rady:

	Získání přehledu
Chcete-li změnit faktor zvětšení, klikněte na klávesu "o" nebo klikněte na ikonu s lupou.
Zkuste levé a pravé kliknutí, abyste získali různé faktory zvětšení.


	Menu editoru

K menu lze přistupovat stisknutím klávesy ESC.

		"Úroveň:"
Zde můžete snadno přejít do ostatních úrovní. Můžete použít buď klávesy šipek, které mají tuto možnost volenou tak,
aby umožnily přechod na další nebo předchozí úroveň (odkazují na čísla úrovní) nebo na ni klepnete, zadejte číslo požadované úrovně a stiskněte klávesu Enter.

		Možnosti úrovně
				Úroveň:	Viz vysvětlění výše
				Název úrovně:	Jméno mapy zobrazené u GPS v pravém horním rohu herní obrazovky. Zobrazeni GPS ve hře lze zakázat pomocí nabídky možností.
				Velikost:	Můžete zvýšit nebo snížit velikost své úrovně. Vyberte požadovanou hranu, kam chcete přidat/odebrat řadu dlaždic a klikněte na klávesy se šipkami  <- nebo ->.
				Podlahové vrstvy: Chcete-li změnit počet podlahových vrstev na aktuální úrovni, použijte klávesy se šipkami <- nebo ->.
				Úrovně na okrajích:	Zde lze nastavit úrovně, které mají sousedit s aktuální úrovní. Zadejte číslo úrovně pro příslušný okraj.
								Úroveň může mít pouze jednu sousední úroveň (dotýkající se okrajem) v každém ze čtyř hlavních směrů (Sever, Jih, Západ, Východ).
				Náhodný žalář:	Pokud tuto volbu nastavíte na "Ano", vygeneruje mapa automaticky podzemní bludiště. Kliknutím na volby nastavíte počet teleportů do a z této mapy.
								Náhodně vygenerovaná bludiště mají automaticky nastaveno vše potřebné, jako jsou navigační body, boti a překážky.
				Třída upuštění předmětu pro překážky:	seznam toho, jaké třídy předmětů by měly vypadnout z barelů/truhel/beden.
				Blokování teleportu:	Učiňte teleportaci z úrovně (ne)možnou.
				Teleportovací pár:	Toto je důležité, pokud vytváříte bludiště, které není přímo spojeno s jinou mapou. Můžete zde nastavit počet vychodů a vstupů pro náhodně vygenerovaná bludiště.
				Světlo:			Jak moc světla byste chtěli? Stiskněte mezerník pro přepnutí mezi okolním prostředím (obecný jas aktuální mapy) a bonusem (světlo vyzařované nějakou překážkou, jako jsou lampy nebo houby).
				Hudba na pozadí:	Zde lze nastavit hudební stopy, které budou hrát, zatímco hráč prochází mapou. Možné skladby lze nalézt v ./sound/music/ .
									Stačí jen zadat název souboru včetně .ogg přípony.
				Výdrž nekonečného běhu:	Pokud nastavíte na "ano", Tuxova výdrž nebude při běhu mapou ubývat. Toto by mělo být použito jen v případě, kdy nemá daná úroveň neprátelskou nehrající postavu, jako je například úroveň 0, město.
				Přidat/Odebrat úroveň:	Nechá vás přidat novou nebo odebrat aktuální úroveň.

		Pokročilé možnosti
Zde můžete spustit kontrolu mapy úrovně
Kontrola mapy úrovně kontroluje všechny cesty mezi propojenými navigačními body, aby se zjistilo, zda-li nejsou blokovány překážkami. Podrobnější vysvětlení, které cesty jsou blokovány, lze nalézt v terminálu za předpokladu, že v něm byla hra spuštěna a lze tedy sledovat výstup, nebo ve výstupním souboru globálních chyb.
Umí také zkontrolovat, zda nemáte v blízkosti hranic mapy kritickým způsobem umístěny překážky.
Tato kontrola by měla být spuštěna VŽDY před prohlášením mapy za dokončenou.
"freedroidRPG -b leveltest" tuto kontrolu také spouští.

		Herní test souboru mapy
Dovoluje jednoduché otestování vašich úprav.
Pokud tento mód opustíte, budou veškeré změny způsobené na překážkách v průběhu hraní, jako je například zničení bedny, navráceny do původního stavu, jaký byl na začátku testovací hry.




Klávesy:
mezerník					přepínání módu přidávání/výběr
w						přidávání navigačních bodů
shift+w					přepínání módu navigačních bodů pro "náhodný bot" nebo "NPC"
esc					přístup do menu
klávesnice čísel 1-9	použitá k přidělení překážek na příslušnou pozici mřížky
n						procházet skrze vybrané překážky (další)
z						vrátit zpět poslední akci
y						obnovit poslední akci
c						nastavení cesty mezi navigačními body
ctrl+x nebo backspace		vyříznout vybraný(é) objekt(y), lze použít k mazání předmětů jejich opětovným nevložením.
ctrl+c					kopírovat vybraný(é) předmět(y)
ctrl+v					vložit vyříznutý/zkopírovaný objekt(y)
alt+shift				táhnout/posunovat vybraný objekt použitím myši
klávesy šipek			posouvat po mapě
ctrl+klávesy šipek		posouvat se s většími kroky
kolečko myši				procházet překážkami ve výběru objektů
ctrl+pageup/page down	procházet překážkami ve výběru objektů
g						přístup na obrazovku s upouštěním předmětů
t						přepnout 3x3 transparentnost kolem zaměřovače 
m						přidat/editovat popisek mapy na pozici zaměřovače nebo vybrané dlaždice
o						zvětšit
tab						přepnutí do následujícího editačního módu
shift+tab				přepnutí do předchozího editačního módu
f						přejít na záložku dalšího předmětu
shift+f					přejít na záložku předchozího předmětu


Pokud se v editoru setkáte s problémy, kontaktujte nás prosím.
Také se nebojte poslat nám mapy, pokud jste udělali něco cool, my nekoušem. :)
]]
}
