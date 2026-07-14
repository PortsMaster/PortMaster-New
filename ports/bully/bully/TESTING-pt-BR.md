# Bully: Anniversary Edition Final - roteiro privado de teste

Use primeiro o `bully.conf` original, com todas as opcoes em `auto`. Nao use
zram para fingir que um aparelho possui 2 GB: a selecao automatica usa a RAM
fisica informada por `MemTotal`.

## Auto-install do PortMaster

1. Copie o ZIP sem extrair para `roms/ports/autoinstall/`.
2. Abra o PortMaster e confirme `SUCCESS` para o arquivo.
3. Confirme que o ZIP foi removido de `autoinstall`, que `Bully.sh` apareceu na
   raiz de Ports e que `bully/port.json` foi registrado como schema 4.
4. Em uma atualizacao, compare antes/depois e confirme que `assets/`,
   `libGame.so`, `libc++_shared.so`, `bully.conf`, `bully.gptk`, `BullyFile*` e
   `FileInfo*` foram preservados.

## Teste principal em aparelho de 2 GB

Na primeira abertura limpa, confirme que a tela aparece antes da validacao
completa do APK, que as barras `VALIDATION` e `EXTRACTION` avancam sem parecer
travadas e que o jogo inicia somente depois das duas chegarem a 100%.

1. Instale o ZIP por cima da pasta existente, sem apagar assets ou saves.
2. Inicie um save, jogue por pelo menos 30 minutos e atravesse duas mudancas de
   area. Abra o mapa, uma cutscene, a tela de save e o menu de graficos.
3. Confirme nitidez do mundo, asfalto e predios; verifique tambem cercas,
   folhagem, reflexos, HUD e fundos de loading para texturas pretas.
4. Teste direcional cima/baixo especificamente na tela de save, salve, carregue
   o save e confirme que um save existente da V11 foi preservado no upgrade.
5. Inicie um New Game e confirme que a primeira cutscene mostra a entrada
   completa do carro, com falas e movimentos de boca sincronizados. Confirme
   tambem que a segunda cutscene continua normal.
6. Teste A/B, L1/R1, L2/R2, L3/R3, Start e Select. Em L2/R2, confirme que o
   item muda uma vez e que nenhum botao touchscreen aparece. Confirme audio
   durante jogo e cutscene; finalize com Select+Start e verifique o retorno ao
   frontend.
7. Envie `roms/ports/bully/log.txt`, `setup.log` quando houver extracao e a
   identificacao do firmware/aparelho.

## Fallback gptokeyb editavel

Mantenha `use_gptk=off` no teste normal. Para validar o fallback, mude somente
essa linha para `use_gptk=on`, abra novamente e confirme no log
`gptokeyb enabled` e `BULLY2_INPUT=gptk mode=editable`. Teste os seis botoes
L/R, os quatro botoes de face, direcionais, analogicos e Select+Start. Altere
temporariamente uma linha de `bully.gptk` e confirme que a funcao acompanha o
arquivo. Ao terminar, restaure `use_gptk=off`; nenhuma outra chave e necessaria.

## Matriz de normalizacao de controle

Teste primeiro `face_buttons=auto` e registre aparelho, firmware e versao do
kernel. No Ark R36T/K36S, o log deve mostrar o perfil e `swap_ab=1 swap_xy=1`;
em outros R36S/GO-Super, deve mostrar o perfil e preservar o mapping SDL;
em driver interno com mapping por label comprovado, deve mostrar somente os
pares `swap_ab`/`swap_xy` necessarios. Em HID externo ordinal antigo, o log deve
mostrar `ordinal fix`.
Confirme cada face pelo label do aparelho, os dois shoulders, gatilhos e cliques
de analogico. Se falhar, repita somente para diagnostico com
`input_debug=on`; nao transforme o override manual em regra global sem anexar o
GUID e o mapping completo do log.

Para isolar o fallback antigo de troca de item, altere somente
`weapon_switch=touch`. A troca deve funcionar, mas o reaparecimento do HUD touch
e esperado nesse modo. Volte para `native` apos o teste.

No tier automatico de 2 GB, o log esperado contem linhas equivalentes a:

```text
[gl] context policy=ES3-first
[gl] renderer mode=ES3 (alta qualidade)
[tex] startup profile=auto-high half=0
[quality] render scale ... chosen=1.00 source=auto-native
[streamdist] ... pct=100
```

Um fallback ES2 pode ser correto quando o driver nao oferece contexto ES3, mas
`chosen=1.00` e `auto-high` ainda devem aparecer em um aparelho realmente acima
do piso automatico.

## Isolamento A/B

Altere somente uma chave por execucao:

```ini
# Backend ES2 com a mesma qualidade alta
renderer=es2
render_scale=1.0
textures=high

# Backend ES3 forcado
renderer=es3
render_scale=1.0
textures=high
```

Para comparar somente o custo da resolucao no mesmo caminho ES3, mantenha
`renderer=es3`, `textures=low`, `trilinear=on`, `stream_distance=50` e rode tres
vezes mudando apenas:

```ini
render_scale=0.5
render_scale=0.75
render_scale=1.0
```

Registre fluidez, nitidez, memoria, mudanca de area e qualquer textura preta em
cada escala. Nao combine os tres valores no mesmo arquivo; use um por execucao.

Para diagnosticar o direcional, use `input_debug=on` apenas durante a reproducao
curta e volte para `off` depois. Para reproduzir exatamente a imagem antiga,
use `renderer=es2`, `render_scale=profile` e `textures=low`.
