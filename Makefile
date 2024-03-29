CXX = g++
LDFLAGS ?=
CXXFLAGS += -D FPGA_DMA_DEBUG=0 -g -O2 -fPIC -D EMU_MODE=0 -Wall -Wno-unknown-pragmas -I$(TBB_HOME)/include -fpermissive -std=c++11
CXXFLAGS += -DFPGA_DMA_MAX_BLOCKS=256 -DFPGA_DMA_BLOCK_SIZE=64

ifdef prefix
CXXFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib -L$(prefix)/lib64 
endif

LDFLAGS += -luuid
LDFLAGS += -lsafestr
LDFLAGS += -lrt
LDFLAGS += -ltbb
LDFLAGS += -L$(TBB_HOME)/lib/intel64_lin/gcc4.7/
ifneq ($(TBB_LIB),)
LDFLAGS += -L$(TBB_LIB)
endif

ifeq ($(USE_ASE),1)
   LDFLAGS += -lopae-c-ase
   CXXFLAGS += -DUSE_ASE
   CFLAGS += -DUSE_ASE
else
   LDFLAGS += -ljson-c
   LDFLAGS += -lopae-c
   LDFLAGS += -lhwloc
endif

LDFLAGS += -pthread
LDFLAGS += -lm

SRCS=$(wildcard *.cpp)
OBJS=$(SRCS:.cpp=.o)
all: $(OBJS) fpga_dma_test

fpga_dma.a: fpga_dma.o x86-sse2.o
	ar rcs $@ $^

fpga_dma_test: $(OBJS) fpga_dma.a
	$(CXX) -o $@ $^ $(LDFLAGS)

clean:
	$(RM) fpga_dma_test *.o *.so *.a *.dat *.log

.PHONY:all clean
