#!/usr/bin/env bash
# ------------------------------------------------------------------
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

# Find perl scripts
perl_script="${script_absdir}/perl/${script_name}.pl"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd: -l help,outdir: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"

# Options
while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    -d|--outdir)
      outdir="$2"
      shift 2
      ;;  
    --)
      shift
      break
      ;;
    *)
      echo "$script_name.sh:Internal error!"
      exit 1
      ;;
  esac
done

# Inputs
fasta_file="$1"
perc="$2"

# Outputs
fasta_basename="$(basename "$fasta_file")"
prefix="${fasta_basename%%.*}"
outfile="${outdir}/${prefix}_${perc}.fa"
mkdir -p "$outdir"

# Count number of entries
Ntotal="$(zcat -f "$fasta_file" | grep '^>' | wc -l)"

# Call perl script
"$perl_script" "$Ntotal" "0.$perc" < "$fasta_file" > "$outfile"
