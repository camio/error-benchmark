.PHONY: all clean

CXX:= g++
CXXFLAGS:= -O3
CPPFLAGS:= -I. -Iexpected/include `pkg-config --cflags benchmark`

all: benchmark

%.o %.o.S: %.C
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $^ -o $@
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -S $^ -o $@.S

clean:
	$(RM) benchmark *.o

benchmark: benchmark.o conderror_exp.o conderror_exc.o conderror_ret.o conderror_cho.o
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $^ -o $@ `pkg-config --libs --static benchmark`
