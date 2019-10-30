#!/bin/echo docker build . -f
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: Apache-2.0
# Copyright: 2019-present Samsung Electronics France SAS, and other contributors

FROM golang:1.12-buster AS kubeedge-builder
LABEL maintainer "Philippe Coval (rzr@users.sf.net)"

ENV project kubeedge
ENV project_dir /usr/local/opt/${project}
ENV src_dir ${project_dir}/src/${project}
ENV pkg_dir ${project_dir}/dist/pkgs

WORKDIR ${src_dir}
COPY debian/rules ${src_dir}/debian/
RUN echo "# log: ${project}: Preparing sources" \
  && set -x \
  && make -f ./debian/rules rule/setup sudo='' \
  && rm -rf /var/cache/apt \
  && ln -fs /usr/local/go/bin/go /usr/bin/ \
  && sync

COPY . ${src_dir}/
RUN echo "# log: ${project}: Building sources" \
  && set -x \
  && go version \
  && make -f debian/rules rule/debuild V=1 \
  && mkdir -p "${pkg_dir}" \
  && cp -av ../*.* "${pkg_dir}/" \
  && sync

FROM golang:1.12-buster
LABEL maintainer "Philippe Coval (rzr@users.sf.net)"

ENV project kubeedge
ENV project_dir /usr/local/opt/${project}
ENV src_dir ${project_dir}/src/${project}
ENV pkg_dir ${project_dir}/dist/pkgs

COPY --from=kubeedge-builder ${pkg_dir} ${pkg_dir}
RUN echo "# log: ${project}: Installing" \
 && set -x \
 && dpkg -i "${pkg_dir}/"*".deb" \
 && sync
