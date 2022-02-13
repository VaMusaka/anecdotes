#!/bin/bash

./src/docker.sh
./src/postgres
./src/db_network_setup.sh
./src/metabase.sh
