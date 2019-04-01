IDIR := src
SRCDIR := src
ODIR := obj
LDIR :=

BLACKTNAME = blackt
BLACKTDIR = ../blackt
LIBSMSNAME = nftred
LIBSMSDIR = ../libnftred

AR=ar
CXX=g++
# Compile only
CDEFINES = -DBLACKT_ENABLE_LIBPNG
#CLIBS = -lpng
CFLAGS = -std=gnu++11 -O2 -Wall -L${LIBSMSDIR} -l${LIBSMSNAME} -L${BLACKTDIR} -l${BLACKTNAME} -lpng
CINCLUDES = -I${BLACKTDIR}/src -I${LIBSMSDIR}/src
CXXFLAGS=$(CFLAGS) $(CDEFINES) $(CINCLUDES) -I$(IDIR)

LIBDEPS := $(LIBSMSDIR)/lib${LIBSMSNAME}.a $(BLACKTDIR)/lib${BLACKTNAME}.a

TOOLSRCS := $(wildcard $(SRCDIR)/*.cpp)
TOOLSINDIR := $(patsubst %.cpp,%,$(TOOLSRCS))
TOOLS := $(notdir $(TOOLSINDIR))

.SECONDEXPANSION:

all: ${BLACKTNAME} lib${LIBSMSNAME} $(TOOLS)

${BLACKTNAME}:
	cd ${BLACKTDIR} && $(MAKE) && cd $(CURDIR)

lib${LIBSMSNAME}:
	cd ${LIBSMSDIR} && $(MAKE) && cd $(CURDIR)

$(TOOLS): $(SRCDIR)/$$@.cpp $(LIBDEPS)
	make ${BLACKTNAME}
	make lib${LIBSMSNAME}
	$(CXX) $(SRCDIR)/$@.cpp $(OBJ) -o $(notdir $@) $(CXXFLAGS)

.PHONY: ${BLACKTNAME} lib${LIBSMSNAME} cleanme clean

cleanme:
	rm -f $(TOOLS)

clean: cleanme
#	rm -f $(LIB)
#	rm -rf $(ODIR)
	cd ${BLACKTDIR} && $(MAKE) clean && cd $(CURDIR)
	cd ${LIBSMSDIR} && $(MAKE) clean && cd $(CURDIR)