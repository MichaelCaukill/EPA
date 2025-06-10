#!/bin/bash
# update_inventory.sh

IP=$(terraform output -raw ec2_public_ip)
cat > ansible/inventory.ini <<EOF
[web]
$IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_python_interpreter=/usr/bin/python3
EOF