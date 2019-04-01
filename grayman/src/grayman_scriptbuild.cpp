#include "util/TStringConversion.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TThingyTable.h"
#include "grayman/GrayManScriptReader.h"
#include "grayman/GrayManLineWrapper.h"
#include "grayman/GrayManScriptCompressor.h"
#include "grayman/GrayManConsts.h"
#include "exception/TGenericException.h"
#include <string>
#include <map>
#include <fstream>
#include <iostream>

using namespace std;
using namespace BlackT;
using namespace Nftred;

TThingyTable table;

//const static int code_space   = 0x20;
//
//const static int code_wait      = 0x81A5;
//const static int code_br        = 0xA;
//const static int code_end       = 0x00;

void printDictEntry(std::string str, GrayManDictionary& dict) {
  int pos = 0;
  while (pos < str.size()) {
    if ((int)(unsigned char)str[pos] >= 0x80) {
      int value = (unsigned char)str[pos];
      value <<= 8;
      value |= (unsigned char)str[pos + 1];
      
//            cerr << "[" << value << "]";

      cerr << "[";
      printDictEntry(dict[value], dict);
      cerr << "]";
      
      pos += 2;
    }
    else {
      char c = str[pos];
      if (c == '\n') cerr << "[br]";
      else cerr << c;
      ++pos;
    }
  }
}

void exportRawResults(GrayManScriptReader::ResultCollection& results,
                      std::string filename) {
  TBufStream ofs(0x10000);
  for (int i = 0; i < results.size(); i++) {
    ofs.write(results[i].str.c_str(), results[i].str.size());
  }
  ofs.save((filename).c_str());
}

void exportRawResults(TLineWrapper::ResultCollection& results,
                      std::string filename) {
  TBufStream ofs(0x400000);
  for (int i = 0; i < results.size(); i++) {
    ofs.write(results[i].str.c_str(), results[i].str.size());
  }
  ofs.save((filename).c_str());
}

void exportRawResults(TStream& ifs,
                      std::string filename) {
  GrayManScriptReader::ResultCollection results;
  GrayManScriptReader(ifs, results, table)();
  exportRawResults(results, filename);
}

void exportTabledResults(TStream& ifs,
                         std::string binFilename,
                         GrayManScriptReader::ResultCollection& results,
                         TBufStream& ofs) {
  int offset = 0;
  for (int i = 0; i < results.size(); i++) {
    ofs.writeu16le(offset + (results.size() * 2));
    offset += results[i].str.size();
  }
  
  for (int i = 0; i < results.size(); i++) {
    ofs.write(results[i].str.c_str(), results[i].str.size());
  }
  
  ofs.save((binFilename).c_str());
}

void exportTabledResults(TStream& ifs,
                         std::string binFilename) {
  GrayManScriptReader::ResultCollection results;
  GrayManScriptReader(ifs, results, table)();
  
//  std::ofstream incofs(incFilename.c_str());
  TBufStream ofs(0x10000);
  exportTabledResults(ifs, binFilename, results, ofs);
}

void exportSizeTabledResults(TStream& ifs,
                         std::string binFilename) {
  GrayManScriptReader::ResultCollection results;
  GrayManScriptReader(ifs, results, table)();
  
//  std::ofstream incofs(incFilename.c_str());
  TBufStream ofs(0x10000);
  ofs.writeu8(results.size());
  exportTabledResults(ifs, binFilename, results, ofs);
}

int main(int argc, char* argv[]) {
  if (argc < 4) {
    cout << "D.Gray-man (NDS) script builder" << endl;
    cout << "Usage: " << argv[0] << " [inprefix] [thingy] [outprefix]"
      << endl;
    
    return 0;
  }
  
  try {
  
  string inPrefix = string(argv[1]);
  string tableName = string(argv[2]);
  string outPrefix = string(argv[3]);
  
  table.readSjis(tableName);
  
  // wrap script
  {
    // read size table
    GrayManLineWrapper::CharSizeTable sizeTable;
    
    int page = 0;
    {
      TBufStream ifs;
      ifs.open("out/font/fontwidth_wide.bin");
      int pos = 0;
      while (!ifs.eof()) {
        sizeTable[(page << 8) | pos++] = ifs.readu8();
      }
    }
    ++page;
    {
      TBufStream ifs;
      ifs.open("out/font/fontwidth.bin");
      int pos = 0;
      while (!ifs.eof()) {
        sizeTable[(page << 8) | pos++] = ifs.readu8();
      }
    }
    
    {
      TBufStream ifs;
//      ifs.open((inPrefix + "dialogue.txt").c_str());
      ifs.open(("out/script/all.txt"));
      
      TLineWrapper::ResultCollection results;
      GrayManLineWrapper(ifs, results, table, sizeTable)();
      
      exportRawResults(results, (outPrefix + "all_wrapped.txt"));
    
//      if (results.size() > 0) {
//        TOfstream ofs((outPrefix + "all_wrapped.txt").c_str());
//        ofs.write(results[0].str.c_str(), results[0].str.size());
//      }
    }
  }
  
  {
    TBufStream ifs;
    ifs.open((outPrefix + "all_wrapped.txt").c_str());
  
//    try {
      GrayManScriptReader::ResultCollection results;
      GrayManScriptReader(ifs, results, table)();
//    }
//    catch (TGenericException& e) {
//      std::cerr << "Exception: " << e.problem() << std::endl;
//      throw e;
//    }
    
    GrayManDictionary dict;
//    GrayManScriptCompressor(results, dict)(15, 2, 8);
    GrayManScriptCompressor(results, dict)(15, 2, 8);
    
    {
      TBufStream ofs(0x40000);
      
      int numDictEntries = dict.size();
      for (int i = 0; i < numDictEntries; i++) ofs.writeu32be(0);
      
      int dictPos = ofs.tell();
      int index = 0;
      for (GrayManDictionary::iterator it = dict.begin();
           it != dict.end();
           ++it) {
        // write offset to dictionary string
        ofs.seek(index * 4);
        ofs.writeu32le(dictPos);
        
        // write dictionary string
        ofs.seek(dictPos);
        ofs.write(it->second.c_str(), it->second.size());
        // add terminator
        ofs.put(0);
        
        cerr << "Dictionary " << hex << it->first << ": ";
        printDictEntry(it->second, dict);
        cerr << endl;
        
        dictPos = ofs.tell();
        ++index;
      }
      ofs.save((outPrefix + "dictionary.bin").c_str());
    }
    
    
    {
      TBufStream ofs;
      std::string openedFile;
      
      for (GrayManScriptReader::ResultCollection::iterator it
            = results.begin();
           it != results.end();
           ++it) {
        GrayManScriptReader::ResultString result = *it;
        std::string str = result.getString();
        
        // acount for terminator
        int trueStrSize = str.size() + 1;
        
        // new strings must fit over old ones
        if (trueStrSize > result.srcSize) {
//          for (int i = 0; i < str.size(); i++) {
//            std::cerr << hex << (unsigned char)str[i] << " ";
//          }
//          std::cerr << std::endl;
          std::string errorStr = std::string("Error: line ")
                                  + TStringConversion::intToString(
                                      result.srcLine)
                                  + ":\ntargeting "
                                  + result.dstFile
                                  + ", offset "
                                  + TStringConversion::intToString(
                                      result.srcOffset,
                                      TStringConversion::baseHex)
                                  + ": new string too long"
                                  + " (old "
                                  + TStringConversion::intToString(
                                      result.srcSize)
                                  + ", new "
                                  + TStringConversion::intToString(
                                      trueStrSize)
                                  + ")"
                                  + "\nRaw content:\n"
                                  + result.str;
          errorStr += "\nCompressed content:\n";
          errorStr += str;
//          for (int i = 0; i < str.size(); i++) {
//            errorStr += str[i];
//          }
          throw TGenericException(T_SRCANDLINE,
                                  "main()",
                                  errorStr);
        }
        
        if (result.dstFile.compare(openedFile) != 0) {
          if (openedFile.size() > 0) {
            std::cout << "Writing: " << openedFile << std::endl;
            ofs.save(openedFile.c_str());
          }
          
          ofs = TBufStream();
          ofs.open(result.dstFile.c_str());
          openedFile = result.dstFile;
//          std::cerr << openedFile << std::endl;
//          if (result.dstFile.compare("") == 0) {
//            std::cerr << result.str << std::endl;
//          }
        }
        
        ofs.seek(result.srcOffset);
        ofs.write(str.c_str(), trueStrSize);
        
        // null-pad to original size
        int remainder = result.srcSize - trueStrSize;
        for (int i = 0; i < remainder; i++) ofs.put(0);
      }
    }
  }
  
/*  generateHashTable((outPrefix + "dialogue_wrapped.txt"),
                    outPrefix,
                    "dialogue");
  
  {
    TBufStream ifs;
    ifs.open((inPrefix + "enemies.txt").c_str());
    exportTabledResults(ifs, outPrefix + "enemies.bin");
  }
    
  {
    TBufStream ifs;
    ifs.open((inPrefix + "enemies_plural.txt").c_str());
    exportTabledResults(ifs, outPrefix + "enemies_plural.bin");
  }
    
  {
    TBufStream ifs;
    ifs.open((inPrefix + "ordinal_numbers.txt").c_str());
    exportTabledResults(ifs, outPrefix + "ordinal_numbers.bin");
  }
  
  {
    TBufStream ifs;
    ifs.open((inPrefix + "new.txt").c_str());
    
    exportRawResults(ifs, outPrefix + "enemy_appeared_plural.bin");
    exportRawResults(ifs, outPrefix + "theend.bin");
    exportRawResults(ifs, outPrefix + "new_system_menu.bin");
    exportRawResults(ifs, outPrefix + "speech_settings_menu.bin");
    exportRawResults(ifs, outPrefix + "speech_settings_explanation.bin");
    exportRawResults(ifs, outPrefix + "speech_settings_menulabel.bin");
  }
  
  {
    TBufStream ifs;
    ifs.open((inPrefix + "nameentry_table.txt").c_str());
    
    exportRawResults(ifs, outPrefix + "nameentry_table.bin");
  }
  
  {
    TBufStream ifs;
    ifs.open((inPrefix + "charnames_default.txt").c_str());
    
    exportRawResults(ifs, outPrefix + "charnames_default_char0.bin");
    exportRawResults(ifs, outPrefix + "charnames_default_char1.bin");
    exportRawResults(ifs, outPrefix + "charnames_default_char2.bin");
  }
  
  {
    TBufStream ifs;
    ifs.open((inPrefix + "charnames_cheat.txt").c_str());
    
    exportRawResults(ifs, outPrefix + "charnames_cheat_char0.bin");
    exportRawResults(ifs, outPrefix + "charnames_cheat_char1.bin");
    exportRawResults(ifs, outPrefix + "charnames_cheat_char2.bin");
    exportRawResults(ifs, outPrefix + "charnames_cheat_soundtest.bin");
  } */
  
  // tilemaps/new
/*  {
    TBufStream ifs;
    ifs.open((inPrefix + "tilemaps.txt").c_str());
    
    exportRawResults(ifs, outPrefix + "roulette_right.bin");
    exportRawResults(ifs, outPrefix + "roulette_wrong.bin");
    exportRawResults(ifs, outPrefix + "roulette_timeup.bin");
    exportRawResults(ifs, outPrefix + "roulette_perfect.bin");
    exportRawResults(ifs, outPrefix + "roulette_blank.bin");
    
    exportRawResults(ifs, outPrefix + "mainmenu_help.bin");
    
    exportSizeTabledResults(ifs, outPrefix + "credits.bin");
  } */
  
  return 0;
  
  }
  catch (TGenericException& e) {
    std::cerr << "Exception:" << std::endl;
    std::cerr << e.problem() << std::endl;
    return 1;
  }
}

