FROM ich777/debian-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-nzbget"

RUN apt-get update && \
	apt-get -y install --no-install-recommends wget ca-certificates netcat-traditional p7zip-full unzip

RUN LAT_V_UNRAR="$(wget -qO- https://api.github.com/repos/ich777/unrar/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	cd /tmp && \
	wget -O unrar.tar.gz "https://github.com/ich777/unrar/releases/download/$LAT_V_UNRAR/rar-v$LAT_V_UNRAR.tar.gz" && \
	tar -C /usr/bin -xvf /tmp/unrar.tar.gz && \
	rm /tmp/unrar.tar.gz

RUN LAT_V_PAR2TURBO="$(wget -qO- https://api.github.com/repos/animetosho/par2cmdline-turbo/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	cd /tmp && \
	wget -O par2turbo.zip "https://github.com/animetosho/par2cmdline-turbo/releases/download/${LAT_V_PAR2TURBO}/par2cmdline-turbo-${LAT_V_PAR2TURBO#v}-linux-amd64.zip" && \
	unzip par2turbo.zip && \
	chmod +x /tmp/par2 && \
	mv /tmp/par2 /usr/bin/par2turbo && \
	ln -s /usr/bin/par2turbo /usr/bin/par2

ENV DATA_DIR="/nzbget"
ENV NZBGET_REL="stable"
ENV START_PARAMS=""
ENV CONNECTED_CONTAINERS=""
ENV CONNECTED_CONTAINERS_TIMEOUT=60
ENV UMASK=0000
ENV DATA_PERM=770
ENV UID=99
ENV GID=100
ENV USER="nzbget"

RUN mkdir $DATA_DIR && \
	mkdir /mnt/downloads && \
	mkdir /mnt/incomplete && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/ && \
	chmod -R 770 /mnt && \
	chown -R $UID:$GID /mnt

EXPOSE 6767

# Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]
