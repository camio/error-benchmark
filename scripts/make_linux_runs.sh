#!/bin/bash -e
#
# Utility script to create Linux runs of the benchmark

sudo cpupower frequency-set -g performance

make clean
make CXX=g++
./scripts/multirun.sh --prefix Linux+GCC-12.2.0+Intel-XEON-X5650


make clean
make CXX=clang++
./scripts/multirun.sh --prefix Linux+Clang-14.0.6+Intel-XEON-X5650

make clean
make CXX=$HOME/code/error-benchmark/circle/circle
./scripts/multirun.sh --prefix Linux+Circle-171+Intel-XEON-X5650

sudo cpupower frequency-set -g schedutil
