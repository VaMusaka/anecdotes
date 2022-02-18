#!/bin/bash

./src/docker.sh
./src/postgres.sh
./src/db_network_setup.sh
./src/metabase.sh
