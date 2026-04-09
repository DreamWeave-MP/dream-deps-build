#!/usr/bin/env bash
set -euo pipefail

dnf install -y epel-release
/usr/bin/crb enable
dnf install -y \
    git \
    tar \
    zip \
    unzip \
    curl \
    gcc-toolset-13 \
    cmake \
    ninja-build \
    python39 \
    perl \
    autoconf \
    autoconf-archive \
    automake \
    libtool \
    nasm \
    pkgconfig \
    mesa-libGL-devel \
    mesa-libEGL-devel \
    libX11-devel \
    libXft-devel \
    libXext-devel \
    libxkbcommon-devel \
    wayland-devel \
    texinfo \
    gettext-devel \
    kernel-headers

alternatives --set python3 /usr/bin/python3.9

# AlmaLinux 8 ships autoconf 2.69, but some vcpkg ports (e.g. gperf) need >= 2.70.
# Install a newer autoconf from source.
AUTOCONF_VER=2.72
if ! /usr/local/bin/autoconf --version 2>/dev/null | head -1 | grep -q "$AUTOCONF_VER"; then
    tmpdir="$(mktemp -d)"
    curl -L "https://ftp.gnu.org/gnu/autoconf/autoconf-${AUTOCONF_VER}.tar.gz" -o "$tmpdir/autoconf.tar.gz"
    tar xf "$tmpdir/autoconf.tar.gz" -C "$tmpdir"
    cd "$tmpdir/autoconf-${AUTOCONF_VER}"
    ./configure --prefix=/usr/local
    make && make install
    rm -rf "$tmpdir"
fi
