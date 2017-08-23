#!/usr/bin/env bash

rm -rf simulated_read_reference_R*

../simulate_sequencing.sh -l 100 -n 100 -- reference.fa
