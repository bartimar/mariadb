#!/bin/bash
set -eo pipefail

if [ -z "$S3_ACCESS_KEY" -a -z "$S3_SECRET_KEY" -a -z "$S3_BUCKET_DIR" ]; then
	echo >&2 'Backup inforamtion is not complete. You need to specify S3_ACCESS_KEY, S3_SECRET_KEY, S3_BUCKET_DIR. No backups, no fun.'
	exit 1
fi

sed -i "s/%%S3_ACCESS_KEY%%/$S3_ACCESS_KEY/g" /root/.s3cfg
sed -i "s/%%S3_SECRET_KEY%%/$S3_SECRET_KEY/g" /root/.s3cfg

# volume check
vol_path=$(mount | grep nfs4 | cut -d\  -f3)
vol_path=${vol_path%/} # delete trailing slash if any

if [[ "$vol_path" != '/var/lib/mysql' ]] 
then
     echo "ERROR: Volume is not mounted on /var/lib/mysql/"
     echo "Start your container again with /var/lib/mysql/ mounted"
     exit 2
fi


# add cron job
echo '0 2 * * * root mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases --single-transaction --force > /tmp/alldb.sql && s3cmd put /tmp/alldb.sql s3://ackee-backups/$S3_BUCKET_DIR/' >> /etc/crontab
