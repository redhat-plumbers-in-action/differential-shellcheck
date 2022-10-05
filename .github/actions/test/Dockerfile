FROM fedora:36

RUN dnf -y update \
    && dnf -y install git kcov bats \
    && dnf clean all
