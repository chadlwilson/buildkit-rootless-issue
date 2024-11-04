FROM curlimages/curl:latest AS download-and-unzip
USER root
ARG TARGETARCH
ARG UID=1000
RUN curl --fail --location --silent --show-error "https://download.gocd.org/binaries/24.4.0-19686/generic/go-agent-24.4.0-19686.zip" > /tmp/go-agent-24.4.0-19686.zip && \
    unzip -q /tmp/go-agent-24.4.0-19686.zip -d /

FROM cgr.dev/chainguard/wolfi-base
ARG TARGETARCH

COPY --from=download-and-unzip /go-agent /go-agent

USER go