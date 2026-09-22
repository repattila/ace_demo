#!/bin/bash

export LICENSE=accept
. /opt/mqm/bin/setmqenv -s
. /opt/ibm/ace-${ACE_VERSION}/server/bin/mqsiprofile

sudo /usr/sbin/sshd

strmqm ${QM_NAME}

runmqsc ${QM_NAME} < /home/mqsi/mqconn.mqsc
runmqsc ${QM_NAME} < /home/mqsi/defineQueues.mqsc

strmqweb

IntegrationServer --work-dir /home/mqsi/ace-server --admin-rest-api 4424 --console-log --http-port-number 7800 --mq-queue-manager-name ${QM_NAME} --name ${ACE_SERVER_NAME} --vault-key ${VAULT_KEY}
