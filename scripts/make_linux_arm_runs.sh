#!/bin/bash -e
#
# Utility script to create Linux ARM runs of the benchmark

sudo cpupower frequency-set -g performance

OS=Linux
CPU=ARM-Cortex-A73

make clean
make CXX=g++
./scripts/multirun.sh --prefix $OS+GCC-12.1.0+$CPU


make clean
make CXX=clang++
./scripts/multirun.sh --prefix $OS+Clang-14.0.6+$CPU

sudo cpupower frequency-set -g schedutil
