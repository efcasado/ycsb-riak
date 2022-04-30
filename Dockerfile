FROM alpine:3.15.4

ENV YCSB_REPO=github.com/brianfrankcooper/YCSB
ENV YCSB_BASE_URL=https://${YCSB_REPO}/releases/download
ENV YCSB_VERSION=0.17.0

RUN apk --no-cache add openjdk8-jre

RUN wget ${YCSB_BASE_URL}/${YCSB_VERSION}/ycsb-${YCSB_VERSION}.tar.gz -P /tmp/ \
    && mkdir -p /opt/ycsb \
    && tar xfvz /tmp/ycsb-${YCSB_VERSION}.tar.gz --strip-components=1 -C /opt/ycsb/ \
    && cd /opt/ycsb \
    && rm -rf /tmp/ycsb-${YCSB_VERSION}

WORKDIR /opt/ycsb/

ENTRYPOINT [ "./bin/ycsb.sh" ]
CMD [ "shell", "basic" ]
