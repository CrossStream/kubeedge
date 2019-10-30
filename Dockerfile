#!/bin/echo docker build . -f
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: Apache-2.0
# Copyright: 2019-present Samsung Electronics France SAS, and other contributors

FROM golang:1.12-buster AS kubeedge-builder
LABEL maintainer "Philippe Coval (p.coval@samsung.com)"

RUN echo "# log: Setup system" \
  && apt-get update \
  && apt-get install -y \
    make bash git gcc \
  && sync

ENV project kubeedge
ENV project_dir /usr/local/opt/${project}
ENV src_dir /usr/local/src/${project}
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
  && make -f ./debian/rules rule/debuild \
  && mkdir -p tmp/debian \
  && cp -rfva debian tmp/ \
  && cp -av ../${project}_* tmp/debian \
  && sync

FROM golang:1.12-buster
LABEL maintainer "Philippe Coval (p.coval@samsung.com)"
ENV project kubeedge
ENV src_dir /usr/local/src/${project}/
COPY --from=kubeedge-builder ${src_dir}/tmp/debian ${src_dir}/tmp/debian/
RUN echo "# log: ${project}: Installing" \
 && set -x \
 && dpkg -I ${src_dir}/tmp/debian/${project}_*.deb \
 && dpkg -i ${src_dir}/tmp/debian/${project}_*.deb \
 && find ${src_dir}/tmp/debian -exec 'rm -vf {}' \; \
 && sync
