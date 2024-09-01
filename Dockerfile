# SPDX-License-Identifier: GPL-3.0-or-later

FROM fedora@sha256:b7b4b222c2a433e831c006a49a397009640cc30e097824410a35b160be4a176b

# --- Version Pinning --- #

ARG fedora="40"
ARG arch="x86_64"

ARG version_csdiff="3.4.0-1"
ARG version_shellcheck="0.9.0-6"

ARG rpm_csdiff="csdiff-${version_csdiff}.fc${fedora}.${arch}.rpm"

ARG rpm_shellcheck="ShellCheck-${version_shellcheck}.fc${fedora}.${arch}.rpm"

# --- Install dependencies --- #

RUN dnf -y upgrade
RUN dnf -y install git koji jq sarif-fmt \
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
