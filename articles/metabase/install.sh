#!/bin/bash

./src/docker.sh
./src/postgres.sh
./src/db_setup.sh
./src/metabase.sh
