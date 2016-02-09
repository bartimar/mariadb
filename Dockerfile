FROM mariadb:latest

# Create fake chown
RUN mv /bin/chown /bin/chown.disabled
RUN echo '#!/bin/bash' > /bin/chown
RUN echo '/bin/chown.disabled "$@"' >> /bin/chown
RUN echo 'exit 0' >> /bin/chown
RUN chmod +x /bin/chown

# switch user to root
RUN sed -i "s/= mysql/= root/g" /etc/mysql/my.cnf
RUN sed -i "s/--user=mysql/--user=root/g" /docker-entrypoint.sh
