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

TEMP=$(getopt -o hd: -l help,outdir:,delim: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="${PWD}/fasta_comm_out"
delim="\s"

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
    --delim)
      delim="$2"
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

# Print LICENSE
cat "${script_absdir}/../../LICENSE"

# Inputs
fasta_file1="$1"
fasta_file2="$2"

# Outputs
fasta_basename1="$(basename "$fasta_file1")"
fasta_basename2="$(basename "$fasta_file2")"
prefix1="${fasta_basename1%%.*}"
prefix2="${fasta_basename2%%.*}"
outfile="${outdir}/${prefix2}.fa"
mkdir -p "$outdir"

# Call perl script
"$perl_script" "$fasta_file1" "$fasta_file2" "$delim" "$outfile" > "$outfile"
