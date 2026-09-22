# Build and run:
#
# podman build -t ace:13.0.6.0 --progress=plain -f Dockerfile . 2> build.log
# podman run --network acenet --name DEV-ACE_13 -p 7800:7800/tcp -p 4424:4424/tcp -p 1414:1414/tcp -p 9443:9443/tcp -p 12345:12345/tcp -p 10022:22/tcp -v mqsidata13:/home/mqsi -v devnodedata13:/opt/DEVNODE -v mqmdata13:/var/mqm -dt localhost/ace:13.0.6.0
#

FROM ubuntu:24.04

ENV ACE_VERSION=13.0.6.0
ARG HOST_IP=192.168.88.170
ARG ACE_FILE_NAME=IBM_ACE_${ACE_VERSION}_LNX_X8664_INCTK.tar.gz
ARG ACE_URL=http://${HOST_IP}/${ACE_FILE_NAME}
ARG MQ_URL=http://${HOST_IP}/9.4.4.0-IBM-MQ-Advanced-for-Developers-UbuntuLinuxX64.tar.gz
ARG DB_STANZA=ORACLEDB DB_USER=xe DB_PASS=pass123

ENV ODBCINI=/home/mqsi/odbc/odbc.ini ODBCSYSINI=/home/mqsi/odbc ACE_SERVER_NAME=DEVSERVER QM_NAME=DEVQM VAULT_KEY=passs1234

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y curl less net-tools ncat sudo openssh-server vim dos2unix

# Set up configuration for SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

# Install MQ
RUN mkdir -p /tmp/mq \
    && cd /tmp/mq \
    && curl --fail --location $MQ_URL | tar --extract --gunzip \
    && cd /tmp/mq/MQServer \
    && groupadd mqm \
    && useradd --uid 1001 --create-home --home-dir /home/mqm --shell /bin/bash -g mqm mqm \
    && ./mqlicense.sh -text_only -accept \
    && echo "deb [trusted=yes] file:/tmp/mq/MQServer ./" > /etc/apt/sources.list.d/ibmmq-install.list \
    && apt update \
    && apt install ibmmq-runtime ibmmq-java ibmmq-jre ibmmq-gskit ibmmq-server ibmmq-man ibmmq-samples ibmmq-sdk ibmmq-web \
    && /opt/mqm/bin/setmqinst -p /opt/mqm -i \
    && rm -rf /etc/apt/sources.list.d/ibmmq-install.list \
    && rm -rf /tmp/mq

COPY conf/mqwebuser.xml /var/mqm/web/installations/Installation1/servers/mqweb/

# Install ACE
RUN mkdir -p /opt/ibm \
    && cd /opt/ibm \
    && curl --fail --location $ACE_URL | tar --extract --gunzip \
    && /opt/ibm/ace-${ACE_VERSION}/ace make registry global accept license deferred \
    && useradd --uid 1002 --create-home --home-dir /home/mqsi --shell /bin/bash -G mqbrkrs,mqm mqsi \
    && echo 'mqsi:mqsi' | chpasswd \
    && echo "export LICENSE=accept" >> /home/mqsi/.profile \
    && echo ". /opt/ibm/ace-${ACE_VERSION}/server/bin/mqsiprofile" >> /home/mqsi/.profile

# Enable sudo for the mqsi user
RUN echo "mqsi ALL=(ALL:ALL) ALL" > /etc/sudoers.d/mqsi \
    && echo "mqsi ALL = (root) NOPASSWD: /usr/sbin/sshd" >> /etc/sudoers.d/mqsi

# Create QM
RUN su - mqsi -c "crtmqm -q -u DLQ -p 1414 ${QM_NAME}" \
    && su - mqsi -c "setmqweb properties -k httpHost -v '*'"

# Create Integration Server work directory
RUN su - mqsi -c "mqsicreateworkdir /home/mqsi/ace-server" \
    && su - mqsi -c "mqsivault --work-dir /home/mqsi/ace-server --create --vault-key ${VAULT_KEY}" \
    && su - mqsi -c "mqsicredentials --work-dir /home/mqsi/ace-server --create --credential-type odbc --credential-name ${DB_STANZA} --username ${DB_USER} --password ${DB_PASS} --vault-key ${VAULT_KEY}" \
    && su - mqsi -c "mqsicredentials --work-dir /home/mqsi/ace-server --create --credential-type local --credential-name UserServiceAuthAlias --username test --password test --vault-key ${VAULT_KEY}"

COPY conf/mqconn.mqsc conf/defineQueues.mqsc /home/mqsi/
COPY conf/odbc.ini conf/odbcinst.ini /home/mqsi/odbc/
COPY conf/server.conf.yaml /home/mqsi/ace-server/overrides/

RUN chown -R mqsi:mqbrkrs /home/mqsi/odbc \
    && chmod 770 /home/mqsi/odbc

COPY entrypoint.sh /usr/local/bin/

RUN chown 1002:root /usr/local/bin/entrypoint.sh \
    && chmod 750 /usr/local/bin/entrypoint.sh \
    && dos2unix /usr/local/bin/entrypoint.sh

# User mqsi
USER 1002

# Expose ports: 7800, 7843, 4424, 12345 for ACE and 1414 9157 9443 for MQ and 22 for SSH
EXPOSE 7800 7843 4424 12345 1414 9157 9443 22

# Set entrypoint to run the server
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
