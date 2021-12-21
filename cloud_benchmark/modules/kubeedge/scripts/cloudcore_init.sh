#!/bin/bash

gsutil cp -r ${config_bucket_url}/ansible /opt

ansible-playbook /opt/ansible/cloudcore_install.yml --extra-vars "bucket_url=${config_bucket_url}"
sleep 30
ansible-playbook /opt/ansible/controller_startup.yml --extra-vars "bucket_url=${config_bucket_url}"
