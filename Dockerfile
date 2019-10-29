FROM golang:1.12-buster AS kubeedge-builder
LABEL maintainer "Philippe Coval (p.coval@samsung.com)"
ENV project kubeedge
ENV project_dir /usr/local/opt/${project}
ENV src_dir /usr/local/src/${project}

RUN echo "# log: Setup system" \
  && apt-get update \
  && apt-get install -y \
    make bash git gcc \
  && sync

COPY Makefile ${src_dir}/
WORKDIR ${src_dir}
RUN echo "# log: ${project}: Preparing sources" \
  && set -x \
  && apt-get update  \
  && apt-get install -y \
     devscripts \
  && ln -fs /usr/local/go/bin/go /usr/bin/ \
  && sync

COPY . ${src_dir}/
RUN echo "# log: ${project}: Buidling sources" \
  && set -x \
  && git archive HEAD .  | xz - > ../kubeedge_0.0.0.orig.tar.xz \
  && make -f ./debian/rules rule/dist \
  && debuild -S || { echo 'TODO' | dpkg-source --commit ; } ||: \
  && mkdir -p debian/patches \
  && cp -av /tmp/${project}_* debian/patches/TODO.patch \
  && echo TODO.patch > debian/patches/serie \
  && debuild -S -uc -us \  
  && debuild -uc -us \
  && mkdir -p tmp/debian \
  && cp -av ../${project}_* tmp/debian \
  && make install INSTALL_DIR="${project_dir}" \
  && sync

FROM debian:buster
LABEL maintainer "Philippe Coval (p.coval@samsung.com)"
ENV project kubeedge
ENV project_dir /usr/local/opt/${project}
ENV src_dir /usr/local/src/${project}
COPY --from=kubeedge-builder ${project_dir}/ ${project_dir}/

# TODO
ENV src_dir /usr/local/src/${project}/
COPY --from=kubeedge-builder ${src_dir}/tmp/debian ${src_dir}/tmp/debian/
RUN echo "# log: ${project}: Installing" \
 && set -x \
 && dpkg -i ${src_dir}/tmp/debian/${project}_*.deb \
 && echo "TODO: remove files" \
 && find ${src_dir}/tmp/debian -exec echo 'rm {} # TODO' \; \
 && sync
 