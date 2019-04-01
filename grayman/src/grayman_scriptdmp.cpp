#include "util/TStringConversion.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TThingyTable.h"
#include "exception/TGenericException.h"
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

using namespace std;
using namespace BlackT;

const static int op_wait       = 0x81A5;
const static int op_br         = 0xA;

string as2bHex(int num) {
  string str = TStringConversion::intToString(num,
                  TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 2) str = string("0") + str;
  
  return "<$" + str + ">";
}

void outputComment(std::ostream& ofs,
               string comment = "") {
  if (comment.size() > 0) {
    ofs << "//=======================================" << endl;
    ofs << "// " << comment << endl;
    ofs << "//=======================================" << endl;
    ofs << endl;
  }
}

void outputLine(std::ostream& ofs,
               string comment = "") {
  if (comment.size() > 0) {
    ofs << endl;
    ofs << comment << endl;
    ofs << endl;
  }
}

void dumpString(TStream& ifs, std::ostream& ofs, const TThingyTable& table,
              int offset,
              string comment = "") {
  ifs.seek(offset);
  
  std::ostringstream oss;
  
  if (comment.size() > 0) {
    oss << "//=======================================" << endl;
    oss << "// " << comment << endl;
    oss << "//=======================================" << endl;
    oss << endl;
  }
  
  // comment out first line of original text
  oss << "// ";
  bool newOrigTextPending = false;
  while (true) {
    // check for terminator
    if (ifs.peek() == 0) {
//      oss << endl;
//      oss << endl << endl;
      ifs.get();
      break;
    }
    
    if (newOrigTextPending) {
      oss << endl << endl;
      oss << "// ";
    }
    
    TThingyTable::MatchResult result = table.matchId(ifs);
    if (result.id == -1) {
      throw TGenericException(T_SRCANDLINE,
                              "dumpString(TStream&, std::ostream&)",
                              string("At offset ")
                                + TStringConversion::intToString(
                                    ifs.tell(),
                                    TStringConversion::baseHex)
                                + ": unknown character '"
                                + TStringConversion::intToString(
                                    (unsigned char)ifs.peek(),
                                    TStringConversion::baseHex)
                                + "'");
    }
    
    string resultStr = table.getEntry(result.id);
    oss << resultStr;
    
/*    if ((result.id == op_terminator)) {
//      oss << endl;
      oss << endl << endl;
      oss << resultStr;
      break;
    } */
    if ((result.id == op_br)) {
      oss << endl;
      oss << "// ";
    }
    else if ((result.id == op_wait)) {
      oss << endl << endl;
      oss << resultStr;
      newOrigTextPending = true;
    }
  }
  
  ofs << "#STARTMSG("
      // offset
      << TStringConversion::intToString(
          offset, TStringConversion::baseHex)
      << ", "
      // size
      << TStringConversion::intToString(
          ifs.tell() - offset, TStringConversion::baseDec)
      << ")" << endl << endl;
  
  ofs << oss.str();
  
//  oss << endl;
  ofs << endl << endl;
//  ofs << "//   end pos: "
//      << TStringConversion::intToString(
//          ifs.tell(), TStringConversion::baseHex)
//      << endl;
//  ofs << "//   size: " << ifs.tell() - offset << endl;
/*      int answerTableAddr = ifs.tell();
      int answerTablePointer = (answerTableAddr % 0x4000) + 0x8000;
      int answerPointerHigh = (answerTablePointer & 0xFF00) >> 8;
      int answerPointerLow = (answerTablePointer & 0xFF);
      ofs << as2bHex(answerPointerLow) << as2bHex(answerPointerHigh) << endl; */
  ofs << endl;
  ofs << "#ENDMSG()";
  ofs << endl << endl;
}

void dumpStringSet(TStream& ifs, std::ostream& ofs, const TThingyTable& table,
               int startOffset,
               int numStrings,
               string comment = "") {
  if (comment.size() > 0) {
    ofs << "//=======================================" << endl;
    ofs << "// " << comment << endl;
    ofs << "//=======================================" << endl;
    ofs << endl;
  }
  
  ifs.seek(startOffset);
  for (int i = 0; i < numStrings; i++) {
    ofs << "// substring " << i << endl;
    dumpString(ifs, ofs, table, ifs.tell(), "");
  }
}

void addComment(std::ostream& ofs, string comment) {
  ofs << "//===========================================================" << endl;
  ofs << "// " << comment << endl;
  ofs << "//===========================================================" << endl;
  ofs << endl;
}

int main(int argc, char* argv[]) {
  if (argc < 2) {
    cout << "D.Gray-man (NDS) script dumper" << endl;
    cout << "Usage: " << argv[0] << " [outprefix]" << endl;
    
    return 0;
  }
  
//  string inPrefix = string(argv[1]);
  string outPrefix = string(argv[1]);
  
//  TBufStream ifs;
//  ifs.open(romName.c_str());
  
  TThingyTable tablestd;
  tablestd.readSjis(string("table/sjis_grayman.tbl"));
  
  // remappable menus
/*  {
//    std::ofstream ofs((outPrefix + "menus.txt").c_str(),
//                  ios_base::binary);
    
//    dumpMenu(ifs, ofs, 0x3B4F, tablestd, "main menu");
  }
  
  // dialogue
  {
//    std::ofstream ofs((outPrefix + "dialogue.txt").c_str(),
//                  ios_base::binary);
    
//    addComment(ofs, "common messages");
//    dumpStringSet(ifs, ofs, tablestd, 0x1BC2, 0, 1, "got item", false);
  } */
  
/*  {
    TBufStream ifs;
    ifs.open("out/romfiles_orig/data/script/stage01.bin");
    std::ofstream ofs((outPrefix + "stage01.txt").c_str());
    
    dumpString(ifs, ofs, tablestd, 0x9FA + 0, "auto-generated string 0");
  } */
  
  #include "../out/scriptsrch/all.txt"
  
  return 0;
} 
