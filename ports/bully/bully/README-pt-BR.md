# Bully: Anniversary Edition - NextOS Final

Este e um pacote de compatibilidade PortMaster AArch64 para a versao Android do
Bully: Anniversary Edition. Ele contem o loader NextOS, launcher, metadados e
ferramentas de instalacao. Ele **nao** contem codigo nem dados runtime do jogo
da Rockstar; os metadados do frontend incluem as imagens de preview
documentadas.

Versao obrigatoria: **1.4.311, arm64-v8a**. Outras versoes nao sao suportadas.

## Auto-instalacao pelo PortMaster

Copie o ZIP completo, sem extrair, para `roms/ports/autoinstall/` e abra o
PortMaster. O HarbourMaster instala automaticamente `Bully.sh` e a pasta
`bully/`, exatamente como nos ports oficiais. O mesmo processo pode atualizar
uma instalacao existente: dados extraidos do jogo, `bully.conf`, `bully.gptk` e
saves nao fazem parte do ZIP e permanecem intactos.

Depois da auto-instalacao, coloque sua fonte legal em
`roms/ports/bully/gamedata/` conforme explicado abaixo. O auto-install instala
somente o port; ele nao baixa nem inclui arquivos da Rockstar.

## Primeira instalacao

Coloque uma fonte legal e completa em `roms/ports/bully/gamedata/`:

- um APK merged completo com `lib/arm64-v8a` e `data_0` ate `data_4`;
- todos os APKs de uma instalacao Play Store comprada, incluindo o APK base, o
  split arm64 e todos os APKs `split_data_*`; ou
- um export completo `.apks`, `.apkm` ou `.xapk` dessa instalacao.

Para splits da Play Store, liste e copie **todos** os APKs retornados, nao apenas
`split_data_1.apk`:

```text
adb shell pm path com.rockstargames.bully
adb pull "<cada caminho mostrado pelo comando>"
```

Um export feito durante o teste limitado e incompleto porque nao contem os
arquivos de dados posteriores. Use uma copia comprada e completa. Mantenha pelo
menos 6 GB livres durante a primeira instalacao; uma reinstalacao sobre payload
antigo invalido pode exigir espaco adicional para rollback.

Abra o Bully no menu Ports. A tela de instalacao aparece antes da leitura CRC
completa e mostra separadamente o progresso de validacao e extracao. Depois ela
extrai a biblioteca e os arquivos `data_0` ate `data_4`, cria o patch local do
menu e inicia o jogo. O pacote nunca fornece esses arquivos.

A tela e apenas informativa, nao faz parte da transacao. Se SDL ou o backend de
video nao funcionar, a instalacao continua em segundo plano e registra o mesmo
trabalho em `roms/ports/bully/setup.log`.

Somente depois de validar e concluir a instalacao, o extrator apaga cada APK,
split ou bundle copiado que realmente forneceu bibliotecas ou dados escolhidos.
Fontes nao usadas, dados instalados, perfis e saves nao sao removidos.

## Atualizacao da V11

Instale a versao Final por cima da pasta `bully/` existente. Nao apague essa
pasta: o arquivo de release nao contem os dados extraidos, perfis ou saves e
nao os sobrepoe. Uma V11 completa deve iniciar sem nova extracao. Se apenas
`assets/` foi copiado de uma instalacao antiga, a fonte legal ainda e necessaria
para recuperar `libGame.so` e `libc++_shared.so`.

Nao e necessario instalar do zero. A versao Final valida o payload completo da
V11, gera o patch de menu e grava seu marcador sem exigir novamente o APK. Uma
fonte legal so volta a ser solicitada quando o payload antigo esta incompleto,
alterado ou danificado.

## Controles

| Controle | Acao |
|---|---|
| Direcional / analogico esquerdo | Movimento e navegacao |
| Analogico direito | Camera |
| A | Atacar / confirmar |
| B | Pular / cancelar |
| L1 / R1 | Mirar / atirar ou arremessar |
| L2 / R2 | Item anterior / proximo item |
| L3 / R3 | Acoes do clique dos analogicos |
| Start | Pausar / confirmar |
| Select | Menu / voltar |
| Select + Start | Sair para o frontend |

O caminho normal usa o controle SDL nativo do jogo. O unico seletor do fallback
e `use_gptk`: `off` usa SDL nativo e `on` inicia o gptokeyb do PortMaster com
`roms/ports/bully/bully.gptk`. Esse arquivo e totalmente editavel e controla
botoes, direcionais e analogicos convertidos em teclado/mouse. O pacote entrega
`bully.gptk.default`; na primeira abertura ele cria o arquivo ativo, mas
atualizacoes nao sobrescrevem a remap do usuario. Apague apenas `bully.gptk`
para restaura-lo a partir do modelo no inicio seguinte.

O modelo atual usa `BULLY_GPTK_VERSION=3`. Um mapa V1 e o mapa V2 padrao da RC
anterior sao migrados uma unica vez e preservados como
`bully.gptk.pre-v3-backup`. Um V2 personalizado e reconhecido e mantido.

No formato editavel, as teclas fixas do lado direito sao: `x/c/q/t` para os
slots finais A/B/X/Y, `u/i` para L1/R1, `k/l` para L2/R2 e `h/j` para L3/R3.
O modelo e neutro para A/B/X/Y. `face_buttons` atua somente no caminho SDL
nativo; o modo gptokey nao aplica uma segunda troca escondida sobre o arquivo.

L2/R2 usam por padrao os eixos nativos que o proprio motor associa a item
anterior/proximo. Isso nao cria um toque e nao faz o HUD touchscreen aparecer.
Se algum firmware nao expuser gatilhos utilizaveis, `weapon_switch=touch`
restaura explicitamente o toque antigo como fallback.

## Graficos e compatibilidade

O build Final corrige separadamente a resolucao da cena 3D e a qualidade das
texturas. O perfil mobile original forca escala interna 0.5 em varias GPUs Mali,
mesmo quando o aparelho possui 2 GB; por isso o HUD fica nitido e o mundo fica
borrado. Em modo automatico:

- abaixo de 1700 MB em `MemTotal`, permanece o perfil de baixa memoria da V11.2;
- a partir de 1700 MB (classe nominal de 2 GB), usa escala interna 1.0, texturas
  High, distancia de streaming nativa e RendererES3 quando existe um contexto
  ES3 real;
- se ES3 nao estiver disponivel, a escada volta para ES2 sem impedir o jogo de
  iniciar. Escala e texturas de alta qualidade continuam independentes do nome
  do renderer.

O streaming e as protecoes de memoria funcionam nos dois renderers. Cubemaps
preservam seus mipmaps nativos. `trilinear=on` forca filtragem trilinear nas
cadeias de mip completas e seguras; UI, render targets, texturas recortadas e
qualquer cadeia incompleta continuam bilineares para evitar texturas pretas.
O caminho de 1 GB continua sendo a base de compatibilidade.

A primeira cutscene tambem protege o relogio visual contra o travamento unico
de carregamento observado em aparelhos mais lentos. Assim a entrada completa do
carro e preservada e a animacao permanece alinhada ao audio, sem alterar o
relogio da gameplay nem as cutscenes posteriores que ja funcionam normalmente.

As sombras do renderer mobile diferido nao ficam disponiveis nos caminhos
nao-Adreno suportados. Esta e uma limitacao da engine, nao falta de dados.

## Configuracao

Edite `roms/ports/bully/bully.conf` usando um valor de cada lista documentada:

| Chave | Valores |
|---|---|
| `renderer` | `auto`, `es2`, `es3` |
| `render_scale` | `auto`, `profile`, `0.5`, `0.75`, `1.0` |
| `textures` | `auto`, `low`, `medium`, `high` |
| `trilinear` | `auto`, `on`, `off` |
| `stream_distance` | `auto`, `50`, `60`, `70`, `75`, `80`, `100` |
| `face_buttons` | `auto`, `normal`, `swap_xy`, `swap_ab`, `swap_both` |
| `input_debug` | `off`, `on` |
| `use_gptk` | `off`, `on` |
| `weapon_switch` | `native`, `touch` |

Em `stream_distance`, um numero e repassado diretamente como
`BULLY2_STREAM_DISTANCE_PCT`; `auto` deixa esse override sem exportar. Mantenha
os valores automaticos, exceto quando um teste controlado justificar um ajuste
especifico do aparelho. `input_debug=on` serve para diagnostico curto de
controle, nao para jogar normalmente. Consulte `TESTING-pt-BR.md` para o roteiro
privado de validacao da versao Final.

`textures=auto` ignora preferencias Low/Medium antigas da V11 e recalcula o
perfil pela RAM em cada inicio. Para manter uma escolha manual entre reinicios,
defina `textures=low`, `medium` ou `high` neste arquivo.

Na primeira abertura, o launcher cria `bully.conf` a partir do modelo do
pacote. Atualizacoes futuras do ZIP nao sobrescrevem esse arquivo.

Em `face_buttons=auto`, a versao Final converte mapping de face por label apenas
quando a semantica evdev fornece evidencia posicional confiavel. O perfil device-tree
`R36T/K36S` testado no Ark troca os dois pares; outros R36S/GO-Super reportados
preservam o mapping ja correto do CFW. A correcao ordinal dos
GTAs so entra para HID externo USB/Bluetooth com a assinatura antiga completa.
Nenhum ramo depende da versao do kernel; `swap_ab`, `swap_xy` e `swap_both`
continuam como overrides manuais.

O automatico prioriza a posicao funcional do layout Bully/PS2. Em clones cuja
serigrafia usa outra ordem, um prompt B pode corresponder ao A fisico que ocupa
a mesma posicao. Ative `use_gptk=on` e edite `bully.gptk` para preferir as
letras impressas; esse mapa continua sendo arquivo do usuario.

As logos e o filme do carro/cidade ainda nao foram restaurados nesta versao. O
motor possui as chamadas originais, mas o port precisa de um decoder H.264/AAC
Linux e da camada JNI de filmes. O ZIP nunca incluira esses videos; quando o
backend estiver pronto, eles deverao vir da copia legal do usuario.

## Solucao de problemas

- `APK SET INCOMPLETE OR MIXED`: falta algum split, ou um `data_N.zip` nao veio
  junto do seu `.idx`; copie todos os APKs da instalacao completa.
- `DATA VALIDATION FAILED`: a fonte esta danificada ou nao corresponde a
  v1.4.311 arm64. Consulte `roms/ports/bully/setup.log` para o arquivo exato.
- `libGame.so` ou `libc++_shared.so` ausente: forneca novamente a fonte arm64;
  copiar apenas a pasta `assets/` antiga nao e suficiente.
- `MISSING REQUIRED TOOL: python3`: o firmware precisa disponibilizar Python 3
  para validar os dados e gerar o patch local do menu.
- O setup nao exige o executavel GNU `stat`. Em sistemas como muOS ele escolhe
  automaticamente um backend BusyBox, Python ou POSIX compativel e registra a
  escolha em `setup.log`.
- Ao relatar extracao, envie `setup.log`. Para inicializacao ou controle, envie
  tambem `roms/ports/bully/log.txt`.

Consulte `licenses/` para licencas e avisos.
