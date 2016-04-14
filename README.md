# Backup container for mariadb instances

This image provides a cron daemon that runs daily backups from mysql (clustered or single instance) to Amazon S3.

Following ENV variables must be specified:
 - `MYSQL_URL` contains the whole connection string for mysql command line client
  - `mysqlserver.domain.com:27017` in case of a single instance
 - `MYSQL_ROOT_PASSWORD` password of user `root` who has access to all dbs
 - `S3_URL` contains address in S3 where to store backups
  - `bucket-name/directory`
 - `S3_ACCESS_KEY`
 - `S3_SECRET_KEY`
 - `CRON_SCHEDULE` cron schedule string, default '0 2 * * *'

