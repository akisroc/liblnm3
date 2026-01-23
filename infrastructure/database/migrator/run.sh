#!/bin/bash

set -eux;

if [ "$#" -gt 0 ]; then
    exec "$@"
fi

echo "--- Waiting for database ---"
dbmate --wait --no-dump -d up

echo "--- Schema up to date ---"
