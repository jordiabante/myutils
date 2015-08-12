#!/usr/bin/env bash
# ------------------------------------------------------------------
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd:p:nt -l help,outdir:,prefix:,na,two -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
prefix="merge_out"

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
    -p|--prefix)			
      prefix="$2"
      shift 2
      ;;
    -n|--na)			
      na="x"
      shift
      ;;
    -t|--two)			
      two="x"
      shift
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

# Temporary file and output
temp_file="/tmp/merge_temp.txt"
out_file="${outdir}/${prefix}.txt"

# Preprocess input files to handle two fields
if [ "$two" ]
then
  for file in "$@";
  do
      zcat -f "$file" | sed 's/\t/_/' > "$temp_file"
      cat "$temp_file" > "$file"
  done
fi

# Copy first file and shift argument
echo "$(date): Merging $1 ..."
first_file="$1"
zcat -f "$first_file" | sort -k 1b,1 > "$out_file" && shift

## Command options
cmd="join"
# Add null fields
if [ "$na" ]
then
  cmd+=" -e "NA" -a1 -a2 -o 0 1.2 2.2"
fi

# Loop through all the other files
i=3
for file in "$@";
do 
    echo "$(date): Merging ${file} ..."
    eval "$cmd" "$out_file" <(sort -k 1b,1 <(zcat -f "$file")) > "$temp_file"
    cat "$temp_file" | sort -k 1,1 > "$out_file" 
    # Update command if na activated
    if [ "$na" ]
    then
        cmd+=" 1.${i}"
    fi
    ((i++))
done

# Postprocess input files and output file
if [ "$two" ]
then
  cat "$out_file" | sed 's/_/\t/' > "$temp_file"
  cat "$temp_file" | sort -k 1,1 -k 2,2n > "$out_file"
  zcat -f "$first_file" | sed 's/_/\t/' > "$temp_file"
  cat "$temp_file" | gzip > "$first_file"
  for file in "$@";
  do
    zcat -f "$file" | sed 's/_/\t/' > "$temp_file"
    cat "$temp_file" | gzip > "$file"
  done
fi

# Compress and remove temporary file
echo "$(date): Compressing ..."
gzip -f "$out_file" &
rm "$temp_file"
