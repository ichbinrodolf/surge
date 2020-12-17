FROM golang:1.14-buster AS easy-novnc-build

LABEL Maintainer="ichbinrodolf"

WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

FROM ubuntu:groovy

ENV SURGE_FILE=surge-0.2.1-beta
ENV SURGE_URL_DIR=https://github.com/rule110-io/surge/releases/download/v0.2.1-beta
ENV PUID=1000
ENV PGID=1000
# Warning as also part of a file

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip && \
    rm -rf /var/lib/apt/lists

RUN echo tzdata tzdata/Areas select Europe \
    tzdata tzdata/Zones/Europe select Paris > preseed.txt && debconf-set-selections preseed.txt

RUN apt-get update -y && \
	export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get install -y --no-install-recommends libgtk3.0-cil libwebkit2gtk-4.0-37 && \
    rm -rf /var/lib/apt/lists

RUN wget $SURGE_URL_DIR/$SURGE_FILE.linux.zip && unzip $SURGE_FILE.linux.zip && rm $SURGE_FILE.linux.zip && mv surge /usr/local/bin/surge

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/

COPY menu.xml /etc/xdg/openbox/

RUN chmod 644 /etc/xdg/openbox/menu.xml

COPY supervisord.conf /etc/
COPY start.sh /

EXPOSE 8080

RUN groupadd --gid $PGID app && \
    useradd --home-dir /data --shell /bin/bash --uid $PUID --gid $PGID app 

VOLUME /data

CMD ["bash", "-c", "/start.sh"]
