# Lightly Sail Metabase in 10 minutes

## Prerequisites 
- AWS Lightsail
- Docker
- PostgresSQL
- MongoDB


> I have searched the internet for a simple (Open Source) Analytics Platform that can be integrated with a many data sources and MongoDb in particular. Another important use case was interactivity and embedded analytics. I found Metabase to tick all the boxes and their pricing and open source offering made this even more attractive. 

> Having played around with docker (knowing just enough to be dangerous) I decided to test metabase and look around using a local version and it because apparent to me that l needed a production version to not lose any of the work i had done while exploring. 

> Although the tutorials for [Deploying new version of Metabase on Elastic Beanstalk](https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-elastic-beanstalk.html) was is very extensive and a good place to start, however, i decided to go a different direction. My ultimate goal was to run Metabase on a simple aws lightsail instance as a docker container and below are the steps of how l did it. 


1. Create an AWS Account
   
   Got to [AWS Console](aws.amazon.com) and create an account if you do not already have one. As a new user Amazon provides a free tier where you can create some resources for free without paying anything for the first year from the day you create an account. 

2. Create an AWS Lightsail instance
   
    Once you account is ready head over to the [Amazon Lightsail](https://lightsail.aws.amazon.com/). 

    - On the lightsail page create a new instance by clicking the **Create Instance** button. 
 
    ![Lightsail](./img/lightsail.png)

    - Choose the instance location closest to you.
    - Pick your instance image 
      - Select platform **Linux/Unix**
      - Select a blueprint **Ubuntu 20.04 LTS**
        - create an ssh key if you do not already have one
    - Choose your instance plan
      - To get started l would recommend selecting the `2gb Ram, 1vCPU, 60gb SSD` instance. *(at the time of this article amazon are offering First 3 months free! on this instance size)* 
    - Identify your instance
      - Give your resource a unique name. 
  
    - Once you are happy with your settings **create instance**


> **NOTE:** In this repository is an `install.sh`  which will take care of all the steps described below with additional configurations. This script will install docker, PostgresQL, setup the database user and enable docker access to the database as well as install and run the Metabase container. To install with this method simple run `sudo ./install.sh`. Follow any instructions whenever prompted for input, alternatively, follow the steps below to install and configure each component on its own. 


1. Install Docker 
   - Connect to your instance via ssh 
   - Follow instructions to [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/).
   - The same steps are described in the `src/docker.sh` file. To install docker using this file simply run `sudo ./src/docker.sh`. This will remove any existing docker versions currently installed on your machine if any and install the latest version through the docker recommended install process. Once the install is finish this will also verify by running the `docker run hello-world` which will confirm that docker is installed. 


2. Install PostgreSQL 
   - Having run into a few issues after attempting to  upgrade the Metabase version on Docker and loosing the work l had done recommend using PostgreSQL to store your Metabase data. 
   - To install this follow instructions on [How To Install PostgreSQL on Ubuntu 20.04 [Quick Start]](https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart)
   - The same steps to install PostgreSQL are described in the `src/postgres.sh` file. To install PostgreSQL using this file simply run `sudo ./src/postgres.sh`. This will install the latest version of PostgreSQL.
  
3. Setup DB User and Network Access
   > ***NOTE*** - Steps below can be achieved by also running the supplied `sudo ./src/db_network_setup.sh`. 
     - Now for the tricky part. Since the main purpose of using a Lightsail/EC2 instance to run Metabase is to have the database as well as the docker container on the same machine.    
     - The installed version of PostgresQL will by default not have access to listen on any address other than `localhost`. 
     - This will need to be changed to allow PostgreSQL to on any address by modifying the `/etc/postgresql/<version>/main/postgresql.conf` by updating the following line:
         ```
         #listen_addresses = 'localhost'
         ```
         to:  
         ```
         listen_addresses = '*'
         ```
     -   In addition to this, you will need to setup PostgresQL to be accessible from docker. When running a container Docker will assign an IP to a container from the range `172.17.0.1/16`, to allow connections to Postgres from this range of addresses modify the `/etc/postgresql/<version>/main/pg_hba.conf` by adding the following line if does not already exist. 
         ```
         host  all   all   172.17.0.1/16  trust
         ```

4. Install Metabase
   - Once you have Docker and PostgreSQL installed its now time to get Metabase running.
   - From the [Running Metabase on Docker](https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html) instructions follow the instructions on **Using Postgres as the Metabase application database** 
   - Before running the Metabase container we will need to setup a PostgreSQL user and password for metabase to use to connect. 
   - The file `/src/metabase.sh` will help to create the user and password as well as run the Metabase docker container to get this . 
   - Alternatively you can follow the steps below to setup the PostgreSQL account and run the Metabase Docker container. 

      - Create the PostgreSQL account.

         ```
         sudo -u postgres psql -c "CREATE USER <username> WITH PASSWORD <password>"
         ``` 
      
      - Set the account as a Superadmin

         ```
         sudo -u postgres psql -c "ALTER GROUP Superuser ADD USER <username>"
         ```  

      - Run the 

         ```
         sudo docker run -d -p 80:3000 \
            --add-host host.docker.internal:host-gateway \
            -e "MB_DB_TYPE=postgres" \
            -e "MB_DB_DBNAME=metabase" \
            -e "MB_DB_PORT=5432" \
            -e "MB_DB_USER=<username>" \
            -e "MB_DB_PASS=<password>" \
            -e "MB_DB_HOST=<host_private_ip>" \
            --name metabase metabase/metabase
         ``` 
      
       - To check the progress you can check the progress by checking the logs every couple of seconds 
         ```
            docker logs metabase
         ``` 
     - Once complete the logs should show the message below 
      ![Confirmed Install](./img/cornfirm_docker_setup.png)

5. Finally using your lightsail's IP Address confirm that metabase is up and running from your browser http://{IP}/setup. If everything is set up correctly page should show a metabase welcome message as shown below. 
   
![Welcome Page](./img/metabase_welcome.png)
