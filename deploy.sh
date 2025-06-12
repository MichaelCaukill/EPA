#!/bin/bash
set -e

# Step 1: Apply Terraform to provision infrastructure
echo "Running terraform apply..."
terraform apply -auto-approve

# Step 2: Update Ansible inventory with new IP(s)
echo "Updating Ansible inventory..."
./update_inventory.sh

# Step 2.5: Wait for EC2 instance to be ready
echo "Waiting 30 seconds for EC2 instance to initialize SSH..."
sleep 30

# Step 3: Change to ansible folder
cd ansible

# Step 4: Run Ansible playbook to configure the server(s)
echo "Running Ansible playbook..."
ansible-playbook playbook.yml -i inventory.ini --ask-vault-pass

echo "Deployment complete!"
