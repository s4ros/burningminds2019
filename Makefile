export AWS_PROFILE=rnd
all: help

help:
	@echo "+-----------------------------------------+"
	@echo "|  Burning Minds 2019                     |"
	@echo "+-----------------------------------------+"
	@echo " - make update  -- will generate all the terraform and ansible files and apply them"
	@echo " - make play    -- run ansible-playbook and provision the instances"
	@echo " - make destroy -- destroy all EC2 resources"
	@echo " - make hosts   -- prepare Ansible inventory hosts file basing on people.txt file"

update:
	bin/make-ec2-instance-from-template.sh
	cd terraform; terraform apply --auto-approve

hosts:
	bin/prepare-ansible-hosts.sh

play: hosts
	cd ansible; \
	./play burningminds.yml

destroy:
	bin/destroy-all-ec2-resources.sh

gogogo: update hosts play
