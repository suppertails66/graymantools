#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TGraphic.h"
#include "util/TStringConversion.h"
#include "util/TPngConversion.h"
#include "util/TCsv.h"
#include <vector>
#include <string>
#include <iostream>

using namespace std;
using namespace BlackT;
//using namespace Sms;

string as2bHex(int num) {
  string str = TStringConversion::intToString(num,
                  TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 2) str = string("0") + str;
  
//  return "<$" + str + ">";
  return str;
}

string as2bHexPrefix(int num) {
  return "$" + as2bHex(num) + "";
}

int main(int argc, char* argv[]) {
  if (argc < 4) {
    std::cout << "ARM word table directive generator" << std::endl;
    std::cout << "Usage: " << argv[0] << " <infile> <offset> <numentries>"
      << std::endl;
    return 0;
  }
  
  TBufStream ifs;
  ifs.open(argv[1]);
  ifs.seek(TStringConversion::stringToInt(std::string(argv[2])));
  int numEntries = TStringConversion::stringToInt(std::string(argv[3]));
  
  for (int i = 0; i < numEntries; i++) {
    int next = ifs.readu32le();
    std::cout << ".dw " << TStringConversion::intToString(next,
        TStringConversion::baseHex) << std::endl;
  }
  
  return 0;
}
