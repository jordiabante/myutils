#/usr/bin/env bash

rm -rf out

set -x
../fasta_split.sh -d out -n 4 -- input.fa
