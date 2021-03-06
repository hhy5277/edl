#!/bin/bash

# Copyright (c) 2020 PaddlePaddle Authors. All Rights Reserved.
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

unset https_proxy http_proxy

version_str=$(python --version 2>&1)
if [[ ${version_str} > "Python 3" ]]; then
    echo "fix me under Python 3"
    exit 0
fi

nohup etcd > test_distill_reader_etcd.log  2>&1 &
etcd_pid=$!

# wait etcd start
sleep 10

nohup python -m edl.discovery.register --service_name DistillReaderTest --server 127.0.0.1:2379 > run_discovery_register.log 2>&1 &
register_pid=$!

nohup python -m edl.distill.discovery_server > run_discovery_server.log 2>&1 &
discovery_pid=$!

# wait discovery start
sleep 5

export PADDLE_DISTILL_BALANCE_TYPE=etcd

export PADDLE_DISTILL_BALANCE_SERVER=127.0.0.1:7001
export PADDLE_DISTILL_SERVICE_NAME=DistillReaderTest
export PADDLE_DISTILL_MAX_TEACHER=4
python distill_reader_test.py

kill -9 $discovery_pid $register_pid $etcd_pid
