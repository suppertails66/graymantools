#ifndef NSCRFILE_H
#define NSCRFILE_H


#include "ds/NitroHeader.h"
#include "ds/ScrnBlock.h"
#include "ds/NitroTileSet.h"
#include "ds/NitroPalette.h"
#include "util/TArray.h"
#include "util/TStream.h"

namespace Nftred {


class NscrFile {
public:
  
  NscrFile();
  
  void read(BlackT::TStream& ifs);
  void write(BlackT::TStream& ofs) const;
  
  NitroHeader header;
  ScrnBlock scrnBlock;
  
  void saveToEditable(const char* prefix,
                      const NitroTileSet& tiles,
                      const NitroPalette& palette,
                      bool rotscale = false) const;
  void patchTileSetFromEditable(const char* prefix,
                                NitroTileSet& tiles);
//  void loadFromEditable(const char* prefix);
  
  void generateTextBgFromEditable(const char* prefix,
                            NitroTileSet& tiles,
                            int paletteIndex = 0);
  
protected:
  
  static int getBaseX(int tileNum, int tilesW, int tilesH);
  static int getBaseY(int tileNum, int tilesW, int tilesH);
  static int getBaseTile(int x, int y, int tilesW, int tilesH);
  
  const static int subscreenW = 32;
  const static int subscreenH = 32;
  
  const static int textHFlipMask = 0x0400;
  const static int textVFlipMask = 0x0800;
  const static int textPaletteIndexMask = 0xF000;
  const static int textPaletteIndexShift = 12;
  
};


}


#endif
