#!/usr/bin/env bash
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

TEMP=$(getopt -o hp: -l help,perc: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
perc=0.5

while true
do
  case "$1" in
    -h|--help)
      cat "$script_absdir"/${script_name}_help.txt
      exit
      ;;  
    -p|--perc)
      perc="$2"
      shift 2
      ;;
    --) 
      shift
      break
      ;;  
    *)  
      echo "$script_name.sh:Internal error!"
      exit -1
      ;;  
  esac
done

# Vars
nanofile="$1"
outdir="$(dirname $(realpath ${nanofile}))"
outfile="${outdir}/${nanofile%.tsv}_perc_${perc}.tsv"

# Cat header
head -n 1 "$nanofile" > "$outfile"

# Add reads
cut -f 5 "$nanofile" | awk 'NR>1{print $0| "sort -r"}' | uniq | awk -v PERC="$perc" 'BEGIN {srand()} !/^$/ { if (rand() <= PERC) print $0}' | grep -f /dev/stdin "$nanofile" >> "$outfile"
