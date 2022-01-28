FROM fedora:rawhide

RUN dnf -y update
RUN dnf -y install csdiff git ShellCheck

RUN mkdir -p /action
WORKDIR /action

COPY src/check-shell.sh src/functions.sh ./

ENTRYPOINT ["/action/check-shell.sh"]
