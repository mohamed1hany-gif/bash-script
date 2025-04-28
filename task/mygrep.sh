#!/bin/bash

# Print usage/help
usage() {
  echo "Usage: $0 [options] search_string filename"
  echo
  echo "Options:"
  echo "  -n    Show line numbers for matching lines"
  echo "  -v    Invert match (show non-matching lines)"
  echo "  --help  Show this help message"
}

# Initialize flags
show_line_number=false
invert_match=false

# Parse options
while [[ "$1" == -* ]]; do
  case "$1" in
    -n) show_line_number=true ;;
    -v) invert_match=true ;;
    --help) usage; exit 0 ;;
    -*)
      # Handle combined options like -vn or -nv
      opt="${1#-}" # remove leading dash
      for ((i=0; i<${#opt}; i++)); do
        case "${opt:$i:1}" in
          n) show_line_number=true ;;
          v) invert_match=true ;;
          *) echo "Unknown option: -${opt:$i:1}"; usage; exit 1 ;;
        esac
      done
      ;;
  esac
  shift
done

# After options are parsed, expect search string and filename
if [[ $# -lt 2 ]]; then
  echo "Error: Missing search string or filename."
  usage
  exit 1
fi

search="$1"
file="$2"

# Check if file exists
if [[ ! -f "$file" ]]; then
  echo "Error: File '$file' not found."
  exit 1
fi

# Perform the search
line_number=0
while IFS= read -r line; do
  ((line_number++))
  if echo "$line" | grep -i -q -- "$search"; then
    matched=true
  else
    matched=false
  fi

  if { $matched && ! $invert_match; } || { ! $matched && $invert_match; }; then
    if $show_line_number; then
      echo "${line_number}:$line"
    else
      echo "$line"
    fi
  fi
done < "$file"
