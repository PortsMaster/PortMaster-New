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
            O EDITOR DE MAPAS DO FREEDROIDRPG

=== INTRODUÇÃO ===

FreedroidRPG vem com um editor de mapas embutido. Esse editor permite-lhe controlar qualquer aspecto de um mapa normal do FreedroidRPG e salvar as mudanças.

Você pode acessá-lo pelo menu principal (clique em "Editor de Mapas") ou executando "freedroidRPG -e".

    --- Dicas ---
Para habilitar/desabilitar as descrições de interface quando o mouse paira sobre algum item, clique no ícone de balão de conversa localizado perto da borda direita da janela (Linha de botões inferior).

    --- Detalhes Resumidos ---
Detalhes resumidos sobre obstáculos e itens vão aparecer se você clicar neles com o botão direito do mouse no seletor de objetos na parte superior da tela.

    --- Navegação ---
Para mudar o mapa atual, clique no número do mapa no minimapa no canto inferior direito, ou procure pelo mapa desejado no menu do editor (descrito posteriormente)

    --- Editando mapas ---
Existem quatro tipos de modo de edição: edição de obstáculos, edição de piso, edição de item e edição de coordenadas.

O botão selecionado ao lado inferior esquerdo indica os objetos que você pode selecionar ou colocar.
Quando o botão está selecionado, e você está no modo de distribuição, o objeto que você irá posicionar será indicado pela fita no topo da tela. A seleção na fita é dividida nas quatro abas imediatamente abaixo.

Você pode selecionar os tipos de obstáculos que você deseja que sejam posicionados no mapa, no selecionador de objeto superior. Apelas clique e selecione. Obstáculos são divididos em grupos, para fornecer uma melhor visualização.

Pressionando espaço, você irá entrar no modo de seleção indicado pelo cursor de troca. Você pode selecionar apenas grupos de objetos representados pelo modo atual de seleção de objeto.
Nota importante: Você só será capaz de selecionar coisas que estão inclusas no modo de seleção atual. Se você está no modo obstáculo, você não será capaz de selecionar itens ou pisos.


        Modo edição de obstáculos:

Para selecionar esse modo, clique no botão "Obstáculo", no selecionador de categorias, na área esquerda inferior.
Tendo selecionado um obstáculo, apenas clique em qualquer lugar no mapa para coloca-lo na posição do cursor.
Caso clicar seja impreciso, você também pode usar seu teclado numérico para posicionar objetos.
Clicando mais a esquerda (isso irá mostrar uma pequena grade) dos cinco botões a cima do seletor de categoria para ter uma grade com números exibidos. Use o botão esquerdo do mouse para trocar entre grade ligada e desligada e o botão direito para trocar os tipos de grade
Esses números se referem ao número do seu teclado numérico, se você tiver um. Pressionando "1" irá colocar o obstáculo que está em destaque no seletor de objetos na posição do digito "1" na grade roxa.
Caso o posicionamento de linhas de parede dessa forma seja muito ineficiente, você pode simplesmente segurar o botão esquerdo do mouse e a linha de paredes será colocada enquanto você mover seu cursor se você tiver um objeto de parede selecionado. Isso funciona com a maioria das paredes comuns em FreedroidRPG
Enquanto segurar o botão esquerdo do mouse e colocando paredes, um clique com o botão direito do mouse irá remover todas as paredes que você desenhou após começar a segurar o botão esquerdo do mouse
Existem alguns objetos especiais. Paredes de vidro e paredes de blocos quebrados, mas também existem barris e engradados que podem ser destruídos com alguns golpes, enquanto os dois últimos possam também liberar itens. Baús podem ser abertos e conter itens também.
O símbolo com pegadas cruzadas não é realmente um objeto, porém uma área pura e invisível bloqueada ("retângulo de colisão"). Retângulos de colisão são a essência de cada objeto, desde que eles previnam você de apenas andar através deles da mesma forma que é possível para pontos de controle ou ladrilhos.

            Selecionando obstáculos

Mantendo pressionado o botão esquerdo do mouse você pode selecionar um retângulo de obstáculos. Após soltar o botão do mouse, os obstáculos selecionados irão trocar para uma cor diferente, indicando que eles estão selecionados. Para selecionar obstáculos que não estão no alcance do retângulo de seleção, segure pressionado "Ctrl" e clique no obstáculo ou selecione outro retângulo para eles.
Você pode ter selecionado automaticamente muitos obstáculos com um clique. Você pode trocar entre os obstáculos clicando no ícone com a cadeira e a prateleira sobre ele, ou pressionando "n".
O ícone com o lixo pode apagar um obstáculo selecionado.
Você também pode recortar (Ctrl+x, podendo ser usado para excluir objetos se não colado em seguida ;) ), copiar (Ctrl+c) e colar (Ctrl+v) obstáculos cortados ou copiados.
Você pode mover os obstáculos selecionados segurando a tecla shift enquanto arrasta o obstáculo ao redor. No entanto, isso pode ser bastante impreciso.

            Colocando objetos dentro de baús

Basta selecionar o baú desejado e clicar no botão mais à esquerda na linha superior do botões.
Você será encaminhado para uma tela que se parece com a tela de loja.
Haverá uma faca exibida (que na verdade não está inserida no baú), selecione-a e clique no botão "vender".
Selecione os itens que você deseja deixar cair quando o jogador abre o baú.
Esses itens serão exibidos na barra superior de loja.
Para remover um desses itens, basta selecioná-lo e clicar em "comprar".
O "X" vermelho te tira da tela.

            Adicionando texto a uma placa

Selecione o placa e adicione uma etiqueta de obstáculo com o texto do sinal. Salve o mapa e saia.
Abra o arquivo de nível (map/levels.dat) e encontre a nova etiqueta de obstáculo. Altere a linha acima do texto de "type=30" para "type=32" e salve.
Agora, quando você clicar na placa no jogo, sua mensagem curta será exibida.

            Adicionando um diálogo a um terminal

Selecione o terminal e adicione uma etiqueta de obstáculo com o nome do diálogo que você deseja usar. Salve o mapa e saia.
Abra o arquivo de nível (map/levels.dat) e encontre o novo rótulo de obstáculo.
Altere a linha acima do texto de "type=30" para "type=32" e salve. Agora, quando você clicar no terminal do jogo, ele vai iniciar a caixa de diálogo que você selecionou.

        Modo de edição de piso:

O modo de edição do piso funciona de forma bastante semelhante ao modo de edição de obstáculos. Você pode selecionar diferentes tipos de piso no seletor de objetos.
Para preencher uma região com um único piso, primeiro selecione o bloco a ser usado, depois clique e arraste o botão esquerdo do mouse até cobrir a região desejada. Os ladrilhos são colocados na camada atual do piso.
Não há pisos que sejam especiais de qualquer forma, são pura decoração.

A visibilidade das camadas do piso pode ser controlada por um botão com o ícone da camada. O botão é exibido apenas para níveis com pisos multicamadas.
Clicar com o botão esquerdo do mouse no botão alterna entre uma única camada de piso exibida e todas as camadas de piso exibidas. Clique com o botão direito do mouse no botão para alterar a camada atual do piso.

            Selecionando tipos de piso

A seleção é tão fácil quanto no modo de obstáculos. Os blocos de piso podem ser movidos com o método descrito acima.
Para níveis com pisos multicamadas, somente camadas de piso visíveis são selecionadas. Quando uma única camada de piso está visível, somente as peças na camada de piso atual são selecionadas.

Para ver apenas o piso, clique no ícone da lâmpada para não exibir obstáculos. Outro clique permitirá que os obstáculos apareçam novamente.
O ícone com o retângulo turquesa exibe retângulos de colisão. Esses retângulos indicam a área de bloqueio de um obstáculo. Tux não pode andar em tal área.
Se você ligá-lo e testar o seu mapa (explicado mais abaixo), os retângulos ainda serão exibidos se ativados, o que é bastante útil para testar se o jogador pode passar uma lacuna ou não.

        Modo de edição de item:

Você também pode colocar itens a serem usados pelo jogador no mapa.
Itens são objetos que o jogador pode pegar. Eles podem ser carregados, alguns podem até ser usados ou equipados.
Alguns itens são usados para avançar o enredo, outros fornecem bônus para o jogador, enquanto outros ainda não fazem nada.
Selecione o modo de item e clique em um item exibido no seletor de objetos. Para alguns itens, você deve especificar um valor antes de serem colocados.
Você pode configurá-lo clicando nos botões de seta ou arrastando a esfera azul para a esquerda ou para a direita.
Pressione "g" para ter uma visão melhor de quais itens estão disponíveis (também pode ser usado para soltar, itens serão soltos na mira). Clique em "Esc" para abortar o processo sem perder nenhum item.
Você também pode clicar no ícone com as botas cruzadas para fazer isso.


        Modo de edição de waypoints:

Atualmente, os robôs (o que significa todos os personagens que não são jogadores) movem-se em níveis usando "waypoints", que podem ser entendidas como coordenadas.
Para plantar um waypoint, pressione a tecla "w". Isto irá alternar o waypoint no retângulo sob a mira.
Você também pode clicar no mapa na posição em que deseja ter um waypoint com esse modo ativado. Outro clique em outro lugar coloca outro waypoint e conecta automaticamente o anterior selecionado com ele.
Clicar em um waypoint preexistente permite conectá-lo com outro (basta clicar no outro também para fazer isso).
No entanto, há uma diferença entre esses dois métodos de colocação. Quando você conecta dois waypoints usando o teclado, as conexões serão unidirecionais.
Isso significa que quando você faz uma conexão do waypoint A ao waypoint B, o bot só poderá andar de A para B, mas não de volta.
Você pode remover uma conexão unidirecional "sobrepondo-a" com outra indo para a mesma direção que a que você deseja excluir (isso não funciona com conexões bidirecionais!).
No entanto, conexões bidirecionais são feitas automaticamente usando o método de clicar para conectar waypoints.
Nota importante: Não é possível conectar waypoints em mapas diferentes uns com os outros!
Waypoints também são usados ​​para posicionar robôs gerados aleatoriamente. No entanto, isso pode ser inadequado para alguns pontos de referência.
Há "normais" que são brancos, para robôs que reaparecem e "especiais", aqueles roxos que devem ser usados ​​para NPCs. Os normais são usados ​​para bots gerados, os roxos devem ser usados ​​para NPCs.
Você pode selecionar esses diferentes tipos de waypoints na barra de seleção superior. Para transformar um waypoint normal em um roxo ou vice-versa, pressione shift+w.
Por favor, certifique-se de que os caminhos entre os waypoints não estão bloqueados por um obstáculo entre dois waypoints.
Para verificar automaticamente um mapa inteiro para isso, você pode usar o validador de nível de mapa, explicado mais abaixo.


        Colocando etiquetas:

Existem dois tipos de tabelas: etiquetas de mapa e etiquetas de obstáculos.
Certifique-se de que cada ID de etiqueta seja único.
Dar uma string vazia excluirá o respectivo rótulo.


            Colocando etiquetas de mapas

Etiquetas de mapa são usadas para definir os locais iniciais de NPCs (veja ReturnOfTux.droids), eventos que ocorrem quando o Tux se move sobre eles (veja events.dat), ou locais usados para movimentação de NPCs através dos arquivos de script lua (eventos, missões e os diálogos).
Para definir uma nova etiqueta de mapa, pressione a tecla "m" no teclado ou clique no botão com o M no sinal nele. Você será solicitado pela etiqueta do mapa. Observe que haverá um círculo colorido aparecendo em qualquer bloco de mapa que tenha sido equipado com uma etiqueta de mapa.
A etiqueta de mapa será automaticamente colocada no bloco no meio da tela.
Você pode ativar ou desativar a exibição de robôs/NPCs pressionando o botão com o robô 302 nele.

            Colocando etiquetas de obstáculos

As etiquetas de obstáculos são importantes para que alguns obstáculos possam ser marcados para que os eventos aconteçam (por exemplo, durante uma missão). Se, por exemplo, um evento deve remover um obstáculo especial de parede, então este obstáculo deve receber um nome ou ID primeiro, para que possa ser referido posteriormente na definição do evento.
Você também pode usá-las para adicionar diálogos a obstáculos, assim você pode conversar com eles como se fossem NPCs.
Para colocar uma etiqueta em um obstáculo, você deve primeiro marcar este obstáculo (veja a explicação do modo de obstáculo acima).
Ao clicar no ícone com a placa e o O nele, você será solicitado a inserir a nova etiqueta nesse obstáculo.

Você pode alternar a exibição de etiquetas de mapa usando o ícone pequeno com o círculo de etiquetas nele.

        Salvando mapas:

Para salvar um mapa, clique no ícone do pequeno disco na área superior direita da tela do editor. O ícone da porta permite que você saia do editor.
Você também pode fazer isso através do menu que é aberto pressionando a tecla "Esc".


Dicas gerais:

	Obtendo uma visão geral
Para alterar o fator de zoom, pressione a tecla "o" ou clique no ícone com a lupa nela.
Tente clicar com o botão esquerdo e direito para acessar diferentes fatores de zoom.


	O menu do editor

Você pode acessar este menu pressionando ESC.

		"Nível:"
Aqui você pode navegar facilmente para outros níveis. Você pode usar as teclas de seta com essa opção selecionada
para mudar para o nível seguinte ou anterior (refere-se a números de nível) ou, clicando sobre ele, insira o número do nível desejado e pressione Enter.

		Opções do Nível
				Nível:	Veja acima para a explicação
				Nome do Nível:	O nome do mapa exibido no GPS no canto superior direito da tela do jogo. Você pode desativar o GPS no jogo usando o menu de opções.
				Tamanho:	Você pode aumentar ou reduzir o tamanho do seu nível. Selecione a borda desejada onde deseja adicionar/remover uma linha de blocos e clique nos botões de seta <- ou ->.
				Camadas de piso: Para alterar o número de camadas de piso para o nível atual, use os botões de seta <- ou ->.
				Interface de bordas:	Aqui você pode definir os níveis que devem estar próximos ao nível atual. Digite o número do nível para a respectiva borda.
								Um nível só pode ter um nível adjacente (um com que ele toque com as bordas) em cada uma das quatro direções cardeais (norte, sul, oeste, leste).
				Mapa aleatório:	Se você definir essa opção como "Sim", o mapa gerará automaticamente uma dungeon. Você define o número de teleportadores de e para este mapa clicando na opção.
								Dungeons geradas aleatoriamente terão automaticamente tudo o que é necessário, como waypoints, robôs e obstáculos, definidos.
				Classe de itens de obstáculos:	Define de qual classe de item devem ser os itens que surgem de barris/baús/caixas.
				Bloqueio de teleporte:	Possibilidade ou não teletransportar de um nível.
				Par de teleporte:	Isso é importante se você faz uma dungeon que não está diretamente conectada a outro mapa. Você pode definir o número de saídas e entradas de uma dungeon gerada aleatoriamente aqui.
				Luz:			Quanta luz você gostaria de ter? Pressione espaço para alternar entre o modo Ambiente (brilho geral do mapa atual) e Bônus (luz emitida por alguns obstáculos, como lâmpadas ou cogumelos).
				Música de fundo:	Aqui você pode definir uma faixa de música para ser tocada enquanto o jogador anda pelo mapa. Faixas possíveis podem ser encontradas em ./sound/music/ .
									Basta inserir o nome do arquivo incluindo a extensão .ogg.
				Vigor infinito:	Se você definir como "Sim", a resistência de Tux não diminuirá enquanto estiver correndo pelo mapa. Isso só deve ser usado se o nível não tiver NPCs hostis, como no nível 0, a Cidade, por exemplo.
				Add/Rem nível:		Permite adicionar um novo nível ou remover o nível atual.

		Opções avançadas
Aqui você pode executar o validador de nível de mapa.
O validador de nível de mapa verifica todos os caminhos entre waypoints conectados para garantir que eles não sejam bloqueados por obstáculos. Uma saída mais detalhada explicando quais caminhos estão bloqueados pode ser encontrada no terminal, caso o jogo esteja sendo executado a partir da linha de comando, ou em um arquivo de saída de erros globais.
Ele também pode verificar se você tem obstáculos próximos às bordas do mapa de maneira crítica.
Isso deve SEMPRE ser executado antes de considerar um mapa como finalizado.
"freedroidRPG -b leveltest" também faz essa verificação.

		Testar o Mapa
Permite que você realizar um teste de jogo de suas modificações facilmente.
Se você deixar este modo, as mudanças de obstáculos que foram feitas durante o jogo, destruindo as caixas, por exemplo, serão revertidas para a hora em que você começou o teste de jogo.




Atalhos:
espaço					alterna entre os modos de posicionamento e seleção
w						posiciona waypoints
shift+w					ativa o modo para waypoints para "robôs aleatórios" ou "NPC"
espaço					acessa o menu
teclas numéricos 1-9	usado para colocar obstáculos nas respectivas posições da grade
n						alterna entre os (próximos) obstáculos selecionados
z						desfaz a última ação
y						refaz a última ação
c						define os caminhos entre os waypoints
ctrl+x ou backspace		recorta um ou mais objetos selecionados, podendo ser usado para excluir objetos se não colado em seguida
ctrl+c					copia um ou mais  objetos selecionados
ctrl+v					cola um ou mais objetos recortados/copiados
alt+shift				arrasta/move o objeto selecionado usando o mouse
teclas de seta			navega pelo mapa
ctrl+teclas de seta		navega pelo mapa em passos longos
rodinha do mouse		navega por obstáculos do seletor de objetos
ctrl+pageup/page down	navega por obstáculos do seletor de objetos
g						acessa a tela de itens caídos
t						ativa transparência 3x3 em volta da mira
m						adiciona/edita uma etiqueta do mapa na posição da mira ou do bloco selecionado
o						zoom
tab						alterna para o modo de edição seguinte
shift+tab				alterna para o modo de edição anterior
f						alterna para a aba de objeto seguinte
shift+f					alterna para a aba de objeto anterior


Se você tiver problemas com o editor, por favor entre em contato conosco.
E não tenha medo de nos enviar um mapa se achar que ele ficou legal. Nós não mordemos. :)
]]
}
