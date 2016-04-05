#!/bin/bash
#set -eo pipefail

if [ -z "$S3_ACCESS_KEY" -a -z "$S3_SECRET_KEY" -a -z "$S3_BUCKET_DIR" ]; then
	echo >&2 'Backup inforamtion is not complete. You need to specify S3_ACCESS_KEY, S3_SECRET_KEY, S3_BUCKET_DIR. No backups, no fun.'
	exit 1
fi

echo "S3 credentials set well."

mkdir -p /root/.aws/
touch /root/.aws/config /root/.aws/credentials

echo "[default]
region=eu-west-1
output=json
" > /root/.aws/config

echo "[default]
aws_access_key_id=$S3_ACCESS_KEY
aws_secret_access_key=$S3_SECRET_KEY
" > /root/.aws/credentials

echo "Aws credentials set"

# Create user and obtain API access key for him
# Username is based on the container ID
#USER="bku-${uuid:0:8}"
USER=$S3_BUCKET_DIR
aws iam create-user --user-name "$USER"
echo  "AWS IAM user $USER successfully created."
aws iam create-access-key --user-name "$USER" >new_access_key
echo  "AWS IAM user's access and secret keys successfully obtained." 

# Parse the new user's credentials
NEW_ACCESS_KEY=$(awk -F\" '$2 ~ /^AccessKeyId$/ {print $4}' new_access_key)
NEW_SECRET_KEY=$(awk -F\" '$2 ~ /^SecretAccessKey$/ {print $4}' new_access_key)
echo "AWS IAM user's keys successfully parsed."

sed -i "s/%%S3_ACCESS_KEY%%/$S3_ACCESS_KEY/" policy.json
sed -i "s/%%USER%%/$USER/" policy.json
sed -i "s/%%S3_BUCKET_DIR%%/$S3_BUCKET_DIR/" policy.json

aws iam put-user-policy --user-name "$USER" --policy-name policy"$USER" --policy-document file://policy.json

if [ -z $DEBUG ]
then
	# Replace the old credentials in the aws config
	sed -i "s#$S3_ACCESS_KEY#$NEW_ACCESS_KEY#" /root/.aws/credentials
	sed -i "s#$S3_SECRET_KEY#$NEW_SECRET_KEY#" /root/.aws/credentials
	echo  "AWS credentials config file successfully updated."

	# Set new ENV variables
	export S3_ACCESS_KEY="$NEW_ACCESS_KEY"
	export S3_SECRET_KEY="$NEW_SECRET_KEY"
	echo  "New AWS Credentials ENV variables successfully updated."
fi

DUMP_FILE=dump$(date '+%y%m%d_%H%M').sql
touch $DUMP_FILE
#mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --all-databases > "$DUMP_FILE"

aws s3 cp "$DUMP_FILE" s3://ack-staticfiles/$S3_BUCKET_DIR/

aws s3 ls s3://ack-staticfiles/$S3_BUCKET_DIR/

