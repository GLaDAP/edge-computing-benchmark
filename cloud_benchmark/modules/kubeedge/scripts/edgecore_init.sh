#!/bin/bash
apt update && apt install -y ansible
gsutil cp -r ${config_bucket_url}/ansible /opt

ansible-playbook /opt/ansible/edge_playbook.yml --extra-vars "bucket_url=${config_bucket_url}"