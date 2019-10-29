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
COPY . ${src_dir}/

RUN echo "# log: ${project}: Buidling sources" \
  && set -x \
  && go version \
  && make V=1 \
  && make install INSTALL_DIR="${project_dir}" V=1 \
  && sync

FROM debian:buster
LABEL maintainer "Philippe Coval (p.coval@samsung.com)"
ENV project kubeedge
ENV project_dir /usr/local/opt/${project}
COPY --from=kubeedge-builder ${project_dir}/ ${project_dir}/
