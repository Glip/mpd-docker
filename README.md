# MPD

Simple docker image for MPD

### Usage

```
 docker run -d -p 6600:6600 -p 8000:8000 --volume /home/docker/mpd/music:/var/lib/mpd/music --volume /home/docker/mpd/playlists:/var/lib/mpd/playlists --volume /home/docker/mpd/mpd
.conf:/etc/mpd.conf --name=mpd kuntsevich89/mpd:latest
```

## Authors

* **Andrey Kuntsevich** - [Taz](https://github.com/Glip)
