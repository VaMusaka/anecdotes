#!/bin/bash

#
# Go to the postgres db directory 
#
cd /etc/postgresql 

#
# check installed versions of postgress
#
installed_versions_count=ls | wc -l 
installed_version_dir=null
 
if [[ $installed_versions_count -eq 0 ]]
then
    installed_version_dir=$(ls -1t|head -n 1)
else
    echo "Please select version option [x] from the list"

    files=$(ls -d *)
    count=1

    for file in $files
    do
        echo "[$count]: $file"
        files[count]=$file
        count=$(( count + 1 ))
    done

#
# ask user to select version to modify
#

    echo "Enter version option"
    read version
    echo "Updating version ${files[$version]}"
    installed_version_dir=${files[$version]}
fi

echo $installed_version_dir
cd $installed_version_dir/main

#
# Set up postgress to be accessible from docker.
#
sudo echo "host     all     all     172.17.0.1/16       trust" >>  pg_hba.conf
sudo echo "host     all     all     0.0.0.0/32          trust" >>  pg_hba.conf


#
# Allow Postgres to listen to all addresses not just localhost
#
search_comment="#listen_addresses = 'localhost'"
search="listen_addresses = 'localhost'"
replace="listen_addresses = '*'"
config_file="postgresql.conf"

if [[ $search_comment != "" && $replace != "" ]]
then
    sudo sed -i "s/$search_comment/$replace/" $config_file
elif  [[ $search != "" && $replace != "" ]] 
then
    sudo sed -i "s/$search/$replace/" $config_file
fi

#
# Restart postgres
#
sudo systemctl restart postgresql
