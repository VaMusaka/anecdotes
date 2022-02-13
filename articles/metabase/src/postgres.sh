#!/bin/bash

#
# Create the file repository configuration:
#
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

#
# Import the repository signing key:
#
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

#
# To install PostgreSQL, first refresh your server’s local package index:
#
sudo apt update

#
# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
#
sudo apt install -y postgresql postgresql-contrib
