#/usr/bin/env bash

rm -rf out

set -x
../split_fasta.sh -d out -n 4 -- input.fa
