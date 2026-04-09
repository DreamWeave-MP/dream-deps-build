FROM almalinux:8

COPY scripts/install-system-deps.sh /tmp/install-system-deps.sh
RUN bash -e /tmp/install-system-deps.sh && rm /tmp/install-system-deps.sh

COPY . /build
WORKDIR /build

RUN bash -e scripts/setup-vcpkg.sh
RUN bash -e scripts/build-deps.sh

RUN source /opt/rh/gcc-toolset-13/enable \
    && export PATH="/opt/vcpkg:$PATH" \
    && vcpkg export --x-all-installed --7zip --output-dir /out --output vcpkg-x64-linux-dynamic

CMD ["echo", "Output at /out/vcpkg-x64-linux-dynamic.7z"]
