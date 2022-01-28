FROM fedora:rawhide

RUN dnf -y update
RUN dnf -y install csdiff git ShellCheck

RUN mkdir -p /action
WORKDIR /action

COPY .github/.diff-shellcheck-exceptions.txt .github/.diff-shellcheck-scripts.txt ./
COPY src/check-shell.sh src/functions.sh ./

ENTRYPOINT ["/action/check-shell.sh"]
