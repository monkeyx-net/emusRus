#!/bin/bash

rclone -v sync --tpslimit 5 --bwlimit 8650k --fast-list --drive-skip-dangling-shortcuts /home/tim/bin "gDrive_TO:/Tim/backup/local_bin" 
rclone -v sync --tpslimit 5 --bwlimit 8650k --fast-list --drive-skip-dangling-shortcuts /home/tim/Documents "gDrive_TO:/Tim/backup/local_documents" 
rclone -v sync --tpslimit 5 --bwlimit 8650k --fast-list --drive-skip-dangling-shortcuts --files-from /home/tim/bin/backfiles.txt /home/tim/ "gDrive_TO:/Tim/backup/local_documents"
rclone -v sync --tpslimit 5 --bwlimit 8650k --exclude=".git**" --fast-list --drive-skip-dangling-shortcuts /srv/http "gDrive_TO:/Tim/backup/www" 
