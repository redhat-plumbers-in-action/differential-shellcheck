# SPDX-License-Identifier: GPL-3.0-or-later

FROM fedora@sha256:8285246bd5fad4e76e17a71c88dee34c49e2f227dab4ce7df704b592f8e72d41

# --- Version Pinning --- #

ARG fedora="38"
ARG arch="x86_64"

ARG version_csdiff="3.0.4-1"
ARG version_shellcheck="0.9.0-2"

ARG rpm_csdiff="csdiff-${version_csdiff}.fc${fedora}.${arch}.rpm"

ARG rpm_shellcheck="ShellCheck-${version_shellcheck}.fc${fedora}.${arch}.rpm"

# --- Install dependencies --- #

RUN dnf -y upgrade
RUN dnf -y install git koji jq \
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
