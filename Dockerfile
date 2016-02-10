FROM mariadb:latest

# Create fake chown so docker scripts won't fail (ugly)
RUN mv /bin/chown /bin/chown.disabled && echo '#!/bin/bash' > /bin/chown && echo '/bin/chown.disabled "$@"' >> /bin/chown && echo 'exit 0' >> /bin/chown && chmod +x /bin/chown

# switch mysql user to root
RUN sed -i "s/= mysql/= root/g" /etc/mysql/my.cnf
RUN sed -i "s/--user=mysql/--user=root/g" /docker-entrypoint.sh

# backups
# install s3cmd
RUN apt-get update && apt-get install -y s3cmd && rm -rf /var/lib/apt/lists/*
COPY s3cfg /root/.s3cfg
COPY mysql-backup.sh /
ENTRYPOINT ["/mysql-backup.sh"]
