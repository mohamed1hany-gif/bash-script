#!/bin/bash

# ---------------- CONFIGURATION ---------------- #
BACKUP_SRC="/etc"                          # Change to /var/www or any other directory
BACKUP_DST="/var/backups/system"          # Where backups will be stored
LOG_DIR="$BACKUP_DST/logs"
DATE=$(date +'%Y-%m-%d')
BACKUP_NAME="backup-$DATE.tar.gz"
BACKUP_PATH="$BACKUP_DST/$BACKUP_NAME"
LOG_FILE="$LOG_DIR/backup-$DATE.log"
KEEP_BACKUPS=7
KEEP_LOGS=5
EMAIL_TO="hanem013@gmail.com"              # Change to your system email (configured with Postfix)
EMAIL_SUBJECT="❌ Backup Failed on $(hostname) at $DATE"
# ------------------------------------------------ #

# Ensure required directories exist
sudo mkdir -p "$BACKUP_DST" "$LOG_DIR"

# Start logging
exec > >(tee -a "$LOG_FILE") 2>&1
echo "[$(date)] ▶ Starting backup process..."

# Function to send error alert
send_alert() {
    local MESSAGE="$1"
    echo -e "$MESSAGE" | mail -s "$EMAIL_SUBJECT" "$EMAIL_TO"
}

# Create the backup
if tar -czf "$BACKUP_PATH" "$BACKUP_SRC"; then
    echo "[$(date)] ✅ Backup created successfully: $BACKUP_PATH"
else
    ERROR="[$(date)] ❌ Failed to create backup from $BACKUP_SRC"
    echo "$ERROR"
    send_alert "$ERROR"
    exit 1
fi

# Remove old backups
if find "$BACKUP_DST" -name "backup-*.tar.gz" -mtime +$KEEP_BACKUPS -exec rm -f {} \;; then
    echo "[$(date)] 🗑️ Deleted backups older than $KEEP_BACKUPS days"
else
    ERROR="[$(date)] ❌ Failed to delete old backups"
    echo "$ERROR"
    send_alert "$ERROR"
fi

# Rotate logs: keep only the latest $KEEP_LOGS
cd "$LOG_DIR" || {
    ERROR="[$(date)] ❌ Failed to access log directory"
    echo "$ERROR"
    send_alert "$ERROR"
    exit 1
}

if ls -1tr backup-*.log | head -n -"$KEEP_LOGS" | xargs -r rm -f; then
    echo "[$(date)] 🔁 Rotated logs (kept last $KEEP_LOGS)"
else
    ERROR="[$(date)] ❌ Failed to rotate logs"
    echo "$ERROR"
    send_alert "$ERROR"
fi

echo "[$(date)] 🎉 Backup process completed successfully."
