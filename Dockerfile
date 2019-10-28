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
  && echo make rule/setup/alpine \
  && sync

COPY . ${project_dir}
RUN echo "#log: ${project}: Buidling sources" \
  && set -x \
  && make \
  && make install INSTALL_DIR="${install_dir}" \
  && sync

#FROM debian:buster # TODO
FROM golang:1.12-buster
LABEL maintainer "Philippe Coval (p.coval@samsung.com)"
ENV project kubeedge
ENV install_dir /usr/local/opt/${project}
COPY --from=kubeedge-builder ${install_dir} ${install_dir} 
