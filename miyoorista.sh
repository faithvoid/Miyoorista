#!/bin/sh
BASE_URL="$1"
MAX_PARALLEL=3

count=0

wget -qO- "$BASE_URL" \
  | grep -i '\.zip' \
  | sed -n 's/.*href="\([^"]*\.zip\)".*/\1/p' \
  | while read -r link; do
      case "$link" in
        http*) url="$link" ;;
        *) url="$(echo "$BASE_URL" | sed 's:/*$::')/$link" ;;
      esac

      rawname="${url##*/}"
      decoded=$(printf '%b' "${rawname//%/\\x}")

      echo "Downloading: $decoded"
      curl -k -L "$url" -o "$decoded" &   # background download
      count=$((count + 1))

      if [ "$count" -ge "$MAX_PARALLEL" ]; then
          wait
          count=0
      fi
    done

wait
