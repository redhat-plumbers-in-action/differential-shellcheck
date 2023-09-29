# SPDX-License-Identifier: GPL-3.0-or-later

FROM fedora@sha256:6fc00f83a1b6526b1c6562e30f552d109ba8e269259c6742a26efab1b7aef59e

# --- Version Pinning --- #

ARG fedora="38"
ARG arch="x86_64"

ARG version_csdiff="3.0.3-1"
ARG version_shellcheck="0.9.0-2"

ARG rpm_csdiff="csdiff-${version_csdiff}.fc${fedora}.${arch}.rpm"

ARG rpm_shellcheck="ShellCheck-${version_shellcheck}.fc${fedora}.${arch}.rpm"

# --- Install dependencies --- #

RUN dnf -y upgrade
RUN dnf -y install git koji kcov bats diffutils jq \
    && dnf clean all

# Download rpms from koji
RUN koji download-build --arch ${arch} ${rpm_shellcheck} \
    && koji download-build --arch ${arch} ${rpm_csdiff}

RUN dnf -y install "./${rpm_shellcheck}" "./${rpm_csdiff}" \
    && dnf clean all

ENTRYPOINT [ "/bin/sh", "-c" ]
