FROM "debian"

RUN apt-get update && \
    apt-get install -y python3-pip pkg-config build-essential libssl-dev libacl1-dev libxxhash-dev liblz4-dev libzstd-dev git

RUN git clone https://github.com/borgbackup/borg
WORKDIR /borg
RUN git checkout 2.0.0b3

RUN python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install -r requirements.d/development.txt && \
    python3 -m pip install -e .

ENTRYPOINT ["bash"]

