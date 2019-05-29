#!/usr/bin/env bash

pushd terraform
find ./ -type f -iname "ec2-*.tf" | while read -r line; do
  USERNAME=$(echo ${line} | cut -d '-' -f 2 | cut -d '.' -f 1)
  RESOURCE="aws_instance.${USERNAME}"
  echo -n " -target=${RESOURCE}" | tee -a /tmp/.terraform.swp
done

RESOURCES=$(cat /tmp/.terraform.swp)
rm -f /tmp/.terraform.swp
terraform destroy --auto-approve ${RESOURCES}
