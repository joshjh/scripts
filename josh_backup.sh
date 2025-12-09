#!/bin/bash

# Check if /dev/mapper/magnetics-junk is mounted on /magnetic
if ! mountpoint -q /magnetic; then
    echo "Error: /magnetic is not mounted"
    exit 1
fi

# Execute backup commands
echo "Starting scheduled josh backup..."

# duplicity commands
duplicity --no-encryption --full-if-older-than 1M /home/josh/ file:///magnetic/josh_backup_dup

echo "Backup completed successfully"
exit 0