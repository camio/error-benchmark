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
  echo "ERROR: jq executable could not be found. Is it installed?" >&2
  exit 1
fi

if ! command -v gnuplot >/dev/null; then
  echo "ERROR: gnuplot executable could not be found. Is it installed?" >&2
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

for ALTERNATIVE in ret exc exp
do
  scripts/collate.sh --prefix ${PREFIX} | \
    jq --raw-output '
    # Put test entries in the desired order
      [ .[]
      | { key: (.test_name | if   startswith("sad") then 0
                             elif startswith("mix") then 1
                                                    else 2
                             end
                )
        , object: .
        }
      ]
    | sort_by(.key)
    | map(.object)

    # Create CSV
    | .[]
    | .test_name as $test_name
    | (.test_name |
        if   startswith("sad/")                        then "0% success"
        elif startswith("happy/")                      then "100% success"
        elif startswith("mix/") and endswith("/10")    then "90% success"
        elif startswith("mix/") and endswith("/100")   then "99% success"
        elif startswith("mix/") and endswith("/1000")  then "99.9% success"
        elif startswith("mix/") and endswith("/10000") then "99.99% success"
        else . end
      ) as $test_name
    | .results[]
    | select(.alternative | contains("'"${ALTERNATIVE}"'"))
    | [ $test_name,
        .periodMean,
        .periodStddev
      ]
    | @csv
    ' > /tmp/${ALTERNATIVE}.csv
done

gnuplot -p <<EOF
set datafile separator ','
set boxwidth 0.8
set style fill solid 1.0 border -1

set title "${PREFIX}" font ",14" tc rgb "#606060"
set ylabel "Nanoseconds per call"
set yrange [0:10e-9]
set xlabel "Test case"
set xtics nomirror rotate by -45
set format y '%.0s %c'
set tic scale 0
set grid ytics
unset border

# Lighter grid lines
set grid ytics lc rgb "#C0C0C0"

set style histogram errorbars gap 2 lw 1
set style data histogram
set bars 2.0
plot "/tmp/ret.csv" using 2:3:xticlabels(1) title "Return code" lt rgb "#909090",\
     "/tmp/exc.csv" using 2:3 title "Exceptions" lt rgb "#406090",\
     "/tmp/exp.csv" using 2:3 title "Expected" lt rgb "#40FF00"
EOF
