#!/usr/bin/env bash

TERRAFORM=terraform
ANSIBLE=ansible



pushd ${TERRAFORM}
  terraform output | grep fqdn | awk '{print $3}' > ../${ANSIBLE}/inventory/hosts
popd
