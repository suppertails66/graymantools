#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TBufStream.h"
#include "util/TStringConversion.h"
#include "util/TOpt.h"
#include "util/TSjis.h"
#include <iostream>
#include <iomanip>
#include <fstream>

using namespace std;
using namespace BlackT;

int main(int argc, char* argv[]) {
  int minimumStringLen = 1;

  if (argc < 2) {
    cout << "SJIS string finder" << endl;
    cout << "Usage: " << argv[0] << " <file> [options]" << endl;
    cout << "Options: " << endl;
    cout
      << "  -l     Minimum characters required for a successful match" << endl
      << "         (default: " << minimumStringLen << ")" << endl;
    return 0;
  }
  
  TBufStream ifs;
  ifs.open(argv[1]);
  
  char* minLenArg = TOpt::getOpt(argc, argv, "-l");
  if (minLenArg != NULL) {
    minimumStringLen = TStringConversion::stringToInt(string(minLenArg));
  }
  
  while (!ifs.eof()) {
    TSjis::SjisCheckResult result = TSjis::checkSjisString(ifs);
    if (result.charCount < minimumStringLen) {
      ifs.get();
      continue;
    }
    
    string str(ifs.data().data() + ifs.tell());
    cout << hex << setw(6) << ifs.tell() << "|" << str << endl;
    ifs.seekoff(result.rawLength);
  }
  
  return 0;
}
