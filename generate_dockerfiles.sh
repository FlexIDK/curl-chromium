#!/bin/sh

BASEDIR=$(dirname "$0")

cd ${BASEDIR}

cat <<EOF | mustache - Dockerfile.template > docker/ubuntu24/Dockerfile
---
ubuntu: true
ubuntu24: true
---
EOF
cat <<EOF | mustache - Dockerfile.template > docker/ubuntu20/Dockerfile
---
ubuntu: true
ubuntu20: true
---
EOF
cat <<EOF | mustache - Dockerfile.template > docker/alpine/Dockerfile
---
alpine: true
---
EOF