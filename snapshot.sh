## 📜 Automation Scripts

### Auto-snapshot script (`snapshot.sh`)
```bash
#!/bin/bash
# Automated LVM snapshot — run via cron daily at 2AM
DATE=$(date +%Y%m%d_%H%M%S)
SNAP_NAME="lv_data_snap_$DATE"
VG="vg_data"
LV="lv_data"
SNAP_SIZE="2G"

echo "Creating snapshot: $SNAP_NAME"
sudo lvcreate -L $SNAP_SIZE -s -n $SNAP_NAME /dev/$VG/$LV

if [ $? -eq 0 ]; then
  echo "Snapshot $SNAP_NAME created successfully at $(date)"
else
  echo "ERROR: Snapshot creation failed!" >&2
  exit 1
fi

# Keep only last 7 snapshots
OLD_SNAPS=$(sudo lvs --noheadings -o lv_name $VG | grep "lv_data_snap" | sort | head -n -7)
for snap in $OLD_SNAPS; do
  echo "Removing old snapshot: $snap"
  sudo lvremove -f /dev/$VG/$snap
done
```

### Add to cron
```bash
crontab -e
# Add this line:
0 2 * * * /home/sushant/scripts/snapshot.sh >> /var/log/lvm_snapshot.log 2>&1
```
