# Copyright © 2023 OpenIM. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# OpenIM base image: https://github.com/openim-sigs/openim-base-image

# Set go mod installation source and proxy

FROM golang:1.23 AS builder

ARG GO111MODULE=on

WORKDIR /openim/openim-server

ENV GO111MODULE=$GO111MODULE
ENV GOPROXY=$GOPROXY
RUN go install github.com/magefile/mage@latest

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN mage build

RUN mkdir ./bin/

RUN cp /openim/openim-server/_output/bin/platforms/$(go env GOOS)/$(go env GOARCH)/* ./bin/

FROM ghcr.io/openim-sigs/openim-bash-image:latest

WORKDIR /openim/openim-server

COPY --from=builder /openim/openim-server/bin/openim-api /usr/bin/openim-api
COPY --from=builder /openim/openim-server/bin/openim-cmdutils /usr/bin/openim-cmdutils
COPY --from=builder /openim/openim-server/bin/openim-crontask /usr/bin/openim-crontask
COPY --from=builder /openim/openim-server/bin/openim-msggateway /usr/bin/openim-msggateway
COPY --from=builder /openim/openim-server/bin/openim-msgtransfer /usr/bin/openim-msgtransfer
COPY --from=builder /openim/openim-server/bin/openim-push /usr/bin/openim-push
COPY --from=builder /openim/openim-server/bin/openim-rpc-auth /usr/bin/openim-rpc-auth
COPY --from=builder /openim/openim-server/bin/openim-rpc-conversation /usr/bin/openim-rpc-conversation
COPY --from=builder /openim/openim-server/bin/openim-rpc-friend /usr/bin/openim-rpc-friend
COPY --from=builder /openim/openim-server/bin/openim-rpc-group /usr/bin/openim-rpc-group
COPY --from=builder /openim/openim-server/bin/openim-rpc-msg /usr/bin/openim-rpc-msg
COPY --from=builder /openim/openim-server/bin/openim-rpc-third /usr/bin/openim-rpc-third
COPY --from=builder /openim/openim-server/bin/openim-rpc-user /usr/bin/openim-rpc-user

COPY --from=builder /openim/openim-server/config /openim/openim-server/config
COPY --from=builder /openim/openim-server/_output/bin/tools /openim/openim-server/tools/

