FROM fedora:36

RUN dnf -y update \
    && dnf -y install csdiff git ShellCheck \
    && dnf clean all

RUN mkdir -p /action
WORKDIR /action

COPY src/index.sh src/functions.sh ./

ENTRYPOINT ["/action/index.sh"]
