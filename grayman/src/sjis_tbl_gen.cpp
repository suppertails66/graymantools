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
/*  if (argc < 2) {
    cout << "SJIS identity table generator" << endl;
    cout << "Usage: " << argv[0] << " <file> [options]" << endl;
    cout << "Options: " << endl;
    cout
      << "  -l     Minimum characters required for a successful match" << endl
      << "         (default: " << minimumStringLen << ")" << endl;
    return 0;
  } */
  
  for (int i = 0; i < 0x10000; i++) {
    // linebreak
    if (i == 0xa) {
      cout << hex << i << "=[br]" << endl;
      continue;
    }
    if (i == 0xd) {
      cout << hex << i << "=[cr]" << endl;
      continue;
    }
    
//    cerr << hex << i << endl;
    if (TSjis::isSjis(i)) {
      cout << hex << i << "=";
      if (i < 0x100) {
//        cout << (unsigned char)i;
        cout.put(i);
      }
      else {
        cout.put((i & 0xFF00) >> 8);
        cout.put((i & 0x00FF));
      }
      cout << endl;
    }
  }
  
  return 0;
}
