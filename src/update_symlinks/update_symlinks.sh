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

# Read package to be updated
package="$1"

# Full path
package_path="$(readlink -f "$package")"

# List bash scripts (avoid symlinks and main.sh)
scripts="$(find "$package" -type f -executable \
! -name main.sh \
! -name *.sample \
! -name *.o \
! -name *.py \
! -name *.pl \
! -name *.R)"

# Refresh symlinks
rm -f "${package_path}"/bin/*.sh
cd "${package_path}/bin"
while read line;do
    name="$(basename "$line")"
    directory="$(dirname "$line")"
    directory="${directory#*/src/}"
    src_path="../src/${directory}/${name}"
    bin_path="../bin/${name}"
    ln -sf "${src_path}" "${bin_path}"
done < <(echo "$scripts")
