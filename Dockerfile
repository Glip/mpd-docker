FROM ubuntu:latest

RUN apt update && apt install -y mpd mpc
RUN apt clean  && apt autoclean
RUN sed -i "s/^#pid_file/pid_file/" /etc/mpd.conf
RUN sed -i "s/localhost/any/" /etc/mpd.conf
RUN mkdir /run/mpd && chmod 777 /run/mpd
RUN touch /var/lib/mpd/tag_cache \
        /var/lib/mpd/state
RUN chown mpd:audio -R /var/lib/mpd/
RUN mkdir /mpd
COPY docker-entrypoint.sh /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]