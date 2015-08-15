#!/usr/bin/env bash
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd:t:c:l:p: -l help,outdir:,threads:,chr:,length:,prefix: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
chr=5
length=2000
prefix="simulated_genome"
bases="ACTG"
threads=2

# Options
while true
do
  case "$1" in
    -h|--help)
      cat "$script_absdir"/${script_name}_help.txt
      exit
      ;;  
    -d|--outdir)
      outdir="$2"
      shift 2
      ;;
    -t|--threads)
      threads="$2"
      shift 2
      ;;
    -c|--chr)
      chr="$2"
      shift 2
      ;;
    -l|--length)
      length="$2"
      shift 2
      ;;
    -p|--prefix)
      prefix="$2"
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

# Start time
start_time="$(date +"%s%3N")"

# Temp and output
outfile="${outdir}/${prefix}.fa"
tempfile="${outdir}/${prefix}"
export outfile
export tempfile
export length

# Outdir
mkdir -p "$outdir"

# Generate a file for each chromosome
seq 1 "$chr" | xargs -I {} --max-proc "$threads" bash -c \
    'echo ">chr{}" >> '${tempfile}_{}.tmp' && random_sequence_generator.sh -l '$length' >> '${tempfile}_{}.tmp''

# Concatenate all chromosomes and filter
seq 1 "$chr" | xargs -I {} --max-proc 1 bash -c \
    'cat '${tempfile}_{}.tmp' >> '$outfile''

# Remove temp file
rm -f ${tempfile}*tmp*

# Time elapsed
end_time="$(date +"%s%3N")"
echo "Time elapsed: $(( $end_time - $start_time )) ms"
