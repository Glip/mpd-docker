# MPD

Small Docker image for [MPD](https://www.musicpd.org/), built from the upstream source tarball rather than a distribution package. The current build is MPD 0.24.17 and mpc 0.35 on Alpine.

Compiled-in codecs are FLAC, Ogg Vorbis, Opus, MP3 and raw AAC. M4A and WAV are omitted so the image stays small. The default config listens on `0.0.0.0:6600` and serves a Vorbis HTTP stream on port 8000 while music is playing. ALSA is compiled in and switched off until `/dev/snd` is available.

### Build

```
docker build -t mpd .
```

### Usage

```
docker run -d -p 6600:6600 -p 8000:8000 --volume /home/docker/mpd/music:/var/lib/mpd/music --volume /home/docker/mpd/playlists:/var/lib/mpd/playlists --volume /home/docker/mpd/mpd.conf:/etc/mpd.conf --name=mpd kuntsevich89/mpd:latest
```

Mounting `/etc/mpd.conf` replaces the config shipped in the image.

## Authors

* **Andrey Kuntsevich** - [Taz](https://github.com/Glip)
