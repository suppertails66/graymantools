

make libnftred && make dsimgconv

#./dsimgconv es rsrc/images/orig/help/HELP01 -p out/romfiles_orig/data/help/HELP01.NCLR -t out/romfiles_orig/data/help/HELP01F.NCGR -s out/romfiles_orig/data/help/help01F.NSCR
#test=$(printf "%02d" 9)
#echo $test

#=============================================
# help images
#=============================================

mkdir -p rsrc/images/orig/help
# for i in `seq 1 31`; do
#   num=$(printf "%02d" $i)
# #  echo $num
#   namebase=help_${num}
#   outbase=rsrc/images/orig/help/${namebase}
#   nclr=out/romfiles_orig/data/help/help_${num}.NCLR
#   ncgr=out/romfiles_orig/data/help/help_${num}F.NCGR
#   nscr=out/romfiles_orig/data/help/help_${num}F.NSCR
#   ./dsimgconv es $outbase -p $nclr -t $ncgr -s $nscr
# #  echo $outbase
# done

#=============================================
# old, unused help images that i ripped
# while trying to figure out a problem
#=============================================

mkdir -p rsrc/images/orig/help_alt
# for i in `seq 1 28`; do
#   num=$(printf "%02d" $i)
# #  echo $num
#   namebase=HELP${num}
#   outbase=rsrc/images/orig/help_alt/${namebase}
#   nclr=out/romfiles_orig/data/help/HELP${num}.NCLR
#   ncgr=out/romfiles_orig/data/help/HELP${num}F.NCGR
#   nscr=out/romfiles_orig/data/help/help${num}F.NSCR
#   ./dsimgconv es $outbase -p $nclr -t $ncgr -s $nscr
# #  echo $outbase
# done

#=============================================
# chapter titles
#=============================================

mkdir -p rsrc/images/orig/main_bg
./dsimgconv es rsrc/images/orig/main_bg/sab_title2_kojyo -p out/romfiles_orig/data/main_bg/sab_title2_kojyo.NCLR -t out/romfiles_orig/data/main_bg/sab_title2_kojyoF.NCGR -s out/romfiles_orig/data/main_bg/sab_title2_kojyof.NSCR
./dsimgconv es rsrc/images/orig/main_bg/sab_title4_kojyo -p out/romfiles_orig/data/main_bg/sab_title4_kojyo.NCLR -t out/romfiles_orig/data/main_bg/sab_title4_kojyoF.NCGR -s out/romfiles_orig/data/main_bg/sab_title4_kojyof.NSCR
./dsimgconv es rsrc/images/orig/main_bg/sab_title5_kojyo -p out/romfiles_orig/data/main_bg/sab_title5_kojyo.NCLR -t out/romfiles_orig/data/main_bg/sab_title5_kojyoF.NCGR -s out/romfiles_orig/data/main_bg/sab_title5_kojyof.NSCR

mkdir -p rsrc/images/new/main_bg
./dsimgconv es rsrc/images/new/main_bg/sab_title2_kojyo -p out/romfiles_orig/data/main_bg/sab_title2_kojyo.NCLR -t rsrc/images/final/main_bg/sab_title2_kojyoF.NCGR -s rsrc/images/final/main_bg/sab_title2_kojyof.NSCR
./dsimgconv es rsrc/images/new/main_bg/sab_title4_kojyo -p out/romfiles_orig/data/main_bg/sab_title4_kojyo.NCLR -t rsrc/images/final/main_bg/sab_title4_kojyoF.NCGR -s rsrc/images/final/main_bg/sab_title4_kojyof.NSCR
./dsimgconv es rsrc/images/new/main_bg/sab_title5_kojyo -p out/romfiles_orig/data/main_bg/sab_title5_kojyo.NCLR -t rsrc/images/final/main_bg/sab_title5_kojyoF.NCGR -s rsrc/images/final/main_bg/sab_title5_kojyof.NSCR
