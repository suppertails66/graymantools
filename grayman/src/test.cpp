#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TGraphic.h"
#include "util/TStringConversion.h"
#include "util/TPngConversion.h"
#include "util/TCsv.h"
#include "util/TSoundFile.h"
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
  TGraphic oldG;
  TPngConversion::RGBAPngToGraphic(std::string(argv[1]), oldG);

  int oldH = 192;
  TGraphic g;
  g.resize(oldG.w(), 256);
  g.clearTransparent();
  g.copy(oldG, TRect(0, 0, 0, 0), TRect(0, 0, 0, 0));
  
  TGraphic tile(8, 8);
  tile.copy(oldG, TRect(0, 0, 0, 0));
  
  int w = g.w() / 8;
  int h = (256 - oldH) / 8;
  for (int j = 0; j < h; j++) {
    for (int i = 0; i < w; i++) {
      g.copy(tile, TRect(i * 8, oldH + (j * 8), 0, 0));
    }
  }
  
  TPngConversion::graphicToRGBAPng(std::string(argv[1]), g);
  
  return 0;
}
