#!/usr/bin/env bash
set -x
../sample_nanopolish.sh nano_ex.tsv
../sample_nanopolish.sh -p 0.5 nano_ex.tsv
../sample_nanopolish.sh --perc 0.5 nano_ex.tsv
