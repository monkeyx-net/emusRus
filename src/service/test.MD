test.service file
[Unit]
Description=Test Service

[Service]
Type=simple
StandardOutput=journal
ExecStart=/home/tim/bin/backlocal2Google.sh

[Install]
WantedBy=default.target

test.timer file
[Unit]
Description=Backup rclone hourly

[Timer]
OnBootSec=3min
OnUnitActiveSec=60min
Persistent=true

[Install]
WantedBy=timers.target



Save these files as ~/.config/systemd/user/some-service-name.*

Run this now and after any modifications: systemctl --user daemon-reload

Check logs if something is wrong: journalctl --user -u some-service-name

systemctl --user enable sync_saves.timer
systemctl --user start sync_saves.timer


systemctl --user status test.service
systemctl --user status test.timer


journalctl --user -u test



# Use Bisync?
#!/bin/sh

~/Applications/rclone bisync --copy-links ~/emulation/saves drive:/rdeck