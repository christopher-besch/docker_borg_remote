FROM "debian" as wgetter
RUN apt-get update && \
    apt-get install -y wget
RUN wget https://github.com/borgbackup/borg/releases/download/2.0.0b3/borg-linux64


FROM "debian"
COPY --from=wgetter /borg-linux64 /usr/local/bin/borg
RUN chmod +x /usr/local/bin/borg

ENTRYPOINT ["bash"]

