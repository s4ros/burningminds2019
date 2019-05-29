#!/usr/bin/env bash

sudo apt update -y -qq
sudo apt upgrade -y -qq
sudo apt dist-upgrade -y -qq
sudo apt install python-minimal curl -y -qq
curl -L get.docker.com | sudo bash
