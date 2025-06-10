#!/bin/bash
set -e

# Step 1: Apply Terraform to provision infrastructure
echo "Running terraform apply..."
terraform apply -auto-approve

# Step 2: Update Ansible inventory with new IP(s)
echo "Updating Ansible inventory..."
./update_inventory.sh

# Step 3: Run Ansible playbook to configure the server(s)
echo "Running Ansible playbook..."
ansible-playbook -i ansible/inventory.ini ansible/provision.yml

echo "Deployment complete!"