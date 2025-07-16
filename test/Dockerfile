# SPDX-License-Identifier: GPL-3.0-or-later

FROM fedora:42

# --- Version Pinning --- #

ARG fedora="42"
ARG arch="x86_64"

ARG version_csdiff="3.5.5-1"
ARG version_shellcheck="0.10.0-4"

ARG rpm_csdiff="csdiff-${version_csdiff}.fc${fedora}.${arch}.rpm"

ARG rpm_shellcheck="ShellCheck-${version_shellcheck}.fc${fedora}.${arch}.rpm"

# --- Install dependencies --- #

RUN dnf -y upgrade
RUN dnf -y install git git-lfs koji kcov bats diffutils jq sarif-fmt \
    && dnf clean all

# Download rpms from koji
RUN koji download-build --arch ${arch} ${rpm_shellcheck} \
    && koji download-build --arch ${arch} ${rpm_csdiff}

RUN dnf -y install "./${rpm_shellcheck}" "./${rpm_csdiff}" \
    && dnf clean all

ENTRYPOINT [ "/bin/sh", "-c" ]
