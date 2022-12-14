.PHONY: all clean

CXX:= g++
CXXFLAGS:= -O3
CPPFLAGS:= -Iexpected/include

all: benchmark

%.o %.S: %.C
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $^ -o $@
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -S $^ -o $@.S

clean:
	$(RM) benchmark *.o

benchmark: benchmark.o conderror_exp.o conderror_exc.o
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $^ -o $@ `pkg-config --libs --static benchmark`
