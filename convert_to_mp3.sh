#! /usr/bin/env bash
DEFAULT_MUSIC_DIR='~/music'
MUSICDIR=""

convert_folder () {
	flac=$(find "${1}" -type f -name "*.flac")
	wav=$(find "${1}" -type f -name "*.wav")
	alac=$(find "${1}" -type f -name "*.alac")
	aiff=$(find "${1}" -type f -name "*.aiff")

	if [[ ! -z  $flac ]] || [[ ! -z  $wav ]] || [[ ! -z  $alac ]] || [[ ! -z  $aiff ]]
	then
	  printf "non-mp3 files found in \"$1\". "
	  [[ "$(read -e -p 'convert to mp3? [y/N]> '; echo $REPLY)" == [Yy]* ]] || return

      cd "${1}"

	  if [[ ! -z $flac ]]
	  then
	    # pwd
	    find -name "*.flac" -exec bash -c 'ffmpeg -i "{}" -y -ab 320k -ar 44100 "${0/.flac}.mp3"' {} \;
	    rm *.flac
	  fi
	  
  	  if [[ ! -z $wav ]]
  	  then
  	    # pwd
  	    find -name "*.wav" -exec bash -c 'ffmpeg -i "{}" -y -ab 320k -ar 44100 "${0/.wav}.mp3"' {} \;
  	    rm *.wav
  	  fi

	  
  	  if [[ ! -z $alac ]]
  	  then
  	    # pwd
  	    find -name "*.alac" -exec bash -c 'ffmpeg -i "{}" -y -ab 320k -ar 44100 "${0/.alac}.mp3"' {} \;
  	    rm *.alac
  	  fi	  

	  if [[ ! -z $aiff ]]
	  then
	    # pwd
	    find -name "*.aiff" -exec bash -c 'ffmpeg -i "{}" -y -ab 320k -ar 44100 "${0/.aiff}.mp3"' {} \;
	    rm *.aiff
	  fi
	fi
}
export -f convert_folder

if [ -z "$1" ]
  then
    printf "check for files in ${DEFAULT_MUSIC_DIR}? "
    [[ "$(read -e -p ' [y/N]> '; echo $REPLY)" == [Yy]* ]] && MUSICDIR="$(echo $HOME/music)" || exit 0
  else
    MUSICDIR=$1
fi

find "${MUSICDIR}" -maxdepth 2 -mindepth 2 -exec bash -c 'convert_folder "$0"' {} \;
