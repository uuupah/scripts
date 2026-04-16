#! /usr/bin/env bash
for f in *.flac; do ffmpeg -i "$f" -b:a 320k -ar 44100 "${f%.flac}.mp3"; done && rm *.flac
for f in *.wav; do ffmpeg -i "$f" -b:a 320k -ar 44100 "${f%.flac}.mp3"; done && rm *.wav
for f in *.aac; do ffmpeg -i "$f" -b:a 320k -ar 44100 "${f%.flac}.mp3"; done && rm *.aac
