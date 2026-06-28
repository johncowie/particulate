#!/usr/bin/env bash
# Output a shuffled ordering of N indices (1-based).
# Usage: shuffle-order.sh <count>
# Example: shuffle-order.sh 4  →  3 1 4 2  (one line, space-separated)

if [ $# -ne 1 ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
  echo "Usage: shuffle-order.sh <count>" >&2
  exit 1
fi

seq 1 "$1" | sort -R | tr '\n' ' ' | sed 's/ $/\n/'
