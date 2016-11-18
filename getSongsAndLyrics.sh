#!/usr/bin/bash

# Requirements (tested on Arch Linux)
# playlist fetching/python 3: python-beautifulsoup4 python-lxml
# song download: youtube-dl
# lyrics download: glyr-git (AUR)

function usage() {
	echo <<EOF
Usage: getSongsAndLyrics.sh songlist

Each line of the file songlist should have the format

    ('Title', 'Artist')

(ish) as generated by fetch.py
EOF
}

if [ "$#" -ne 1 ]; then
	usage
	exit 1
fi

SONG_LIST="$1"
LIST=$(cat "${SONG_LIST}"| sort | uniq)

while read LINE
do
    TITLE=$(echo $LINE | sed "s/([\"']//g" | sed "s/[\"'],.*//")
    ARTIST=$(echo $LINE | sed "s/.*, [\"']//" | sed "s/[\"'])//")
    CLEAN_TITLE=$(echo "$TITLE" | sed "s/(.*)//g" | sed "s/\\[.*\\]//g")
    CLEAN_ARTIST=$(echo "$ARTIST" | sed "s/(.*)//g" | sed "s/\\[.*\\]//g")

	DIR="${CLEAN_TITLE}__${CLEAN_ARTIST}"
	if [ ! -d "${DIR}" ]; then
		mkdir -p "$DIR"

		echo "Downloading music to ${DIR}"
		youtube-dl --quiet --extract-audio --audio-format "best" --no-overwrites --output "${DIR}/${TITLE}.%(ext)s" "ytsearch:${TITLE}"
		echo "Downloading lyrics to ${DIR}"
		glyrc lyrics --artist "${CLEAN_ARTIST}" --title "${CLEAN_TITLE}" --parallel 9 --number 1 --write "${DIR}/lyrics.txt" --verbosity 0
	else
		echo "Skipping ${DIR}, already exists"
	fi
done < <(echo "${LIST}")
