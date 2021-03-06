

# ok, apparently having a large number of lines of code in a single
# function increases the build time exponentially, to the point that for
# our ~12000 autogenerated lines, the script dumper will basically
# never compile (or at any rate, not in a usable timeframe; i waited
# 10-15 minutes and it wasn't complete).
# so instead, we rotate each auto-generated script file into "all.txt",
# which is included into the script dumper, and build and run the dumper
# once per file.
# god this is stupid.
# but it works.

set -e

mkdir -p script/orig

./srchscript.sh

for file in out/scriptsrch/*.txt; do
  echo $file
  cp $file out/scriptsrch/all.txt
  
  # fucking dependencies
  rm -f grayman_scriptdmp
  make blackt && make grayman_scriptdmp
  
  ./grayman_scriptdmp "script/orig/"
  rm -f out/scriptsrch/all.txt
done

>out/scriptsrch/all.txt
