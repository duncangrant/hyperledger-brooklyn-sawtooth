#!/bin/bash
# Copyright 2018 by Blockchain Technology Partners
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#set -x # DEBUG

##
# Gets the current status of a running Brooklyn Sawtooth application.
#
# Usage: status.sh [application-name [server-node-name]]
##

APP=${1:-sawtooth-platform-application}
NODE=${2:-sawtooth-platform-server-node}

# get sensor data
host_address=$(br app ${APP} entity ${NODE} sensor host.address)
seth_account=$(br app ${APP} entity ${NODE} sensor sawtooth.seth.account)
administrator_id=$(br app ${APP} entity ${NODE} sensor sawtooth.next-directory.administrator.id)

# output json data
cat <<EOF
{
  "host.address": "${host_address}",
  "seth.account": "${seth_account}",
  "administrator.id": "${administrator_id}",
  "links": {
EOF

# output links
eol="," i=0 svcs=(
  grafana rest-api seth-rpc next-directory-api next-directory-ui rethinkdb explorer
)
while (( i < ${#svcs[@]} )) ; do
  svc=${svcs[$i]}
  uri=$(br app ${APP} entity ${NODE} sensor sawtooth.${svc}.uri)
  if (( ++i >= ${#svcs[@]} )) ; then
    eol=""
  fi
  echo "    \"${svc}.uri\": \"${uri}\"${eol}"
done

cat <<EOF
  }
}
EOF
