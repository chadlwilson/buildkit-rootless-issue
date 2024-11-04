FROM curlimages/curl:latest AS gocd-agent-unzip
USER root
ARG TARGETARCH
ARG UID=1000
RUN curl --fail --location --silent --show-error "https://download.gocd.org/binaries/24.4.0-19686/generic/go-agent-24.4.0-19686.zip" > /tmp/go-agent-24.4.0-19686.zip && \
    unzip -q /tmp/go-agent-24.4.0-19686.zip -d / && \
    mkdir -p /go-agent/wrapper /go-agent/bin && \
    mv -v /go-agent-24.4.0/LICENSE /go-agent/LICENSE && \
    mv -v /go-agent-24.4.0/*.md /go-agent && \
    mv -v /go-agent-24.4.0/bin/go-agent /go-agent/bin/go-agent && \
    mv -v /go-agent-24.4.0/lib /go-agent/lib && \
    mv -v /go-agent-24.4.0/logs /go-agent/logs && \
    mv -v /go-agent-24.4.0/run /go-agent/run && \
    mv -v /go-agent-24.4.0/wrapper-config /go-agent/wrapper-config && \
    WRAPPERARCH=$(if [ $TARGETARCH == amd64 ]; then echo x86-64; elif [ $TARGETARCH == arm64 ]; then echo arm-64; else echo $TARGETARCH is unknown!; exit 1; fi) && \
    mv -v /go-agent-24.4.0/wrapper/wrapper-linux-$WRAPPERARCH* /go-agent/wrapper/ && \
    mv -v /go-agent-24.4.0/wrapper/libwrapper-linux-$WRAPPERARCH* /go-agent/wrapper/ && \
    mv -v /go-agent-24.4.0/wrapper/wrapper.jar /go-agent/wrapper/ && \
    chown -R ${UID}:0 /go-agent && chmod -R g=u /go-agent

FROM cgr.dev/chainguard/wolfi-base
ARG TARGETARCH

ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-static-${TARGETARCH} /usr/local/sbin/tini

# force encoding
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV GO_JAVA_HOME="/gocd-jre"

ARG UID=1000
ARG GID=1000

RUN \
# add mode and permissions for files we added above
  chmod 0755 /usr/local/sbin/tini && \
  chown root:root /usr/local/sbin/tini && \
  apk --no-cache upgrade && \
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
  adduser -D -u ${UID} -s /bin/bash -G root go && \
  apk add --no-cache git openssh-client bash curl procps glibc-locale-en && \
  curl --fail --location --silent --show-error "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jre_$(uname -m | sed -e s/86_//g)_linux_hotspot_21.0.5_11.tar.gz" --output /tmp/jre.tar.gz && \
  mkdir -p /gocd-jre && \
  tar -xf /tmp/jre.tar.gz -C /gocd-jre --strip 1 && \
  rm -rf /tmp/jre.tar.gz && \
  mkdir -p /go-agent /docker-entrypoint.d /go /godata

COPY --from=gocd-agent-unzip /go-agent /go-agent

USER go