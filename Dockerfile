FROM mariadb:latest

# Create fake chown so docker scripts won't fail (ugly)
RUN mv /bin/chown /bin/chown.disabled
COPY chown /bin/chown

# switch mysql user to root
RUN sed -i "s/= mysql/= root/g" /etc/mysql/my.cnf

# volume check
COPY volume-check.sh /docker-entrypoint-initdb.d/volume-check.sh
ENV TERM dumb
