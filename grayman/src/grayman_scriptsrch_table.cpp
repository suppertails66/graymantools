#include "util/TStringConversion.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TThingyTable.h"
#include "util/TSjis.h"
#include "exception/TGenericException.h"
#include <string>
#include <fstream>
#include <iostream>

using namespace std;
using namespace BlackT;

TThingyTable table;

const int minStringLen = 3;
const int maxStringLen = 512;

int dumpedStringCount = 0;

int dumpString(TStream& ifs, std::ostream& ofs) {
  int size = TSjis::checkSjisString(ifs).rawLength;
  if (size > 0) {
    ofs << "    dumpString(ifs, ofs, tablestd, "
        << TStringConversion::intToString(ifs.tell(), TStringConversion::baseHex)
        << " + 0, "
        << "\"auto-generated string "
        << dumpedStringCount++
        << "\");"
        << endl;
    ifs.seekoff(size);
  }
  return size;
}

void dumpToLimit(TStream& ifs, std::ostream& ofs, int limit) {
  while (ifs.tell() < limit) {
    int result = dumpString(ifs, ofs);
    if (result < 0) {
      ifs.get();
    }
    while (!ifs.eof() && (ifs.peek() == 0)) ifs.get();
  }
}

int main(int argc, char* argv[]) {
  if (argc < 2) {
    cout << "D.Gray-man (NDS) string table searcher" << endl;
    cout << "Usage: " << argv[0] << " [outprefix]" << endl;
    
    return 0;
  }
  
  string outPrefix = string(argv[1]);
  
  
//  table.readSjis(tableName);
  
  {
    TBufStream ifs;
    ifs.open("out/romfiles_orig/arm9.bin");
    std::ofstream ofs((outPrefix + "arm9.txt").c_str(),
                  ios_base::binary);
    
    ofs << "  {" << endl;
    ofs << "    TBufStream ifs;" << endl;
    ofs << "    ifs.open(\"out/romfiles_orig/arm9.bin\");" << endl;
    ofs << "    std::ofstream ofs((outPrefix + \"arm9.txt\").c_str());" << endl;
    ofs << "    " << endl;
    ofs << "    outputLine(ofs, \"#SETDSTFILE(\\\"out/romfiles/arm9.bin\\\")\");"
        << endl;
    ofs << "    outputLine(ofs, \"#SETSIZE(224, 3)\");" << endl;
    
    // stuff
    // probably stdlib time but just in case it's used for save file time display
//    ifs.seek(0x6e3ac);
//    dumpToLimit(ifs, ofs, 0x6e3d0);
    
    // stuff
    ifs.seek(0x70034);
    dumpToLimit(ifs, ofs, 0x700a9);
    
    // no data
    ifs.seek(0x70558);
    dumpToLimit(ifs, ofs, 0x70588);
    
    // main data
    ifs.seek(0xCF44C);
    dumpToLimit(ifs, ofs, 0xd19b4);
    
    ofs << "  }" << endl;
  }
  
//  ifs.seek(searchStart);
//  while (ifs.tell() < searchEnd) {
//    dumpStringTable(ifs, ofs);
//  }
  
  return 0;
}

