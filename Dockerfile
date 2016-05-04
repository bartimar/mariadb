FROM mariadb:latest

# Create fake chown so docker scripts won't fail (ugly)
RUN mv /bin/chown /bin/chown.disabled && echo '#!/bin/bash' > /bin/chown && echo '/bin/chown.disabled "$@"' >> /bin/chown && echo 'exit 0' >> /bin/chown && chmod +x /bin/chown

# multiple entrypoints
COPY ackee-entrypoint.sh /ackee-entrypoint.sh
RUN mv /docker-entrypoint.sh /opt/02-docker-entrypoint.sh && mv /ackee-entrypoint.sh /docker-entrypoint.sh

# switch mysql user to root
RUN sed -i "s/= mysql/= root/g" /etc/mysql/my.cnf
RUN sed -i "s/--user=mysql/--user=root/g" /opt/02-docker-entrypoint.sh

# backups to Amazon S3
RUN apt-get update && apt-get install -y s3cmd && apt-get install -y cron && rm -rf /var/lib/apt/lists/*
COPY s3cfg /root/.s3cfg
COPY mysql-backup.sh /opt/01-mysql-backup.sh
COPY s3-login-validation.sh /opt/03-s3-login-validation.sh

ENV TERM dumb
RUN sed -i 's/#\(bind-address=0.0.0.0\)/\1/' /etc/mysql/my.cnf
