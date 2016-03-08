#!/bin/bash
set -eo pipefail

if [ -z "$S3_ACCESS_KEY" -a -z "$S3_SECRET_KEY" -a -z "$S3_BUCKET_DIR" ]; then
	echo >&2 'Backup inforamtion is not complete. You need to specify S3_ACCESS_KEY, S3_SECRET_KEY, S3_BUCKET_DIR. No backups, no fun.'
	exit 1
fi

sed -i "s/%%S3_ACCESS_KEY%%/$S3_ACCESS_KEY/g" /root/.s3cfg
sed -i "s/%%S3_SECRET_KEY%%/$S3_SECRET_KEY/g" /root/.s3cfg

/volume-check.sh

# export ENV variables for crontab
echo "S3_ACCESS_KEY=$S3_ACCESS_KEY" >> /etc/crontab
echo "S3_SECRET_KEY=$S3_SECRET_KEY" >> /etc/crontab
echo "S3_BUCKET_DIR=$S3_BUCKET_DIR" >> /etc/crontab
echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" >> /etc/crontab

# add a cron job every hour
echo -e '0 * * * * root mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases --single-transaction --force > /tmp/alldb.sql && s3cmd put /tmp/alldb.sql s3://ackee-backups/$S3_BUCKET_DIR/\n' >> /etc/crontab
crontab /etc/crontab

#start cron
cron -f &
