# Bluemix mariadb
## Fixes Bluemix permissions problem
Fixes Docker containers failing on bluemix due to nfs4 root->non-root translation on bluemix Volumes with chown.disabled (see Dockerfile)

## Checks volumes connected to /var/lib/mysql 
If there is no volume connected to that path, the container will fail and stop + prints error (see volumecheck.sh)

##EDIT!
Also fixes the TERM=dumb bug

