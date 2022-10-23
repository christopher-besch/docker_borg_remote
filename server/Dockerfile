FROM "chrisbesch/borg2"
RUN apt-get update && \
    apt-get install -y openssh-server

# disable password login
RUN mkdir -p /var/run/sshd /root/.ssh && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

COPY ./init.sh /var/lib/borg_server/

EXPOSE 22
ENTRYPOINT ["bash", "/var/lib/borg_server/init.sh"]

