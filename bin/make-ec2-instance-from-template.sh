#!/bin/bash

EC2_TEMPLATE=terraform/_ec2-instance.tf.template
DEST=terraform
PEOPLE=people.txt

for person in $(cat ${PEOPLE}); do
  cat ${EC2_TEMPLATE} | sed "s/NETGURU_USERNAME/${person}/g" | \
    sed "s/NETGURU_INSTANCE_NAME/${person}/g"> ${DEST}/ec2-${person}.tf
done
