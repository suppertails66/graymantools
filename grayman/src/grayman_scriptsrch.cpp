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

int checkPascalSjisString(TStream& ifs) {
  int start = ifs.tell();
  
  int count = ifs.readu16le();
  if (ifs.remaining() < count) goto fail;
  if (count < minStringLen) goto fail;
  if (count >= maxStringLen) goto fail;
  
  {
    TSjis::SjisCheckResult sjisCheckResult = TSjis::checkSjisString(ifs);
    if (sjisCheckResult.rawLength < 0) goto fail;
    if (sjisCheckResult.rawLength != count) goto fail;
    
//    ifs.seek(start);
    // leave stream pointed at string
    return sjisCheckResult.rawLength;
  }

  fail:
    ifs.seek(start);
    return -1;
}

int main(int argc, char* argv[]) {
  if (argc < 5) {
    cout << "D.Gray-man (NDS) script string searcher" << endl;
    cout << "Usage: " << argv[0] << " [file] [outname] [targetfile] [dstfile]" << endl;
    
    return 0;
  }
  
  string fileName = string(argv[1]);
  string outName = string(argv[2]);
  string targetFile = string(argv[3]);
  string dstFile = string(argv[4]);
  
  TBufStream ifs;
  ifs.open(fileName.c_str());
  
//  table.readSjis(tableName);
  
  std::ofstream ofs((outName).c_str(),
                ios_base::binary);
  
  ofs << "  {" << endl;
  ofs << "    TBufStream ifs;" << endl;
  ofs << "    ifs.open(\"" << fileName << "\");" << endl;
  ofs << "    std::ofstream ofs((outPrefix + \"" << targetFile << "\").c_str());" << endl;
  ofs << "    " << endl;
  ofs << "    outputLine(ofs, \"#SETDSTFILE(\\\"" << dstFile << "\\\")\");" << endl;
  ofs << "    outputLine(ofs, \"#SETSIZE(224, 3)\");" << endl;
  
  // we're searching for pascal-style SJIS strings:
  // 16-bit LE count of characters, including terminator, followed by content
  while (ifs.remaining() > 3) {
    int count = checkPascalSjisString(ifs);
    if (count > 0) {
      ofs << "    dumpString(ifs, ofs, tablestd, "
          << TStringConversion::intToString(ifs.tell(), TStringConversion::baseHex)
          << " + 0, "
//          << count
//          << ", "
          << "\"auto-generated string "
          << dumpedStringCount++
          << "\");"
          << endl;
      
      ifs.seekoff(count);
    }
    else {
      ifs.get();
    }
  }
  
  ofs << "  }" << endl;
  
//  ifs.seek(searchStart);
//  while (ifs.tell() < searchEnd) {
//    dumpStringTable(ifs, ofs);
//  }
  
  return 0;
}

