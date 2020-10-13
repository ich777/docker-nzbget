FROM ich777/debian-baseimage

LABEL maintainer="admin@minenet.at"

RUN apt-get update && \
	apt-get -y install --no-install-recommends libstdc++6 libxml2 libncurses5 gnutls-bin openssl && \
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/nzbget"
ENV NZBGET_V="latest"
ENV START_PARAMS=""
ENV DELETE_LOG_ON_START="true"
ENV UMASK=0000
ENV DATA_PERM=770
ENV UID=99
ENV GID=100
ENV USER="nzbget"

RUN mkdir $DATA_DIR && \
	mkdir /mnt/downloads && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/ && \
	chmod -R 770 /mnt && \
	chown -R $UID:$GID /mnt

EXPOSE 6789

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]