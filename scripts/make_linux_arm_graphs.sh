#!/bin/bash -e
#
# Utility script to create graphs of Linux runs

OS=Linux
CPU=ARM-Cortex-A73

./scripts/build_graph.sh --prefix $OS+Clang-14.0.6+$CPU
./scripts/build_graph.sh --prefix $OS+GCC-12.1.0+$CPU
