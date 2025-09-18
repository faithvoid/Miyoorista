#!/bin/sh
URL_FILE="downloads.txt"
MAX_PARALLEL=4 # Downloads 4 files at a time, can possibly be increased for speed benefits but this may cause issues, YMMV.

while read -r BASE_URL DOWNLOAD_DIR; do
  [ -z "$BASE_URL" ] && continue

  mkdir -p "$DOWNLOAD_DIR"

  echo "Processing $BASE_URL -> $DOWNLOAD_DIR"

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

        echo "Downloading: $decoded -> $DOWNLOAD_DIR"
        curl -k -L "$url" -o "$DOWNLOAD_DIR/$decoded" &   # background download
        count=$((count + 1))

        if [ "$count" -ge "$MAX_PARALLEL" ]; then
            wait
            count=0
        fi
      done

  wait
done < "$URL_FILE"
