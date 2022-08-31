#!/bin/bash
service mpd stop
if [[ ! -f /mpd/music ]]; then
  ln -s /var/lib/mpd/music /mpd/music
fi
if [[ ! -f /mpd/playlists ]]; then
  ln -s /var/lib/mpd/playlists /mpd/playlists
fi
if [[ ! -f /mpd/mpd.conf ]]; then
  ln -s /etc/mpd.conf /mpd/mpd.conf
fi
mpd --stdout --no-daemon
mpc update