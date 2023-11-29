# SPDX-License-Identifier: GPL-3.0-or-later

FROM fedora@sha256:06df381d697d14940c886fda8e94a4fdc838df74e93f65111ed3ea04f7a7d6e0

# --- Version Pinning --- #

ARG fedora="39"
ARG arch="x86_64"

ARG version_csdiff="3.0.4-1"
ARG version_shellcheck="0.9.0-4"

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
