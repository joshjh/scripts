UUID="33536292-a474-4319-a80a-2dd911da7b74"
MOUNT_POINT="/mnt/backup_target"

backup_cerberus_vms() {
    # Function to backup Cerberus VMs
    echo "Starting backup of Cerberus VMs..."
    # Add your VM backup logic here
    sudo virsh dumpxml win11 > "$MOUNT_POINT"/vms/cerberus_vms/win11_cerberus.xml
    sudo rsync -avz --exclude '.snapshots' /opt/vms/ "$MOUNT_POINT"/vms/cerberus_vms/
    echo "Finished backup of Cerberus VMs..."
}

backup_thinkpad_vms() {
    # Function to backup Thinkpad VMs
    echo "Starting backup of Thinkpad VMs..."
    # Add your VM backup logic here
    sudo virsh dumpxml win11 > "$MOUNT_POINT"/vms/thinkpad_vms/win11_cerberus.xml
    sudo rsync -avz --exclude '.snapshots' /opt/vms/ "$MOUNT_POINT"/vms/thinkpad_vms/
    
}

# Check if the disk is already mounted
if ! findmnt -U "$UUID" >/dev/null 2>&1; then
    echo "Disk with UUID $UUID is not mounted. Attempting to mount..."
    # Create mount point if it doesn't exist
    sudo mkdir -p "$MOUNT_POINT"
    # Mount the disk
    sudo mount -t btrfs  UUID="$UUID" "$MOUNT_POINT" 
    if [ $? -eq 0 ]; then
        echo "Successfully mounted disk to $MOUNT_POINT"
        if [ "$(hostname)" = "cerberus" ]; then
            backup_cerberus_vms
        else
            echo "Hostname is not cerberus, skipping cerberus VM backup"
        fi

        if [ "$(hostname)" = "thinkpad" ]; then
            backup_thinkpad_vms
        else
            echo "Hostname is not thinkpad, skipping cerberus VM backup"
        fi
        
    else
        echo "Failed to mount disk with UUID $UUID"
        exit 1
    fi
    exit 0
else
    echo "Disk with UUID $UUID is already mounted"
    exit 1
fi