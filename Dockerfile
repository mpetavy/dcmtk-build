FROM debian:bookworm-slim AS builder

ARG CMAKE_OPTIONS=\
	-DDCMTK_ENABLE_PRIVATE_TAGS:BOOL=TRUE \
	-DDCMTK_LINK_STATIC:BOOL=TRUE \
#	-DDCMTK_PORTABLE_LINUX_BINARIES:BOOL=TRUE \
	-DBUILD_SHARED_LIBS:BOOL=FALSE \
	-DCMAKE_EXE_LINKER_FLAGS="-static"

RUN apt update -y \
&& apt upgrade -y

RUN apt install \
autoconf \
automake \
bc \
build-essential \
cmake zlib1g-dev \
cmake-curses-gui \
fftw-dev \
gtk-doc-tools \
libarchive-dev \
libexif-dev \
libgdk-pixbuf2.0-dev \
libghc-persistent-sqlite-dev \
libgif-dev \
libglib2.0-dev \
libgsf-1-dev \
libjpeg-dev \
libjpeg62-turbo-dev \
liblcms2-dev \
libopenexr-dev \
libopenjp2-7-dev \
libpng-dev \
libpoppler-dev \
librsvg2-dev \
libssl-dev \
libtiff-dev \
libtool \
libwebp-dev \
libxml2-dev \
wget \
zlib1g-dev \
zip \
-y

RUN wget --no-check-certificate https://dicom.offis.de/download/dcmtk/dcmtk369/dcmtk-3.6.9.tar.gz -O dcmtk-3.6.9.tar.gz \
&& tar -xzf dcmtk-3.6.9.tar.gz \
&& mkdir dcmtk-3.6.9-install \
&& mkdir dcmtk-3.6.9-build \
&& cd dcmtk-3.6.9-build \
&& cmake $CMAKE_OPTIONS ../dcmtk-3.6.9 \
&& make -j8 \
&& make DESTDIR=../dcmtk-3.6.9-install install \
&& zip -r /dcmtk.zip /dcmtk-3.6.9-install/

FROM debian:bookworm-slim

RUN apt update -y \
&& apt upgrade -y

RUN apt install \
libtiff-dev \
libpng-dev \
libssl-dev \
libxml2-dev \
-y

COPY --from=builder /dcmtk-3.6.9-install /

# copy the ZIP content to the host
# docker create dcmtk
# docker create <container id>:/dcmtk.zip .

COPY --from=builder /dcmtk.zip /

ENTRYPOINT ["bash"]
