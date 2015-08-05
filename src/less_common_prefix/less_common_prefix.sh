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

TEMP=$(getopt -o h -l help -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults

# Options
while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
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

# Loop through all the arguments to find the less common prefix
lcp="$1" && shift
length=${#lcp}
for arg in "$@"
do
    for ((i=0; i<${length}; i++)); do
        if [[ "${lcp:0:i}" == "${arg:0:i}" ]] 
        then
            continue
        else
            (( i-- ))
            lcp="${lcp:0:i}"                       
            length="${#lcp}"
        fi
    done
done

# Get rid of the underscore at the end
lcp="${lcp%_}"

# Get rid of the path if existent
lcp="${lcp##*/}"

# Output
echo "$lcp"

