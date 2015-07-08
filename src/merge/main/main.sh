#!/usr/bin/env bash
prefix=merge_out

set -x
../merge.sh -n -p ${prefix}_1 -- one_field/a.txt one_field/b.txt one_field/c.txt.gz
../merge.sh -tn -p ${prefix}_2 -- two_fields/a.txt two_fields/b.txt two_fields/c.txt

