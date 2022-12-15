#!/bin/bash -e
#
# Utility script to generate a comparison graph from benchmark output.

usage() {
  cat <<EOF
Usage: build_graph.sh --prefix string

Utility script to generate a comparison graph from benchmark output.  --prefix
should be set to a string that was used with multirun.sh. The generated graph
shows up in a window.

This command is expected to be run at the top level of the error-benchmark
repository where it can find multirun.sh output in the runs/ folder. It also
requires jq and gnuplot to be in the current path.
EOF
}

if ! command -v jq >/dev/null; then
  echo "ERROR: jq executable could not be found. Is it installed" >&2
  exit 1
fi

if ! command -v gnuplot >/dev/null; then
  echo "ERROR: gnuplot executable could not be found. Is it installed" >&2
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit ;;
    --prefix)
      PREFIX="$2"
      shift ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      exit 1;;
  esac
  shift
done

if [[ -z "${PREFIX}" ]]; then
  echo "--prefix must be specified. See --help for more info" >&2
  exit 1
fi

for ALTERNATIVE in exc exp
do
  scripts/collate.sh --prefix ${PREFIX} | \
    jq --raw-output '
    .[]
    | .test_name as $test_name
    | .results[]
    | select(.alternative | contains("'"${ALTERNATIVE}"'"))
    | [ $test_name,
        .mean,
        .stddev
      ]
    | @csv
    ' > /tmp/${ALTERNATIVE}.csv
done

gnuplot -p <<EOF
set datafile separator ','
set boxwidth 0.8
set style fill solid 1.00

set title "${PREFIX}" font ",14" tc rgb "#606060"
set ylabel "Iterations per second"
set xlabel "Test case"
set xtics nomirror rotate by -45
set format y '%.0s %c'
set tic scale 0
set grid ytics
unset border

# Lighter grid lines
set grid ytics lc rgb "#C0C0C0"

set style data histograms
plot "/tmp/exc.csv" using 2:xticlabels(1) title "Exceptions" lt rgb "#406090",\
     "/tmp/exp.csv" using 2 title "Expected" lt rgb "#40FF00"
EOF
