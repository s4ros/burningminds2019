export AWS_PROFILE=rnd
all: help

help:
	@echo "+-----------------------------------------+"
	@echo "|  Burning Minds 2019                     |"
	@echo "+-----------------------------------------+"
	@echo " - make update  -- will generate all the terraform and ansible files"
	@echo " - make play    -- run ansible-playbook and provision the instances"
	@echo " - make destroy -- destroy all EC2 resources"

update:
	bin/make-ec2-instance-from-template.sh
	cd terraform; terraform apply --auto-approve
	bin/prepare-ansible-hosts.sh

play:
	cd ansible; \
	./play burningminds.yml

destroy:
	bin/destroy-all-ec2-resources.sh

gogogo: update play
