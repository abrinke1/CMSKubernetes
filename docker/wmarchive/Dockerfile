FROM registry.cern.ch/cmsweb/exporters:latest as exporters
FROM registry.cern.ch/cmsweb/cmsweb-base:latest as cmsweb-base
FROM golang:latest as go-builder
MAINTAINER Valentin Kuznetsov vkuznet@gmail.com

# tag to use
ENV TAG=v00.08.77

ENV WDIR=/data
ENV USER=wmarchive
ADD run.sh $WDIR/run.sh
ADD wmarch_go.json $WDIR/wmarch_go.json
WORKDIR $WDIR
RUN mkdir gopath
ENV GOPATH=$WDIR/gopath
ARG CGO_ENABLED=0
RUN git clone https://github.com/dmwm/WMArchive.git
WORKDIR $WDIR/WMArchive
RUN git checkout tags/$TAG -b build && cd src/go && make && cp wmarchive /data/

# for musl C-libary and smallest base image we will use alpine
FROM alpine:3.16
RUN apk add sudo
RUN mkdir -p /data/
ENV PATH $PATH:/data
COPY --from=go-builder /data/wmarchive /data/
COPY --from=go-builder /data/wmarch_go.json /data/
COPY --from=go-builder /data/run.sh /data/
#ADD run.sh /data/run.sh

COPY --from=exporters /data/process_exporter /data/
COPY --from=exporters /data/process_monitor.sh /data/
COPY --from=cmsweb-base /etc/grid-security /etc/grid-security

ENV USER=wmarchive
#RUN adduser -D -u 1000 -h ${WDIR} ${USER}
ENV WDIR=/data
WORKDIR $WDIR
RUN adduser --disabled-password --home "${WDIR}" --uid 1000 "$USER"
# # add user to sudoers file
RUN echo "%$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
#
USER ${USER}
#
RUN sed -i -e "s,bash,sh,g" -e "s,print \$2,print \$1,g" /data/process_monitor.sh
