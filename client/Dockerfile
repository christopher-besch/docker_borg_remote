FROM "chrisbesch/borg2"
RUN apt-get update && \
    apt-get install -y ssh

RUN mkdir /root/.ssh
COPY ./init.sh ./borg_client.sh ./echo_passphrase.sh /var/lib/borg_client/
RUN chmod +x /var/lib/borg_client/echo_passphrase.sh

ENTRYPOINT ["bash", "/var/lib/borg_client/init.sh"]

