#!/bin/bash -e
#
# Utility script to create graphs of Linux runs

./scripts/build_graph.sh --prefix Linux+Clang-14.0.6+Intel-XEON-X5650
./scripts/build_graph.sh --prefix Linux+GCC-12.2.0+Intel-XEON-X5650
