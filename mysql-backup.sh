#!/bin/bash
set -eo pipefail

if [ -z "$S3_ACCESS_KEY" -o -z "$S3_SECRET_KEY" -o -z "$S3_BUCKET_DIR" ]; then
	echo >&2 'Backup information is not complete. You need to specify S3_ACCESS_KEY, S3_SECRET_KEY, S3_BUCKET_DIR. No backups, no fun.'
	exit 1
fi

sed -i "s#%%S3_ACCESS_KEY%%#$S3_ACCESS_KEY#" /root/.s3cfg
sed -i "s#%%S3_SECRET_KEY%%#$S3_SECRET_KEY#" /root/.s3cfg

# add a cron job every hour
echo -e '0 * * * * root mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases --single-transaction --force > /tmp/alldb.sql && s3cmd put /tmp/alldb.sql s3://ackee-backups/$S3_BUCKET_DIR/\n' >> /etc/crontab
crontab /etc/crontab

#start cron
cron -f &
