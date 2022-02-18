#!/bin/bash 

#
# Create a new user and set password
#
echo Enter username: 
read username

echo Enter password: 
read password

ip=$(hostname -I | grep -o "^[0-9.]*")

sudo -u postgres psql -c "CREATE USER $username WITH PASSWORD '$password'"

#
# Add user to super user group
#
sudo -u postgres psql -c "ALTER USER $username WITH SUPERUSER"

sudo -u postgres psql-tc "SELECT 1 FROM pg_database WHERE datname = 'metabase'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE metabase WITH OWNER $username"

#
# Start Metabase contected to the database
#
sudo docker run -d -p 80:3000 \
      --add-host host.docker.internal:host-gateway \
      -e "MB_DB_TYPE=postgres" \
      -e "MB_DB_DBNAME=metabase" \
      -e "MB_DB_PORT=5432" \
      -e "MB_DB_USER=$username" \
      -e "MB_DB_PASS=$password" \
      -e "MB_DB_HOST=$ip" \
      --name metabase metabase/metabase

#
# Check for progress every 6 seconds for 1 minute
#
for counter in {1..10};
      do
            sudo docker logs metabase
            sleep 6
      done