FROM golang:1.12-buster AS kubeedge-builder
LABEL maintainer "Philippe Coval (p.coval@samsung.com)"
ENV project kubeedge
ENV project_dir /usr/local/src/${project}/
ENV install_dir /usr/local/opt/${project}/

RUN echo "#log: Setup system" \
  && apt-get update \
  && apt-get install -y \
    make sudo bash git gcc \
  && sync

COPY Makefile ${project_dir}
WORKDIR ${project_dir}
RUN echo "#log: ${project}: Preparing sources" \
  && set -x \
  && sudo apt-get update  \
  && sudo apt-get install -y \
     devscripts \
  && ln -fs /usr/local/go/bin/go /usr/bin/ \
  && sync

COPY . ${project_dir}
RUN echo "#log: ${project}: Buidling sources" \
  && set -x \
  && git archive HEAD .  | xz - > ../kubeedge_0.0.0.orig.tar.xz \
  && debuild -S \
  && debuild \
  && mkdir -p tmp/out/debian \
  && cp -av ../${project}_ tmp/out/debian \
  && make install INSTALL_DIR="${install_dir}" \
  && sync

  FROM debian:buster
LABEL maintainer "Philippe Coval (p.coval@samsung.com)"
ENV project kubeedge
ENV install_dir /usr/local/opt/${project}
COPY --from=kubeedge-builder ${install_dir} ${install_dir} 
