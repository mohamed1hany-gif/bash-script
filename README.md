# 🛡️ Automated Daily System Backup Script

This is a Bash script for automating daily backups of critical system directories such as `/etc` or `/var/www`. It includes logging, retention policy, error alerts via email (using Postfix), and cron job support.

---

## 🚀 Features

- ✅ Daily automatic backups
- 📦 Compressed `.tar.gz` backup files
- 🔁 Backup retention (keep last 7 backups, configurable)
- 🧾 Log rotation (keep last 5 logs)
- 🚨 Email alerts on backup failure (via Postfix)
- 🕒 Cron job–friendly for full automation 
