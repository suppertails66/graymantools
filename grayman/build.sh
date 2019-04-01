function generateNewNscr() {
  convert ${1}-grp.png -dither None -remap ${1}-pal.png PNG32:${1}-grp.png
  dsimgconv gscrn ${1} -t ${2} -s ${3} -p ${4}
}

echo "*******************************************************************************"
echo "Setting up environment..."
echo "*******************************************************************************"

set -o errexit

BASE_PWD=$PWD
#PATH=".:./asm/bin/:$PATH"
PATH=".:$PATH"

INROM="grayman.nds"
OUTROM="grayman_en.nds"

if [ ! -f $INROM ]; then
  
  echo "*** Error: input ROM '$INROM' not found."
  echo "*** Ensure the file exists and try again."
  exit 1
  
fi

NDSTOOL="./ndstool/ndstool"
ARMIPS="./armips/build/armips"

ROM_EXTRACT_DIR="out/romfiles_orig"
ROM_SRC_DIR="out/romfiles"

#cp "$INROM" "$OUTROM"

mkdir -p out

echo "*******************************************************************************"
echo "Building tools..."
echo "*******************************************************************************"

#  make blackt
#  make libnftred
  
  # don't ask, you're better off not knowing
  >out/scriptsrch/all.txt

  make

  if [ ! -e $ROM_EXTRACT_DIR ]; then

    echo "*******************************************************************************"
    echo "Extracting ROM data..."
    echo "*******************************************************************************"
    
    extract_rom.sh "grayman.nds" "$ROM_EXTRACT_DIR"
    
  fi

#   echo "*******************************************************************************"
#   echo "Building CUE's compression tools..."
#   echo "*******************************************************************************"
#   
#   cd dscmprcue
#     make
#   cd $BASE_PWD

  if [ ! -e $NDSTOOL ]; then
    
    echo "********************************************************************************"
    echo "Building ndstool..."
    echo "********************************************************************************"
    
    cd ndstool
      ./autogen.sh
      ./configure
      make
    cd $BASE_PWD
    
  fi

  if [ ! -e $ARMIPS ]; then
    
    echo "********************************************************************************"
    echo "Building armips..."
    echo "********************************************************************************"
    
    cd armips
      mkdir build && cd build
      cmake -DCMAKE_BUILD_TYPE=Release ..
      make
    cd $BASE_PWD
    
  fi

# echo "*******************************************************************************"
# echo "Copying original ROM data..."
# echo "*******************************************************************************"
# 
# #for file in $ROM_EXTRACT_DIR/*; do
# #  cp -r "$file" "out/romfiles"
# #done
# 
# # this is correct, but interferes with using makefile rules to avoid
# # regenerating the script unless the source files have actually changed.
# # so assume, incorrectly, we won't screw up the files.
# rm -r -f "$ROM_SRC_DIR"
# cp -r "$ROM_EXTRACT_DIR" "$ROM_SRC_DIR"

echo "*******************************************************************************"
echo "Building font..."
echo "*******************************************************************************"

mkdir -p out/font
./fontbuild font/font.png font/index.txt out/font/font.bin out/font/fontwidth.bin

mkdir -p out/font
./fontbuild font/font_wide.png font/index_wide.txt out/font/font_wide.bin out/font/fontwidth_wide.bin

echo "*******************************************************************************"
echo "Building script..."
echo "*******************************************************************************"

mkdir -p out/script
make -f Makefile_script

# cat together all string files intro one big file
#cat script/*.txt > "out/script/all.txt"

#grayman_scriptbuild script/ table/grayman_en.tbl out/script/

echo "*******************************************************************************"
echo "Updating images..."
echo "*******************************************************************************"

rm -r out/rsrc/images
mkdir -p out/rsrc/images/new

for folder in rsrc/images/final/*; do
#  if [ $folder != "rsrc/images/final/main_bg" ]; then
    echo "Copying folder: $folder"
    cp "$folder" "out/romfiles/data" -r
#  fi
done

cp -r rsrc/images/new/help out/rsrc/images/new
for i in `seq 1 31`; do
  num=$(printf "%02d" $i)
  namebase=help_${num}
  inbase=out/rsrc/images/new/help/${namebase}
  inbase_rom=out/romfiles_orig/data/help/help_${num}
  outbase=out/romfiles/data/help/help_${num}
  
  srcgrp=${inbase_rom}F.NCGR
  srcscrn=${inbase_rom}F.NSCR
  srcpal=${inbase_rom}.NCLR
  outgrp=${outbase}F.NCGR
  outscrn=${outbase}F.NSCR
  
  grp=rsrc/images/new/help/${namebase}-grp.png
#  ncgr=rsrc/images/new/help/${namebase}-dat.bin
  if [ -e $grp ]; then
    echo "Patching $inbase to $outbase"
    
    cp "$srcgrp" "$outgrp"
    cp "$srcscrn" "$outscrn"
    
    convert ${inbase}-grp.png -dither None -remap ${inbase}-pal.png PNG32:${inbase}-grp.png
    dsimgconv gscrn ${inbase} -t ${outgrp} -s ${outscrn} -p ${srcpal}
  fi
done

# for i in `seq 1 5`; do
#   num=$(printf "%02d" $i)
#   oldname=help_${num}
#   newname=HELP${num}
#   echo "Copying $oldname to $newname"
#   cp "out/romfiles/data/help/${oldname}.NCLR" "out/romfiles/data/help/${newname}.NCLR"
#   cp "out/romfiles/data/help/${oldname}F.NCGR" "out/romfiles/data/help/${newname}F.NCGR"
#   cp "out/romfiles/data/help/${oldname}F.NSCR" "out/romfiles/data/help/help${num}F.NSCR"
# done

echo "*******************************************************************************"
echo "Applying ASM patches..."
echo "*******************************************************************************"

mkdir -p out/asm
$ARMIPS asm/grayman.asm -temp out/asm/temp.txt -sym out/asm/symbols.sym -sym2 out/asm/symbols.sym2

echo "*******************************************************************************"
echo "Packing ROM..."
echo "*******************************************************************************"

#$NDSTOOL -c $OUTROM -9 ${ROM_SRC_DIR}/arm9.bin -7 ${ROM_SRC_DIR}/arm7.bin -y9 ${ROM_SRC_DIR}/y9.bin -y7 ${ROM_SRC_DIR}/y7.bin -d ${ROM_SRC_DIR}/data -y ${ROM_SRC_DIR}/overlay -t ${ROM_SRC_DIR}/banner.bin -h ${ROM_SRC_DIR}/header.bin

# allow me to copy and paste from my previous project:
#  
# After testing on real hardware, I discovered that ROMs built using ndstool
# on *nix wouldn't boot (despite working in desmume). On a hunch that the FAT
# was somehow getting built in an invalid way due to observing *nix
# conventions on upper/lower case, I tried building with the ancient (circa
# 2005) Windows binary of ndstool that was bundled with dslazy, and it
# actually worked.
# So that's the story behind this very very stupid line in the build script.
# Maybe if I'm ever feeling ambitious, I'll fix ndstool. Or not.
wine ndstool.exe -c $OUTROM -9 ${ROM_SRC_DIR}/arm9.bin -7 ${ROM_SRC_DIR}/arm7.bin -y9 ${ROM_SRC_DIR}/y9.bin -y7 ${ROM_SRC_DIR}/y7.bin -d ${ROM_SRC_DIR}/data -y ${ROM_SRC_DIR}/overlay -t ${ROM_SRC_DIR}/banner.bin -h ${ROM_SRC_DIR}/header.bin

echo "*******************************************************************************"
echo "Success!"
echo "Output file:" $OUTROM
echo "*******************************************************************************"
