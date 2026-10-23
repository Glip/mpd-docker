# MPD and mpc are compiled from the upstream tarballs.
# https://www.musicpd.org/download.html
ARG ALPINE_VERSION=3.24
ARG MPD_VERSION=0.24.17
ARG MPC_VERSION=0.35

FROM alpine:${ALPINE_VERSION} AS build

ARG MPD_VERSION
ARG MPC_VERSION

RUN apk add --no-cache \
        build-base \
        ca-certificates \
        curl \
        meson \
        pkgconf \
        samurai \
        alsa-lib-dev \
        curl-dev \
        expat-dev \
        faad2-dev \
        flac-dev \
        fmt-dev \
        libid3tag-dev \
        libmpdclient-dev \
        libogg-dev \
        libvorbis-dev \
        libshout-dev \
        mpg123-dev \
        opusfile-dev \
        pcre2-dev \
        sqlite-dev \
        zlib-dev

WORKDIR /src

# These tags are the release listed on https://www.musicpd.org/download.html.
# The tarballs on that site often stall mid-download, so the build uses the
# matching git tags instead.
RUN curl -fsSL --retry 5 --retry-all-errors --retry-delay 2 \
        -o mpd.tar.gz \
        "https://github.com/MusicPlayerDaemon/MPD/archive/refs/tags/v${MPD_VERSION}.tar.gz" \
    && curl -fsSL --retry 5 --retry-all-errors --retry-delay 2 \
        -o mpc.tar.gz \
        "https://github.com/MusicPlayerDaemon/mpc/archive/refs/tags/v${MPC_VERSION}.tar.gz" \
    && mkdir mpd mpc \
    && tar -xf mpd.tar.gz -C mpd --strip-components=1 \
    && tar -xf mpc.tar.gz -C mpc --strip-components=1

# Codecs and outputs cover a music library plus Icecast (shout).
# FFmpeg, ICU, Avahi, Pulse and UPnP are left out: they dominate the image size.
WORKDIR /src/mpd
RUN meson setup build \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --buildtype=minsize \
        -Db_ndebug=true \
        -Db_lto=true \
        -Dstrip=true \
        -Ddocumentation=disabled \
        -Dhtml_manual=false \
        -Dmanpages=false \
        -Dtest=false \
        -Dsystemd=disabled \
        -Dio_uring=disabled \
        -Dneighbor=false \
        -Dupnp=disabled \
        -Dlibmpdclient=disabled \
        -Dudisks=disabled \
        -Dwebdav=disabled \
        -Dcdio_paranoia=disabled \
        -Dcurl=enabled \
        -Dmms=disabled \
        -Dnfs=disabled \
        -Dsmbclient=disabled \
        -Dqobuz=disabled \
        -Dbzip2=disabled \
        -Diso9660=disabled \
        -Dzzip=disabled \
        -Did3tag=enabled \
        -Dchromaprint=disabled \
        -Dadplug=disabled \
        -Daudiofile=disabled \
        -Dfaad=enabled \
        -Dffmpeg=disabled \
        -Dflac=enabled \
        -Dfluidsynth=disabled \
        -Dgme=disabled \
        -Dmad=disabled \
        -Dmikmod=disabled \
        -Dmodplug=disabled \
        -Dopenmpt=disabled \
        -Dmpcdec=disabled \
        -Dmpg123=enabled \
        -Dopus=enabled \
        -Dsidplay=disabled \
        -Dsndfile=disabled \
        -Dtremor=disabled \
        -Dvorbis=enabled \
        -Dwavpack=disabled \
        -Dwildmidi=disabled \
        -Dvorbisenc=enabled \
        -Dlame=disabled \
        -Dtwolame=disabled \
        -Dshine=disabled \
        -Dlibsamplerate=disabled \
        -Dsoxr=disabled \
        -Dalsa=enabled \
        -Dao=disabled \
        -Djack=disabled \
        -Dopenal=disabled \
        -Doss=disabled \
        -Dpipewire=disabled \
        -Dpulse=disabled \
        -Dshout=enabled \
        -Dsndio=disabled \
        -Dsolaris_output=disabled \
        -Ddbus=disabled \
        -Dexpat=enabled \
        -Dicu=disabled \
        -Dnlohmann_json=disabled \
        -Dpcre=enabled \
        -Dsqlite=enabled \
        -Dzlib=enabled \
        -Dzeroconf=disabled \
    && ninja -C build \
    && DESTDIR=/out ninja -C build install

WORKDIR /src/mpc
RUN meson setup build \
        --prefix=/usr \
        --buildtype=minsize \
        -Db_ndebug=true \
        -Db_lto=true \
        -Dstrip=true \
        -Ddocumentation=disabled \
        -Dtest=false \
    && ninja -C build \
    && DESTDIR=/out ninja -C build install

FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache \
        alsa-lib \
        ca-certificates \
        faad2-libs \
        fmt \
        libcurl \
        libexpat \
        libflac \
        libgcc \
        libid3tag \
        libmpdclient \
        libshout \
        libstdc++ \
        libvorbis \
        mpg123-libs \
        opusfile \
        pcre2 \
        sqlite-libs \
        zlib \
    && adduser -S -D -H -h /var/lib/mpd -G audio mpd \
    && mkdir -p /var/lib/mpd/music /var/lib/mpd/playlists /run/mpd \
    && chown -R mpd:audio /var/lib/mpd /run/mpd \
    && chmod 777 /var/lib/mpd/playlists /run/mpd

COPY --from=build /out/usr/bin/mpd /out/usr/bin/mpc /usr/bin/
COPY mpd.conf /etc/mpd.conf

RUN if ldd /usr/bin/mpd /usr/bin/mpc | grep -q 'not found'; then \
        ldd /usr/bin/mpd /usr/bin/mpc; \
        exit 1; \
    fi \
    && mpd --version \
    && mpc help >/dev/null

EXPOSE 6600 8000

CMD ["mpd", "--stdout", "--no-daemon", "/etc/mpd.conf"]
