#!/bin/bash

set -e

if [ ! -d "ansible" ]; then
    echo "Run from project root directory"
    exit 1
fi

echo "Installing Ansible collections..."
ansible-galaxy collection install microsoft.ad
ansible-galaxy collection install ansible.windows
ansible-galaxy collection install community.docker
ansible-galaxy collection install community.crypto

echo "Checking connectivity..."
ping -c 1 192.168.74.130 > /dev/null || { echo "Linux server unreachable"; exit 1; }
ping -c 1 192.168.74.129 > /dev/null || { echo "Windows server unreachable"; exit 1; }

echo "Starting installation..."
cd ansible

echo "1/7 Setting up Active Directory..."
ansible-playbook 01.setup_active_directory/playbook.yml

echo "2/7 Setting up Certificate Authority..."
ansible-playbook 02.setup_certificate_authority/playbook.yml

echo "3/7 Setting up IIS..."
ansible-playbook 03.setup_iis/playbook.yml

echo "4/7 Generating certificates..."
ansible-playbook 04.generate_certificates/playbook.yml

echo "5/7 Setting up Splunk with SSL..."
ansible-playbook 05.configure_splunk_ssl/playbook.yml

echo "6/7 Setting up log forwarding..."
ansible-playbook 06.setup_log_forwarding/playbook.yml

echo "7/7 Finalizing setup..."
ansible-playbook 07.finalize_setup/playbook.yml

echo ""
echo "Done!"
echo "Web Server: http://192.168.74.129"
echo "Splunk: https://192.168.74.130:8000 (admin/SplunkAdmin123!)"