#!/bin/echo docker build . -f
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: Apache-2.0
# Copyright: 2019-present Samsung Electronics France SAS, and other contributors

FROM golang:1.12-buster AS kubeedge-builder
LABEL maintainer "Philippe Coval (p.coval@samsung.com)"

ENV project kubeedge
ENV project_dir /usr/local/opt/${project}
ENV src_dir ${project_dir}/src/${project}
ENV pkg_dir ${project_dir}/dist/pkgs

RUN echo "# log: Setup system" \
  && apt-get update \
  && apt-get install -y \
    make bash git gcc \
  && sync

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
  && go version \
  && make -f debian/rules rule/debuild \
  && mkdir -p "${pkg_dir}" \
  && cp -av ../*.* "${pkg_dir}/" \
  && sync

FROM golang:1.12-buster
LABEL maintainer "Philippe Coval (p.coval@samsung.com)"

ENV project kubeedge
ENV project_dir /usr/local/opt/${project}
ENV src_dir ${project_dir}/src/${project}
ENV pkg_dir ${project_dir}/dist/pkgs

COPY --from=kubeedge-builder ${pkg_dir} ${pkg_dir}
RUN echo "# log: ${project}: Installing" \
 && set -x \
 && dpkg -i "${pkg_dir}/"*".deb" \
 && rm -rfv -- "${pkg_dir}" \
 && sync
