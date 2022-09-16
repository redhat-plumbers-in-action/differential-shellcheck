FROM fedora:36

RUN dnf -y update \
    && dnf -y install git ShellCheck dnf-plugins-core \
    && sudo dnf copr enable -y packit/csutils-csdiff-68 \
    && sudo dnf install -y csdiff \
    && dnf clean all

RUN mkdir -p /action
WORKDIR /action

COPY src/index.sh src/functions.sh ./

ENTRYPOINT ["/action/index.sh"]
