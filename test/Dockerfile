# SPDX-License-Identifier: GPL-3.0-or-later

FROM fedora@sha256:61f921e0c7b51e162e6f94b14ef4e6b0d38eac5987286fe4f52a2c1158cc2399

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
