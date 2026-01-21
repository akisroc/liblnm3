#!/bin/bash
set -eux;

echo "--- Waiting for database ---"
# --wait attend que Postgres soit prêt
# create crée la base si elle n'existe pas encore
dbmate --wait create

echo "--- Executing migrations ---"
dbmate -d "./migrations" --no-dump up

echo "--- Schema up to date ---"
