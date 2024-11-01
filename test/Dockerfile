# SPDX-License-Identifier: GPL-3.0-or-later

FROM fedora@sha256:3ec60eb34fa1a095c0c34dd37cead9fd38afb62612d43892fcf1d3425c32bc1e

# --- Version Pinning --- #

ARG fedora="40"
ARG arch="x86_64"

ARG version_csdiff="3.5.0-1"
ARG version_shellcheck="0.9.0-6"

ARG rpm_csdiff="csdiff-${version_csdiff}.fc${fedora}.${arch}.rpm"

ARG rpm_shellcheck="ShellCheck-${version_shellcheck}.fc${fedora}.${arch}.rpm"

# --- Install dependencies --- #

RUN dnf -y upgrade
RUN dnf -y install git koji kcov bats diffutils jq sarif-fmt \
    && dnf clean all

# Download rpms from koji
RUN koji download-build --arch ${arch} ${rpm_shellcheck} \
    && koji download-build --arch ${arch} ${rpm_csdiff}

RUN dnf -y install "./${rpm_shellcheck}" "./${rpm_csdiff}" \
    && dnf clean all

ENTRYPOINT [ "/bin/sh", "-c" ]
