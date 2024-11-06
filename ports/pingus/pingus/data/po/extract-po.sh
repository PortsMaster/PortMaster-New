#!/bin/sh

set -e

TMP=$(mktemp)
OUT="data/po/pingus.pot"

cd ../.. # go to toplevel dir
echo -n "Generating C++ file list... "
find src/ -name "*.?pp" > "$TMP"
echo "done"

echo -n "Extracting strings from C++..."
xgettext \
    --c++ \
    --boost \
    --directory "." \
    --output "${OUT}.tmp" \
    --from=code=ASCII \
    --keyword=_ \
    --keyword=N_ \
    --files-from "$TMP"
echo "done"

echo "" >> "${OUT}.tmp"

echo -n "Extracting strings from levels... "
data/po/extract-levels.guile data/levels/tutorial/*.pingus >> "${OUT}.tmp"
data/po/extract-levels.guile data/levels/halloween/*.pingus >> "${OUT}.tmp"
data/po/extract-levels.guile data/levels/halloween2011/*.pingus >> "${OUT}.tmp"
data/po/extract-levels.guile data/levels/desert/*.pingus >> "${OUT}.tmp"
data/po/extract-levels.guile data/levels/mysteryisland/*.pingus >> "${OUT}.tmp"
data/po/extract-levels.guile data/levels/alien/*.pingus >> "${OUT}.tmp"
data/po/extract-levels.guile data/levels/factorycampaign/*.pingus >> "${OUT}.tmp"
data/po/extract-levels.guile data/levels/xmas2011/*.pingus >> "${OUT}.tmp"
echo "done"

echo -n "Extracting strings from worldmaps... "
data/po/extract-levels.guile data/worldmaps/tutorial.worldmap >> "${OUT}.tmp"
echo "done"

echo -n "Extracting strings from stories... "
data/po/extract-levels.guile data/stories/*.story >> "${OUT}.tmp"
echo "done"

echo -n "Extracting strings from levelsets... "
data/po/extract-levels.guile data/levelsets/*.levelset >> "${OUT}.tmp"
echo "done"

sed -i "s/^\"Content-Type: text\\/plain; charset=CHARSET/\"Content-Type: text\\/plain; charset=ASCII/" \
    "${OUT}.tmp"

echo -n "Removing duplicate entries... "
msguniq -o "$OUT" "${OUT}.tmp"
echo "done"

echo "Output written to pingus.pot"

rm $TMP

# EOF #
