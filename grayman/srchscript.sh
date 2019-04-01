
set -e

function dumpScriptFile() {
  ./grayman_scriptsrch out/romfiles_orig/data/script/${1}.bin out/scriptsrch/${1}.txt  ${1}.txt out/romfiles/data/script/${1}.bin
}

make blackt && make grayman_scriptsrch
make blackt && make grayman_scriptsrch_table
rm -r out/scriptsrch
mkdir -p out/scriptsrch

#./grayman_scriptsrch out/romfiles_orig/data/script/stage00.bin out/scriptsrch/stage00.txt  out/script/orig/stage00.txt

# empty
#dumpScriptFile message
dumpScriptFile stage00
dumpScriptFile stage01
dumpScriptFile stage02
dumpScriptFile stage02_01
dumpScriptFile stage02_03
dumpScriptFile stage02_04
dumpScriptFile stage03
dumpScriptFile stage03_01
dumpScriptFile stage03_03
dumpScriptFile stage03_04
dumpScriptFile stage04
dumpScriptFile stage04_01
dumpScriptFile stage04_02
dumpScriptFile stage04_04
dumpScriptFile stage05
dumpScriptFile stage05_01
dumpScriptFile stage05_02
dumpScriptFile stage05_03
dumpScriptFile stage06
dumpScriptFile stage07
# ?
dumpScriptFile stage_03

./grayman_scriptsrch_table "out/scriptsrch/"

#cat out/scriptsrch/*.txt > out/scriptsrch/all.txt
