#!/bin/bash

# Execute backup commands
echo "Starting scheduled backup..."

# duplicity commands
PASSPHRASE='' duplicity --exclude /dev --exclude /sys --exclude /proc --exclude /tmp --exclude /mnt --full-if-older-than 6M --encrypt-key 9F5DC4EE41F82C42802BAE2CD5AD53A16C0209D4 backup / onedrive:///backup-target/orzo-system

echo "Backup completed successfully"
exit 0