# SPDX-License-Identifier: GPL-3.0-or-later

FROM fedora:41@sha256:f84a7b765ce09163d11de44452a4b56c1b2f5571b6f640b3b973c6afc4e63212

# --- Version Pinning --- #

ARG fedora="41"
ARG arch="x86_64"

ARG version_csdiff="3.5.2-1"
ARG version_shellcheck="0.10.0-3"

ARG rpm_csdiff="csdiff-${version_csdiff}.fc${fedora}.${arch}.rpm"

ARG rpm_shellcheck="ShellCheck-${version_shellcheck}.fc${fedora}.${arch}.rpm"

# --- Install dependencies --- #

RUN dnf -y upgrade
RUN dnf -y install git git-lfs koji jq sarif-fmt \
    && dnf clean all

# Download rpms from koji
RUN koji download-build --arch ${arch} ${rpm_shellcheck} \
    && koji download-build --arch ${arch} ${rpm_csdiff}

RUN dnf -y install "./${rpm_shellcheck}" "./${rpm_csdiff}" \
    && dnf clean all

# --- Setup --- #

RUN mkdir -p /action
WORKDIR /action

COPY src/* ./

ENTRYPOINT ["/action/index.sh"]
