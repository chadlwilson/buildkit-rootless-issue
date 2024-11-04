FROM curlimages/curl:latest AS download-and-unzip
USER root
RUN curl --fail --location --silent --show-error "https://download.gocd.org/binaries/24.4.0-19686/generic/go-agent-24.4.0-19686.zip" > /tmp/go-agent-24.4.0-19686.zip && \
    unzip -q /tmp/go-agent-24.4.0-19686.zip -d /

FROM cgr.dev/chainguard/wolfi-base
COPY --from=download-and-unzip /go-agent /go-agent