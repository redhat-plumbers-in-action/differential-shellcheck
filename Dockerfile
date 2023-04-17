# SPDX-License-Identifier: GPL-3.0-or-later

FROM fedora@sha256:ca620b6a713882989f2dfb31dd34705834c95bc23e493687828080f6e5ad1be6

# --- Version Pinning --- #

ARG fedora="37"
ARG arch="x86_64"

ARG version_csdiff="3.0.0-1"
ARG version_shellcheck="0.8.0-3"

ARG rpm_csdiff="csdiff-${version_csdiff}.fc${fedora}.${arch}.rpm"

ARG rpm_shellcheck="ShellCheck-${version_shellcheck}.fc${fedora}.${arch}.rpm"

# --- Install dependencies --- #

RUN dnf -y upgrade
RUN dnf -y install git koji \
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
