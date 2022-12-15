#!/bin/bash -e
#
# Utility script to turn the bechmark output (from multirun.sh) into a readily
# readable form.

usage() {
  cat <<EOF
Usage: collate.sh --prefix string

Utility script to turn the bechmark output (from multirun.sh) into a readily
readable form.  --prefix should be set to a string that was used with
multirun.sh. The readable form is sent to stdout

This command is expected to be run at the top level of the error-benchmark
repository where it can find multirun.sh output in the runs/ folder. It also
requires jq to be in the current path.
EOF
}

if ! command -v jq >/dev/null; then
  echo "ERROR: jq executable could not be found. Is it installed" >&2
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

jq --slurp '[.[].benchmarks[]]
  | group_by(.name)
  | [ .[] | { test_name:   .[0].name | sub("BM_(?<test>.*)_.../.*";.test)
            , alternative: .[0].name | sub("BM_.*_(?<alt>...)/.*";.alt)
            , samples:     [.[].items_per_second]
            , mean:        ([.[].items_per_second] | add / length)
            , stddev:      ( [.[].items_per_second]
                           | (add / length) as $mean
                           | (map(. - $mean | . * .) | add) / (length - 1)
                           | sqrt
                           )
            }
    ]
  | group_by(.test_name)
  | [ .[] | { test_name: .[0].test_name,
              results: [.[] | { alternative: .alternative
                              , mean: .mean
                              , stddev: .stddev
                              , samples: .samples
                              }
                       ]
            }
    ]
  ' run/${PREFIX}.run.*.json